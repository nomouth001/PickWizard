import 'package:pick_wizard/services/ads/ad_adapter.dart';

/// AdRaven 어댑터 스켈레톤 (041 설계서 §1.2, Phase 2 전환 대비)
///
/// 전환 시 AdService._NETWORK 만 'adraven'로 변경하면 이 구현이 사용된다.
class AdRavenAdapter extends AdAdapter {
  @override
  Future<void> initialize() async {
    // TODO: AdRaven SDK 초기화
  }

  @override
  void incrementActionCount() {}

  @override
  Future<bool> showInterstitial() async => false;

  @override
  Future<bool> showRewarded() async => false;
}
