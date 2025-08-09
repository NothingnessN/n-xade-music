import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    
    if (savedLocale != null) {
      // Kullanıcı daha önce dil seçimi yapmışsa, onu kullan
      _locale = Locale(savedLocale);
      print('🌍 Saved locale loaded: $savedLocale');
    } else {
      // İlk kurulum - cihaz diline göre otomatik seçim
      final deviceLocale = ui.window.locale;
      print('🌍 Device locale detected: ${deviceLocale.languageCode}_${deviceLocale.countryCode}');
      
      if (deviceLocale.languageCode == 'tr') {
        // Türk kullanıcılar için Türkçe
        _locale = const Locale('tr');
        print('🇹🇷 Turkish user detected, setting Turkish');
      } else {
        // Diğer tüm bölgeler için İngilizce
        _locale = const Locale('en');
        print('🇺🇸 Non-Turkish user detected, setting English');
      }
      
      // Otomatik seçilen dili kaydet
      await prefs.setString('locale', _locale!.languageCode);
      print('💾 Auto-selected locale saved: ${_locale!.languageCode}');
    }
    
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    print('🌍 Locale manually changed to: ${locale.languageCode}');
  }

  void clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('locale');
    print('🌍 Locale preference cleared');
  }
} 