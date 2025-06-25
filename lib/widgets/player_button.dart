import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class PlayerButton extends StatelessWidget {
  final String iconType;
  final VoidCallback onPress;
  final double size;

  const PlayerButton({
    Key? key,
    required this.iconType,
    required this.onPress,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    IconData icon;
    switch (iconType) {
      case 'PLAY':
        icon = MdiIcons.play;
        break;
      case 'PAUSE':
        icon = MdiIcons.pause;
        break;
      case 'NEXT':
        icon = MdiIcons.skipNext;
        break;
      case 'PREV':
        icon = MdiIcons.skipPrevious;
        break;
      default:
        icon = MdiIcons.play;
    }

    return IconButton(
      icon: Icon(icon, size: size, color: theme.accentColor),
      onPressed: onPress,
    );
  }
}