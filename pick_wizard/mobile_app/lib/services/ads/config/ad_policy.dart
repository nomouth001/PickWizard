/// 광고 정책 SSOT (041 설계서 §2)
///
/// 모든 광고 설정과 정책은 이 파일에서만 관리한다.
/// 043 적용 시: 보상형 광고는 전면 광고와 동일한 수익용으로만 사용(코인/SSV 미사용).
class AdPolicy {
  AdPolicy._();

  /// 전면 광고 최소 노출 간격 (5분)
  static const Duration minInterstitialInterval = Duration(minutes: 5);

  /// 전면 광고 노출 확률 (60%)
  static const double showProbability = 0.6;

  /// 노출 전 최소 액션 횟수 (3회)
  static const int actionsBeforeShow = 3;

  /// 보상형 광고 일일 한도 — 코인 활성화 시에만 사용 (043 비활성 시 보상형=전면형 수익용)
  static const int rewardedDailyLimit = 20;

  /// 보상형 광고 코인 — 코인 활성화 시에만 사용 (실제 지급 SSOT는 백엔드 원장)
  static const int rewardedCoins = 1;
}
