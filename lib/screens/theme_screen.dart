import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:akn_music/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeKeys = themeProvider.themes.keys.toList();
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.choose_theme,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeProvider.currentTheme.textColor,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: themeKeys.length,
                itemBuilder: (context, index) {
                  final themeKey = themeKeys[index];
                  final theme = themeProvider.themes[themeKey]!;
                  final isSelected = themeProvider.selectedThemeKey == themeKey;

                  return GestureDetector(
                    onTap: () => themeProvider.setTheme(themeKey),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Color(0xFF660099), width: 4)
                            : Border.all(color: Colors.transparent, width: 2),
                        gradient: theme.gradientColors != null
                            ? LinearGradient(colors: theme.gradientColors!)
                            : null,
                        color: theme.gradientColors == null
                            ? theme.backgroundColor
                            : null,
                        image: theme.backgroundImage != null
                            ? DecorationImage(
                                image: AssetImage(theme.backgroundImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          themeKey,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black45,
                                offset: Offset(-1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.options + ': '),
                DropdownButton<Locale>(
                  value: localeProvider.locale ?? Localizations.localeOf(context),
                  items: [
                    DropdownMenuItem(
                      value: const Locale('tr'),
                      child: Text(AppLocalizations.of(context)!.language_turkish),
                    ),
                    DropdownMenuItem(
                      value: const Locale('en'),
                      child: Text(AppLocalizations.of(context)!.language_english),
                    ),
                  ],
                  onChanged: (locale) {
                    if (locale != null) localeProvider.setLocale(locale);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}