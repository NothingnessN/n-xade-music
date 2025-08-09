import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/premium_provider.dart';

class PremiumThemeCard extends StatelessWidget {
  final String themeKey;
  final VoidCallback? onTap;
  final VoidCallback? onPurchase;

  const PremiumThemeCard({
    Key? key,
    required this.themeKey,
    this.onTap,
    this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final premiumProvider = Provider.of<PremiumProvider>(context);
    final theme = themeProvider.themes[themeKey];
    
    if (theme == null) return SizedBox.shrink();

    final isPurchased = premiumProvider.isThemePurchased(themeKey);
    final isPremium = premiumProvider.isPremiumTheme(themeKey);
    final isLoading = premiumProvider.isLoading;

    return GestureDetector(
      onTap: isPurchased ? () {
        // Satın alınmış tema seçildiğinde
        print('🎨 Premium theme selected: $themeKey');
        themeProvider.setTheme(themeKey);
        if (onTap != null) onTap!();
      } : null,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Tema arka planı
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
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
                        )
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.palette,
                    size: 40,
                    color: theme.textColor,
                  ),
                ),
              ),
              
              // Premium badge
              if (isPremium && !isPurchased)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Kilit ikonu (premium ve satın alınmamış)
              if (isPremium && !isPurchased)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // Satın alınmış badge
              if (isPurchased)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // Fiyat etiketi (premium ve satın alınmamış)
              if (isPremium && !isPurchased)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      premiumProvider.getThemePrice(themeKey),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              // Loading overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              
              // Satın al butonu (premium ve satın alınmamış)
              if (isPremium && !isPurchased && !isLoading)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPurchase,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Satın Al',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 