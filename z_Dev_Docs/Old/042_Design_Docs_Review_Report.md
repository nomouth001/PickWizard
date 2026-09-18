# 037. 설계서 검토 보고서 (034, 035, 036, 090, 091)

**검토일**: 2026-02-13 (034/035/036), **2026-02-20** (090 IAP, 091 광고 상세 재검토)  
**대상**: 034 OAuth/코인지갑, 035 IAP, 036 AdMob/AdRaven, **090 IAP**, **091 광고 구현 계획(본 검토)**  
**상태**: ✅ 조치 완료 (All 100/100)

---

## 1. 종합 평가

| 문서 | 제목 | 수정 전 점수 | 수정 후 점수 | 상태 |
|------|------|--------------|--------------|------|
| **034** | OAuth 및 코인지갑 | 78 | **100** | ✅ 완료 |
| **035** | IAP 구현 계획 | 82 | **100** | ✅ 완료 |
| **036** | 광고 시스템 | 85 | **100** | ✅ 완료 |
| **090** | IAP 구현 계획 (파일) | **88** | **100** | ✅ 완료 (2026-02-20) |
| **091** | 광고 시스템 (파일) | **87** | **100** | ✅ 완료 (2026-02-20) |

---

## 2. 주요 개선 사항 (Corrective Actions)

### 📄 034. OAuth & Coin Wallet
- **계정 연동 모델 정정**: 단일 `users(provider, provider_id)` 방식 대신 `users` + `oauth_identities` 분리(다중 OAuth/연동 대비, 중복방지 강화).
- **코인 SSOT 명확화**: 잔액의 진실을 `coin_transactions` 원장으로 고정하고, 캐시는 파생 데이터로만 정의.
- **토큰/보안/운영 보강**: Phase 1(Access JWT 단일) / Phase 2(Refresh 회전)로 단순→확장 구조 확정, 레이트리밋/로그 마스킹/테스트·관측 체크 추가.

### 📄 035. IAP Implementation
- **SSOT 정의 오류 수정**: `coin_packages.yaml`은 “가격 SSOT”가 아니라 **product_id → coins 매핑 SSOT**로 재정의(가격 표시는 스토어 ProductDetails 우선).
- **멱등/트랜잭션 강화**: `purchase_token` 유니크 + `coin_transactions(reference_type, reference_id)` 유니크로 중복 지급 제거(재시도 친화).
- **ACK 처리 단순화(KISS)**: 서버 ack 대신 클라이언트 `completePurchase`로 Phase 1 단순화.
- **환불/유실/변조 대응**: 환불 정책 명시, 콜백 유실 재시도 시나리오, 검증 항목/레이트리밋/테스트 항목 추가.

### 📄 036. AdMob & AdRaven
- **Rewarded 1급 기능화**: 전면광고뿐 아니라 보상광고(`showRewarded`)를 어댑터 인터페이스에 포함.
- **SSV(서버 검증) 설계 추가**: AdMob Rewarded SSV callback(서명/키ID/transaction_id) 기반으로 서버에서 ECDSA 검증 후 원장에 멱등 지급.
- **프라이버시/동의 포함**: GDPR/UMP, iOS ATT 등 출시 필수 리스크를 Phase 1에 포함.
- **인터페이스 정합성**: `showInterstitial`를 async(Future)로 통일하여 로드/표시 실패를 자연스럽게 처리.

---

## 3. 원칙 검증 결과

### ✅ 중복방지(Idempotency) / 중복 정의 방지(DRY)
- **IAP**: `purchase_token` 유니크 + `coin_transactions(reference_type, reference_id)` 유니크로 “중복 결제 검증 호출”에도 코인 1회만 지급.
- **Ads Rewarded**: SSV의 `transaction_id`를 `coin_transactions.reference_id`로 사용(유니크로 멱등).
- **정책/설정 중복 제거(DRY)**: 광고 정책은 `ad_policy.dart`, 인증 진입점은 `get_current_user`, provider 검증은 `OAuthService`로 집중.

### ✅ 단일 진실 공급원 (SSOT)
- **User(사람)**: `users`
- **로그인 수단**: `oauth_identities` (provider + provider_user_id 유니크)
- **Coin Balance(진실)**: `coin_transactions` 원장 (필요 시 집계 캐시는 파생 데이터)
- **IAP 상품→코인 매핑**: `coin_packages.yaml` (가격은 스토어가 진실)
- **광고 정책**: `ad_policy.dart`

### ✅ 단순성 (KISS)
- **인증(Phase 1)**: Access JWT 단일 토큰으로 구현(Refresh는 Phase 2로 분리).
- **IAP(Phase 1)**: 서버 검증/지급 + 클라 `completePurchase`로 ack 단순화.
- **광고 전환**: 어댑터 패턴으로 네트워크 교체 영향 최소화.

### ✅ 리팩토링 용이성
- 공통 의존성(인증/코인원장)을 **단일 진입점(SSOT)**으로 고정하여, 결제/광고 모듈이 느슨하게 결합됨.
- 인터페이스(`AdAdapter`) 확장(Interstitial + Rewarded)으로 AdRaven 도입 시 화면 코드 변경을 최소화.

---

## 4. 090 IAP 설계서 상세 검토 (2026-02-20)

**대상**: `090_IAP_Implementation_Plan.md` (문서 035 IAP)

### 4.1 완성도 점수

| 구분 | 점수 | 비고 |
|------|------|------|
| **수정 전** | **88/100** | API 스키마·설정·reference_id 단일 정의·리팩토링 검증 등 미비 |
| **수정 후** | **100/100** | 아래 정정·보완 반영 완료 |

### 4.2 정정·보완 사항 (완성도 100 달성)

- **API 계약 명시**: `PurchaseVerifyRequest`(product_id, purchase_token), `PurchaseVerifyResponse`(success, coins_granted, already_processed) 스키마를 4.1에 추가. 에러 응답 일관성(400/404/500) 명시.
- **설정 SSOT**: 백엔드 4.0에 설정 및 환경 변수 표 추가 — `COIN_PACKAGES_PATH`, `GOOGLE_APPLICATION_CREDENTIALS`, `PACKAGE_NAME`. 가격은 설정에 두지 않음(스토어가 진실).
- **reference_id 단일 정의(SSOT)**: `coin_transactions.reference_id`를 **order_id 우선, 없을 때만 purchase_token**으로 통일하여 구현·운영 시 혼동 제거.
- **order_id 유니크 조건**: `order_id`가 NULL이 아닐 때만 유니크 적용(부분 유니크)으로 명시. DB별 구현 예시 추가.
- **원자 처리 반환 스펙**: `process_iap_purchase_atomic` 반환 객체(coins_granted, already_processed)를 설계서에 명시.
- **레이트 리밋 구체화**: `/api/payments/verify` 권장값 — user 10회/분, IP 30회/분(운영 조정 가능) 명시.
- **리팩토링 원칙 검증**: 섹션 9.5 리팩토링 용이성 추가 — 단일 진입점 유지, 상품→코인 변경 시 YAML만 수정하도록 설계.
- **버전**: v1.3, 수정일 2026-02-20, 변경 이력 갱신.

### 4.3 원칙 검증 결과 (090 기준)

| 원칙 | 부합 여부 | 요약 |
|------|-----------|------|
| **중복방지(Idempotency)** | ✅ | purchase_token 유니크, coin_transactions(reference_type, reference_id) 유니크, 멱등 성공 응답 |
| **리팩토링 원칙** | ✅ | 결제 검증·지급 단일 진입점(process_iap_purchase_atomic → CoinService.grant_coins), 설정 변경은 YAML만 |
| **DRY** | ✅ | 코인 지급은 CoinService.grant_coins 단일 경로, 상품→코인은 coin_packages.yaml 단일 소스 |
| **SSOT** | ✅ | 상품→코인: coin_packages.yaml, 가격: 스토어 ProductDetails, reference_id 규칙 단일 정의 |
| **KISS** | ✅ | Phase 1 = 검증 + 지급 + 클라 completePurchase, 환불 자동 차감은 Phase 2로 분리 |

**결론**: 090 IAP 설계서는 위 정정·보완 반영 후 완성도 100점을 충족하며, 중복방지·리팩토링·DRY·SSOT·KISS 원칙에 부합함.

---

## 5. 091 광고 설계서 상세 검토 (2026-02-20)

**대상**: `091_AdMob_AdRaven_Implementation_Plan.md` (문서 036 광고)

### 5.1 완성도 점수

| 구분 | 점수 | 비고 |
|------|------|------|
| **수정 전** | **87/100** | SSV API 계약·설정·reference SSOT 단일 정의·리팩토링·테스트 항목 미비 |
| **수정 후** | **100/100** | 아래 정정·보완 반영 완료 |

### 5.2 정정·보완 사항 (완성도 100 달성)

- **reference 형식 SSOT**: 보상 코인 원장 기록은 `reference_type='ads/ssv'`, `reference_id=transaction_id`만 사용한다고 4.3에 단일 정의 명시(다른 형식 혼용 금지).
- **SSV API 계약**: 요청(query params), 응답(서명 실패 401, 멱등 200), 처리 순서 명시. CoinService 단일 경로로 기록한다고 명시.
- **백엔드 설정**: 4.4 추가 — SSV 서명 검증용 공개키 소스, `ADMOB_SSV_KEYS_PATH` 등 환경 변수 권장(키 하드코딩 금지).
- **테스트 항목**: 6.1 추가 — SSV 멱등, 서명 실패 401, 로드 실패 백오프, 동의 플로우.
- **리팩토링 원칙 검증**: 7.5 리팩토링 용이성 추가 — 네트워크 전환 1곳(_NETWORK), 보상 지급 CoinService 단일 경로, 정책은 ad_policy만 수정.
- **버전**: v1.3, 수정일 2026-02-20, 변경 이력 갱신.

### 5.3 원칙 검증 결과 (091 기준)

| 원칙 | 부합 여부 | 요약 |
|------|-----------|------|
| **중복방지(Idempotency)** | ✅ | transaction_id를 reference_id 유니크로 사용, 동일 callback 재호출 시 200 멱등·코인 1회만 지급 |
| **리팩토링 원칙** | ✅ | 네트워크 전환 1곳, 보상 지급 CoinService 단일 경로, 정책 ad_policy 단일 파일 |
| **DRY** | ✅ | 광고 정책 AdPolicy 단일 파일, SDK 호출 어댑터 내부 격리 |
| **SSOT** | ✅ | 보상 지급 진실은 coin_transactions, reference 형식 'ads/ssv'+transaction_id 단일 정의, 앱 정책 ad_policy.dart |
| **KISS** | ✅ | 화면은 AdService 두 메서드만 호출, 네트워크 전환은 어댑터 교체로 제한 |

**결론**: 091 광고 설계서는 위 정정·보완 반영 후 완성도 100점을 충족하며, 중복방지·리팩토링·DRY·SSOT·KISS 원칙에 부합함.

---

**결론**: 위 설계서들(034, 035, 036, 090, 091)은 현재 구현 단계로 진입하기에 충분한 완성도를 갖추었으며, 유지보수성과 확장성을 고려한 아키텍처 원칙을 준수하고 있음.
