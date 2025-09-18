import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/theme_model.dart'; // Added import for AppTheme

class Screen extends StatelessWidget {
  final Widget child;

  const Screen({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    // Determine if the theme is dark based on backgroundColor or gradientColors
    final isDarkTheme = _isDarkTheme(theme);
    final barStyle = isDarkTheme ? Brightness.light : Brightness.dark;

    // Set the system UI overlay style (status bar)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: barStyle,
      statusBarBrightness: barStyle,
    ));

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
          Container(color: theme.backgroundColor ?? Colors.white),
        SafeArea(child: child),
      ],
    );
  }

  bool _isDarkTheme(AppTheme theme) {
    if (theme.backgroundColor != null) {
      return theme.backgroundColor!.computeLuminance() < 0.5;
    } else if (theme.gradientColors != null && theme.gradientColors!.isNotEmpty) {
      return theme.gradientColors!.first.computeLuminance() < 0.5;
    }
    // Fallback for cases where both are null (e.g., image themes)
    return false; // Default to light theme for image-based themes
  }
}