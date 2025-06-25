import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class Screen extends StatelessWidget {
  final Widget child;

  Screen({required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    final isDarkTheme = theme.backgroundColor.computeLuminance() < 0.5;
    final barStyle = isDarkTheme ? Brightness.light : Brightness.dark;

    return Stack(
      children: [
        if (theme.gradientColors != null)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )
        else if (theme.backgroundImage != null)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(theme.backgroundImage!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(color: theme.backgroundColor),
        SafeArea(child: child),
      ],
    );
  }
}