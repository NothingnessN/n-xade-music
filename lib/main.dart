/*
 * AKN Music Player - A simple, elegant and open source music player
 * Copyright (C) 2024 AKN Music Player
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'providers/audio_controller.dart';
import 'providers/theme_provider.dart';
import 'screens/app_navigator.dart';
import 'screens/theme_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:akn_music/l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        // AudioController'a AudioProvider'ı burada bağla
        final audioController = Provider.of<AudioController>(context, listen: false);
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
        audioController.setAudioProvider(audioProvider);

        return Consumer2<ThemeProvider, LocaleProvider>(
          builder: (context, themeProvider, localeProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'AKN Music',
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