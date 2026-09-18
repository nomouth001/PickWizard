/// 광고 어댑터 인터페이스 (041 설계서 §4.5)
///
/// AdMob / AdRaven 등 네트워크별 구현이 이 인터페이스를 따른다.
abstract class AdAdapter {
  Future<void> initialize();
  void incrementActionCount();
  Future<bool> showInterstitial();
  Future<bool> showRewarded();
}
