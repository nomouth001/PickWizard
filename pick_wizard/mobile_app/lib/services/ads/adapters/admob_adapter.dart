import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pick_wizard/services/ads/ad_adapter.dart';
import 'package:pick_wizard/services/ads/config/admob_config.dart';

/// AdMob 어댑터 (041 설계서 §3.2)
///
/// 전면/보상 광고 로드·표시, Random 확률 로직, 지수 백오프 적용.
class AdMobAdapter extends AdAdapter {
  AdMobAdapter() : _random = Random();

  final Random _random;
  int _actionCount = 0;
  DateTime _lastShowTime = DateTime(0);
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;

  static const _maxLoadAttempts = 5;
  static const _baseBackoffSeconds = 2;

  String get _platform => Platform.isAndroid ? 'android' : 'ios';
  String get _interstitialAdUnitId =>
      AdMobConfig.testAdUnits[_platform]!['interstitial']!;
  String get _rewardedAdUnitId =>
      AdMobConfig.testAdUnits[_platform]!['rewarded']!;
  String get _bannerAdUnitId =>
      AdMobConfig.testAdUnits[_platform]!['banner']!;

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadRewarded();
  }

  /// 지수 백오프 후 전면 광고 로드 (설계서 5.3)
  void _loadInterstitial() {
    if (_interstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) {
              a.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (a, e) {
              a.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (e) {
          debugPrint('AdMob interstitial load failed: $e');
          _interstitialAd = null;
          _interstitialLoadAttempts++;
          if (_interstitialLoadAttempts < _maxLoadAttempts) {
            final delay = Duration(
              seconds: _baseBackoffSeconds * (1 << (_interstitialLoadAttempts - 1)),
            );
            Future.delayed(delay, _loadInterstitial);
          }
        },
      ),
    );
  }

  /// 보상 광고 로드 (SSV 옵션: userId, customData — 설계서 §4.2)
  void _loadRewarded({String? userId, String? customData}) {
    if (_rewardedAd != null) return;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
          if (userId != null || customData != null) {
            ad.setServerSideOptions(ServerSideVerificationOptions(
              userId: userId ?? '',
              customData: customData ?? '',
            ));
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) {
              a.dispose();
              _rewardedAd = null;
              _loadRewarded(userId: userId, customData: customData);
            },
            onAdFailedToShowFullScreenContent: (a, e) {
              a.dispose();
              _rewardedAd = null;
              _loadRewarded(userId: userId, customData: customData);
            },
          );
        },
        onAdFailedToLoad: (e) {
          debugPrint('AdMob rewarded load failed: $e');
          _rewardedAd = null;
          _rewardedLoadAttempts++;
          if (_rewardedLoadAttempts < _maxLoadAttempts) {
            final delay = Duration(
              seconds: _baseBackoffSeconds * (1 << (_rewardedLoadAttempts - 1)),
            );
            Future.delayed(delay, () => _loadRewarded(userId: userId, customData: customData));
          }
        },
      ),
    );
  }

  @override
  void incrementActionCount() {
    _actionCount++;
  }

  @override
  Future<bool> showInterstitial() async {
    if (DateTime.now().difference(_lastShowTime) <
        AdMobConfig.minInterstitialInterval) {
      return false;
    }
    if (_actionCount < AdMobConfig.actionsBeforeShow) return false;
    if (_random.nextDouble() > AdMobConfig.showProbability) {
      debugPrint('광고 스킵 (확률)');
      return false;
    }
    if (_interstitialAd == null) return false;
    await _interstitialAd!.show();
    _lastShowTime = DateTime.now();
    return true;
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewardedAd;
    if (ad == null) return false;
    bool earned = false;
    ad.onUserEarnedRewardCallback = (_, __) {
      earned = true;
      // 실제 지급 SSOT는 백엔드 SSV; 여기는 UX용
    };
    await ad.show(onUserEarnedReward: (_, __) {
      earned = true;
    });
    return earned;
  }

  /// 배너 광고 유닛 ID (BannerAdWidget에서 사용)
  String get bannerAdUnitId => _bannerAdUnitId;
}
