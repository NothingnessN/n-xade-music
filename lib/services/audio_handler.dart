import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';

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
    _player.positionStream.listen((position) {
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          playbackPosition: position.inMilliseconds.toDouble(),
        );
      }
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    _player.durationStream.listen((duration) {
      if (duration != null && _audioProvider != null) {
        _audioProvider!.updateState(
          playbackDuration: duration.inMilliseconds.toDouble(),
        );
        mediaItem.add(mediaItem.value?.copyWith(
          duration: duration,
        ));
      }
    });

    _player.playbackEventStream.listen((event) {
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
    });

    _player.playerStateStream.listen((playerState) async {
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          isPlaying: playerState.playing,
        );

        // Şarkı bittiğinde tekrarlama kontrolü
        if (playerState.processingState == ProcessingState.completed) {
          if (_repeatOne && _audioProvider!.currentAudioIndex != null) {
            final currentIndex = _audioProvider!.currentAudioIndex!;
            final currentAudio = _audioProvider!.audioFiles[currentIndex];
            await playAudio(currentAudio.uri ?? '', currentAudio.displayNameWOExt);
          } else {
            await skipToNext();
          }
        }
      }
    });
  }

  void setAudioProvider(AudioProvider provider) {
    _audioProvider = provider;
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
        
        // Önce durumu sıfırla
        _audioProvider!.resetPlaybackState();
        
        // Yeni şarkıyı ayarla
        _audioProvider!.updateState(currentAudioIndex: nextIndex);
        
        // MediaItem'ı güncelle
        mediaItem.add(MediaItem(
          id: audio.uri ?? '',
          title: audio.displayNameWOExt,
          artist: 'AKN Music',
          artUri: Uri.parse('android.resource://com.nothingnessn.aknmusic/drawable/notification_logo'),
          playable: true,
          displayTitle: audio.displayNameWOExt,
          displaySubtitle: 'AKN Music',
          duration: _player.duration,
          extras: {
            'notification_color': _themeProvider.currentTheme.accentColor.value,
          },
        ));
        
        // Yeni şarkıyı çal
        await _player.stop();
        await playAudio(audio.uri ?? '', audio.displayNameWOExt);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_audioProvider != null && _audioProvider!.currentAudioIndex != null) {
      int prevIndex = _audioProvider!.currentAudioIndex! - 1;
      if (prevIndex >= 0) {
        final audio = _audioProvider!.audioFiles[prevIndex];
        
        // Önce durumu sıfırla
        _audioProvider!.resetPlaybackState();
        
        // Yeni şarkıyı ayarla
        _audioProvider!.updateState(currentAudioIndex: prevIndex);
        
        // MediaItem'ı güncelle
        mediaItem.add(MediaItem(
          id: audio.uri ?? '',
          title: audio.displayNameWOExt,
          artist: 'AKN Music',
          artUri: Uri.parse('android.resource://com.nothingnessn.aknmusic/drawable/notification_logo'),
          playable: true,
          displayTitle: audio.displayNameWOExt,
          displaySubtitle: 'AKN Music',
          duration: _player.duration,
          extras: {
            'notification_color': _themeProvider.currentTheme.accentColor.value,
          },
        ));
        
        // Yeni şarkıyı çal
        await _player.stop();
        await playAudio(audio.uri ?? '', audio.displayNameWOExt);
      }
    }
  }

  Future<void> playAudio(String uri, String title) async {
    try {
      final source = AudioSource.uri(Uri.parse(uri));
      
      // Önce mevcut çalanı durdur
      await _player.stop();
      
      // Yeni kaynağı ayarla
      await _player.setAudioSource(source);
      
      // MediaItem'ı güncelle
      mediaItem.add(MediaItem(
        id: uri,
        title: title,
        artist: 'AKN Music',
        artUri: Uri.parse('android.resource://com.nothingnessn.aknmusic/drawable/notification_logo'),
        playable: true,
        displayTitle: title,
        displaySubtitle: 'AKN Music',
        duration: _player.duration,
        extras: {
          'notification_color': _themeProvider.currentTheme.accentColor.value,
        },
      ));
      
      // Çalmaya başla
      await _player.play();
      
      // Provider'ı güncelle
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          isPlaying: true,
          playbackPosition: 0,
          playbackDuration: _player.duration?.inMilliseconds.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      print('Error in playAudio: $e');
      if (_audioProvider != null) {
        _audioProvider!.updateState(isPlaying: false);
      }
    }
  }
} 