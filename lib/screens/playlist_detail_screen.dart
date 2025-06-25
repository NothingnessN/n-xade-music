import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/screen.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../widgets/audio_list_item.dart';
import '../widgets/option_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:akn_music/l10n/app_localizations.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playList;

  PlaylistDetailScreen({required this.playList});

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  AudioFile? _currentItem;
  bool _optionModalVisible = false;

  Future<void> _playAudio(AudioFile audio, BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final audioController = Provider.of<AudioController>(context, listen: false);
    
    // Önce durumu sıfırla
    audioProvider.resetPlaybackState();
    
    // Yeni şarkıyı ayarla
    final audioIndex = audioProvider.audioFiles.indexWhere((a) => a.id == audio.id);
    if (audioIndex != -1) {
      audioProvider.updateState(
        currentAudioIndex: audioIndex,
        isPlaying: true,
      );
    }
    
    // Çalmaya başla
    await audioController.play(audio.uri);
  }

  Future<void> _deleteFromPlaylist(AudioFile audio) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.removeAudioFromPlaylist(widget.playList['id'], audio.id);
    setState(() => _optionModalVisible = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${audio.filename} playlist\'ten kaldırıldı'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final songCount = widget.playList['audios']?.length ?? 0;

    return Screen(
      child: Stack(
        children: [
          Dialog(
            backgroundColor: theme.backgroundColor.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Hero(
                    tag: 'playlist_${widget.playList['id']}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.playList['title'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${songCount} ${AppLocalizations.of(context)!.songs}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: songCount,
                    itemBuilder: (context, index) {
                      final audio = AudioFile(
                        id: widget.playList['audios'][index]['id'],
                        filename: widget.playList['audios'][index]['filename'],
                        uri: widget.playList['audios'][index]['uri'],
                        duration: widget.playList['audios'][index]['duration'],
                      );
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: AudioListItem(
                          title: audio.filename,
                          duration: audio.duration,
                          onAudioPress: () => _playAudio(audio, context),
                          onOptionPress: () {
                            setState(() {
                              _currentItem = audio;
                              _optionModalVisible = true;
                            });
                          },
                          isPlaying: Provider.of<AudioProvider>(context)
                                  .isPlaying &&
                              Provider.of<AudioProvider>(context)
                                      .currentAudio
                                      ?.id ==
                                  audio.id,
                          activeListItem:
                              Provider.of<AudioProvider>(context)
                                      .currentAudio
                                      ?.id ==
                                  audio.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_optionModalVisible && _currentItem != null)
            GestureDetector(
              onTap: () => setState(() => _optionModalVisible = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: OptionModal(
                    filename: _currentItem!.filename,
                    options: [],
                    onClose: () => setState(() => _optionModalVisible = false),
                    onDeletePress: () => _deleteFromPlaylist(_currentItem!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}