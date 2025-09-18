import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nxade_music/models/theme_model.dart';

class ThemeProvider with ChangeNotifier {
  String _selectedThemeKey = 'gradient1';
  Color _accentColor = const Color(0xFF6200EA);

  final Map<String, AppTheme> themes = {
    // Gradyan Temalar (20 adet)
    'gradient1': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF6200EA),
        Color(0xFFBB86FC),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFBB86FC),
      accentColor: const Color(0xFFBB86FC),
      name: {'en': 'Purple Haze', 'tr': 'Mor Sis'},
    ),
    'gradient2': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF0288D1),
        Color(0xFF4FC3F7),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF4FC3F7),
      accentColor: const Color(0xFF4FC3F7),
      name: {'en': 'Ocean Breeze', 'tr': 'Okyanus Esintisi'},
    ),
    'gradient3': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFD81B60),
        Color(0xFFFF8A80),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFFF8A80),
      accentColor: const Color(0xFFFF8A80),
      name: {'en': 'Crimson Glow', 'tr': 'Kızıl Parıltı'},
    ),
    'gradient4': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF388E3C),
        Color(0xFF81C784),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF81C784),
      accentColor: const Color(0xFF81C784),
      name: {'en': 'Forest Mist', 'tr': 'Orman Sisi'},
    ),
    'gradient5': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFFFA726),
        Color(0xFFFFE082),
      ],
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFFFE082),
      accentColor: const Color(0xFFFFE082),
      name: {'en': 'Sunset Glow', 'tr': 'Gün Batımı Parıltısı'},
    ),
    'gradient6': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF1976D2),
        Color(0xFF42A5F5),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF42A5F5),
      accentColor: const Color(0xFF42A5F5),
      name: {'en': 'Sky Blue', 'tr': 'Gökyüzü Mavisi'},
    ),
    'gradient7': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFE91E63),
        Color(0xFFF06292),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFF06292),
      accentColor: const Color(0xFFF06292),
      name: {'en': 'Pink Blossom', 'tr': 'Pembe Çiçek'},
    ),
    'gradient8': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF7B1FA2),
        Color(0xFFAB47BC),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFAB47BC),
      accentColor: const Color(0xFFAB47BC),
      name: {'en': 'Violet Dream', 'tr': 'Menekşe Rüyası'},
    ),
    'gradient9': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF4CAF50),
        Color(0xFF80DEEA),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF80DEEA),
      accentColor: const Color(0xFF80DEEA),
      name: {'en': 'Emerald Wave', 'tr': 'Zümrüt Dalga'},
    ),
    'gradient10': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFFF5722),
        Color(0xFFFFB300),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFFFB300),
      accentColor: const Color(0xFFFFB300),
      name: {'en': 'Fiery Amber', 'tr': 'Ateşli Kehribar'},
    ),
    'gradient11': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF0288D1),
        Color(0xFF26C6DA),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF26C6DA),
      accentColor: const Color(0xFF26C6DA),
      name: {'en': 'Aqua Pulse', 'tr': 'Aqua Nabız'},
    ),
    'gradient12': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFAD1457),
        Color(0xFFF06292),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFF06292),
      accentColor: const Color(0xFFF06292),
      name: {'en': 'Rose Quartz', 'tr': 'Pembe Kuvars'},
    ),
    'gradient13': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF8E24AA),
        Color(0xFFE1BEE7),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFE1BEE7),
      accentColor: const Color(0xFFE1BEE7),
      name: {'en': 'Amethyst Glow', 'tr': 'Ametist Parıltısı'},
    ),
    'gradient14': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF455A64),
        Color(0xFF90A4AE),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF90A4AE),
      accentColor: const Color(0xFF90A4AE),
      name: {'en': 'Slate Serenity', 'tr': 'Arduvaz Huzuru'},
    ),
    'gradient15': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFFBC02D),
        Color(0xFFFFE082),
      ],
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFFFE082),
      accentColor: const Color(0xFFFFE082),
      name: {'en': 'Golden Dawn', 'tr': 'Altın Şafak'},
    ),
    'gradient16': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF1A237E),
        Color(0xFF3F51B5),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF3F51B5),
      accentColor: const Color(0xFF3F51B5),
      name: {'en': 'Midnight Blue', 'tr': 'Gece Mavisi'},
    ),
    'gradient17': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF00695C),
        Color(0xFF4DB6AC),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF4DB6AC),
      accentColor: const Color(0xFF4DB6AC),
      name: {'en': 'Teal Tide', 'tr': 'Turkuaz Dalga'},
    ),
    'gradient18': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF6D4C41),
        Color(0xFFD7CCC8),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFD7CCC8),
      accentColor: const Color(0xFFD7CCC8),
      name: {'en': 'Coffee Cream', 'tr': 'Kahve Kreması'},
    ),
    'gradient19': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFFEF5350),
        Color(0xFFF06292),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFF06292),
      accentColor: const Color(0xFFF06292),
      name: {'en': 'Coral Sunset', 'tr': 'Mercan Gün Batımı'},
    ),
    'gradient20': AppTheme(
      backgroundColor: null,
      gradientColors: const [
        Color(0xFF9C27B0),
        Color(0xFFE1BEE7),
      ],
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFE1BEE7),
      accentColor: const Color(0xFFE1BEE7),
      name: {'en': 'Lavender Bliss', 'tr': 'Lavanta Mutluluğu'},
    ),
    // Solid Renk Temalar (15 adet)
    'light': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      name: {'en': 'Light', 'tr': 'Açık'},
    ),
    'dark': AppTheme(
      backgroundColor: const Color(0xFF121212),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFBB86FC),
      accentColor: const Color(0xFFBB86FC),
      name: {'en': 'Dark', 'tr': 'Koyu'},
    ),
    'blue': AppTheme(
      backgroundColor: const Color(0xFF2196F3),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF1976D2),
      accentColor: const Color(0xFF1976D2),
      name: {'en': 'Deep Blue', 'tr': 'Derin Mavi'},
    ),
    'red': AppTheme(
      backgroundColor: const Color(0xFFF44336),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFD32F2F),
      accentColor: const Color(0xFFD32F2F),
      name: {'en': 'Fiery Red', 'tr': 'Ateş Kırmızısı'},
    ),
    'green': AppTheme(
      backgroundColor: const Color(0xFF4CAF50),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF388E3C),
      accentColor: const Color(0xFF388E3C),
      name: {'en': 'Lush Green', 'tr': 'Canlı Yeşil'},
    ),
    'yellow': AppTheme(
      backgroundColor: const Color(0xFFFFEB3B),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFFBC02D),
      accentColor: const Color(0xFFFBC02D),
      name: {'en': 'Bright Yellow', 'tr': 'Parlak Sarı'},
    ),
    'purple': AppTheme(
      backgroundColor: const Color(0xFF9C27B0),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF7B1FA2),
      accentColor: const Color(0xFF7B1FA2),
      name: {'en': 'Vivid Purple', 'tr': 'Canlı Mor'},
    ),
    'orange': AppTheme(
      backgroundColor: const Color(0xFFFF9800),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFF57C00),
      accentColor: const Color(0xFFF57C00),
      name: {'en': 'Zesty Orange', 'tr': 'Canlı Turuncu'},
    ),
    'pink': AppTheme(
      backgroundColor: const Color(0xFFE91E63),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFD81B60),
      accentColor: const Color(0xFFD81B60),
      name: {'en': 'Bold Pink', 'tr': 'Cesur Pembe'},
    ),
    'teal': AppTheme(
      backgroundColor: const Color(0xFF26A69A),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF00897B),
      accentColor: const Color(0xFF00897B),
      name: {'en': 'Cool Teal', 'tr': 'Serin Turkuaz'},
    ),
    'grey': AppTheme(
      backgroundColor: const Color(0xFF607D8B),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF455A64),
      accentColor: const Color(0xFF455A64),
      name: {'en': 'Sleek Grey', 'tr': 'Şık Gri'},
    ),
    'amber': AppTheme(
      backgroundColor: const Color(0xFFFFC107),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFFFA000),
      accentColor: const Color(0xFFFFA000),
      name: {'en': 'Warm Amber', 'tr': 'Sıcak Kehribar'},
    ),
    'cyan': AppTheme(
      backgroundColor: const Color(0xFF00BCD4),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF0097A7),
      accentColor: const Color(0xFF0097A7),
      name: {'en': 'Fresh Cyan', 'tr': 'Taze Camgöbeği'},
    ),
    'lime': AppTheme(
      backgroundColor: const Color(0xFFCDDC39),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFFAFB42B),
      accentColor: const Color(0xFFAFB42B),
      name: {'en': 'Vibrant Lime', 'tr': 'Canlı Limon'},
    ),
    'indigo': AppTheme(
      backgroundColor: const Color(0xFF3F51B5),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF303F9F),
      accentColor: const Color(0xFF303F9F),
      name: {'en': 'Royal Indigo', 'tr': 'Kraliyet Çivit'},
    ),
    // Resimli Temalar (5 adet)
    'image1': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      backgroundImage: 'assets/1.png',
      name: {'en': 'Beach-1', 'tr': 'Sahil-1'},
    ),
    'image2': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      backgroundImage: 'assets/2.png',
      name: {'en': 'Beach-2', 'tr': 'Sahil-2'},
    ),
    'image3': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF000000),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      backgroundImage: 'assets/3.png',
      name: {'en': 'Forest', 'tr': 'Orman'},
    ),
    'image4': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      backgroundImage: 'assets/4.png',
      name: {'en': 'Space and Stars', 'tr': 'Uzay ve Yıldızlar'},
    ),
    'image5': AppTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFF6200EA),
      accentColor: const Color(0xFF6200EA),
      backgroundImage: 'assets/5.png',
      name: {'en': 'Mystery of the Sky', 'tr': 'Gökyüzünün Gizemi'},
    ),
  };

  String get selectedThemeKey => _selectedThemeKey;
  AppTheme get currentTheme => themes[_selectedThemeKey]!;
  Color get accentColor => _accentColor;

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
      print('🎨 Tema ayarlanıyor: $themeKey');
      print('🎨 Tema detayları: ${themes[themeKey]}');
      _selectedThemeKey = themeKey;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedTheme', themeKey);
      print('🎨 Tema kaydedildi: $themeKey');
      notifyListeners();
      print('🎨 Dinleyiciler bilgilendirildi');
    } else {
      print('❌ Tema bulunamadı: $themeKey');
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
    Map<String, String>? name,
  }) {
    return AppTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      buttonColor: buttonColor ?? this.buttonColor,
      accentColor: accentColor ?? this.accentColor,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      name: name ?? this.name,
    );
  }
}