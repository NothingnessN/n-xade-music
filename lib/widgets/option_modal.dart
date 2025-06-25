import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:akn_music/l10n/app_localizations.dart';

class OptionModal extends StatelessWidget {
  final String filename;
  final List<Map<String, dynamic>> options;
  final VoidCallback onClose;
  final VoidCallback onDeletePress;

  const OptionModal({
    Key? key,
    required this.filename,
    required this.options,
    required this.onClose,
    required this.onDeletePress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filename,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (options.isNotEmpty)
            ...options.map((option) => ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.add_to_playlist.replaceFirst('{}', option['title']),
                    style: TextStyle(color: theme.textColor),
                  ),
                  onTap: option['onPress'] as VoidCallback,
                )),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.delete_playlist,
              style: TextStyle(color: Colors.red),
            ),
            onTap: onDeletePress,
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.options,
              style: TextStyle(color: theme.textColor),
            ),
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}