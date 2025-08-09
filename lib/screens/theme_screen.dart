import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/premium_provider.dart';
import 'package:provider/provider.dart';
import 'package:nxade_music/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../widgets/premium_theme_card.dart';

class ThemeScreen extends StatelessWidget {
  
  Future<void> _handlePurchase(BuildContext context, PremiumProvider premiumProvider, String themeKey) async {
    final success = await premiumProvider.purchaseTheme(themeKey);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.theme_purchased),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(premiumProvider.errorMessage ?? AppLocalizations.of(context)!.purchase_failed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final premiumProvider = Provider.of<PremiumProvider>(context);
    final themeKeys = themeProvider.themes.keys.toList();
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Premium olmayan temaları filtrele
    final freeThemeKeys = themeKeys.where((key) => !premiumProvider.isPremiumTheme(key)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.themes),
        actions: [
          // Dil değiştirme butonu
          IconButton(
            icon: Icon(
              (localeProvider.locale?.languageCode ?? 'tr') == 'tr' 
                ? Icons.language 
                : Icons.translate,
            ),
            onPressed: () {
              final currentLang = localeProvider.locale?.languageCode ?? 'tr';
              final newLocale = currentLang == 'tr' 
                ? const Locale('en') 
                : const Locale('tr');
              localeProvider.setLocale(newLocale);
            },
            tooltip: (localeProvider.locale?.languageCode ?? 'tr') == 'tr' 
              ? 'Switch to English' 
              : 'Türkçeye geç',
          ),
        ],
      ),
      body: Column(
        children: [
          // Premium temalar
          if (PremiumProvider.premiumThemeIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.premium_themes,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: PremiumProvider.premiumThemeIds.length,
                itemBuilder: (context, index) {
                  final themeKey = PremiumProvider.premiumThemeIds[index];
                  return PremiumThemeCard(
                    themeKey: themeKey,
                    onPurchase: () => _handlePurchase(context, premiumProvider, themeKey),
                    onTap: () {
                      // Premium tema seçildiğinde (eğer satın alınmışsa)
                      print('🎨 Premium theme selected: $themeKey');
                      themeProvider.setTheme(themeKey);
                    },
                  );
                },
              ),
            ),
          ],
          
          // Ücretsiz temalar
          if (freeThemeKeys.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.free_themes,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: freeThemeKeys.length,
                itemBuilder: (context, index) {
                  final themeKey = freeThemeKeys[index];
                  final theme = themeProvider.themes[themeKey]!;
                  final isSelected = themeProvider.selectedThemeKey == themeKey;

                  return GestureDetector(
                    onTap: () {
                      print('🎨 Theme selected: $themeKey');
                      themeProvider.setTheme(themeKey);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? theme.accentColor : Colors.transparent,
                          width: 3,
                        ),
                        image: theme.backgroundImage != null
                            ? DecorationImage(
                                image: AssetImage(theme.backgroundImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: theme.backgroundImage == null && theme.gradientColors == null ? theme.backgroundColor : null,
                        gradient: theme.gradientColors != null
                            ? LinearGradient(
                                colors: theme.gradientColors!,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (theme.backgroundImage == null && theme.gradientColors == null)
                            Center(
                              child: Icon(
                                Icons.palette,
                                size: 50,
                                color: theme.textColor,
                              ),
                            ),
                          if (theme.gradientColors != null)
                            Center(
                              child: Icon(
                                Icons.gradient,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}