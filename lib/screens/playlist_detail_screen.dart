import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/screen.dart';
import '../widgets/audio_list_item.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playList;

  const PlaylistDetailScreen({Key? key, required this.playList}) : super(key: key);

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  Future<void> _playAudio(AudioFile audio, BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final audioController = Provider.of<AudioController>(context, listen: false);

    audioProvider.resetPlaybackState();

    final playlistSongs = (widget.playList['songs'] as List<dynamic>?)
            ?.map((e) => AudioFile.fromJson(e))
            .toList() ??
        [];

    final songIndexInPlaylist = playlistSongs.indexWhere((song) => song.id == audio.id);
    if (songIndexInPlaylist != -1) {
      await audioProvider.startPlaylistMode(context, widget.playList, songIndexInPlaylist);
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
          color: (theme.backgroundImage != null)
              ? Colors.black.withOpacity(0.85)
              : theme.backgroundColor,
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
                      localizations.removed_from_playlist(audio.filename),
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
    final localizations = AppLocalizations.of(context)!;

    return Screen(
      child: SafeArea(
        child: Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            final playlist = audioProvider.playlists.firstWhere(
              (p) => p['id'] == widget.playList['id'],
              orElse: () => widget.playList,
            );
            final songCount = (playlist['songs'] as List<dynamic>?)?.length ?? 0;

            return Column(
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
                          tag: 'playlist_${playlist['id']}',
                          child: Column(
                            children: [
                              Text(
                                playlist['title'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$songCount ${localizations.songs}',
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
                Expanded(
                  child: songCount == 0
                      ? Center(
                          child: Text(
                            localizations.no_songs_in_playlist,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.textColor.withOpacity(0.7),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: songCount,
                          itemBuilder: (context, index) {
                            final audio = AudioFile.fromJson(playlist['songs'][index]);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AudioListItem(
                                audio: audio,
                                onTap: () => _playAudio(audio, context),
                                onMoreTap: () => _showOptionsModal(audio, playlist, context),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}