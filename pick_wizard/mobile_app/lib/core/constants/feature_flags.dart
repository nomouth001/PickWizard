/// 기능 플래그 (043: 수익모델 광고 전용화 시 코인/지갑 비활성화)
///
/// 2026-02-20 - 초기 생성

class FeatureFlags {
  FeatureFlags._();

  /// 코인·코인지갑 기능 사용 여부.
  /// - `false`: 비활성화 (수익은 광고만 사용)
  /// - `true`: 코인 잔액/스토어/차감/보상 사용 (034·040·041 연동)
  static const bool useCoinAndWallet = false;
}
