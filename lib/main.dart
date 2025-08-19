import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'providers/audio_provider.dart';
import 'providers/audio_controller.dart';
import 'providers/theme_provider.dart';
import 'providers/premium_provider.dart';
import 'screens/app_navigator.dart';
import 'screens/theme_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nxade_music/l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AdService.initialize() void döndürdüğü için await kullanmıyoruz
  AdService.initialize();
  
  // In-app purchase listener'ı başlat
  final Stream<List<PurchaseDetails>> purchaseUpdated = 
      InAppPurchase.instance.purchaseStream;
  
  purchaseUpdated.listen(_listenToPurchaseUpdated);
  
  runApp(const MyApp());
}

void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
  for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // Bekleyen ödeme
      print('🔄 Purchase pending: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      // Hata durumu
      print('❌ Purchase error: ${purchaseDetails.error?.message}');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
               purchaseDetails.status == PurchaseStatus.restored) {
      // Başarılı satın alma
      print('✅ Purchase successful: ${purchaseDetails.productID}');
      
      // Premium provider'a bildir
      // Bu işlem MyApp widget'ında yapılacak
      
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      // İptal edildi
      print('🚫 Purchase canceled: ${purchaseDetails.productID}');
    }
    
    if (purchaseDetails.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(
          create: (context) => AudioController(
            Provider.of<ThemeProvider>(context, listen: false),
          ),
        ),
      ],
      builder: (context, child) {
        // AudioController'a AudioProvider'ı burada bağla
        final audioController = Provider.of<AudioController>(context, listen: false);
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
        audioController.setAudioProvider(audioProvider);

        return Consumer3<ThemeProvider, LocaleProvider, PremiumProvider>(
          builder: (context, themeProvider, localeProvider, premiumProvider, _) {
            // İlk frame'den sonra izin isteğini tetikle
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                Provider.of<AudioProvider>(context, listen: false).ensurePermissionRequested();
              } catch (e) {
                print('❌ İzin isteği hatası: $e');
                // Hata durumunda uygulamayı durdurmak yerine sadece log yaz
              }
            });
            
            // Satın alma stream'ini premium provider'a bağla
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                final purchaseStream = InAppPurchase.instance.purchaseStream;
                purchaseStream.listen((purchaseDetailsList) {
                  for (final purchaseDetails in purchaseDetailsList) {
                    premiumProvider.handlePurchaseUpdate(purchaseDetails);
                  }
                });
              } catch (e) {
                print('❌ Satın alma stream hatası: $e');
              }
            });
            
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'N-Xade Music',
              theme: ThemeData(
                primaryColor: themeProvider.currentTheme.accentColor,
                scaffoldBackgroundColor: themeProvider.currentTheme.backgroundColor,
              ),
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('tr'),
              ],
              home: AppNavigator(),
              routes: {
                '/theme': (context) => ThemeScreen(),
              },
            );
          },
        );
      },
    );
  }
}