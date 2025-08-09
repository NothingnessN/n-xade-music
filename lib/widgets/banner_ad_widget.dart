import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBannerAd(context));
  }

  void _loadBannerAd(BuildContext context) async {
    final mediaQuery = MediaQuery.of(context);
    final deviceWidth = mediaQuery.size.width;
    // Genişliğe göre uygun banner boyutu seç
    if (deviceWidth >= 728) {
      _adSize = AdSize.leaderboard; // 728x90
    } else if (deviceWidth >= 468) {
      _adSize = AdSize.fullBanner; // 468x60
    } else if (deviceWidth >= 320) {
      _adSize = AdSize.banner; // 320x50
    } else {
      _adSize = AdSize.banner;
    }

    final AdSize resolvedSize = _adSize!;
    _bannerAd = AdService.createBannerAdWithSize(resolvedSize);

    _bannerAd!.load().then((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    }).catchError((error) {
      print('Banner reklam yükleme hatası: $error');
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return SizedBox(
        height: (_adSize?.height ?? 50).toDouble(),
        width: double.infinity,
        child: const Center(
          child: Text(
            'Reklam yükleniyor...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}