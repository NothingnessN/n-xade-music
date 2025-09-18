import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import 'debug_logger.dart';

class AknAudioHandler extends BaseAudioHandler {
  AudioPlayer? _player; // final kaldırıldı, dispose edilebilir
  final ThemeProvider _themeProvider;
  AudioProvider? _audioProvider;
  bool _repeatOne = false;
  bool _isAutoSkipping = false;

  AknAudioHandler(this._themeProvider, {AudioProvider? audioProvider}) {
    _audioProvider = audioProvider;
    _init();
  }

  void setAudioProvider(AudioProvider provider) {
    _audioProvider = provider;
    DebugLogger.log('🎵 AudioProvider set successfully');
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    _repeatOne = mode == AudioServiceRepeatMode.one;
    await _player?.setLoopMode(_repeatOne ? LoopMode.one : LoopMode.all);
  }

  Future<void> _init() async {
    try {
      DebugLogger.log('🎵 AudioHandler _init başlatıldı');
      _player = AudioPlayer(); // Yeni player oluştur
      _player!.positionStream.listen((position) {
        try {
          if (_audioProvider == null) {
            DebugLogger.log('⚠️ _audioProvider is null in positionStream');
            return;
          }
          _audioProvider!.updateState(
            playbackPosition: position.inMilliseconds.toDouble(),
          );
          playbackState.add(playbackState.value.copyWith(
            updatePosition: position,
          ));
        } catch (e) {
          DebugLogger.log('❌ Position stream hatası: $e');
        }
      });

      _player!.durationStream.listen((duration) {
        try {
          if (duration == null || _audioProvider == null) {
            DebugLogger.log('⚠️ duration or _audioProvider is null');
            return;
          }
          _audioProvider!.updateState(
            playbackDuration: duration.inMilliseconds.toDouble(),
          );
          mediaItem.add(mediaItem.value?.copyWith(
            duration: duration,
          ));
        } catch (e) {
          DebugLogger.log('❌ Duration stream hatası: $e');
        }
      });

      _player!.playbackEventStream.listen((event) {
        try {
          playbackState.add(playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              _player!.playing ? MediaControl.pause : MediaControl.play,
              MediaControl.skipToNext,
            ],
            systemActions: {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
            },
            androidCompactActionIndices: [0, 1, 2],
            processingState: {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player!.processingState] ?? AudioProcessingState.idle,
            playing: _player!.playing,
          ));
        } catch (e) {
          DebugLogger.log('❌ Playback event stream hatası: $e');
        }
      });

      _player!.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed && !_repeatOne) {
          if (_isAutoSkipping) {
            DebugLogger.log('⏭️ Skip zaten sürüyor, ikinci tetik yok sayıldı');
            return;
          }
          _isAutoSkipping = true;
          DebugLogger.log('🎵 Şarkı tamamlandı → doğrudan sonraki şarkıya geçiliyor');
          try {
            await skipToNext();
          } catch (e) {
            DebugLogger.log('❌ Tamamlanınca skipToNext hatası: $e');
          } finally {
            _isAutoSkipping = false;
          }
        }
      });
    } catch (e) {
      DebugLogger.log('❌ AudioHandler init hatası: $e');
    }
  }

  Future<void> _updateMediaItem(AudioFile audio) async {
    mediaItem.add(MediaItem(
      id: audio.id,
      title: audio.displayNameWOExt,
      artist: audio.artist ?? 'Unknown Artist',
      album: audio.album ?? 'Unknown Album',
      duration: Duration(milliseconds: audio.duration.toInt()),
    ));
  }

  Future<void> playAudio(String uri, AudioFile audio) async {
    try {
      DebugLogger.log('🎵 Playing audio: ${uri.split('/').last}');
      await _player?.stop(); // Önce mevcut oynatmayı durdur
      await _updateMediaItem(audio);
      await _player?.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await _player?.play();
      // Yeni parça başladı; olası eski skip bayrağını temizle
      _isAutoSkipping = false;
      if (_audioProvider != null) {
        _audioProvider!.updateState(isPlaying: true, playbackPosition: 0);
      } else {
        DebugLogger.log('⚠️ _audioProvider is null during playAudio');
      }
    } catch (e) {
      DebugLogger.log('❌ Şarkı çalma hatası: $e');
      rethrow; // Hatanın üst katmanlara ulaşmasını sağla
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player?.play();
      if (_audioProvider != null) {
        _audioProvider!.updateState(isPlaying: true);
      }
    } catch (e) {
      DebugLogger.log('❌ Play hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player?.pause();
      if (_audioProvider != null) {
        _audioProvider!.updateState(isPlaying: false);
      }
    } catch (e) {
      DebugLogger.log('❌ Pause hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player?.stop();
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          isPlaying: false,
          playbackPosition: 0,
        );
      }
    } catch (e) {
      DebugLogger.log('❌ Stop hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player?.seek(position);
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          playbackPosition: position.inMilliseconds.toDouble(),
        );
      }
    } catch (e) {
      DebugLogger.log('❌ Seek hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      if (_audioProvider == null) {
        DebugLogger.log('⚠️ _audioProvider is null in skipToNext');
        return;
      }
      final nextAudio = _audioProvider!.getNextAudio();
      if (nextAudio != null) {
        await playAudio(nextAudio.uri, nextAudio);
      } else {
        DebugLogger.log('⚠️ Sonraki şarkı bulunamadı');
        await stop();
      }
    } catch (e) {
      DebugLogger.log('❌ Skip to next hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      if (_audioProvider == null) {
        DebugLogger.log('⚠️ _audioProvider is null in skipToPrevious');
        return;
      }
      final prevAudio = _audioProvider!.getPreviousAudio();
      if (prevAudio != null) {
        await playAudio(prevAudio.uri, prevAudio);
      } else {
        DebugLogger.log('⚠️ Önceki şarkı bulunamadı');
        await stop();
      }
    } catch (e) {
      DebugLogger.log('❌ Skip to previous hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
      DebugLogger.log('🎵 AudioHandler dispose edildi');
    } catch (e) {
      DebugLogger.log('❌ Dispose hatası: $e');
    }
  }
}