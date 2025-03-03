// /Users/janogroup/Documents/GitHub/Libras_a_Kilos/lib/services/ad_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdHelper {
  // Singleton pattern
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  // Test Ad Unit IDs
  static const String _testAppOpenAdUnitIdAndroid = 'ca-app-pub-3940256099942544/3419835294';
  static const String _testAppOpenAdUnitIdIOS = 'ca-app-pub-3940256099942544/5662855259';
  static const String _testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  
  bool _isATTCompleted = false;
  bool _isAdInitialized = false;
  bool _isInterstitialAdReady = false;
  int _interstitialLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;
  
  Timer? _interstitialTimer;
  final ValueNotifier<bool> bannerAdLoaded = ValueNotifier<bool>(false);

  // Get appropriate ad unit IDs based on build mode and platform
  String get appOpenAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testAppOpenAdUnitIdAndroid : _testAppOpenAdUnitIdIOS;
    } else {
      return Platform.isIOS
          ? 'ca-app-pub-8204427937072562/9158760593'
          : 'ca-app-pub-8204427937072562/1450563480';
    }
  }

  String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testInterstitialAdUnitIdAndroid : _testInterstitialAdUnitIdIOS;
    } else {
      return Platform.isIOS
          ? 'ca-app-pub-8204427937072562/2572073462'
          : 'ca-app-pub-8204427937072562/5411087278';
    }
  }

  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testBannerAdUnitIdAndroid : _testBannerAdUnitIdIOS;
    } else {
      return Platform.isIOS
          ? 'ca-app-pub-8204427937072562/1471842262'
          : 'ca-app-pub-8204427937072562/4289577292';
    }
  }

  /// Initialize ads when called from MainScreen after UI is loaded
  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isAdInitialized) return;
    _isAdInitialized = true;
    
    debugPrint('AdHelper initializing with delay - UI is fully loaded');
    
    if (Platform.isIOS) {
      debugPrint('Waiting a moment before showing ATT dialog...');
      // Short delay to ensure UI is fully interactive before ATT dialog
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('Requesting ATT authorization now');
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('ATT authorization status: $status');
      _isATTCompleted = true;
      
      // After ATT response, start loading ads with a small delay
      debugPrint('ATT request completed, loading ads after delay');
      await Future.delayed(const Duration(seconds: 1));
      _loadAppOpenAd();
      _loadInterstitialAd();
      _scheduleInterstitialAd();
      loadBannerAd();
    } else {
      // For Android: Mark ATT as completed and load ads immediately
      _isATTCompleted = true;
      _loadAppOpenAd();
      _loadInterstitialAd();
      _scheduleInterstitialAd();
      loadBannerAd();
    }
  }

  void _scheduleInterstitialAd() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer(const Duration(seconds: 70), () {
      showInterstitialAd();
    });
  }

  /// Check if ATT dialog has been answered
  bool get isATTCompleted => _isATTCompleted;

  /// Loads an App Open Ad.
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          debugPrint('App Open Ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open Ad failed to load: $error');
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadAppOpenAd);
        },
      ),
    );
  }

  /// Loads an Interstitial Ad.
  void _loadInterstitialAd() {
    if (_interstitialLoadAttempts >= maxFailedLoadAttempts) {
      debugPrint('Max failed load attempts reached for interstitial ad');
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial Ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          debugPrint('Interstitial Ad failed to load: $error');
          
          if (_interstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 5), () {
              _loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  /// Loads a Banner Ad.
  Future<void> loadBannerAd() async {
    debugPrint('AdHelper: Starting banner ad load...');
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('AdHelper: Banner ad loaded successfully');
          bannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdHelper: Banner ad failed to load: $error');
          bannerAdLoaded.value = false;
          ad.dispose();
          _bannerAd = null;
          // Retry after delay
          Future.delayed(
            const Duration(minutes: 1),
            loadBannerAd,
          );
        },
      ),
    );

    try {
      await _bannerAd?.load();
    } catch (e) {
      debugPrint('AdHelper: Error loading banner ad: $e');
      bannerAdLoaded.value = false;
      _bannerAd = null;
    }
  }

  /// Pauses the banner ad by disposing it
  void pauseBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    bannerAdLoaded.value = false;
  }

  /// Pauses all ads by disposing them
  void pauseAllAds() {
    // Dispose and clear banner ad
    _bannerAd?.dispose();
    _bannerAd = null;
    bannerAdLoaded.value = false;

    // Dispose and clear interstitial ad
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _interstitialTimer?.cancel();

    // Dispose and clear app open ad
    _appOpenAd?.dispose();
    _appOpenAd = null;

    _isAdInitialized = false;
    debugPrint('All ads have been paused');
  }

  /// Shows the Interstitial Ad if available.
  void showInterstitialAd() {
    if (_interstitialAd == null || !_isInterstitialAdReady) {
      debugPrint('Interstitial Ad not ready. Loading a new one...');
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial Ad is showing.');
        _isInterstitialAdReady = false;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial Ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd(); 
        _scheduleInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial Ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdReady = false;
        _loadInterstitialAd();
        _scheduleInterstitialAd();
      },
    );

    _interstitialAd!.show();
  }

  /// Shows the App Open Ad if available.
  void showAppOpenAd() {
    if (_appOpenAd == null) {
      debugPrint('App Open Ad not ready yet.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('App Open Ad is showing.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open Ad dismissed.');
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  // Add getter for banner ad
  BannerAd? get bannerAd => _bannerAd;

  // Update getter to also check if ad exists
  bool get isBannerAdLoaded => bannerAdLoaded.value && _bannerAd != null;

  /// Dispose loaded ads and timer if needed.
  void dispose() {
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    _interstitialTimer?.cancel();
    bannerAdLoaded.dispose();
  }
}
