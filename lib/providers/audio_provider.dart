import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'audio_controller.dart';
import '../services/debug_logger.dart';

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
  
  // Aktif playlist'teki şarkıların listesi
  List<AudioFile> get currentPlaylistSongs {
    if (_activePlayList == null) return [];
    return (_activePlayList!['audios'] as List<dynamic>?)
        ?.map((e) => AudioFile.fromJson(e))
        .toList() ?? [];
  }

  AudioProvider() {
    _loadPlaylists();
    _loadFilterSettings();
    // İzin isteğini dışarıdan, ilk frame'den sonra tetikleyeceğiz
  }

  void ensurePermissionRequested() {
    if (_hasPermission || _isRequestingPermission) return;
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (_isRequestingPermission || _hasPermission) return;
    _isRequestingPermission = true;
    notifyListeners(); // UI'ı güncelle
    
    try {
      DebugLogger.log('🔐 on_audio_query için izin isteniyor...');
      
      // Önce mevcut izin durumunu kontrol et
      var permissionStatus = await _audioQuery.permissionsStatus();
      DebugLogger.log('📋 Mevcut izin durumu: $permissionStatus');
      
      if (permissionStatus) {
        DebugLogger.log('✅ İzin zaten verilmiş');
        _hasPermission = true;
        await _getAudioFiles();
      } else {
        DebugLogger.log('🔐 İzin isteniyor...');
        var hasPermission = await _audioQuery.permissionsRequest();
        DebugLogger.log('📋 İzin sonucu: $hasPermission');
        
        if (hasPermission) {
          DebugLogger.log('✅ İzin verildi');
          _hasPermission = true;
          // İzin verildikten sonra kısa bir bekleme süresi ekle
          await Future.delayed(Duration(milliseconds: 500));
          await _getAudioFiles();
        } else {
          DebugLogger.log('❌ on_audio_query izni reddedildi');
          // İzin reddedildiğinde uygulamayı durdurmak yerine sadece log yaz
        }
      }
    } catch (e) {
      DebugLogger.log('❌ on_audio_query izin hatası: $e');
      // Hata durumunda uygulamayı durdurmak yerine sadece log yaz
    } finally {
      _isRequestingPermission = false;
      notifyListeners();
    }
  }

  Future<void> _getAudioFiles() async {
    try {
      DebugLogger.log('🔍 on_audio_query ile tarama başlatıldı...');
      
      // Tarama öncesi kısa bir bekleme
      await Future.delayed(Duration(milliseconds: 200));
      
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      DebugLogger.log('📊 ${songs.length} şarkı bulundu');
      
      _audioFiles = [];
      for (var song in songs) {
        try {
          if (song.isMusic == true && song.fileExtension != null) {
            // Öncelikle displayNameWOExt kullan (uzantısız dosya adı)
            String songTitle = song.displayNameWOExt ?? '';
            
            // Eğer displayNameWOExt boşsa, displayName'i kullan ve uzantıyı kaldır
            if (songTitle.isEmpty) {
              songTitle = song.displayName ?? '';
              // Uzantıyı kaldır
              final lastDot = songTitle.lastIndexOf('.');
              if (lastDot != -1) {
                songTitle = songTitle.substring(0, lastDot);
              }
            }
            
            // Hala boşsa veya sadece sayısal değerse title'ı kullan
            if (songTitle.isEmpty || RegExp(r'^\d+$').hasMatch(songTitle)) {
              songTitle = song.title ?? 'Unknown Song';
            }
            
            // Son kontrol - boşsa varsayılan değer
            if (songTitle.isEmpty) {
              songTitle = 'Unknown Song';
            }
            
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
        } catch (songError) {
          DebugLogger.log('⚠️ Şarkı işlenirken hata: $songError');
          continue; // Bu şarkıyı atla, diğerlerine devam et
        }
      }
      
      _audioFiles.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
      notifyListeners();
      DebugLogger.log('🎉 on_audio_query ile ${_audioFiles.length} ses dosyası yüklendi');
    } catch (e) {
      DebugLogger.log('❌ on_audio_query tarama hatası: $e');
      // Hata durumunda boş liste ile devam et
      _audioFiles = [];
      notifyListeners();
    }
  }

  Future<void> getAudioFiles() async => await _getAudioFiles();

  Future<void> loadPreviousAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final previousAudioJson = prefs.getString('previousAudio');
    if (previousAudioJson != null && _audioFiles.isNotEmpty) {
      final previousAudio = jsonDecode(previousAudioJson);
      try {
        _currentAudio = _audioFiles.firstWhere(
          (audio) => audio.id == previousAudio['audio']['id'],
        );
        _currentAudioIndex = previousAudio['index'];
      } catch (e) {
        // Eğer önceki audio bulunamazsa, ilk audio'yu seç
        _currentAudio = _audioFiles[0];
        _currentAudioIndex = 0;
      }
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
    // Eğer silinen playlist aktif playlist ise, oynatıcı durumunu temizle
    if (_activePlayList != null && _activePlayList!['id'] == playlistId) {
      print('🔄 Active playlist deleted, clearing player state');
      _activePlayList = null;
      _isPlayListRunning = false;
    }
    
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

  // Playlist çalma modunu başlat
  void startPlaylistMode(Map<String, dynamic> playlist, int songIndex) {
    _activePlayList = playlist;
    _isPlayListRunning = true;
    _currentAudioIndex = songIndex;
    notifyListeners();
    DebugLogger.log('🎵 Playlist çalma modu başlatıldı: ${playlist['name']}, şarkı index: $songIndex');
  }
  
  // Normal çalma moduna dön (tüm şarkı listesi)
  void exitPlaylistMode() {
    _activePlayList = null;
    _isPlayListRunning = false;
    notifyListeners();
    DebugLogger.log('🎵 Playlist çalma modu bitti, normal moda döndü');
  }
  
  // Playlist'te sonraki şarkının index'ini al
  int? getNextSongIndexInPlaylist() {
    if (!_isPlayListRunning || _activePlayList == null) return null;
    
    final playlistSongs = currentPlaylistSongs;
    if (playlistSongs.isEmpty) return null;
    
    // Mevcut şarkının playlist içindeki index'ini bul
    final currentAudio = _currentAudio;
    if (currentAudio == null) return null;
    
    final currentPlaylistIndex = playlistSongs.indexWhere((song) => song.id == currentAudio.id);
    if (currentPlaylistIndex == -1) return null;
    
    // Sonraki şarkı var mı?
    if (currentPlaylistIndex + 1 < playlistSongs.length) {
      return currentPlaylistIndex + 1;
    }
    
    return null; // Son şarkıdayız
  }
  
  // Playlist'te önceki şarkının index'ini al
  int? getPreviousSongIndexInPlaylist() {
    if (!_isPlayListRunning || _activePlayList == null) return null;
    
    final playlistSongs = currentPlaylistSongs;
    if (playlistSongs.isEmpty) return null;
    
    // Mevcut şarkının playlist içindeki index'ini bul
    final currentAudio = _currentAudio;
    if (currentAudio == null) return null;
    
    final currentPlaylistIndex = playlistSongs.indexWhere((song) => song.id == currentAudio.id);
    if (currentPlaylistIndex == -1) return null;
    
    // Önceki şarkı var mı?
    if (currentPlaylistIndex > 0) {
      return currentPlaylistIndex - 1;
    }
    
    return null; // İlk şarkıdayız
  }

  Future<void> playAtIndex(int index, AudioController audioController) async {
    DebugLogger.log('playAtIndex çağrıldı, index: $index, şarkı: ${_audioFiles[index].filename}');
    if (index < 0 || index >= _audioFiles.length) return;
    _currentAudioIndex = index;
    _currentAudio = _audioFiles[index];
    _isPlaying = true;
    notifyListeners(); // UI hemen güncellenir
    await audioController.play(_audioFiles[index].uri, title: _audioFiles[index].filename, index: index, provider: this);
    DebugLogger.log('playAtIndex tamamlandı, index: $index, şarkı: ${_audioFiles[index].filename}');
  }
  
  // Playlist'te belirli bir şarkıyı çal
  Future<void> playPlaylistSongAtIndex(int playlistSongIndex, AudioController audioController) async {
    if (!_isPlayListRunning || _activePlayList == null) return;
    
    final playlistSongs = currentPlaylistSongs;
    if (playlistSongIndex < 0 || playlistSongIndex >= playlistSongs.length) return;
    
    final songToPlay = playlistSongs[playlistSongIndex];
    
    // Ana şarkı listesindeki index'ini bul
    final mainIndex = _audioFiles.indexWhere((audio) => audio.id == songToPlay.id);
    if (mainIndex == -1) return;
    
    _currentAudioIndex = mainIndex;
    _currentAudio = songToPlay;
    _isPlaying = true;
    notifyListeners();
    
    await audioController.play(songToPlay.uri, title: songToPlay.filename, index: mainIndex, provider: this);
    DebugLogger.log('Playlist şarkısı çalınıyor: ${songToPlay.filename} (playlist index: $playlistSongIndex)');
  }
}