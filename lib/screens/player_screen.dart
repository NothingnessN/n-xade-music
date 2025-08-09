import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/player_button.dart';
import '../widgets/screen.dart';
import '../widgets/banner_ad_widget.dart';
import 'package:nxade_music/l10n/app_localizations.dart';

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: theme.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(theme.backgroundImage!),
                  fit: BoxFit.cover,
                )
              : theme.gradientColors != null
                  ? null
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
                // Üst kısım - sabit yükseklik
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                          child: Text(
                            audioProvider.currentAudio?.filename ?? '',
                            key: ValueKey(audioProvider.currentAudio?.id ?? ''),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.textColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Orta kısım - esnek yükseklik
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Single music note icon
                      Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: theme.backgroundImage != null
                              ? Image.asset(
                                  theme.backgroundImage!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: theme.backgroundImage == null && theme.gradientColors == null ? theme.backgroundColor : null,
                                    gradient: theme.gradientColors != null
                                        ? LinearGradient(
                                            colors: theme.gradientColors!,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: theme.textColor,
                                  ),
                                ),
                        ),
                      ),
                      
                      if (audioProvider.isPlayListRunning && audioProvider.activePlayList != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          margin: EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.playing_from} ${audioProvider.activePlayList!['title'] ?? 'Unknown Playlist'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      
                      // Player controls
                      Column(
                        children: [
                          Slider(
                            value: _isSeeking
                                ? audioController.position
                                : audioController.position.clamp(0.0, audioController.duration),
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
                            padding: EdgeInsets.symmetric(horizontal: 16),
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
                                        fontSize: 12,
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
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PlayerButton(
                                iconType: 'PREV',
                                onPress: () async {
                                  print('🔄 Previous button pressed');
                                  await _handlePrevious(audioProvider, audioController);
                                },
                              ),
                              SizedBox(width: 20),
                              PlayerButton(
                                iconType: audioController.isPlaying ? 'PAUSE' : 'PLAY',
                                size: 60,
                                onPress: () async {
                                  print('🎵 Play/Pause button pressed');
                                  if (audioController.isPlaying) {
                                    print('⏸️ Pausing...');
                                    await audioController.pause();
                                  } else {
                                    print('▶️ Resuming...');
                                    await audioController.resume();
                                  }
                                },
                              ),
                              SizedBox(width: 20),
                              PlayerButton(
                                iconType: 'NEXT',
                                onPress: () async {
                                  print('⏭️ Next button pressed');
                                  await _handleNext(audioProvider, audioController);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final audioController = Provider.of<AudioController>(context, listen: false);
                                  audioController.setRepeatOne(!audioController.repeatOne);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Alt kısım - reklam boyutuna göre dinamik yükseklik
                const SizedBox(height: 8),
                const BannerAdWidget(),
              ],
            ),
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
    if (audioProvider.isPlayListRunning) {
      // Playlist modunda - sadece playlist içinde geç
      final nextPlaylistIndex = audioProvider.getNextSongIndexInPlaylist();
      if (nextPlaylistIndex != null) {
        await audioProvider.playPlaylistSongAtIndex(nextPlaylistIndex, audioController);
      }
      // Playlist sonu ise hiçbir şey yapma
    } else {
      // Normal mod - tüm şarkı listesinde geç
      int currentIndex = audioProvider.currentAudioIndex;
      if (currentIndex < 0) return;
      int nextIndex = currentIndex + 1;
      if (nextIndex >= audioProvider.audioFiles.length) nextIndex = 0;
      await audioProvider.playAtIndex(nextIndex, audioController);
    }
  }

  Future<void> _handlePrevious(AudioProvider audioProvider, AudioController audioController) async {
    if (audioProvider.isPlayListRunning) {
      // Playlist modunda - sadece playlist içinde geç
      final prevPlaylistIndex = audioProvider.getPreviousSongIndexInPlaylist();
      if (prevPlaylistIndex != null) {
        await audioProvider.playPlaylistSongAtIndex(prevPlaylistIndex, audioController);
      }
      // Playlist başı ise hiçbir şey yapma
    } else {
      // Normal mod - tüm şarkı listesinde geç
      int currentIndex = audioProvider.currentAudioIndex;
      if (currentIndex < 0) return;
      int prevIndex = currentIndex - 1;
      if (prevIndex < 0) prevIndex = audioProvider.audioFiles.length - 1;
      await audioProvider.playAtIndex(prevIndex, audioController);
    }
  }
}