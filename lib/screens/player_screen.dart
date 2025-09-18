import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/player_button.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:nxade_music/l10n/app_localizations.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDisposed = false;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));

    final audioController = Provider.of<AudioController>(context, listen: false);

    if (audioController.isPlaying) {
      _animationController.repeat();
    }

    audioController.addListener(() {
      if (_isDisposed) return;
      if (audioController.isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final audioController = Provider.of<AudioController>(context);
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: theme.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(theme.backgroundImage!), fit: BoxFit.cover)
              : null,
          gradient: theme.gradientColors != null
              ? LinearGradient(
                  colors: theme.gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: theme.backgroundImage == null && theme.gradientColors == null
              ? theme.backgroundColor
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.by_nxade_studios,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                      if (audioProvider.currentAudio != null)
                        Text(
                          audioProvider.currentAudio!.displayNameWOExt,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (audioProvider.currentAudio != null)
                        Text(
                          audioProvider.currentAudio!.artist ?? 'Bilinmeyen Sanatçı',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.accentColor.withOpacity(0.2),
                        ),
                        child: Icon(Icons.music_note,
                            size: 100, color: theme.accentColor),
                      ),
                    ),
                  ),
                ),
                StreamBuilder<Duration>(
                  stream: audioController.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = Duration(
                        milliseconds: audioController.duration.toInt());
                    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
                    final rawMs = position.inMilliseconds.toDouble();
                    final clampedMs = rawMs.clamp(0.0, maxMs);

                    return Column(
                      children: [
                        Slider(
                          value: clampedMs,
                          max: maxMs,
                          onChanged: (value) {
                            setState(() {
                              _isSeeking = true;
                            });
                          },
                          onChangeEnd: (value) {
                            audioController.moveAudio(value);
                            setState(() {
                              _isSeeking = false;
                            });
                          },
                          activeColor: theme.accentColor,
                          inactiveColor: theme.textColor.withOpacity(0.3),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(color: theme.textColor),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(color: theme.textColor),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayerButton(
                      iconType: 'PREV',
                      onPress: () =>
                          _handlePrevious(audioProvider, audioController),
                      size: 40,
                    ),
                    PlayerButton(
                      iconType: audioController.isPlaying ? 'PAUSE' : 'PLAY',
                      onPress: () {
                        if (audioController.isPlaying) {
                          audioController.pause();
                        } else {
                          audioController.resume();
                        }
                      },
                      size: 60,
                    ),
                    PlayerButton(
                      iconType: 'NEXT',
                      onPress: () =>
                          _handleNext(audioProvider, audioController),
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.repeat_one,
                          color: audioController.repeatOne
                              ? theme.accentColor
                              : theme.textColor.withOpacity(0.7)),
                      onPressed: () {
                        audioController.setRepeatOne(!audioController.repeatOne);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 60, child: const BannerAdWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleNext(
      AudioProvider audioProvider, AudioController audioController) async {
    if (audioProvider.isPlayListRunning) {
      final nextAudio = audioProvider.getNextAudio();
      if (nextAudio != null) {
        await audioController.play(
          nextAudio.uri,
          title: nextAudio.filename,
        );
      } else {
        await audioController.pause();
      }
    } else {
      final nextAudio = audioProvider.getNextAudio();
      if (nextAudio != null) {
        await audioController.play(
          nextAudio.uri,
          title: nextAudio.filename,
        );
      } else {
        await audioController.pause();
      }
    }
  }

  Future<void> _handlePrevious(
      AudioProvider audioProvider, AudioController audioController) async {
    if (audioProvider.isPlayListRunning) {
      final prevAudio = audioProvider.getPreviousAudio();
      if (prevAudio != null) {
        await audioController.play(
          prevAudio.uri,
          title: prevAudio.filename,
        );
      } else {
        await audioController.pause();
      }
    } else {
      final prevAudio = audioProvider.getPreviousAudio();
      if (prevAudio != null) {
        await audioController.play(
          prevAudio.uri,
          title: prevAudio.filename,
        );
      } else {
        await audioController.pause();
      }
    }
  }
}