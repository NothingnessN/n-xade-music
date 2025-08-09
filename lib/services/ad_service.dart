import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Gerçek reklam ID'si (Release'te kullanılır)
  static const String prodBannerAdUnitId = 'ca-app-pub-8912562360998351/7102047003';
  // Test ID (Debug/emulator için güvenli)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  static void initialize() {
    MobileAds.instance.initialize().then((initializationStatus) {
      print('AdMob initialized: ${initializationStatus.adapterStatuses}');
    });
  }

  static String get bannerAdUnitId {
    const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
    return kReleaseMode ? prodBannerAdUnitId : testBannerAdUnitId;
  }

  static BannerAd createBannerAdWithSize(AdSize size) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully (${ad is BannerAd ? (ad as BannerAd).size : size})');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
}