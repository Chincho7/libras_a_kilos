// /Users/janogroup/Documents/GitHub/Libras_a_Kilos/lib/services/ad_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Singleton pattern
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  static const bool _isTest = false; // Changed from true to false

  // Updated ad unit getters with new production IDs
  static String get appOpenAdUnitId => Platform.isIOS
      ? 'ca-app-pub-8204427937072562/9158760593'
      : 'ca-app-pub-8204427937072562/1450563480';

  static String get interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-8204427937072562/2572073462'
      : 'ca-app-pub-8204427937072562/5411087278';

  static String get bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-8204427937072562/1471842262'
      : 'ca-app-pub-8204427937072562/4289577292';

  // Properties
  bool _initialized = false;
  bool _isDisposed = false;
  bool _isAnyAdShowing = false;
  final bool _wasAppOpenAdShown = false;
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  final ValueNotifier<bool> bannerAdLoaded = ValueNotifier<bool>(false);
  BannerAd? _bannerAd;

  // Add timer property
  Timer? _interstitialTimer;
  bool _isInterstitialAdReady = false;

  Future<void> initialize() async {
    if (_initialized || _isDisposed) return;
    _initialized = true;

    print('AdHelper: Initializing...');

    try {
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1));
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }

      await loadBannerAd();
      await _loadAppOpenAd();
      await _loadInterstitialAd();
      _startInterstitialTimer(); // Add this line to start the timer
    } catch (e) {
      print('AdHelper: Initialization error: $e');
    }
  }

  Future<void> _loadAppOpenAd() async {
    if (_wasAppOpenAdShown || _isDisposed) return;

    print('AdHelper: Loading app open ad...');
    await AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('AdHelper: App open ad loaded successfully');
          _appOpenAd = ad;
          _showAppOpenAd();
        },
        onAdFailedToLoad: (error) {
          print('AdHelper: App open ad failed to load - $error');
          _appOpenAd = null;
          Future.delayed(
            const Duration(minutes: 1),
            () => _loadAppOpenAd(),
          );
        },
      ),
    );
  }

  Future<void> loadBannerAd() async {
    if (_isDisposed) return;

    print('AdHelper: Starting banner ad load...');
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('AdHelper: Banner ad loaded successfully');
          bannerAdLoaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('AdHelper: Banner ad failed to load: $error');
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
      print('AdHelper: Error loading banner ad: $e');
      bannerAdLoaded.value = false;
      _bannerAd = null;
    }
  }

  Future<void> _loadInterstitialAd() async {
    if (_isDisposed || _isInterstitialAdReady) return;

    print('AdHelper: Loading interstitial ad...');
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('AdHelper: Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          print('AdHelper: Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          _interstitialAd = null;
          // Retry after delay
          Future.delayed(
            const Duration(minutes: 1),
            _loadInterstitialAd,
          );
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('AdHelper: Interstitial ad shown');
        _isAnyAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('AdHelper: Interstitial ad dismissed');
        _isAnyAdShowing = false;
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('AdHelper: Interstitial ad failed to show - $error');
        _isAnyAdShowing = false;
        ad.dispose();
        _loadInterstitialAd();
      },
    );
  }

  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = Timer.periodic(
      const Duration(seconds: 30), // Changed from 90 to 30 seconds
      (_) {
        print('AdHelper: Attempting to show interstitial ad from timer');
        _showInterstitialAd();
      },
    );
  }

  void _showAppOpenAd() {
    if (_appOpenAd == null || _isAnyAdShowing || _isDisposed) return;

    _appOpenAd!.show();
  }

  void _showInterstitialAd() {
    if (!_isInterstitialAdReady || _interstitialAd == null || _isAnyAdShowing) {
      print(
          'AdHelper: Cannot show interstitial ad - Ready: $_isInterstitialAdReady, Ad exists: ${_interstitialAd != null}, Other ad showing: $_isAnyAdShowing');
      return;
    }

    print('AdHelper: Showing interstitial ad');
    _interstitialAd!.show();
    _isInterstitialAdReady = false;
  }

  // Add getter for banner ad
  BannerAd? get bannerAd => _bannerAd;

  // Update getter to also check if ad exists
  bool get isBannerAdLoaded => bannerAdLoaded.value && _bannerAd != null;

  // Update dispose method
  void dispose() {
    _isDisposed = true;
    _interstitialTimer?.cancel();
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    bannerAdLoaded.dispose();
  }

  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return 'YOUR_ANDROID_BANNER_AD_UNIT_ID'; // Replace with your actual ad unit ID
    } else if (Platform.isIOS) {
      return 'YOUR_IOS_BANNER_AD_UNIT_ID'; // Replace with your actual ad unit ID
    }
    throw UnsupportedError('Unsupported platform');
  }
}
