# 036. 광고 시스템 설계 및 구현 계획 (AdMob → AdRaven 전환 대비)

**작성일**: 2026-01-19  
**수정일**: 2026-02-20  
**버전**: 1.4 (043 수익모델 반영: 보상형 → 전면형 수익용)  
**대상**: LuckyAI 645 Flutter 앱  
**목표**: 어댑터 패턴을 통한 유연한 광고 SDK 전환 (AdMob ↔ AdRaven)

---

## ✅ 리뷰 요약 (완성도 100점 기준 반영)

### 결정 사항(SSOT/DRY/KISS)
- **광고 타입 확장**: Interstitial 뿐 아니라 **Rewarded(보상)**를 1급 기능으로 포함한다.
- **043 수익모델(광고 전용) 적용 시**: 코인/지갑 비활성화 상태에서는 **보상형 광고를 전면 광고와 동일한 수익용 노출**로만 사용한다. 코인 지급·SSV 콜백·“보상” UX 없음. (재활성화 시 §4 보상+SSV 적용)
- **보상 지급 SSOT**: 코인 사용 시에 한해, 보상 코인 지급은 반드시 백엔드 `coin_transactions` 원장에 기록(034 SSOT)하고, **SSV transaction_id로 멱등 처리**한다.
- **프라이버시/동의**: GDPR/UMP, iOS ATT 등 동의 흐름을 Phase 1에 포함한다(출시 리스크 제거).
- **인터페이스 일관성**: `showInterstitial()`는 async로 정의(Future)하여 로딩/표시 실패를 자연스럽게 처리한다.

### 변경 이력
- v1.2: Rewarded+SSV 검증/프라이버시 동의/인터페이스 정합성/운영·테스트/원칙검증 보강 (2026-02-13)
- v1.3: SSV API 계약·설정·reference SSOT 단일 정의, 리팩토링 검증(7.5), 테스트 항목 보강 (2026-02-20)
- v1.4: 043 반영 — 보상형 광고를 전면 광고와 동일한 수익용으로 운영(코인/SSV 미사용) (2026-02-20)

## 📋 목차

1. [전략 및 패턴](#1-전략-및-패턴)
2. [광고 정책 (SSOT)](#2-광고-정책-ssot)
3. [어댑터 구현](#3-어댑터-구현)
4. [보상(Rewarded) + 서버 검증(SSV)](#4-보상rewarded--서버-검증ssv)
5. [프라이버시/동의/정책 준수](#5-프라이버시동의정책-준수)
6. [구현 체크리스트](#6-구현-체크리스트)
7. [원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)](#7-원칙-검증-중복방지dryssotkiss리팩토링)

---

## 1. 전략 및 패턴

### 1.1 어댑터 패턴 (Adapter Pattern)
- **목적**: 광고 네트워크(AdMob, AdRaven 등) 변경 시 클라이언트 코드(`AdService` 사용자) 수정을 0으로 만듦.
- **구조**:
  - `AdAdapter` (Interface)
  - `AdMobAdapter` (Implementation)
  - `AdRavenAdapter` (Implementation - Future)
  - `AdService` (Factory/Singleton)

### 1.2 전환 전략
- **Phase 1**: AdMob (테스트 광고 모드) 사용.
- **Phase 2**: 앱 출시 후 AdRaven으로 전환 시 `AdService` 내 상수 1줄만 변경.

---

## 2. 광고 정책 (SSOT)

모든 광고 설정과 정책은 단일 파일에서 관리하여 일관성을 유지한다.

**`lib/services/ads/config/ad_policy.dart`**:
```dart
class AdPolicy {
  // 전면 광고 최소 노출 간격 (5분)
  static const Duration minInterstitialInterval = Duration(minutes: 5);
  
  // 전면 광고 노출 확률 (60%)
  static const double showProbability = 0.6;
  
  // 노출 전 최소 액션 횟수 (3회)
  static const int actionsBeforeShow = 3;

  // 보상 광고 일일 한도(예: 20회) - 코인 활성화 시에만 사용 (043 비활성 시 미사용)
  static const int rewardedDailyLimit = 20;

  // 보상 광고 코인(정책 값; 코인 활성화 시에만 사용, 실제 지급 SSOT는 백엔드 원장)
  static const int rewardedCoins = 1;
}
```

---

## 3. 어댑터 구현

### 3.1 AdMob 설정 (`admob_config.dart`)
```dart
import 'ad_policy.dart'; // SSOT 참조

class AdMobConfig {
  static const bool isTestMode = true; // 계정 이슈로 테스트 모드 강제
  
  // AdPolicy 값 참조 (DRY 준수)
  static Duration get minInterstitialInterval => AdPolicy.minInterstitialInterval;
  static double get showProbability => AdPolicy.showProbability;
  static int get actionsBeforeShow => AdPolicy.actionsBeforeShow;
  
  static final Map<String, String> testAdUnits = { ... };
}
```

### 3.2 AdMob 어댑터 로직 (`admob_adapter.dart`)

```dart
@override
Future<bool> showInterstitial() async {
  // 1. 시간 체크
  if (DateTime.now().difference(_lastShowTime) < AdMobConfig.minInterstitialInterval) return false;
  
  // 2. 액션 횟수 체크
  if (_actionCount < AdMobConfig.actionsBeforeShow) return false;
  
  // 3. 확률 체크 (Random 사용 - 올바른 구현)
  if (Random().nextDouble() > AdMobConfig.showProbability) {
    debugPrint('광고 스킵 (확률)');
    return false;
  }
  
  if (_interstitialAd == null) return false;
  _interstitialAd!.show();
  return true;
}
```

### 3.3 서비스 통합 (`ad_service.dart`)

```dart
class AdService {
  // 🎯 이 줄만 수정하면 네트워크 교체 완료
  static const String _NETWORK = 'admob'; 
  
  Future<void> initialize() async {
    if (_NETWORK == 'admob') _adapter = AdMobAdapter();
    else if (_NETWORK == 'adraven') _adapter = AdRavenAdapter();
    
    await _adapter.initialize();
  }
  
  // 클라이언트는 이 메서드만 호출 (KISS)
  void incrementActionCount() => _adapter.incrementActionCount();
  Future<bool> showInterstitial() => _adapter.showInterstitial();

  // Rewarded(보상)도 동일한 인터페이스로 제공(KISS)
  Future<bool> showRewarded() => _adapter.showRewarded();
}
```

---

## 4. 보상(Rewarded) / 전면형 수익용

### 4.0 043 적용 시 (수익모델 광고 전용)
- **코인/지갑 비활성** 상태에서는 보상형 광고를 **전면 광고와 동일한 수익용**으로만 사용한다.
- `showRewarded()`는 그대로 호출 가능(동일 RewardedAd 유닛 사용). 시청 완료 시 **코인 지급·SSV·보상 API 호출 없음**.
- 정책상 **보상형 = “추가 전면형” 노출**로 간주(노출 간격/빈도는 전면과 별도로 둘 수 있음). `rewardedCoins`·`rewardedDailyLimit`·SSV 엔드포인트는 코인 재활성화 시에만 사용.

### 4.1 목표 (코인/지갑 활성화 시)
- 보상 광고 시청 완료 시 **코인 지급**(정책은 `AdPolicy.rewardedCoins`)
- 지급의 진실은 반드시 백엔드 `coin_transactions`(034 SSOT)
- 클라이언트 콜백 위변조를 막기 위해 **AdMob SSV(Server-side verification)**를 사용

### 4.2 권장 플로우(AdMob 기준; KISS + 보안)
1. Flutter에서 RewardedAd 로드 시 `ServerSideVerificationOptions(userId, customData)` 설정  
2. 사용자가 광고를 끝까지 시청하면 Google이 **SSV callback URL**을 서버로 호출  
3. 서버는 callback의 `signature`, `key_id`를 이용해 **ECDSA 서명 검증**  
4. 서버는 `transaction_id`를 `reference_id`로 사용하여 `coin_transactions`에 기록(유니크로 멱등)  
5. 앱은 “보상 처리 중/완료” UX를 제공(서버 반영은 약간의 지연 가능)

### 4.3 서버 엔드포인트(권장)

**reference 형식 SSOT (단일 정의)**  
- 보상 코인 원장 기록은 **`reference_type='ads/ssv'`**, **`reference_id=transaction_id`**만 사용한다. 다른 형식 혼용 금지(멱등·조회 일관성).

- **엔드포인트**: `POST /api/ads/ssv/admob` (Google SSV callback 수신)
  - **요청**: query params — `transaction_id`, `reward_amount`, `reward_item`, `ad_unit`, `ad_network`, `user_id`, `custom_data`, `signature`, `key_id` 등 (Google 문서 준수)
  - **처리**:
    - 서명 검증 실패 → **401 Unauthorized**
    - 서명 검증 성공 시 `coin_transactions(reference_type='ads/ssv', reference_id=transaction_id, delta=+reward_amount)` 기록 (034 원장·CoinService 단일 경로)
    - 이미 존재(유니크 충돌) 시 → **200 OK** (멱등, 코인 중복 지급 없음)
  - **응답**: 성공/멱등 모두 200. 본문에 `granted: bool`, `already_processed: bool` 등 선택적 제공 가능

### 4.4 백엔드 설정 (SSV 검증)
- **AdMob SSV 서명 검증**: Google에서 제공하는 공개키(키 ID별)로 ECDSA 검증. 키 소스는 환경별로 관리.
- **권장 설정/환경 변수**: `ADMOB_SSV_KEYS_PATH` 또는 공개키를 서버 설정에 로드(코드에 키 하드코딩 금지).

### 4.5 어댑터 인터페이스(권장)
- `AdAdapter`는 최소 아래를 제공:
  - `Future<void> initialize()`
  - `void incrementActionCount()`
  - `Future<bool> showInterstitial()`
  - `Future<bool> showRewarded()`

---

## 5. 프라이버시/동의/정책 준수

### 5.1 GDPR/UMP
- (EU 대상 가능성 존재 시) UMP 동의 플로우를 앱 시작 시점에 통합
- 동의 결과에 따라 personalized/non-personalized 설정 반영

### 5.2 iOS ATT(해당 시)
- iOS 출시 시 ATT 권한 요청 타이밍을 UX 관점에서 설계(최초 진입 직후 강제 금지)

### 5.3 정책/안정성
- 테스트 광고 유닛 사용 및 릴리즈 전 실유닛 전환 체크리스트화
- 광고 로드 실패 시 지수 백오프, 과도한 재시도 금지
- 어린이 대상/연령 제한 정책이 있다면 별도 토글로 SSOT화

---

## 6. 구현 체크리스트

- [ ] **공통**: `ad_policy.dart` 작성 (SSOT)
- [ ] **AdMob**: `google_mobile_ads` 패키지 설치 및 설정
- [ ] **AdMob**: `AdMobAdapter` 구현 (Random 확률 로직 적용)
- [ ] **UI**: `BannerAdWidget` 구현
- [ ] **UI**: 번호 생성 로직(`_handleGenerate`) 내 `incrementActionCount` 호출 추가
- [ ] **전환 대비**: `AdRavenAdapter` 스켈레톤 코드 작성
- [ ] **Rewarded**: `showRewarded()` 구현 + SSV 옵션(userId/customData) 설정
- [ ] **백엔드(연동)**: SSV callback 엔드포인트 구현 및 서명 검증 + 원장 기록(034 SSOT)
- [ ] **프라이버시**: UMP/ATT 등 동의 플로우 통합(플랫폼별)

### 6.1 테스트 항목(최소)
- [ ] **SSV 멱등**: 동일 `transaction_id`로 2회 이상 callback 호출 시 코인 1회만 지급, 응답 200
- [ ] **서명 검증 실패**: 위조 요청 시 401, 원장 미기록
- [ ] **광고 로드 실패**: 지수 백오프 재시도, 과도 재시도 없음
- [ ] **동의 플로우**: UMP/ATT(해당 시) 동의 후 광고 요청 가능

---

## 7. 원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)

### 7.1 중복방지(Idempotency)
- [ ] SSV의 `transaction_id`를 `coin_transactions.reference_id`로 사용(유니크로 멱등)
- [ ] 클라이언트에서 보상 UI를 여러 번 눌러도 서버 지급은 1회만

### 7.2 DRY
- [ ] 광고 정책은 `AdPolicy` 단일 파일
- [ ] 네트워크별 SDK 코드는 어댑터 내부로 격리(화면 코드에 SDK 직접 호출 금지)

### 7.3 SSOT
- [ ] 보상 코인 지급의 진실은 백엔드 `coin_transactions`
- [ ] 앱 내 카운터/로컬 상태는 UX용(진실 아님)

### 7.4 KISS
- [ ] 화면은 `AdService.showInterstitial/showRewarded`만 호출
- [ ] 네트워크 전환은 어댑터 교체로 제한

### 7.5 리팩토링 용이성
- [ ] 네트워크 전환 시 변경 지점 **1곳**: `AdService._NETWORK` 상수만 변경(어댑터 교체)
- [ ] 보상 코인 지급은 백엔드 **CoinService 단일 경로**로만 수행(034 원장; SSV callback → 원장 기록)
- [ ] 광고 정책 변경 시 `ad_policy.dart`만 수정(어댑터는 정책 참조만)

**관련 문서**:
- `034_OAuth_CoinWallet_Plan.md`
- `035_IAP_Implementation_Plan.md`
- `043_Revenue_Model_Ads_Only_Coin_Disable_Plan.md` (광고 전용 시 보상형 → 전면형 수익용)
