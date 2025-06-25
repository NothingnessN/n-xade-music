import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'audio_controller.dart';

class AudioFile {
  final String id;
  final String filename;
  final String uri;
  final double duration;
  final String? artist;
  final String? album;
  final int? size;

  AudioFile({
    required this.id,
    required this.filename,
    required this.uri,
    required this.duration,
    this.artist,
    this.album,
    this.size,
  });

  String get displayNameWOExt {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot != -1) {
      return filename.substring(0, lastDot);
    }
    return filename;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'uri': uri,
      'duration': duration,
      'artist': artist,
      'album': album,
      'size': size,
    };
  }
}

class AudioProvider with ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<AudioFile> _audioFiles = [];
  AudioFile? _currentAudio;
  bool _isPlaying = false;
  int? _currentAudioIndex;
  double? _playbackPosition;
  double? _playbackDuration;
  List<Map<String, dynamic>> _playList = [];
  AudioFile? _addToPlayList;
  Map<String, dynamic>? _activePlayList;
  bool _isPlayListRunning = false;

  // Filtre ayarları (basitleştirilmiş)
  int _minFileSize = 100; // 100 bytes
  double _minDuration = 0.1; // 0.1 saniye
  int _maxFileSize = 2000000000; // 2GB
  bool _excludeVoiceFiles = false; // Kapalı
  bool _excludeAppFiles = true; // Sadece android/data/ için açık

  bool _isRequestingPermission = false;
  bool _hasPermission = false;

  // Getters
  List<AudioFile> get audioFiles => _audioFiles;
  AudioFile? get currentAudio => _currentAudio;
  bool get isPlaying => _isPlaying;
  int? get currentAudioIndex => _currentAudioIndex;
  double? get playbackPosition => _playbackPosition;
  double? get playbackDuration => _playbackDuration;
  List<Map<String, dynamic>> get playList => _playList;
  AudioFile? get addToPlayList => _addToPlayList;
  Map<String, dynamic>? get activePlayList => _activePlayList;
  bool get isPlayListRunning => _isPlayListRunning;

  AudioProvider() {
    _loadPlaylists();
    _loadFilterSettings();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (_isRequestingPermission || _hasPermission) return;
    _isRequestingPermission = true;
    try {
      print('🔐 on_audio_query için izin isteniyor...');
      var permissionStatus = await _audioQuery.permissionsStatus();
      if (permissionStatus) {
        _hasPermission = true;
        await _getAudioFiles();
      } else {
        var hasPermission = await _audioQuery.permissionsRequest();
        if (hasPermission) {
          _hasPermission = true;
          await _getAudioFiles();
        } else {
          print('❌ on_audio_query izni reddedildi');
        }
      }
    } catch (e) {
      print('❌ on_audio_query izin hatası: $e');
    } finally {
      _isRequestingPermission = false;
      notifyListeners();
    }
  }

  Future<void> _getAudioFiles() async {
    try {
      print('🔍 on_audio_query ile tarama başlatıldı...');
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      print('📊 ${songs.length} şarkı bulundu');
      _audioFiles = [];
      for (var song in songs) {
        if (song.isMusic == true && song.fileExtension != null) {
          final audioFile = AudioFile(
            id: song.id.toString(),
            filename: song.displayName ?? song.title ?? 'Unknown',
            uri: song.uri ?? '',
            duration: (song.duration ?? 0) / 1000.0,
            artist: song.artist,
            album: song.album,
            size: song.size,
          );
          _audioFiles.add(audioFile);
        }
      }
      _audioFiles.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
      notifyListeners();
      print('🎉 on_audio_query ile ${_audioFiles.length} ses dosyası yüklendi');
    } catch (e) {
      print('❌ on_audio_query tarama hatası: $e');
    }
  }

  Future<void> getAudioFiles() async => await _getAudioFiles();

  Future<void> loadPreviousAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final previousAudioJson = prefs.getString('previousAudio');
    if (previousAudioJson != null) {
      final previousAudio = jsonDecode(previousAudioJson);
      _currentAudio = _audioFiles.firstWhere(
        (audio) => audio.id == previousAudio['audio']['id'],
        orElse: () => _audioFiles.isNotEmpty ? _audioFiles[0] : null as AudioFile,
      );
      _currentAudioIndex = previousAudio['index'];
    } else if (_audioFiles.isNotEmpty) {
      _currentAudio = _audioFiles[0];
      _currentAudioIndex = 0;
    }
    notifyListeners();
  }

  void createPlayList(String title) {
    print('🎵 Creating playlist: "$title"');
    print('📊 Current playlist count: ${_playList.length}');
    
    if (title.trim().isEmpty) {
      print('❌ Playlist title is empty');
      return;
    }
    
    final newPlaylist = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title.trim(),
      'audios': [],
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _playList.add(newPlaylist);
    print('✅ Playlist added to memory: ${newPlaylist['title']}');
    
    _savePlaylists();
    notifyListeners();
    
    print('🎉 Playlist created successfully: "$title"');
    print('📊 New playlist count: ${_playList.length}');
  }

  void deletePlaylist(String playlistId) {
    _playList.removeWhere((playlist) => playlist['id'] == playlistId);
    _savePlaylists();
    notifyListeners();
    print('🗑️ Playlist deleted: $playlistId');
  }

  void addAudioToPlaylist(String playlistId, AudioFile audio) {
    final playlistIndex = _playList.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      // Şarkının zaten playlist'te olup olmadığını kontrol et
      final audioExists = _playList[playlistIndex]['audios'].any((item) => item['id'] == audio.id);
      if (!audioExists) {
        _playList[playlistIndex]['audios'].add({
          'id': audio.id,
          'filename': audio.filename,
          'uri': audio.uri,
          'duration': audio.duration,
          'addedAt': DateTime.now().toIso8601String(),
        });
        _savePlaylists();
        notifyListeners();
        print('✅ Audio added to playlist: ${audio.filename}');
      } else {
        print('⚠️ Audio already exists in playlist: ${audio.filename}');
      }
    }
  }

  void removeAudioFromPlaylist(String playlistId, String audioId) {
    final playlistIndex = _playList.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      _playList[playlistIndex]['audios'].removeWhere((audio) => audio['id'] == audioId);
      _savePlaylists();
      notifyListeners();
      print('❌ Audio removed from playlist: $audioId');
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = jsonEncode(_playList);
      await prefs.setString('playlists', playlistsJson);
      print('💾 Playlists saved to storage: ${_playList.length} playlists');
      print('📄 JSON data: $playlistsJson');
    } catch (e) {
      print('❌ Error saving playlists: $e');
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString('playlists');
      print('📂 Loading playlists from storage...');
      
      if (playlistsJson != null) {
        print('📄 Found playlists JSON: $playlistsJson');
        final List<dynamic> playlistsData = jsonDecode(playlistsJson);
        _playList = playlistsData.cast<Map<String, dynamic>>();
        print('📂 Loaded ${_playList.length} playlists from storage');
        
        // Her playlist'i listele
        for (int i = 0; i < _playList.length; i++) {
          print('   ${i + 1}. ${_playList[i]['title']} (${_playList[i]['audios'].length} songs)');
        }
      } else {
        print('📂 No playlists found in storage');
      }
    } catch (e) {
      print('❌ Error loading playlists: $e');
    }
  }

  void updateState({
    bool? isPlaying,
    int? currentAudioIndex,
    double? playbackPosition,
    double? playbackDuration,
  }) {
    if (isPlaying != null) _isPlaying = isPlaying;
    
    if (currentAudioIndex != null) {
      _currentAudioIndex = currentAudioIndex;
      if (currentAudioIndex >= 0 && currentAudioIndex < _audioFiles.length) {
        _currentAudio = _audioFiles[currentAudioIndex];
      }
    }
    
    if (playbackPosition != null) {
      _playbackPosition = playbackPosition;
    }
    
    if (playbackDuration != null) {
      _playbackDuration = playbackDuration;
    }
    
    // Her durum güncellemesinde dinleyicileri haberdar et
    notifyListeners();
  }

  void resetPlaybackState() {
    _playbackPosition = 0;
    _playbackDuration = 0;
    notifyListeners();
  }

  // Filtre ayarlarını yükle
  Future<void> _loadFilterSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _minFileSize = prefs.getInt('minFileSize') ?? 100;
      _minDuration = prefs.getDouble('minDuration') ?? 0.1;
      _maxFileSize = prefs.getInt('maxFileSize') ?? 2000000000;
      _excludeVoiceFiles = prefs.getBool('excludeVoiceFiles') ?? false;
      _excludeAppFiles = prefs.getBool('excludeAppFiles') ?? true;
      print('📋 Filter settings loaded');
    } catch (e) {
      print('❌ Error loading filter settings: $e');
    }
  }

  // Filtre ayarlarını kaydet
  Future<void> _saveFilterSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('minFileSize', _minFileSize);
      await prefs.setDouble('minDuration', _minDuration);
      await prefs.setInt('maxFileSize', _maxFileSize);
      await prefs.setBool('excludeVoiceFiles', _excludeVoiceFiles);
      await prefs.setBool('excludeAppFiles', _excludeAppFiles);
      print('💾 Filter settings saved');
    } catch (e) {
      print('❌ Error saving filter settings: $e');
    }
  }

  // Filtre ayarlarını güncelle
  void updateFilterSettings({
    int? minFileSize,
    double? minDuration,
    int? maxFileSize,
    bool? excludeVoiceFiles,
    bool? excludeAppFiles,
  }) {
    if (minFileSize != null) _minFileSize = minFileSize;
    if (minDuration != null) _minDuration = minDuration;
    if (maxFileSize != null) _maxFileSize = maxFileSize;
    if (excludeVoiceFiles != null) _excludeVoiceFiles = excludeVoiceFiles;
    if (excludeAppFiles != null) _excludeAppFiles = excludeAppFiles;
    
    _saveFilterSettings();
    notifyListeners();
    print('🔧 Filter settings updated');
  }

  // Ses dosyalarını yeniden tara (filtre ayarları değiştiğinde)
  Future<void> rescanAudioFiles() async {
    print('🔄 Rescanning audio files with new filter settings...');
    _audioFiles.clear();
    notifyListeners();
    await _getAudioFiles();
  }

  // Getter'lar
  int get minFileSize => _minFileSize;
  double get minDuration => _minDuration;
  int get maxFileSize => _maxFileSize;
  bool get excludeVoiceFiles => _excludeVoiceFiles;
  bool get excludeAppFiles => _excludeAppFiles;

  Future<void> playAtIndex(int index, AudioController audioController) async {
    print('playAtIndex çağrıldı, index: $index, şarkı: ${_audioFiles[index].filename}');
    if (index < 0 || index >= _audioFiles.length) return;
    _currentAudioIndex = index;
    _currentAudio = _audioFiles[index];
    _isPlaying = true;
    notifyListeners(); // UI hemen güncellenir
    await audioController.play(_audioFiles[index].uri, title: _audioFiles[index].filename, index: index, provider: this);
    print('playAtIndex tamamlandı, index: $index, şarkı: ${_audioFiles[index].filename}');
  }
}