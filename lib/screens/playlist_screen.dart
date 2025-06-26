import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/screen.dart';
import '../widgets/playlist_input_modal.dart';
import 'package:akn_music/l10n/app_localizations.dart';
import '../screens/playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final localizations = AppLocalizations.of(context)!;

    return Screen(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.playlist_title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _showCreatePlaylistModal(context),
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: audioProvider.playlists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.queue_music,
                              size: 64,
                              color: theme.textColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.no_playlists,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.click_to_create,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: audioProvider.playlists.length,
                        itemBuilder: (context, index) {
                          final item = audioProvider.playlists[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.queue_music,
                                  color: theme.accentColor,
                                ),
                              ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textColor,
                                ),
                              ),
                              subtitle: Text(
                                '${item['audios'].length} ${localizations.songs}',
                                style: TextStyle(
                                  color: theme.textColor.withOpacity(0.7),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: theme.textColor,
                                ),
                                onPressed: () => _showPlaylistOptionsModal(context, item),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDetailScreen(playList: item),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlaylistModal(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaylistInputModal(
        title: localizations.new_playlist,
        onSubmit: (title) {
          if (title.isNotEmpty) {
            Provider.of<AudioProvider>(context, listen: false)
                .createPlayList(title);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showPlaylistOptionsModal(BuildContext context, Map<String, dynamic> playlist) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        title: Text(
          localizations.delete_playlist_title,
          style: TextStyle(color: theme.textColor),
        ),
        content: Text(
          localizations.delete_playlist_message(playlist['title']),
          style: TextStyle(color: theme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancel,
              style: TextStyle(color: theme.textColor),
            ),
          ),
          TextButton(
            onPressed: () {
              audioProvider.deletePlaylist(playlist['id']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    localizations.playlist_deleted(playlist['title']),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              localizations.delete_playlist,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}