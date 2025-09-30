import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:nxade_music/l10n/app_localizations.dart';

class PlaylistInputModal extends StatelessWidget {
  final String title;
  final Function(String) onSubmit;

  PlaylistInputModal({
    required this.title,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Görsel temalara uyum: arka planı hafif şeffaflaştır ve kenar çizgisi ekle
          color: (theme.backgroundImage != null)
              ? Colors.black.withOpacity(0.85)
              : theme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: theme.textColor.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: theme.textColor),
              decoration: InputDecoration(
                hintText: localizations.playlist_title,
                hintStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
                filled: true,
                fillColor: (theme.backgroundImage != null)
                    ? theme.textColor.withOpacity(0.08)
                    : theme.textColor.withOpacity(0.06),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.textColor.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) {
                onSubmit(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    localizations.cancel,
                    style: TextStyle(color: theme.textColor.withOpacity(0.9)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onSubmit(controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    localizations.create,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}