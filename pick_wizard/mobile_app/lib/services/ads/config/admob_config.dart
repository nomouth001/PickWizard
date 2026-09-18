import 'ad_policy.dart';

/// AdMob 설정 (041 설계서 §3.1)
///
/// AdPolicy 값 참조 (DRY 준수). 테스트 광고 유닛 사용.
class AdMobConfig {
  AdMobConfig._();

  /// 테스트 모드 강제 (계정 이슈 시)
  static const bool isTestMode = true;

  // AdPolicy 참조 (DRY)
  static Duration get minInterstitialInterval =>
      AdPolicy.minInterstitialInterval;
  static double get showProbability => AdPolicy.showProbability;
  static int get actionsBeforeShow => AdPolicy.actionsBeforeShow;
  static int get rewardedCoins => AdPolicy.rewardedCoins;
  static int get rewardedDailyLimit => AdPolicy.rewardedDailyLimit;

  /// 테스트 광고 유닛 ID (Google 샘플)
  /// https://developers.google.com/admob/android/test-ads
  static final Map<String, Map<String, String>> testAdUnits = {
    'android': {
      'app': 'ca-app-pub-3940256099942544~3347511713',
      'banner': 'ca-app-pub-3940256099942544/6300978111',
      'interstitial': 'ca-app-pub-3940256099942544/1033173712',
      'rewarded': 'ca-app-pub-3940256099942544/5224354911',
    },
    'ios': {
      'app': 'ca-app-pub-3940256099942544~1458002511',
      'banner': 'ca-app-pub-3940256099942544/2934735716',
      'interstitial': 'ca-app-pub-3940256099942544/4411468910',
      'rewarded': 'ca-app-pub-3940256099942544/1712485313',
    },
  };
}
