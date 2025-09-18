import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';

class AudioListItem extends StatelessWidget {
  final AudioFile audio;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const AudioListItem({
    Key? key,
    required this.audio,
    required this.onTap,
    required this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final audioProvider = Provider.of<AudioProvider>(context);
    final isPlaying = audioProvider.isPlaying && audioProvider.currentAudio?.id == audio.id;
    final isActive = audioProvider.currentAudio?.id == audio.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive 
                    ? theme.accentColor.withOpacity(0.22)
                    : (theme.backgroundImage != null
                        ? theme.textColor.withOpacity(0.12)
                        : theme.textColor.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isActive ? theme.accentColor : theme.textColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audio.filename,
                      style: TextStyle(
                        color: isActive ? theme.accentColor : theme.textColor,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(audio.duration),
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.textColor.withOpacity(0.7),
                ),
                onPressed: onMoreTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(double durationMs) {
    // Duration milisaniye cinsinden geliyor, saniyeye çevir
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}