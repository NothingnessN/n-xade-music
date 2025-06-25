import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AudioListItem extends StatelessWidget {
  final String title;
  final double duration;
  final VoidCallback onOptionPress;
  final VoidCallback onAudioPress;
  final bool isPlaying;
  final bool activeListItem;

  AudioListItem({
    required this.title,
    required this.duration,
    required this.onOptionPress,
    required this.onAudioPress,
    required this.isPlaying,
    required this.activeListItem,
  });

  String _getThumbnailText(String filename) => filename[0].toUpperCase();

  String _convertTime(double seconds) {
    final minutes = seconds ~/ 60;
    final secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Play/Pause butonu
              GestureDetector(
                onTap: onAudioPress,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getThumbnailText(title),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 15),
              
              // Şarkı bilgileri
              Expanded(
                child: GestureDetector(
                  onTap: onAudioPress,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: activeListItem && isPlaying
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: activeListItem && isPlaying
                              ? Color(0xFF660099)
                              : theme.textColor,
                        ),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _convertTime(duration),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 10),
              
              // Seçenekler butonu
              Container(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onOptionPress,
                  icon: Icon(
                    MdiIcons.dotsVertical,
                    color: theme.textColor,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        
        // Ayırıcı çizgi
        Container(
          height: 0.5,
          color: Colors.grey.withOpacity(0.3),
          margin: EdgeInsets.only(left: 85, right: 20),
        ),
      ],
    );
  }
}