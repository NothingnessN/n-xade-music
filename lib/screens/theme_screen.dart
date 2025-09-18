import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:nxade_music/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    final themeKeys = themeProvider.themes.keys.toList();
    final currentTheme = themeProvider.currentTheme;

    // Dinamik yazı rengi hesaplaması
    Color textColor = currentTheme.textColor;
    if (currentTheme.backgroundImage != null) {
      textColor = _calculateTextColorFromImage(currentTheme.backgroundImage!);
    } else if (currentTheme.gradientColors != null) {
      final endColor = currentTheme.gradientColors!.last;
      textColor = endColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Şeffaf arka plan
      body: Container(
        decoration: BoxDecoration(
          gradient: currentTheme.gradientColors != null
              ? LinearGradient(
                  colors: currentTheme.gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          image: currentTheme.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(currentTheme.backgroundImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    (textColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                    BlendMode.darken,
                  ),
                )
              : null,
          color: currentTheme.gradientColors == null &&
                  currentTheme.backgroundImage == null
              ? currentTheme.backgroundColor ?? Colors.grey[900] // Varsayılan koyu renk
              : null,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Kapat Butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.themes,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        shadows: [
                          Shadow(
                            color: currentTheme.accentColor.withOpacity(0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: textColor,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  AppLocalizations.of(context)!.free_themes,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              // Tema Kartları
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: themeKeys.length,
                  itemBuilder: (context, index) {
                    final themeKey = themeKeys[index];
                    final theme = themeProvider.themes[themeKey]!;
                    final isSelected = themeProvider.selectedThemeKey == themeKey;

                    // Kart için dinamik yazı rengi
                    Color cardTextColor = theme.textColor;
                    if (theme.backgroundImage != null) {
                      cardTextColor = _calculateTextColorFromImage(theme.backgroundImage!);
                    } else if (theme.gradientColors != null) {
                      final endColor = theme.gradientColors!.last;
                      cardTextColor = endColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
                    }

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        themeProvider.setTheme(themeKey);
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(
                                    color: theme.accentColor,
                                    width: 4,
                                  )
                                : Border.all(
                                    color: cardTextColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? theme.accentColor.withOpacity(0.7)
                                    : (cardTextColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
                                blurRadius: isSelected ? 12 : 6,
                                spreadRadius: isSelected ? 3 : 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            gradient: theme.gradientColors != null
                                ? LinearGradient(
                                    colors: theme.gradientColors!,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            image: theme.backgroundImage != null
                                ? DecorationImage(
                                    image: AssetImage(theme.backgroundImage!),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      (cardTextColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                            color: theme.gradientColors == null &&
                                    theme.backgroundImage == null
                                ? theme.backgroundColor ?? Colors.grey[900]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              // Tema Adı
                              Positioned(
                                top: 12,
                                left: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (cardTextColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8)),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (cardTextColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4)),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    theme.name[currentLocale] ??
                                        theme.name['en'] ??
                                        'Tema',
                                    style: TextStyle(
                                      color: cardTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // Seçili Tema İşareti
                              if (isSelected)
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.accentColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              theme.accentColor.withOpacity(0.6),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dil Değiştirme Bölümü
              Container(
                color: (textColor.computeLuminance() < 0.5 ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.7)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.language_selection,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // Sabit beyaz renk
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        'Türkçe',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: currentLocale == 'tr'
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                      onTap: () {
                        final newLocale = const Locale('tr');
                        localeProvider.setLocale(newLocale);
                      },
                    ),
                    ListTile(
                      title: Text(
                        'English',
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: currentLocale == 'en'
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                      onTap: () {
                        final newLocale = const Locale('en');
                        localeProvider.setLocale(newLocale);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _calculateTextColorFromImage(String imagePath) {
    // Gerçek bir parlaklık analizi için ImageProvider kullanılabilir
    return Colors.white; // Placeholder
  }
}