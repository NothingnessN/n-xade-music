import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Gerçek reklam ID'si
  static const String bannerAdUnitId = 'ca-app-pub-8912562360998351/7102047003';
  
  static void initialize() {
    MobileAds.instance.initialize().then((initializationStatus) {
      print('AdMob initialized: ${initializationStatus.adapterStatuses}');
    });
  }
  
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner ad opened');
        },
        onAdClosed: (ad) {
          print('Banner ad closed');
        },
      ),
    );
  }
} 