import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nxade_music/l10n/app_localizations.dart';

class PremiumProvider with ChangeNotifier {
  static const String _purchasedThemesKey = 'purchased_themes';
  
  // Premium tema ID'leri - sadece image1-5 (1.png, 2.png, 3.png, 4.png, 5.png)
  static const List<String> premiumThemeIds = [
    'image1', 'image2', 'image3', 'image4', 'image5'
  ];
  
  // Play Store ürün ID'leri - özel isimlerle
  static const Map<String, String> productIds = {
    'image1': 'premium_theme_sahil_1',      // Sahil-1
    'image2': 'premium_theme_sahil_2',      // Sahil-2
    'image3': 'premium_theme_orman',        // Orman
    'image4': 'premium_theme_uzay_yildizlar', // Uzay Ve Yıldızlar
    'image5': 'premium_theme_gokyuzu_gizemi', // Gökyüzünün Gizemi
  };
  
  // Tema isimleri (dil bazlı)
  static const Map<String, Map<String, String>> themeNames = {
    'tr': {
      'image1': 'Sahil-1',
      'image2': 'Sahil-2',
      'image3': 'Orman',
      'image4': 'Uzay Ve Yıldızlar',
      'image5': 'Gökyüzünün Gizemi',
    },
    'en': {
      'image1': 'Beach-1',
      'image2': 'Beach-2',
      'image3': 'Forest',
      'image4': 'Space and Stars',
      'image5': 'Mystery of the Sky',
    },
  };
  
  Set<String> _purchasedThemes = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Set<String> get purchasedThemes => _purchasedThemes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  PremiumProvider() {
    _loadPurchasedThemes();
  }
  
  // Tema satın alınmış mı kontrol et
  bool isThemePurchased(String themeKey) {
    return _purchasedThemes.contains(themeKey);
  }
  
  // Premium tema mı kontrol et
  bool isPremiumTheme(String themeKey) {
    return premiumThemeIds.contains(themeKey);
  }
  
  // Tema ismini al (dil bazlı)
  String getThemeName(String themeKey, String languageCode) {
    return themeNames[languageCode]?[themeKey] ?? themeNames['en']?[themeKey] ?? themeKey;
  }
  
  // Tema fiyatını al (dil bazlı fiyatlandırma)
  String getThemePrice(String themeKey, String languageCode) {
    // Türkiye için 10 TL, diğer ülkeler için 1 USD
    if (languageCode == 'tr') {
      return '10 TL';
    } else {
      return '\$1.00';
    }
  }
  
  // Tema açıklamasını al (dil bazlı)
  String getThemeDescription(String themeKey, String languageCode) {
    final themeName = getThemeName(themeKey, languageCode);
    if (languageCode == 'tr') {
      return '$themeName teması - Özel tasarım premium tema';
    } else {
      return '$themeName Theme - Premium custom designed theme';
    }
  }
  
  // Satın alınmış temaları yükle
  Future<void> _loadPurchasedThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedThemesJson = prefs.getString(_purchasedThemesKey);
      
      if (purchasedThemesJson != null) {
        final List<dynamic> themesList = jsonDecode(purchasedThemesJson);
        _purchasedThemes = Set<String>.from(themesList);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Satın alınmış temalar yüklenirken hata: $e';
      notifyListeners();
    }
  }
  
  // Satın alınmış temaları kaydet
  Future<void> _savePurchasedThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasedThemesJson = jsonEncode(_purchasedThemes.toList());
      await prefs.setString(_purchasedThemesKey, purchasedThemesJson);
    } catch (e) {
      _errorMessage = 'Satın alınmış temalar kaydedilirken hata: $e';
      notifyListeners();
    }
  }
  
  // Tema satın alma işlemi
  Future<bool> purchaseTheme(String themeKey) async {
    if (!isPremiumTheme(themeKey)) {
      _errorMessage = 'Bu tema premium değil';
      notifyListeners();
      return false;
    }
    
    if (isThemePurchased(themeKey)) {
      _errorMessage = 'Bu tema zaten satın alınmış';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final productId = productIds[themeKey];
      if (productId == null) {
        _errorMessage = 'Ürün ID bulunamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Play Store'dan ürün bilgilerini al
      final ProductDetailsResponse response = 
          await InAppPurchase.instance.queryProductDetails({productId});
      
      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = 'Ürün Play Store\'da bulunamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (response.productDetails.isEmpty) {
        _errorMessage = 'Ürün detayları alınamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Satın alma işlemini başlat
      final PurchaseParam purchaseParam = 
          PurchaseParam(productDetails: response.productDetails.first);
      
      final bool success = await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        // Satın alma başarılı - tema açılacak
        _purchasedThemes.add(themeKey);
        await _savePurchasedThemes();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Satın alma işlemi başlatılamadı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
    } catch (e) {
      _errorMessage = 'Satın alma hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Satın alma işlemini tamamla (callback'ten çağrılır)
  void completePurchase(PurchaseDetails purchaseDetails) {
    try {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Ürün ID'sinden tema key'ini bul
        final themeKey = productIds.entries
            .firstWhere((entry) => entry.value == purchaseDetails.productID)
            .key;
        
        print('🎉 Premium theme purchased: $themeKey');
        _purchasedThemes.add(themeKey);
        _savePurchasedThemes();
        _errorMessage = null;
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _errorMessage = 'Ödeme hatası: ${purchaseDetails.error?.message ?? "Bilinmeyen hata"}';
        print('❌ Purchase error: $_errorMessage');
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _errorMessage = 'Ödeme iptal edildi';
        print('🚫 Purchase canceled');
      } else if (purchaseDetails.status == PurchaseStatus.pending) {
        print('🔄 Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        // Restore edilen satın alma
        final themeKey = productIds.entries
            .firstWhere((entry) => entry.value == purchaseDetails.productID)
            .key;
        
        print('🔄 Premium theme restored: $themeKey');
        _purchasedThemes.add(themeKey);
        _savePurchasedThemes();
        _errorMessage = null;
      }
    } catch (e) {
      print('❌ Complete purchase error: $e');
      _errorMessage = 'Satın alma işlemi tamamlanırken hata oluştu';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Satın alma işlemini tamamla (main.dart'tan çağrılır)
  void handlePurchaseUpdate(PurchaseDetails purchaseDetails) {
    completePurchase(purchaseDetails);
  }
  
  // Satın alınmış temaları restore et
  Future<void> restorePurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await InAppPurchase.instance.restorePurchases();
      print('🔄 Restore purchases requested');
    } catch (e) {
      _errorMessage = 'Restore işlemi başlatılamadı: $e';
      print('❌ Restore error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Test için tema açma (geliştirme aşamasında)
  void unlockThemeForTesting(String themeKey) {
    if (isPremiumTheme(themeKey)) {
      _purchasedThemes.add(themeKey);
      _savePurchasedThemes();
      notifyListeners();
    }
  }
} 