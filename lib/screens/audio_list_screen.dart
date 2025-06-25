import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/audio_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/option_modal.dart';
import '../widgets/screen.dart';
import '../widgets/audio_list_item.dart';
import 'dart:io';
import 'package:akn_music/l10n/app_localizations.dart';

class AudioListScreen extends StatelessWidget {
  const AudioListScreen({Key? key}) : super(key: key);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.all_audios,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  Row(
                    children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/theme'),
                    icon: Icon(
                      Icons.color_lens,
                      color: theme.accentColor,
                    ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: audioProvider.audioFiles.length,
                  itemBuilder: (context, index) {
                    final audio = audioProvider.audioFiles[index];
                    return AudioListItem(
                      title: audio.filename,
                      duration: audio.duration,
                      onAudioPress: () async {
                        await audioProvider.playAtIndex(index, audioController);
                      },
                      onOptionPress: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => OptionModal(
                            filename: audio.filename,
                            options: audioProvider.playList.isEmpty
                                ? []
                                : audioProvider.playList
                                    .map((playlist) => {
                                          'title': playlist['title'] as String,
                                          'onPress': () {
                                            audioProvider.addAudioToPlaylist(playlist['id'], audio);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    Icon(Icons.check_circle, color: Colors.white),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        '${audio.filename} ${playlist['title']} playlist\'ine eklendi',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: theme.accentColor,
                                                duration: Duration(seconds: 2),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          },
                                        })
                                .toList(),
                            onClose: () => Navigator.pop(context),
                            onDeletePress: () async {
                              // Silme onayı dialogu
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: theme.backgroundColor,
                                  title: Text(
                                    'Şarkıyı Sil',
                                    style: TextStyle(color: theme.textColor),
                                  ),
                                  content: Text(
                                    '${audio.filename} dosyasını cihazdan silmek istediğinizden emin misiniz?',
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
                                      onPressed: () async {
                                        Navigator.pop(context); // Dialog'u kapat
                                        Navigator.pop(context); // Modal'ı kapat
                                        
                                        try {
                              final file = File(audio.uri);
                              await file.delete();
                              await audioProvider.getAudioFiles();
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.white),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text('${audio.filename} silindi'),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Dosya silinirken hata oluştu'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                      isPlaying: audioProvider.isPlaying &&
                          audioProvider.currentAudio?.id == audio.id,
                      activeListItem: audioProvider.currentAudio?.id == audio.id,
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
}