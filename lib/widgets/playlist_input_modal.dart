import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:akn_music/l10n/app_localizations.dart';

class PlaylistInputModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(String) onSubmit;
  final String value;
  final Function(String) onChangeText;

  PlaylistInputModal({
    required this.visible,
    required this.onClose,
    required this.onSubmit,
    required this.value,
    required this.onChangeText,
  });

  @override
  _PlaylistInputModalState createState() => _PlaylistInputModalState();
}

class _PlaylistInputModalState extends State<PlaylistInputModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
  }

  @override
  void didUpdateWidget(PlaylistInputModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    if (!widget.visible) return SizedBox.shrink();

    return Dialog(
      backgroundColor: theme.backgroundColor.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.new_playlist,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.accentColor,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              onChanged: (value) {
                print('📝 Text changed: "$value"');
                widget.onChangeText(value);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.playlist_title,
                hintStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.accentColor, width: 2),
                ),
              ),
              style: TextStyle(color: theme.textColor),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final text = _controller.text.trim();
                      print('🎵 Creating playlist with text: "$text"');
                      if (text.isNotEmpty) {
                        widget.onSubmit(text);
                      } else {
                        print('❌ Empty playlist name');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.playlist_title + ' ' + AppLocalizations.of(context)!.options),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add_playlist,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      print('❌ Modal closed');
                      widget.onClose();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.options,
                      style: TextStyle(color: theme.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}