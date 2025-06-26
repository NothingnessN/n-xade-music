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

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      filename: json['filename'],
      uri: json['uri'],
      duration: json['duration'].toDouble(),
      artist: json['artist'],
      album: json['album'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'uri': uri,
      'duration': duration,
      'artist': artist,
      'album': album,
    };
  }

  String get displayName {
    // Sayısal değer kontrolü
    if (RegExp(r'^\d+$').hasMatch(filename)) {
      return 'Unknown Song';
    }
    return filename;
  }

  String get displayNameWOExt {
    String name = displayName;
    final lastDot = name.lastIndexOf('.');
    if (lastDot != -1) {
      return name.substring(0, lastDot);
    }
    return name;
  }
}

class AudioProvider with ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<AudioFile> _audioFiles = [];
  List<Map<String, dynamic>> _playlists = [];
  AudioFile? _currentAudio;
  bool _isPlaying = false;
  int _currentAudioIndex = -1;
  double? _playbackPosition;
  double? _playbackDuration;
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
  List<Map<String, dynamic>> get playlists => _playlists;
  AudioFile? get currentAudio => _currentAudio;
  bool get isPlaying => _isPlaying;
  int get currentAudioIndex => _currentAudioIndex;
  double? get playbackPosition => _playbackPosition;
  double? get playbackDuration => _playbackDuration;
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
          // Şarkı adını düzgün bir şekilde al
          String songTitle = song.title ?? '';
          // Eğer title boşsa veya sayısal bir değerse displayName'i kullan
          if (songTitle.isEmpty || RegExp(r'^\d+$').hasMatch(songTitle)) {
            songTitle = song.displayName ?? songTitle;
          }
          // Hala boşsa veya sayısal değerse displayNameWOExt'i kullan
          if (songTitle.isEmpty || RegExp(r'^\d+$').hasMatch(songTitle)) {
            songTitle = song.displayNameWOExt ?? songTitle;
          }
          // Uzantıyı kaldır
          songTitle = songTitle.replaceAll(RegExp(r'\.[^.]*$'), '');
          
          final audioFile = AudioFile(
            id: song.id.toString(),
            filename: songTitle,
            uri: song.uri ?? '',
            duration: (song.duration ?? 0) / 1000.0,
            artist: song.artist ?? 'Unknown Artist',
            album: song.album ?? 'Unknown Album',
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
    notifyListeners();
  }

  void resetPlaybackState() {
    _isPlaying = false;
    _currentAudioIndex = -1;
    _currentAudio = null;
    _playbackPosition = 0;
    _playbackDuration = 0;
    notifyListeners();
  }

  void removeAudio(String audioId) {
    _audioFiles.removeWhere((audio) => audio.id == audioId);
    if (_currentAudio?.id == audioId) {
      resetPlaybackState();
    }
    for (var playlist in _playlists) {
      removeAudioFromPlaylist(playlist['id'], audioId);
    }
    notifyListeners();
  }

  void createPlayList(String title) {
    print('🎵 Creating playlist: "$title"');
    print('📊 Current playlist count: ${_playlists.length}');
    
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
    
    _playlists.add(newPlaylist);
    print('✅ Playlist added to memory: ${newPlaylist['title']}');
    
    _savePlaylists();
    notifyListeners();
    
    print('🎉 Playlist created successfully: "$title"');
    print('📊 New playlist count: ${_playlists.length}');
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((playlist) => playlist['id'] == playlistId);
    _savePlaylists();
    notifyListeners();
    print('🗑️ Playlist deleted: $playlistId');
  }

  void addAudioToPlaylist(String playlistId, AudioFile audio) {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      final audioExists = _playlists[playlistIndex]['audios'].any((item) => item['id'] == audio.id);
      if (!audioExists) {
        _playlists[playlistIndex]['audios'].add({
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
    } else {
      print('❌ Playlist not found: $playlistId');
    }
  }

  void removeAudioFromPlaylist(String playlistId, String audioId) {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      _playlists[playlistIndex]['audios'].removeWhere((audio) => audio['id'] == audioId);
      _savePlaylists();
      notifyListeners();
      print('🗑️ Audio removed from playlist: $audioId');
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = jsonEncode(_playlists);
      await prefs.setString('playlists', playlistsJson);
      print('💾 Playlists saved to storage: ${_playlists.length} playlists');
    } catch (e) {
      print('❌ Error saving playlists: $e');
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsString = prefs.getString('playlists');
      if (playlistsString != null) {
        final playlistsData = jsonDecode(playlistsString) as List<dynamic>;
        _playlists = playlistsData.cast<Map<String, dynamic>>();
        print('📂 Loaded ${_playlists.length} playlists from storage');
        
        // Debug: Print loaded playlists
        for (int i = 0; i < _playlists.length; i++) {
          print('   ${i + 1}. ${_playlists[i]['title']} (${_playlists[i]['audios'].length} songs)');
        }
      } else {
        print('📂 No playlists found in storage');
      }
    } catch (e) {
      print('❌ Error loading playlists: $e');
    }
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