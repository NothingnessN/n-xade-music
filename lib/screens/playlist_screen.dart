import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/playlist_input_modal.dart';
import 'playlist_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:akn_music/l10n/app_localizations.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool _modalVisible = false;
  String _newPlaylistName = '';

  Future<void> _createPlayList(String title) async {
    print('🎵 _createPlayList called with title: "$title"');
    if (title.isNotEmpty) {
      print('✅ Title is valid, creating playlist...');
      Provider.of<AudioProvider>(context, listen: false).createPlayList(title);
      setState(() {
        _modalVisible = false;
        _newPlaylistName = '';
      });
      print('✅ Playlist creation completed');
    } else {
      print('❌ Title is empty, cannot create playlist');
    }
  }

  void _handleBannerPress(Map<String, dynamic> item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: PlaylistDetailScreen(playList: item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.playlist_title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _modalVisible = true),
                    icon: Icon(
                      Icons.add_circle,
                      color: theme.accentColor,
                      size: 30,
                    ),
                    tooltip: AppLocalizations.of(context)!.add_playlist,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Playlist listesi
              Expanded(
                child: audioProvider.playList.isEmpty
                    ? SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.library_music,
                                  size: 50,
                                  color: theme.textColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.no_playlists,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textColor.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30),
                                  child: Text(
                                    AppLocalizations.of(context)!.click_to_create,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.textColor.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: audioProvider.playList.length,
                        itemBuilder: (context, index) {
                          final item = audioProvider.playList[index];
                          return Hero(
                            tag: 'playlist_${item['id']}',
                            child: Material(
                              color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: theme.backgroundColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: theme.accentColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(15),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: theme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                                    child: Icon(
                                      Icons.library_music,
                                      color: theme.accentColor,
                                      size: 30,
                                    ),
                                  ),
                                  title: Text(
                              item['title'],
                                    style: TextStyle(
                                      color: theme.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                            ),
                                  subtitle: Text(
                              item['audios'].length > 1
                                        ? '${item['audios'].length} şarkı'
                                        : '${item['audios'].length} şarkı',
                              style: TextStyle(
                                      color: theme.textColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                                  trailing: PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: theme.textColor,
                      ),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _showDeleteDialog(context, item);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 10),
                                            Text('Sil', style: TextStyle(color: Colors.red)),
                                          ],
                ),
              ),
                                    ],
                                  ),
                                  onTap: () => _handleBannerPress(item),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Yeni playlist ekleme butonu
              if (audioProvider.playList.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _modalVisible = true),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: theme.accentColor,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Yeni Playlist Ekle',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Playlist oluşturma modalı
              if (_modalVisible)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: PlaylistInputModal(
                  visible: _modalVisible,
                      onClose: () {
                        print('❌ Modal close button pressed');
                        setState(() {
                          _modalVisible = false;
                          _newPlaylistName = '';
                        });
                      },
                      onSubmit: (title) {
                        print('🎵 Modal submit button pressed with title: "$title"');
                        _createPlayList(title);
                      },
                  value: _newPlaylistName,
                      onChangeText: (value) {
                        print('📝 Modal text changed: "$value"');
                        setState(() {
                          _newPlaylistName = value;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> playlist) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        title: Text(
          'Playlist Sil',
          style: TextStyle(color: theme.textColor),
        ),
        content: Text(
          '${playlist['title']} playlist\'ini silmek istediğinizden emin misiniz?',
          style: TextStyle(color: theme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: theme.textColor.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AudioProvider>(context, listen: false)
                  .deletePlaylist(playlist['id']);
              Navigator.pop(context);
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}