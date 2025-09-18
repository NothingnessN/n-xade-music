import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'dart:convert';
import 'audio_provider.dart';
import 'theme_provider.dart';
import '../services/audio_handler.dart';
import '../services/debug_logger.dart';

class AudioController with ChangeNotifier {
  AknAudioHandler? _audioHandler;
  bool _isInitializingHandler = false;
  Future<void>? _handlerInitFuture;
  bool _isPlaying = false;
  double _position = 0;
  double _duration = 0;
  bool _isLoaded = false;
  AudioProvider? _audioProvider;
  bool _isAutoNexting = false;
  bool _repeatOne = false;
  final ThemeProvider _themeProvider;
  Timer? _endGuardTimer;

  bool get isPlaying => _isPlaying;
  double get position => _position;
  double get duration => _duration;
  bool get isLoaded => _isLoaded;
  bool get repeatOne => _repeatOne;

  Stream<Duration> get positionStream => 
      _audioHandler?.playbackState.map((state) => state.position) ?? Stream.value(Duration.zero);

  AudioController(this._themeProvider) {
    _init();
  }

  Future<void> _init() async {
    await _loadRepeatState();
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
      if (_audioHandler != null) {
        return;
      }
      if (_isInitializingHandler) {
        // Halihazırda başlatılıyorsa onu bekle
        await _handlerInitFuture;
        return;
      }
      _isInitializingHandler = true;
      DebugLogger.log('🎵 AudioHandler kuruluyor...');
      DebugLogger.log('🎵 themeProvider: ${_themeProvider != null ? 'NOT NULL' : 'NULL'}');
      _handlerInitFuture = AudioService.init(
        builder: () => AknAudioHandler(_themeProvider),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.nxadestudios.nxademusic.channel.audio',
          androidNotificationChannelName: 'N-Xade Music',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
        ),
      ).then((handler) {
        _audioHandler = handler;
      });
      await _handlerInitFuture;
      DebugLogger.log('🎵 AudioHandler oluşturuldu: ${_audioHandler != null ? 'BAŞARILI' : 'BAŞARISIZ'}');
      if (_audioProvider != null) {
        DebugLogger.log('🎵 AudioHandler\'a AudioProvider ayarlanıyor...');
        _audioHandler?.setAudioProvider(_audioProvider!);
        DebugLogger.log('🎵 AudioProvider başarıyla ayarlandı');
      } else {
        DebugLogger.log('⚠️ AudioProvider NULL, AudioHandler\'a ayarlanamadı');
      }
      _audioHandler?.playbackState.listen((state) {
        if (state.playing != _isPlaying) {
          DebugLogger.log('🎵 Çalma durumu değişti: ${state.playing ? 'ÇALIYOR' : 'DURAKLATILDI'}');
          _isPlaying = state.playing;
          _position = state.position.inMilliseconds.toDouble();
          if (_audioProvider != null) {
            _audioProvider!.updateState(isPlaying: _isPlaying, playbackPosition: _position);
          }
          notifyListeners();
        }
        // Tamamlanınca geçişi artık handler yönetiyor
      });
      _audioHandler?.mediaItem.listen((mediaItem) {
        if (mediaItem != null) {
          DebugLogger.log('🎵 Medya öğesi güncellendi: ${mediaItem.title}');
          _duration = mediaItem.duration?.inMilliseconds.toDouble() ?? 0.0;
          if (_audioProvider != null) {
            _audioProvider!.updateState(playbackDuration: _duration);
          }
          notifyListeners();
        }
      });

      // Son-kontrol döngüsü artık gereksiz; geçişi handler tetikliyor
      _endGuardTimer?.cancel();
      _endGuardTimer = null;
    } catch (e) {
      DebugLogger.log('❌ AudioHandler kurulurken hata: $e');
    } finally {
      _isInitializingHandler = false;
    }
  }

  void setAudioProvider(AudioProvider provider) {
    _audioProvider = provider;
    _audioHandler?.setAudioProvider(provider);
  }

  void setRepeatOne(bool value) {
    _repeatOne = value;
    _saveRepeatState();
    _audioHandler?.setRepeatMode(value ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.all);
    notifyListeners();
  }

  Future<bool> play(String uri, {String? title, AudioProvider? provider, Duration? initialPosition}) async {
    try {
      DebugLogger.log('🎵 Ses çalınıyor: ${uri.split('/').last}');
      // Sağlanan provider'ı kaydet
      if (provider != null) {
        _audioProvider = provider;
        _audioHandler?.setAudioProvider(provider);
      }
      // Handler henüz kurulmadıysa kur
      await _setupAudioHandler();
      if (_audioHandler != null && _audioProvider != null) {
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
        // AudioProvider'ın state'ini güncelle
        _audioProvider!.updateState(
          isPlaying: true,
          currentAudioIndex: _audioProvider!.currentAudioIndex,
        );
        await storeAudioForNextOpening(uri, _audioProvider!.currentAudioIndex);
        return true;
      }
      DebugLogger.log('❌ AudioHandler veya AudioProvider null');
      return false;
    } catch (e) {
      DebugLogger.log('❌ Ses çalınırken hata: $e');
      return false;
    }
  }

  Future<bool> pause() async {
    try {
      DebugLogger.log('⏸️ Ses duraklatılıyor');
      if (_audioHandler != null) {
        await _audioHandler!.pause();
        return true;
      }
      DebugLogger.log('❌ AudioHandler null');
      return false;
    } catch (e) {
      DebugLogger.log('❌ Ses duraklatılırken hata: $e');
      return false;
    }
  }

  Future<bool> resume() async {
    try {
      DebugLogger.log('▶️ Ses devam ettiriliyor');
      if (_audioHandler != null) {
        await _audioHandler!.play();
        return true;
      }
      DebugLogger.log('❌ AudioHandler null');
      return false;
    } catch (e) {
      DebugLogger.log('❌ Ses devam ettirilirken hata: $e');
      return false;
    }
  }

  Future<bool> playNext() async {
    try {
      if (_repeatOne) {
        DebugLogger.log('🔁 Tekrar modu açık, mevcut şarkı tekrar çalınıyor');
        final currentAudio = _audioProvider?.currentAudio;
        if (currentAudio != null) {
          await play(currentAudio.uri, title: currentAudio.filename);
          return true;
        }
        return false;
      }
      DebugLogger.log('⏭️ Sonraki ses çalınıyor');
      if (_audioProvider != null) {
        final nextAudio = _audioProvider!.getNextAudio();
        if (nextAudio != null) {
          await play(nextAudio.uri, title: nextAudio.filename);
          // Oynatma durumu doğrulama: bazı cihazlarda state gecikebiliyor
          await Future.delayed(const Duration(milliseconds: 100));
          if (!_isPlaying) {
            try {
              await _audioHandler?.play();
            } catch (_) {}
            await Future.delayed(const Duration(milliseconds: 100));
          }
          return true;
        } else {
          DebugLogger.log('⏹️ Liste bitti, oynatma durduruluyor');
          await pause();
          return false;
        }
      }
      DebugLogger.log('❌ AudioProvider null');
      return false;
    } catch (e) {
      DebugLogger.log('❌ Sonraki ses çalınırken hata: $e');
      return false;
    }
  }

  Future<bool> playPrevious() async {
    try {
      if (_repeatOne) {
        DebugLogger.log('🔁 Tekrar modu açık, mevcut şarkı tekrar çalınıyor');
        final currentAudio = _audioProvider?.currentAudio;
        if (currentAudio != null) {
          await play(currentAudio.uri, title: currentAudio.filename);
          return true;
        }
        return false;
      }
      DebugLogger.log('⏮️ Önceki ses çalınıyor');
      if (_audioProvider != null) {
        final prevAudio = _audioProvider!.getPreviousAudio();
        if (prevAudio != null) {
          await play(prevAudio.uri, title: prevAudio.filename);
          return true;
        } else {
          DebugLogger.log('⏹️ Liste başında, oynatma durduruluyor');
          await pause();
          return false;
        }
      }
      DebugLogger.log('❌ AudioProvider null');
      return false;
    } catch (e) {
      DebugLogger.log('❌ Önceki ses çalınırken hata: $e');
      return false;
    }
  }

  Future<void> moveAudio(double value) async {
    try {
      DebugLogger.log('⏩ Ses şu konuma taşınıyor: ${value ~/ 1000} saniye');
      if (_audioHandler != null) {
        await _audioHandler!.seek(Duration(milliseconds: value.toInt()));
        // Kullanıcı çubuğu sona çok yakın taşıdıysa tamamlanmış kabul edip sonraki parçaya geç
        final totalMs = duration;
        if (totalMs > 0) {
          final remaining = totalMs - value;
          if (remaining <= 3000 && !_isAutoNexting && !_repeatOne) {
            // Artık geçişi handler yapıyor; burada sadece stop + küçük seek ile tamamlanmayı tetikle
            try {
              await _audioHandler?.seek(Duration(milliseconds: (totalMs - 10).toInt()));
            } catch (_) {}
            return;
          }
        }
      }
    } catch (e) {
      DebugLogger.log('❌ Ses taşınırken hata: $e');
    }
  }

  Future<void> destroyPlayer() async {
    try {
      DebugLogger.log('🛑 Oynatıcı yok ediliyor');
      if (_audioHandler != null) {
        await _audioHandler!.stop();
      }
    } catch (e) {
      DebugLogger.log('❌ Oynatıcı yok edilirken hata: $e');
    }
  }

  Future<void> storeAudioForNextOpening(String uri, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final audioData = {
        'audio': {'id': _audioProvider?.audioFiles[index].id, 'uri': uri},
        'index': index,
      };
      await prefs.setString('previousAudio', jsonEncode(audioData));
    } catch (e) {
      DebugLogger.log('❌ Ses verisi kaydedilirken hata: $e');
    }
  }
}
