import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:convert';
import 'audio_provider.dart';
import 'theme_provider.dart';
import '../services/audio_handler.dart';

class AudioController with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  AknAudioHandler? _audioHandler;
  bool _isPlaying = false;
  double _position = 0;
  double _duration = 0;
  bool _isLoaded = false;
  AudioProvider? _audioProvider;
  bool _isAutoNexting = false;
  bool _repeatOne = false;
  final ThemeProvider _themeProvider;

  bool get isPlaying => _isPlaying;
  double get position => _position;
  double get duration => _duration;
  bool get isLoaded => _isLoaded;
  bool get repeatOne => _repeatOne;

  AudioController(this._themeProvider) {
    _init();
  }

  Future<void> _init() async {
    await _loadRepeatState();
    await _setupPlayer();
    await _setupAudioHandler();
  }

  Future<void> _loadRepeatState() async {
    final prefs = await SharedPreferences.getInstance();
    _repeatOne = prefs.getBool('repeatOne') ?? false;
    notifyListeners();
  }

  Future<void> _saveRepeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('repeatOne', _repeatOne);
  }

  Future<void> _setupAudioHandler() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => AknAudioHandler(_themeProvider),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.nothingnessn.aknmusic.channel.audio',
          androidNotificationChannelName: 'AKN Music',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
          notificationColor: _themeProvider.currentTheme.accentColor,
        ),
      );

      if (_audioProvider != null) {
        _audioHandler?.setAudioProvider(_audioProvider!);
      }

      // AudioHandler durumunu dinle
      _audioHandler?.playbackState.listen((state) {
        _isPlaying = state.playing;
        _position = state.position.inMilliseconds.toDouble();
        if (_audioProvider != null) {
          _audioProvider!.updateState(
            isPlaying: _isPlaying,
            playbackPosition: _position,
          );
        }
        notifyListeners();
      });

      // MediaItem durumunu dinle
      _audioHandler?.mediaItem.listen((mediaItem) {
        if (mediaItem != null) {
          _duration = mediaItem.duration?.inMilliseconds.toDouble() ?? 0.0;
          if (_audioProvider != null) {
            _audioProvider!.updateState(
              playbackDuration: _duration,
            );
          }
          notifyListeners();
        }
      });

    } catch (e) {
      print('Error setting up audio handler: $e');
      rethrow;
    }
  }

  void setAudioProvider(AudioProvider provider) {
    _audioProvider = provider;
    _audioHandler?.setAudioProvider(provider);
  }

  void setRepeatOne(bool value) {
    _repeatOne = value;
    _audioHandler?.setRepeatOne(value);
    _saveRepeatState();
    notifyListeners();
  }

  Future<void> _setupPlayer() async {
    print('🎵 Setting up player');
    
    // Pozisyon değişikliklerini dinle
    _player.positionStream.listen((position) {
      _position = position.inMilliseconds.toDouble();
      if (_audioProvider != null) {
        _audioProvider!.updateState(
          playbackPosition: _position,
        );
      }
      notifyListeners();
      print('Position updated: ${_formatDuration(_position)}');
    });

    // Süre değişikliklerini dinle
    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration.inMilliseconds.toDouble();
        if (_audioProvider != null) {
          _audioProvider!.updateState(
            playbackDuration: _duration,
          );
        }
        notifyListeners();
        print('Duration updated: ${_formatDuration(_duration)}');
      }
    });

    _player.playerStateStream.listen((state) async {
      _isPlaying = state.playing;
      _isLoaded = state.processingState != ProcessingState.idle;
      notifyListeners();

      if (state.processingState == ProcessingState.completed && !_isAutoNexting) {
        _isAutoNexting = true;
        if (_audioProvider != null && _audioProvider!.audioFiles.isNotEmpty) {
          int? currentIndex = _audioProvider!.currentAudioIndex;
          print('Şarkı bitti, mevcut index: $currentIndex, repeatOne: $_repeatOne');
          if (currentIndex != null) {
            if (_repeatOne) {
              print('Tekrar aynı şarkı başlatılıyor: $currentIndex');
              await _audioProvider!.playAtIndex(currentIndex, this);
            } else {
              int nextIndex = currentIndex + 1;
              if (nextIndex < _audioProvider!.audioFiles.length) {
                print('Sonraki şarkı başlatılıyor: $nextIndex');
                await _audioProvider!.playAtIndex(nextIndex, this);
              } else {
                print('Son şarkıdayız, çalma duracak.');
                await pause();
                _audioProvider!.resetPlaybackState();
              }
            }
          }
        }
        _isAutoNexting = false;
      }
    });
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<bool> play(String uri, {Duration? initialPosition, String? title, int? index, AudioProvider? provider}) async {
    try {
      print('🎵 Playing audio: \x1b[32m${uri.split('/').last}\x1b[0m');
      if (_audioHandler != null && _audioProvider != null) {
        // Şarkıyı bul
        final audio = _audioProvider!.audioFiles.firstWhere(
          (a) => a.uri == uri,
          orElse: () => AudioFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filename: title ?? uri.split('/').last,
            uri: uri,
            duration: 0,
          ),
        );

        await _audioHandler!.playAudio(uri, audio);
        if (initialPosition != null) {
          await _audioHandler!.seek(initialPosition);
        }
        if (index != null) {
          await storeAudioForNextOpening(uri, index);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  Future<bool> pause() async {
    try {
      print('⏸️ Pausing audio');
      if (_audioHandler != null) {
        await _audioHandler!.pause();
        return true;
      }
      return false;
    } catch (e) {
      print('Error pausing audio: $e');
      return false;
    }
  }

  Future<bool> resume() async {
    try {
      print('▶️ Resuming audio');
      if (_audioHandler != null) {
        await _audioHandler!.play();
        return true;
      }
      return false;
    } catch (e) {
      print('Error resuming audio: $e');
      return false;
    }
  }

  Future<bool> playNext(String uri, {String? title, int? index, AudioProvider? provider}) async {
    try {
      print('⏭️ Playing next audio: ${uri.split('/').last}');
      if (_audioHandler != null && _audioProvider != null) {
        // Şarkıyı bul
        final audio = _audioProvider!.audioFiles.firstWhere(
          (a) => a.uri == uri,
          orElse: () => AudioFile(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filename: title ?? uri.split('/').last,
            uri: uri,
            duration: 0,
          ),
        );

        await _audioHandler!.playAudio(uri, audio);
        if (index != null) {
          await storeAudioForNextOpening(uri, index);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error playing next audio: $e');
      return false;
    }
  }

  Future<void> moveAudio(double value) async {
    try {
      print('⏩ Moving audio to position: ${value ~/ 1000} seconds');
      if (_audioHandler != null) {
        await _audioHandler!.seek(Duration(milliseconds: value.toInt()));
      }
    } catch (e) {
      print('Error moving audio: $e');
    }
  }

  Future<void> destroyPlayer() async {
    try {
      print('🛑 Destroying player');
      if (_audioHandler != null) {
        await _audioHandler!.stop();
      }
      await _player.dispose();
    } catch (e) {
      print('Error destroying player: $e');
    }
  }

  Future<void> storeAudioForNextOpening(String uri, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final audioData = {
        'audio': {
          'id': _audioProvider?.audioFiles[index].id,
          'uri': uri,
        },
        'index': index,
      };
      await prefs.setString('previousAudio', jsonEncode(audioData));
    } catch (e) {
      print('Error storing audio data: $e');
    }
  }
}