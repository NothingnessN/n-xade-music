import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/screen.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../widgets/audio_list_item.dart';

import 'package:nxade_music/l10n/app_localizations.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playList;

  PlaylistDetailScreen({required this.playList});

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Future<void> _playAudio(AudioFile audio, BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final audioController = Provider.of<AudioController>(context, listen: false);
    
    audioProvider.resetPlaybackState();
    
    // Playlist modunu başlat
    final playlistSongs = (widget.playList['audios'] as List<dynamic>?)
        ?.map((e) => AudioFile.fromJson(e))
        .toList() ?? [];
    
    final songIndexInPlaylist = playlistSongs.indexWhere((song) => song.id == audio.id);
    if (songIndexInPlaylist != -1) {
      audioProvider.startPlaylistMode(widget.playList, songIndexInPlaylist);
      
      // Ana şarkı listesindeki index'ini bul
      final audioIndex = audioProvider.audioFiles.indexWhere((a) => a.id == audio.id);
      if (audioIndex != -1) {
        audioProvider.updateState(
          currentAudioIndex: audioIndex,
          isPlaying: true,
        );
      }
      
      await audioController.play(audio.uri);
    }
  }

  void _showOptionsModal(AudioFile audio, Map<String, dynamic> playlist, BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.remove_circle_outline, color: Colors.red),
              title: Text(
                localizations.remove_from_playlist,
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                audioProvider.removeAudioFromPlaylist(playlist['id'], audio.id);
                Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.removed_from_playlist(audio.filename)
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final songCount = widget.playList['audios']?.length ?? 0;
    final localizations = AppLocalizations.of(context)!;

    return Screen(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
        children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.queue_music,
                      size: 40,
                      color: theme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: Hero(
                      tag: 'playlist_${widget.playList['id']}',
            child: Column(
              children: [
                          Text(
                    widget.playList['title'],
                    style: TextStyle(
                              fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                          const SizedBox(height: 8),
                Text(
                            '${songCount} ${localizations.songs}',
                  style: TextStyle(
                              fontSize: 16,
                              color: theme.textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                  ),
                ),
            if (widget.playList['audios']?.isNotEmpty ?? false)
                Expanded(
                  child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.playList['audios']?.length ?? 0,
                    itemBuilder: (context, index) {
                    final audio = AudioFile.fromJson(widget.playList['audios'][index]);
                      return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                        child: AudioListItem(
                        audio: audio,
                        onTap: () => _playAudio(audio, context),
                        onMoreTap: () => _showOptionsModal(audio, widget.playList, context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      ),
    );
  }
}