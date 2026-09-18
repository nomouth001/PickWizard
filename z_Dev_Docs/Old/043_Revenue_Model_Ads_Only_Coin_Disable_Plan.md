# 043. 수익모델 광고 전용화 및 코인/코인지갑 비활성화 계획

**작성일**: 2026-02-20  
**버전**: 1.0  
**대상**: LuckyAI 645 Flutter 앱 + FastAPI 백엔드  
**목표**: 수익모델을 광고만 사용하고, 코인 모델·코인지갑은 일단 비활성화(disable)

---

## 📋 목차

1. [배경 및 목표](#1-배경-및-목표)
2. [현재 구조 요약](#2-현재-구조-요약)
3. [비활성화 범위](#3-비활성화-범위)
4. [구현 방안 (Feature Flag 기반)](#4-구현-방안-feature-flag-기반)
5. [작업 체크리스트](#5-작업-체크리스트)
6. [수익 정책 (광고 전용)](#6-수익-정책-광고-전용)
7. [재활성화 시 고려사항](#7-재활성화-시-고려사항)
8. [관련 문서](#8-관련-문서)

---

## 1. 배경 및 목표

### 1.1 배경

- 현재: 코인 지갑(잔액/차감/보상) + IAP(코인 구매) + 광고(보상/전면)가 혼재한 수익·소비 구조.
- 요구: **수익은 광고만** 사용하고, 코인 모델과 코인지갑은 당분간 **비활성화**하여 단순화.

### 1.2 목표

| 항목 | 목표 |
|------|------|
| **수익모델** | 광고만 사용 (배너, 전면, 보상 광고) |
| **코인 모델** | 일단 비활성화 (UI/플로우 미노출, 백엔드 차감 미수행) |
| **코인지갑** | 일단 비활성화 (잔액 조회/표시/차감 미사용) |
| **재활성화** | 추후 플래그/설정만으로 복구 가능하도록 유지 |

### 1.3 비범위

- 코인/지갑 **코드 삭제**는 하지 않음 (비활성화만).
- IAP(인앱결제) 구현은 040/041 등 기존 계획서대로 두되, **노출만 하지 않음**.

---

## 2. 현재 구조 요약

### 2.1 Flutter 앱

| 구분 | 위치 | 설명 |
|------|------|------|
| **코인 잔액 표시** | `home_screen.dart` | AppBar에 잔액 표시, 탭 시 `CoinStoreScreen` 이동 |
| **코인 스토어** | `coin_store_screen.dart` | 잔액 카드, 무료 코인/구매, 거래 내역 |
| **코인 프로바이더** | `coin_provider.dart` | `coinBalanceProvider`, `coinHistoryProvider`, `dailyLoginProvider`, `adRewardProvider` |
| **API** | `lotto_api.dart` / `api_endpoints.dart` | `getMeCoins`, `getCoinBalance`, `claimDailyLogin`, `claimAdReward`, `getCoinHistory`, `purchaseCoins` 등 |
| **번호 생성** | `lotto_repository.dart` | 402 응답 시 `InsufficientCoinsFailure` 처리 |
| **문자열** | `app_strings.dart`, 로컬라이제이션 | 코인/잔액/구매/부족 메시지 |

### 2.2 백엔드

| 구분 | 위치 | 설명 |
|------|------|------|
| **번호 생성** | `generation.py` | `user_id` 있을 때 코인 차감, 부족 시 402 |
| **코인 API** | `coins.py` | `/coins/balance`, `/coins/daily-login`, `/coins/watch-ad`, `/coins/history` |
| **모델/서비스** | `coin_wallet.py`, `coin_service.py` | 지갑·원장·차감·지급 로직 |
| **사용자** | `users.py` 등 | `/api/users/me/coins`, `/api/users/me/coin-transactions` |

### 2.3 광고와의 관계

- **041 계획**: 보상 광고 시청 시 코인 지급(SSV 등). 코인 비활성화 시 보상 광고는 **시청만** 하고 코인 지급/API 호출은 하지 않거나 무시.

---

## 3. 비활성화 범위

### 3.1 앱(Flutter)

- **숨김**: 홈 화면 코인 잔액 영역, 코인 스토어 진입 버튼/메뉴, 설정 등에서 코인/지갑 관련 항목.
- **미호출**: 코인 잔액/히스토리/일일로그인/광고보상 API 호출을 하지 않거나, 플래그가 꺼져 있으면 스킵.
- **번호 생성**: 코인 차감 없이 항상 생성 가능하게 (서버에서도 차감 생략).

### 3.2 백엔드

- **생성 API**: `user_id` 유무와 관계없이 **코인 차감 로직 스킵** (플래그 또는 설정으로 제어).
- **코인 API**: 라우트는 유지하되, 앱에서는 호출하지 않음. (또는 플래그로 503/비활성 응답 처리 선택 가능.)

### 3.3 광고

- **배너/전면**: 그대로 유지 (수익화 핵심).
- **보상 광고**: 재생·완료 콜백은 유지하되, **코인 지급 API 호출 및 SSV→원장 기록은 비활성화** (또는 no-op).

---

## 4. 구현 방안 (Feature Flag 기반)

### 4.1 원칙

- **단일 스위치**: 앱·백엔드 모두 `코인/지갑 사용 여부`를 하나의 플래그(또는 설정)로 제어.
- **코드 제거 최소화**: 분기로 비활성화하여, 추후 플래그만 켜면 복구 가능하게 유지.

### 4.2 앱 측 플래그 제안

**위치**: `lib/core/constants/feature_flags.dart` (신규) 또는 기존 설정 파일

```dart
/// 수익모델: true = 광고만, false = 코인+광고(IAP 등) 포함
class FeatureFlags {
  /// 코인·코인지갑 기능 사용 여부 (false = 비활성화, 광고만 수익)
  static const bool useCoinAndWallet = false;
}
```

- `useCoinAndWallet == false`일 때:
  - 홈에서 코인 잔액·코인 스토어 진입 UI 미표시.
  - `coinBalanceProvider` / `coinHistoryProvider` / `dailyLoginProvider` / `adRewardProvider` 구독 시 **즉시 빈/더미 데이터 반환** 또는 API 호출 스킵.
  - 번호 생성 시 코인 관련 안내/에러 처리하지 않음 (서버가 차감하지 않으므로 402 없음).
- `useCoinAndWallet == true`일 때: 기존 동작 유지.

### 4.3 백엔드 측 플래그 제안

**위치**: 환경 변수 또는 설정 모듈 (예: `app.core.config`)

```python
# 예: .env 또는 config
COIN_WALLET_ENABLED=false
```

- `COIN_WALLET_ENABLED=false`일 때:
  - **generation.py**: 코인 차감 로직 전체 스킵 (비용 계산은 할 수 있으나, `wallet.deduct_coins` 호출 안 함, 402 반환 안 함).
  - **coins.py**: (선택) 그대로 두고 앱이 호출만 안 하거나, 503 + "코인 기능 비활성화" 등으로 통일 가능.
- SSV 콜백: `COIN_WALLET_ENABLED=false`이면 원장 기록 스킵, 200만 반환(멱등 유지).

### 4.4 보상 광고와의 정리

- **보상 광고 표시**: 계속 가능 (광고 수익 + 사용자 참여).
- **시청 완료 시**:  
  - `useCoinAndWallet == false` / `COIN_WALLET_ENABLED=false`:  
    - 앱: `claimAdReward`(또는 동일 역할 API) 호출 안 함.  
    - 서버: SSV 수신 시 서명 검증만 하고 원장 기록은 하지 않음.

---

## 5. 작업 체크리스트

### 5.1 Flutter

- [x] **FeatureFlags**: `useCoinAndWallet = false` 상수 추가 (또는 설정에서 로드)
- [x] **HomeScreen**: `useCoinAndWallet`가 false일 때 AppBar 코인 잔액·코인 스토어 진입 UI 숨김
- [x] **네비게이션/메뉴**: 코인 스토어로 가는 다른 진입점 있으면 플래그로 숨김
- [x] **CoinStoreScreen**: 플래그가 false일 때 진입 불가 또는 리다이렉트 처리 (선택)
- [x] **coin_provider**: 플래그가 false일 때 잔액/히스토리/일일로그인/광고보상 API 호출 스킵, 더미/빈 값 반환
- [x] **번호 생성**: 코인 부족(402) 처리 유지하되, 서버가 402를 안 주므로 실제로는 발생하지 않음 (추가 UI 메시지 제거 가능)
- [ ] **로컬라이제이션/문자열**: 코인 관련 문구는 유지 (재활성화 대비), 필요 시 “일시 비활성” 툴팁만 추가 가능

### 5.2 백엔드

- [x] **설정**: `COIN_WALLET_ENABLED` (또는 동일 의미) 환경 변수/설정 추가, 기본값 `false`
- [x] **generation.py**: `COIN_WALLET_ENABLED`가 false이면 코인 조회·차감·402 로직 스킵
- [ ] **coins.py**: (선택) 비활성 시 503 또는 고정 응답 반환
- [x] **SSV/보상**: SSV 콜백에서 `COIN_WALLET_ENABLED`가 false이면 원장 기록만 스킵, 200 반환

### 5.3 문서·테스트

- [ ] **041 등**: “현재 수익모델은 광고 전용, 코인/지갑 비활성” 문구 추가 또는 043 참조 명시
- [ ] **회귀 테스트**: 플래그 true로 되돌렸을 때 기존 코인/지갑 플로우 동작 확인

---

## 6. 수익 정책 (광고 전용)

| 수단 | 사용 여부 | 비고 |
|------|-----------|------|
| **배너 광고** | ✅ 사용 | 수익 + UX 정책은 041 등 기존 계획 따름 |
| **전면 광고** | ✅ 사용 | 노출 간격/확률 등 041 AdPolicy 준수 |
| **보상형 광고** | ✅ 사용 | **전면 광고와 동일한 수익용**으로만 사용. 코인 지급·SSV·“보상” UX 없음(041 §4.0 반영). |
| **코인 판매(IAP)** | ❌ 비활성 | UI/플로우 미노출, 백엔드 연동은 유지 가능 |
| **코인 지갑** | ❌ 비활성 | 잔액 표시·차감·보상 지급 미사용 |

---

## 7. 재활성화 시 고려사항

- 앱: `FeatureFlags.useCoinAndWallet = true` (또는 원격 설정 반영)로 복구.
- 백엔드: `COIN_WALLET_ENABLED=true`로 복구.
- SSV·IAP 등 기존 설계(034, 040, 041)는 그대로 두고, 플래그만 켜면 다시 코인 지급/차감이 동작하도록 구현하면 됨.
- 필요 시 원격 설정(Firebase Remote Config 등)으로 플래그 제어 시 재배포 없이 전환 가능.

---

## 8. 관련 문서

- **034** OAuth_CoinWallet_Plan.md — 코인지갑·원장 설계 (비활성화 후 재활성화 시 참고)
- **040** IAP_Implementation_Plan.md — IAP(코인 구매) 계획 (현재 비노출)
- **041** AdMob_AdRaven_Implementation_Plan.md — 광고 정책·SSV·보상 (광고 전용 수익 적용)
- **042** Design_Docs_Review_Report.md — 설계서 검토
