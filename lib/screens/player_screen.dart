import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/player_button.dart';
import '../widgets/screen.dart';
import 'package:akn_music/l10n/app_localizations.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  bool _isSeeking = false;
  bool _repeatOne = false;
  late AnimationController _animationController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
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

    return Screen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.by_nothingnessn,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Text(
                  audioProvider.currentAudio?.filename ?? '',
                  key: ValueKey(audioProvider.currentAudio?.id ?? ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              if (audioProvider.isPlayListRunning && audioProvider.activePlayList != null)
                Text(
                  'Playing from: ${audioProvider.activePlayList!['title'] ?? 'Unknown Playlist'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Container(
                      key: ValueKey(audioProvider.currentAudio?.id ?? ''),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accentColor.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          audioController.isPlaying ? 'assets/6.png' : 'assets/7.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Slider(
                      value: _isSeeking
                          ? audioController.position
                          : audioController.position.clamp(
                              0.0, audioController.duration),
                      max: audioController.duration,
                      onChanged: (value) {
                        setState(() => _isSeeking = true);
                        audioController.moveAudio(value);
                      },
                      onChangeEnd: (value) {
                        setState(() => _isSeeking = false);
                      },
                      activeColor: theme.accentColor,
                      inactiveColor: theme.textColor.withOpacity(0.3),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<double>(
                            valueListenable: ValueNotifier<double>(audioController.position),
                            builder: (context, position, child) {
                              return Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable: ValueNotifier<double>(audioController.duration),
                            builder: (context, duration, child) {
                              return Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlayerButton(
                          iconType: 'PREV',
                          onPress: () => _handlePrevious(audioProvider, audioController),
                        ),
                        SizedBox(width: 20),
                        PlayerButton(
                          iconType: audioController.isPlaying ? 'PAUSE' : 'PLAY',
                          size: 70,
                          onPress: () async {
                            if (audioController.isPlaying) {
                              await audioController.pause();
                            } else {
                              await audioController.resume();
                            }
                          },
                        ),
                        SizedBox(width: 20),
                        PlayerButton(
                          iconType: 'NEXT',
                          onPress: () => _handleNext(audioProvider, audioController),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final audioController = Provider.of<AudioController>(context, listen: false);
                            audioController.setRepeatOne(!audioController.repeatOne);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: audioController.repeatOne ? theme.accentColor : Colors.white.withOpacity(0.3),
                            ),
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: audioController.repeatOne
                                    ? Colors.white
                                    : (Provider.of<ThemeProvider>(context).selectedThemeKey == 'light'
                                        ? Colors.black
                                        : Colors.white.withOpacity(0.7)),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleNext(AudioProvider audioProvider, AudioController audioController) async {
    int? currentIndex = audioProvider.currentAudioIndex;
    if (currentIndex == null) return;
    int nextIndex = currentIndex + 1;
    if (nextIndex >= audioProvider.audioFiles.length) nextIndex = 0;
    await audioProvider.playAtIndex(nextIndex, audioController);
  }

  Future<void> _handlePrevious(AudioProvider audioProvider, AudioController audioController) async {
    int? currentIndex = audioProvider.currentAudioIndex;
    if (currentIndex == null) return;
    int prevIndex = currentIndex - 1;
    if (prevIndex < 0) prevIndex = audioProvider.audioFiles.length - 1;
    await audioProvider.playAtIndex(prevIndex, audioController);
  }
}