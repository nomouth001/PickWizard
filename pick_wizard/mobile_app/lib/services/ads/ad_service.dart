import 'package:pick_wizard/services/ads/ad_adapter.dart';
import 'package:pick_wizard/services/ads/adapters/admob_adapter.dart';
import 'package:pick_wizard/services/ads/adapters/adraven_adapter.dart';

/// 광고 서비스 (041 설계서 §3.3)
///
/// 이 줄만 수정하면 네트워크 교체 완료. 클라이언트는 showInterstitial/showRewarded만 호출.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// 네트워크 전환 시 이 상수만 변경
  static const String _NETWORK = 'admob';

  AdAdapter? _adapter;
  bool _initialized = false;

  AdAdapter get _adapterOrThrow {
    final a = _adapter;
    if (a == null) throw StateError('AdService not initialized');
    return a;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    if (_NETWORK == 'admob') {
      _adapter = AdMobAdapter();
    } else if (_NETWORK == 'adraven') {
      _adapter = AdRavenAdapter();
    } else {
      throw StateError('Unknown ad network: $_NETWORK');
    }
    await _adapter!.initialize();
    _initialized = true;
  }

  void incrementActionCount() => _adapterOrThrow.incrementActionCount();
  Future<bool> showInterstitial() => _adapterOrThrow.showInterstitial();
  Future<bool> showRewarded() => _adapterOrThrow.showRewarded();

  /// 배너 광고 유닛 ID (AdMob 시에만 반환; BannerAdWidget에서 사용)
  String? get bannerAdUnitId {
    final a = _adapter;
    if (a is AdMobAdapter) return a.bannerAdUnitId;
    return null;
  }

  bool get isInitialized => _initialized;
}
