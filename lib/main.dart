import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/audio_controller.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/app_navigator.dart';
import 'screens/theme_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:nxade_music/l10n/app_localizations.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Açılışı hızlandırmak için reklam başlatmayı frame sonrasına erteliyoruz
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AdService.initialize();
  });

  runApp(const MyApp());
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
        ChangeNotifierProvider(
          create: (context) => AudioController(
            Provider.of<ThemeProvider>(context, listen: false),
          ),
        ),
      ],
      builder: (context, child) {
        // AudioController'a AudioProvider'ı bağla
        final audioController = Provider.of<AudioController>(context, listen: false);
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
        audioController.setAudioProvider(audioProvider);

        return Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, _) {
            // İlk frame'den sonra izin isteğini tetikle
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                Provider.of<AudioProvider>(context, listen: false).ensurePermissionRequested();
              } catch (e) {
                print('❌ İzin isteği hatası: $e');
              }
            });

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'N-Xade Music',
              theme: ThemeData(
                primaryColor: themeProvider.currentTheme.accentColor,
                scaffoldBackgroundColor: themeProvider.currentTheme.backgroundColor ?? Colors.white,
                brightness: (themeProvider.currentTheme.backgroundImage != null)
                    ? Brightness.dark
                    : ((themeProvider.currentTheme.textColor.computeLuminance() < 0.5)
                        ? Brightness.dark
                        : Brightness.light),
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: themeProvider.currentTheme.textColor),
                  bodyMedium: TextStyle(color: themeProvider.currentTheme.textColor),
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: themeProvider.currentTheme.textColor,
                  systemOverlayStyle: (themeProvider.currentTheme.textColor.computeLuminance() < 0.5)
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark,
                ),
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
              home: const AppNavigator(),
              routes: {
                '/theme': (context) => const ThemeScreen(),
              },
            );
          },
        );
      },
    );
  }
}