import 'package:flutter/material.dart';

class AppTheme {
  final Color? backgroundColor;
  final Color textColor;
  final Color buttonColor;
  final Color accentColor;
  final List<Color>? gradientColors;
  final String? backgroundImage;
  final Map<String, String> name;

  AppTheme({
    this.backgroundColor,
    required this.textColor,
    required this.buttonColor,
    required this.accentColor,
    this.gradientColors,
    this.backgroundImage,
    required this.name,
  });
}