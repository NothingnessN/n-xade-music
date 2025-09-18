import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'audio_controller.dart';
import '../services/debug_logger.dart';
import '../providers/theme_provider.dart';

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
  int _currentPlaylistIndex = -1;

  List<AudioFile> get audioFiles => _audioFiles;
  AudioFile? get currentAudio => _currentAudio;
  bool get isPlaying => _isPlaying;
  int get currentAudioIndex => _currentAudioIndex;
  double? get playbackPosition => _playbackPosition;
  double? get playbackDuration => _playbackDuration;
  bool get isPlayListRunning => _isPlayListRunning;
  Map<String, dynamic>? get activePlayList => _activePlayList;
  List<Map<String, dynamic>> get playlists => _playlists;
  int get currentPlaylistIndex => _currentPlaylistIndex;

  AudioProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _loadPlaylists();
      // Uygulama açılışını hızlandırmak için şarkı taramasını frame sonrasına ertele
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await loadSongs();
      });
    } catch (e) {
      DebugLogger.log('❌ AudioProvider init hatası: $e');
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistData = prefs.getString('playlists');
      if (playlistData != null) {
        _playlists = List<Map<String, dynamic>>.from(jsonDecode(playlistData));
        // Veri hijyeni: songs alanı olmayan listelere boş liste ata
        bool changed = false;
        for (final p in _playlists) {
          if (p['songs'] == null || p['songs'] is! List) {
            p['songs'] = <Map<String, dynamic>>[];
            changed = true;
          }
        }
        if (changed) {
          await _savePlaylists();
        }
        DebugLogger.log('🎵 Çalma listeleri yüklendi: ${_playlists.length} liste');
      } else {
        _playlists = [];
        DebugLogger.log('🎵 Çalma listesi verisi bulunamadı, boş liste oluşturuldu');
      }
      notifyListeners();
    } catch (e) {
      DebugLogger.log('❌ Çalma listeleri yüklenirken hata: $e');
      _playlists = [];
      notifyListeners();
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playlists', jsonEncode(_playlists));
      DebugLogger.log('🎵 Çalma listeleri kaydedildi: ${_playlists.length} liste');
      notifyListeners();
    } catch (e) {
      DebugLogger.log('❌ Çalma listeleri kaydedilirken hata: $e');
    }
  }

  Future<void> ensurePermissionRequested() async {
    try {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
    } catch (e) {
      DebugLogger.log('❌ İzin isteme hatası: $e');
    }
  }

  Future<void> createPlayList(String title) async {
    try {
      final newPlaylist = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'songs': <Map<String, dynamic>>[],
      };
      _playlists.add(newPlaylist);
      await _savePlaylists();
      DebugLogger.log('🎵 Yeni çalma listesi oluşturuldu: $title');
      notifyListeners();
    } catch (e) {
      DebugLogger.log('❌ Çalma listesi oluşturma hatası: $e');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      _playlists.removeWhere((playlist) => playlist['id'] == playlistId);
      if (_activePlayList != null && _activePlayList!['id'] == playlistId) {
        _activePlayList = null;
        _isPlayListRunning = false;
        _currentPlaylistIndex = -1;
        _isPlaying = false;
      }
      await _savePlaylists();
      DebugLogger.log('🎵 Çalma listesi silindi: $playlistId');
      notifyListeners();
    } catch (e) {
      DebugLogger.log('❌ Çalma listesi silme hatası: $e');
    }
  }

  Future<void> addAudioToPlaylist(String playlistId, AudioFile audio) async {
    try {
      final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
      if (playlistIndex != -1) {
        _playlists[playlistIndex]['songs'] ??= <Map<String, dynamic>>[];
        final List songs = _playlists[playlistIndex]['songs'];
        final exists = songs.any((e) => (e as Map<String, dynamic>)['id'] == audio.id);
        if (!exists) {
          songs.add(audio.toJson());
        }
        await _savePlaylists();
        DebugLogger.log('🎵 Şarkı eklendi: ${audio.filename} -> Çalma listesi: $playlistId');
        notifyListeners();
      } else {
        DebugLogger.log('⚠️ Çalma listesi bulunamadı: $playlistId');
      }
    } catch (e) {
      DebugLogger.log('❌ Şarkı çalma listesine ekleme hatası: $e');
    }
  }

  Future<void> removeAudioFromPlaylist(String playlistId, String audioId) async {
    try {
      final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
      if (playlistIndex != -1) {
        _playlists[playlistIndex]['songs'].removeWhere((song) => song['id'] == audioId);
        await _savePlaylists();
        DebugLogger.log('🎵 Şarkı kaldırıldı: $audioId -> Çalma listesi: $playlistId');
        notifyListeners();
      } else {
        DebugLogger.log('⚠️ Çalma listesi bulunamadı: $playlistId');
      }
    } catch (e) {
      DebugLogger.log('❌ Şarkı çalma listesinden kaldırma hatası: $e');
    }
  }

  Future<void> startPlaylistMode(BuildContext context, Map<String, dynamic> playlist, [int songIndex = 0]) async {
    try {
      _activePlayList = playlist;
      _isPlayListRunning = true;
      _currentPlaylistIndex = songIndex;
      notifyListeners();
      final playlistSongs = currentPlaylistSongs;
      if (songIndex < playlistSongs.length) {
        final song = playlistSongs[songIndex];
        final mainIndex = _audioFiles.indexWhere((audio) => audio.id == song.id);
        if (mainIndex != -1) {
          final audioController = Provider.of<AudioController>(context, listen: false);
          // Ana liste indeksini de hizala
          _currentAudioIndex = mainIndex;
          _currentAudio = _audioFiles[mainIndex];
          notifyListeners();
          await playAtIndex(mainIndex, audioController, playlistSongIndex: songIndex);
        }
      }
    } catch (e) {
      DebugLogger.log('❌ Çalma listesi başlatma hatası: $e');
    }
  }

  Future<void> exitPlaylistMode() async {
    _activePlayList = null;
    _isPlayListRunning = false;
    _currentPlaylistIndex = -1;
    notifyListeners();
  }

  Future<List<AudioFile>> _querySongs() async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return songs.map((song) {
        final uri = song.uri ?? '';
        DebugLogger.log('Şarkı URI: $uri');
        return AudioFile(
          id: song.id.toString(),
          filename: song.displayName,
          uri: uri,
          duration: song.duration?.toDouble() ?? 0.0,
          artist: song.artist,
          album: song.album,
        );
      }).toList();
    } catch (e) {
      DebugLogger.log('❌ Şarkı sorgulama hatası: $e');
      rethrow;
    }
  }

  Future<void> loadSongs() async {
    try {
      await ensurePermissionRequested();
      _audioFiles = await _querySongs();
      DebugLogger.log('🎵 Şarkılar yüklendi: ${_audioFiles.length} şarkı bulundu');
      notifyListeners();
    } catch (e) {
      DebugLogger.log('❌ Şarkı yükleme hatası: $e');
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
      _currentAudio = _audioFiles.isNotEmpty && currentAudioIndex >= 0 && currentAudioIndex < _audioFiles.length
          ? _audioFiles[currentAudioIndex]
          : null;
    }
    if (playbackPosition != null) _playbackPosition = playbackPosition;
    if (playbackDuration != null) _playbackDuration = playbackDuration;
    notifyListeners();
  }

  void resetPlaybackState() {
    _playbackPosition = 0;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> playAtIndex(int index, AudioController audioController, {int? playlistSongIndex}) async {
    DebugLogger.log('playAtIndex çağrıldı, index: $index, şarkı: ${_audioFiles[index].filename}, uri: ${_audioFiles[index].uri}');
    if (index < 0 || index >= _audioFiles.length) {
      DebugLogger.log('⚠️ Invalid index: $index');
      return;
    }
    _currentAudioIndex = index;
    _currentAudio = _audioFiles[index];
    _isPlaying = true;
    if (playlistSongIndex != null) {
      _currentPlaylistIndex = playlistSongIndex;
    }
    notifyListeners();
    await audioController.play(_audioFiles[index].uri, title: _audioFiles[index].filename, provider: this);
    DebugLogger.log('playAtIndex tamamlandı, index: $index, şarkı: ${_audioFiles[index].filename}');
  }

  Future<void> playPlaylistSongAtIndex(int playlistSongIndex, AudioController audioController) async {
    if (!_isPlayListRunning || _activePlayList == null) {
      DebugLogger.log('⚠️ Playlist mode is not active');
      return;
    }
    final playlistSongs = currentPlaylistSongs;
    if (playlistSongIndex < 0 || playlistSongIndex >= playlistSongs.length) {
      DebugLogger.log('⚠️ Invalid playlist song index: $playlistSongIndex');
      _isPlaying = false;
      notifyListeners();
      return;
    }
    final songToPlay = playlistSongs[playlistSongIndex];
    final mainIndex = _audioFiles.indexWhere((audio) => audio.id == songToPlay.id);
    if (mainIndex == -1) {
      DebugLogger.log('⚠️ Song not found in audioFiles: ${songToPlay.id}');
      return;
    }
    await playAtIndex(mainIndex, audioController, playlistSongIndex: playlistSongIndex);
  }

  List<AudioFile> get currentPlaylistSongs {
    if (_activePlayList == null) return [];
    return (_activePlayList!['songs'] as List<dynamic>?)
            ?.map((song) => AudioFile.fromJson(song))
            .toList() ??
        [];
  }

  AudioFile? getNextAudio() {
    if (_isPlayListRunning && _activePlayList != null) {
      final playlistSongs = currentPlaylistSongs;
      final nextPlaylistIndex = _currentPlaylistIndex + 1;
      if (nextPlaylistIndex < playlistSongs.length) {
        final nextAudio = playlistSongs[nextPlaylistIndex];
        // Ana listedeki index'i bul ve güncelle
        final mainIndex = _audioFiles.indexWhere((a) => a.id == nextAudio.id);
        if (mainIndex != -1) {
          _currentAudioIndex = mainIndex;
        }
        _currentPlaylistIndex = nextPlaylistIndex;
        _currentAudio = nextAudio;
        notifyListeners();
        return nextAudio;
      } else {
        _isPlaying = false;
        _currentPlaylistIndex = -1;
        _currentAudio = null;
        notifyListeners();
        return null;
      }
    } else {
      if (_currentAudioIndex >= 0 && _currentAudioIndex + 1 < _audioFiles.length) {
        final nextIndex = _currentAudioIndex + 1;
        _currentAudioIndex = nextIndex;
        _currentAudio = _audioFiles[nextIndex];
        notifyListeners();
        return _currentAudio;
      } else {
        _isPlaying = false;
        _currentAudioIndex = -1;
        _currentAudio = null;
        notifyListeners();
        return null;
      }
    }
  }

  AudioFile? getPreviousAudio() {
    if (_isPlayListRunning && _activePlayList != null) {
      final playlistSongs = currentPlaylistSongs;
      if (_currentPlaylistIndex > 0) {
        _currentPlaylistIndex--;
        final prevAudio = playlistSongs[_currentPlaylistIndex];
        // Ana listedeki index'i bul ve güncelle
        final mainIndex = _audioFiles.indexWhere((a) => a.id == prevAudio.id);
        if (mainIndex != -1) {
          _currentAudioIndex = mainIndex;
        }
        _currentAudio = prevAudio;
        notifyListeners();
        return prevAudio;
      } else {
        _isPlaying = false;
        _currentPlaylistIndex = -1;
        _currentAudio = null;
        notifyListeners();
        return null;
      }
    } else {
      if (_currentAudioIndex > 0) {
        final prevIndex = _currentAudioIndex - 1;
        _currentAudioIndex = prevIndex;
        _currentAudio = _audioFiles[prevIndex];
        notifyListeners();
        return _currentAudio;
      } else {
        _isPlaying = false;
        _currentAudioIndex = -1;
        _currentAudio = null;
        notifyListeners();
        return null;
      }
    }
  }
}