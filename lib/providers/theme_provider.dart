import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color buttonColor;
  final Color accentColor;
  final List<Color>? gradientColors;
  final String? backgroundImage;

  AppTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.buttonColor,
    required this.accentColor,
    this.gradientColors,
    this.backgroundImage,
  });
}

class ThemeProvider with ChangeNotifier {
  final Map<String, AppTheme> themes = {
    'light': AppTheme(
      backgroundColor: Color(0xFFFFFFFF), // Tam beyaz
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
    ),
    'dark': AppTheme(
      backgroundColor: Color(0xFF000000),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFFF8CFF),
      accentColor: Color(0xFFFF8CFF),
    ),
    'solidRed': AppTheme(
      backgroundColor: Color(0xFFFF0000),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFFF3333),
      accentColor: Color(0xFFFF3333),
    ),
    'solidBlue': AppTheme(
      backgroundColor: Color(0xFF0000FF),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF3333FF),
      accentColor: Color(0xFF3333FF),
    ),
    'solidGreen': AppTheme(
      backgroundColor: Color(0xFF00FF00),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFF33FF33),
      accentColor: Color(0xFF33FF33),
    ),
    'solidPurple': AppTheme(
      backgroundColor: Color(0xFF800080),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF9933CC),
      accentColor: Color(0xFF9933CC),
    ),
    'solidOrange': AppTheme(
      backgroundColor: Color(0xFFFFA500),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFFFFB333),
      accentColor: Color(0xFFFFB333),
    ),
    'solidPink': AppTheme(
      backgroundColor: Color(0xFFFFC0CB),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFFFF99CC),
      accentColor: Color(0xFFFF99CC),
    ),
    'solidYellow': AppTheme(
      backgroundColor: Color(0xFFFFFF00),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFFFFF033),
      accentColor: Color(0xFFFFF033),
    ),
    'solidCyan': AppTheme(
      backgroundColor: Color(0xFF00FFFF),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFF33FFFF),
      accentColor: Color(0xFF33FFFF),
    ),
    'solidBrown': AppTheme(
      backgroundColor: Color(0xFF8B4513),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFA0522D),
      accentColor: Color(0xFFA0522D),
    ),
    'solidGray': AppTheme(
      backgroundColor: Color(0xFF808080),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF999999),
      accentColor: Color(0xFF999999),
    ),
    'solidLime': AppTheme(
      backgroundColor: Color(0xFF32CD32),
      textColor: Color(0xFF000000),
      buttonColor: Color(0xFF66FF66),
      accentColor: Color(0xFF66FF66),
    ),
    'solidTeal': AppTheme(
      backgroundColor: Color(0xFF008080),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF33CCCC),
      accentColor: Color(0xFF33CCCC),
    ),
    'solidIndigo': AppTheme(
      backgroundColor: Color(0xFF4B0082),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF6633CC),
      accentColor: Color(0xFF6633CC),
    ),
    'solidMaroon': AppTheme(
      backgroundColor: Color(0xFF800000),
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFCC3333),
      accentColor: Color(0xFFCC3333),
    ),
    
    // Resim Temaları
    'image1': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
      backgroundImage: 'assets/1.png',
    ),
    'image2': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
      backgroundImage: 'assets/2.png',
    ),
    'image3': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
      backgroundImage: 'assets/3.png',
    ),
    'image4': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
      backgroundImage: 'assets/4.png',
    ),
    'image5': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF660099),
      accentColor: Color(0xFF660099),
      backgroundImage: 'assets/5.png',
    ),
    
    // Gradyan Temaları (15 adet)
    'gradient1': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF9932CC),
      accentColor: Color(0xFF9932CC),
      gradientColors: [Color(0xFF660099), Color(0xFFFF8CFF)],
    ),
    'gradient2': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF4CAF50),
      accentColor: Color(0xFF4CAF50),
      gradientColors: [Color(0xFF2E7D32), Color(0xFF81C784)],
    ),
    'gradient3': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF2196F3),
      accentColor: Color(0xFF2196F3),
      gradientColors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
    ),
    'gradient4': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFFF5722),
      accentColor: Color(0xFFFF5722),
      gradientColors: [Color(0xFFD84315), Color(0xFFFF8A65)],
    ),
    'gradient5': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF9C27B0),
      accentColor: Color(0xFF9C27B0),
      gradientColors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
    ),
    'gradient6': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFFF9800),
      accentColor: Color(0xFFFF9800),
      gradientColors: [Color(0xFFF57C00), Color(0xFFFFB74D)],
    ),
    'gradient7': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF607D8B),
      accentColor: Color(0xFF607D8B),
      gradientColors: [Color(0xFF455A64), Color(0xFF90A4AE)],
    ),
    'gradient8': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF795548),
      accentColor: Color(0xFF795548),
      gradientColors: [Color(0xFF5D4037), Color(0xFFBCAAA4)],
    ),
    'gradient9': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF009688),
      accentColor: Color(0xFF009688),
      gradientColors: [Color(0xFF00695C), Color(0xFF80CBC4)],
    ),
    'gradient10': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF673AB7),
      accentColor: Color(0xFF673AB7),
      gradientColors: [Color(0xFF512DA8), Color(0xFFB39DDB)],
    ),
    'gradient11': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF3F51B5),
      accentColor: Color(0xFF3F51B5),
      gradientColors: [Color(0xFF303F9F), Color(0xFF9FA8DA)],
    ),
    'gradient12': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF00BCD4),
      accentColor: Color(0xFF00BCD4),
      gradientColors: [Color(0xFF0097A7), Color(0xFF80DEEA)],
    ),
    'gradient13': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFF8BC34A),
      accentColor: Color(0xFF8BC34A),
      gradientColors: [Color(0xFF689F38), Color(0xFFC5E1A5)],
    ),
    'gradient14': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFFFEB3B),
      accentColor: Color(0xFFFFEB3B),
      gradientColors: [Color(0xFFFBC02D), Color(0xFFFFF59D)],
    ),
    'gradient15': AppTheme(
      backgroundColor: Colors.transparent,
      textColor: Color(0xFFFFFFFF),
      buttonColor: Color(0xFFE91E63),
      accentColor: Color(0xFFE91E63),
      gradientColors: [Color(0xFFC2185B), Color(0xFFF8BBD9)],
    ),
  };

  String _selectedThemeKey = 'light';
  Color? _accentColor;

  String get selectedThemeKey => _selectedThemeKey;
  AppTheme get currentTheme => themes[_selectedThemeKey]!.copyWith(
        accentColor: _accentColor ?? themes[_selectedThemeKey]!.accentColor,
      );

  ThemeProvider() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selectedTheme');
    final savedAccent = prefs.getString('accentColor');

    if (savedTheme != null && themes.containsKey(savedTheme)) {
      _selectedThemeKey = savedTheme;
    }
    if (savedAccent != null) {
      _accentColor = Color(int.parse(savedAccent.replaceFirst('#', '0xFF')));
    }
    notifyListeners();
  }

  Future<void> setTheme(String themeKey) async {
    if (themes.containsKey(themeKey)) {
      _selectedThemeKey = themeKey;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedTheme', themeKey);
      notifyListeners();
    }
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', color.value.toRadixString(16));
    notifyListeners();
  }
}

extension on AppTheme {
  AppTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? buttonColor,
    Color? accentColor,
    List<Color>? gradientColors,
    String? backgroundImage,
  }) {
    return AppTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      buttonColor: buttonColor ?? this.buttonColor,
      accentColor: accentColor ?? this.accentColor,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}