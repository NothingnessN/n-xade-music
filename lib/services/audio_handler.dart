import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import 'debug_logger.dart';

class AknAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final ThemeProvider _themeProvider;
  AudioProvider? _audioProvider;
  bool _repeatOne = false;

  AknAudioHandler(this._themeProvider) {
    _init();
  }

  void setRepeatOne(bool value) {
    _repeatOne = value;
  }

  Future<void> _init() async {
    try {
      DebugLogger.log('🎵 AudioHandler _init başlatıldı');
      
      _player.positionStream.listen((position) {
        try {
          if (_audioProvider != null) {
            _audioProvider!.updateState(
              playbackPosition: position.inMilliseconds.toDouble(),
            );
          }
          playbackState.add(playbackState.value.copyWith(
            updatePosition: position,
          ));
        } catch (e) {
          DebugLogger.log('❌ Position stream hatası: $e');
        }
      });

      _player.durationStream.listen((duration) {
        try {
          if (duration != null && _audioProvider != null) {
            _audioProvider!.updateState(
              playbackDuration: duration.inMilliseconds.toDouble(),
            );
            mediaItem.add(mediaItem.value?.copyWith(
              duration: duration,
            ));
          }
        } catch (e) {
          DebugLogger.log('❌ Duration stream hatası: $e');
        }
      });

      _player.playbackEventStream.listen((event) {
        try {
          playbackState.add(playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (_player.playing) MediaControl.pause else MediaControl.play,
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
            }[_player.processingState]!,
            playing: _player.playing,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
            queueIndex: _audioProvider?.currentAudioIndex,
          ));
        } catch (e) {
          DebugLogger.log('❌ Playback event stream hatası: $e');
        }
      });

      _player.playerStateStream.listen((playerState) async {
        try {
          if (_audioProvider != null) {
            _audioProvider!.updateState(
              isPlaying: playerState.playing,
            );

            if (playerState.processingState == ProcessingState.completed) {
              DebugLogger.log('🎵 Şarkı bitti, tekrarlama modu: ${_repeatOne ? 'Açık' : 'Kapalı'}');
              
              if (_repeatOne) {
                if (_audioProvider!.currentAudioIndex != null) {
                  final currentIndex = _audioProvider!.currentAudioIndex!;
                  final currentAudio = _audioProvider!.audioFiles[currentIndex];
                  DebugLogger.log('🔄 Aynı şarkı tekrar başlatılıyor: ${currentAudio.filename}');
                  
                  await _player.seek(Duration.zero);
                  await _player.play();
                  
                  _audioProvider!.updateState(
                    currentAudioIndex: currentIndex,
                    isPlaying: true,
                    playbackPosition: 0,
                  );
                }
              } else {
                if (_audioProvider!.currentAudioIndex != null) {
                  int nextIndex = _audioProvider!.currentAudioIndex! + 1;
                  if (nextIndex < _audioProvider!.audioFiles.length) {
                    DebugLogger.log('⏭️ Sonraki şarkıya geçiliyor...');
                    final nextAudio = _audioProvider!.audioFiles[nextIndex];
                    await playAudio(nextAudio.uri, nextAudio);
                    
                    _audioProvider!.updateState(
                      currentAudioIndex: nextIndex,
                      isPlaying: true,
                      playbackPosition: 0,
                    );
                  } else {
                    DebugLogger.log('📋 Playlist bitti, çalma duruyor.');
                    await stop();
                  }
                }
              }
            }
          }
        } catch (e) {
          DebugLogger.log('❌ Player state stream hatası: $e');
        }
      });
      
      DebugLogger.log('🎵 AudioHandler _init tamamlandı');
    } catch (e) {
      DebugLogger.log('❌ AudioHandler _init hatası: $e');
    }
  }

  void setAudioProvider(AudioProvider provider) {
    _audioProvider = provider;
  }

  Future<void> _updateMediaItem(AudioFile audio) async {
    mediaItem.add(MediaItem(
      id: audio.uri,
      title: audio.filename,
              artist: audio.artist ?? 'N-Xade Music',
              artUri: Uri.parse('android.resource://com.nxadestudios.nxademusic/drawable/notification_logo'),
      playable: true,
      displayTitle: audio.filename,
              displaySubtitle: audio.artist ?? 'N-Xade Music',
      duration: _player.duration,
      extras: {
        'notification_color': _themeProvider.currentTheme.accentColor.value,
      },
    ));
  }

  Future<void> playAudio(String uri, AudioFile audio) async {
    try {
      DebugLogger.log('🎵 Şarkı çalınıyor: ${audio.filename}');
      
      _audioProvider?.resetPlaybackState();
      
      if (_audioProvider != null) {
        final audioIndex = _audioProvider!.audioFiles.indexWhere((a) => a.uri == uri);
        if (audioIndex != -1) {
          _audioProvider!.updateState(
            currentAudioIndex: audioIndex,
            isPlaying: true,
            playbackPosition: 0,
          );
        }
      }

      await _updateMediaItem(audio);

      await _player.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      await _player.play();
    } catch (e) {
      DebugLogger.log('❌ Şarkı çalma hatası: $e');
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
    if (_audioProvider != null) {
      _audioProvider!.updateState(isPlaying: true);
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    if (_audioProvider != null) {
      _audioProvider!.updateState(isPlaying: false);
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    if (_audioProvider != null) {
      _audioProvider!.updateState(
        isPlaying: false,
        playbackPosition: 0,
      );
    }
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    if (_audioProvider != null) {
      _audioProvider!.updateState(
        playbackPosition: position.inMilliseconds.toDouble(),
      );
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_audioProvider != null && _audioProvider!.currentAudioIndex != null) {
      int nextIndex = _audioProvider!.currentAudioIndex! + 1;
      if (nextIndex < _audioProvider!.audioFiles.length) {
        final audio = _audioProvider!.audioFiles[nextIndex];
        
        _audioProvider!.resetPlaybackState();
        _audioProvider!.updateState(
          currentAudioIndex: nextIndex,
          isPlaying: true,
          playbackPosition: 0,
        );
        
        await _player.stop();
        await playAudio(audio.uri, audio);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioProvider != null && _audioProvider!.currentAudioIndex != null) {
      int prevIndex = _audioProvider!.currentAudioIndex! - 1;
      if (prevIndex >= 0) {
        final audio = _audioProvider!.audioFiles[prevIndex];
        
        _audioProvider!.resetPlaybackState();
        _audioProvider!.updateState(
          currentAudioIndex: prevIndex,
          isPlaying: true,
          playbackPosition: 0,
        );
        
        await _player.stop();
        await playAudio(audio.uri, audio);
      }
    }
  }
} 