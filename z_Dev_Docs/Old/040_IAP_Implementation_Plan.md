# 035. IAP (In-App Purchase) 구현 계획

**작성일**: 2026-01-19  
**수정일**: 2026-02-20  
**버전**: 1.3 (완성도 100 검토 반영)  
**대상**: LuckyAI 645 Flutter 앱 + FastAPI 백엔드  
**목표**: 코인 구매 시스템 구현 (SSOT, DRY 준수)

---

## ✅ 리뷰 요약 (완성도 100점 기준 반영)

### 결정 사항(중복방지/SSOT/KISS)
- **SSOT(상품→코인 매핑)**: `coin_packages.yaml`은 “결제에 쓰는 가격”이 아니라 **product_id → coins** 매핑의 진실이다.
  - 실제 가격/통화 표시는 **스토어(ProductDetails)**를 우선 사용한다.
- **중복 방지(Idempotency)**: `order_id` 뿐 아니라 **`purchase_token`도 유니크**로 잡는다.
- **원장/지급**: 코인 지급은 `coin_transactions`에 `reference_type='iap'`로 기록하고 유니크 충돌 시 **성공으로 취급(멱등)**한다.
- **Acknowledge/CompletePurchase**: Phase 1은 **클라이언트에서 `completePurchase`로 처리**(가장 단순/일반적). 서버는 검증+지급만 담당.

### 변경 이력
- v1.2: SSOT 정의 수정(가격 제거), DB 제약/트랜잭션/멱등/환불 정책/운영·테스트 보강 (2026-02-13)
- v1.3: API 스키마·설정·reference_id SSOT 단일화, order_id 부분 유니크 명시, 레이트리밋 권장값, 리팩토링 검증(9.5) 추가 (2026-02-20)

## 📋 목차

1. [개요](#1-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [데이터 SSOT 관리](#3-데이터-ssot-관리)
4. [백엔드 구현](#4-백엔드-구현)
5. [프론트엔드 구현](#5-프론트엔드-구현)
6. [환불/취소/이상 상황 정책](#6-환불취소이상-상황-정책)
7. [운영/보안/테스트](#7-운영보안테스트)
8. [구현 체크리스트](#8-구현-체크리스트)
9. [원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)](#9-원칙-검증-중복방지dryssotkiss)

---

## 1. 개요

### 1.1 목표
- Google Play IAP를 통한 코인 구매.
- 영수증 검증을 통한 위변조 방지.
- **SSOT 원칙**: “product_id → coins” 매핑은 `coin_packages.yaml`을 유일한 진실 공급원으로 함.

### 1.2 선행 조건
- **034 OAuth**: 사용자 인증(`get_current_user`)이 선행되어야 함.

---

## 2. 시스템 아키텍처

### 2.1 결제 검증 플로우

```
[Flutter] 구매 완료 -> purchase_token 수신 -> [백엔드] /api/payments/verify 요청
[백엔드] Google Play API로 토큰 검증 -> 상품 ID 확인 -> 코인 지급 -> DB 기록 -> [Flutter] 응답
```

---

## 3. 데이터 SSOT 관리

### 3.1 코인 패키지 정의 (`backend/app/config/coin_packages.yaml`)

이 파일은 **결제 가격의 진실(SSOT)이 아니다.**
- 가격/통화/현지화 표시는 **Google Play에서 내려주는 ProductDetails**를 우선 사용한다.
- 이 파일은 오직 **상품 ID ↔ 코인 수량(그리고 선택적으로 UI 라벨)**을 관리한다.
- 099번 문서(가격 정책)와는 “정책적 의도”를 동기화하되, 실제 결제 금액은 스토어가 결정한다.

```yaml
packages:
  - id: "coins_10"
    coins: 10
  - id: "coins_75"
    coins: 75
  - id: "coins_175"
    coins: 175
  - id: "coins_375"
    coins: 375
  - id: "coins_900"
    coins: 900
```

---

## 4. 백엔드 구현

### 4.0 설정 및 환경 변수 (SSOT)

| 변수/설정 | 용도 | 비고 |
|-----------|------|------|
| `COIN_PACKAGES_PATH` | `coin_packages.yaml` 파일 경로 | 기본값 예: `backend/app/config/coin_packages.yaml` |
| `GOOGLE_APPLICATION_CREDENTIALS` | Google Play Developer API Service Account JSON 경로 | 환경별(Dev/Prod) 분리 |
| `PACKAGE_NAME` | 앱 패키지명 (검증 시 사용) | 예: `com.example.luckyai645` |

- 가격/통화는 스토어가 진실이므로 **설정에 가격을 두지 않는다.**

### 4.1 결제 검증 API (`payments.py`)

#### 요청/응답 스키마 (API 계약)

- **PurchaseVerifyRequest**
  - `product_id`: str (필수) — 스토어 상품 ID
  - `purchase_token`: str (필수) — Google Play 구매 토큰
- **PurchaseVerifyResponse**
  - `success`: bool
  - `coins_granted`: int — 이번 호출로 지급된 코인 (멱등 시 0)
  - `already_processed`: bool — 이미 처리된 주문이면 true

#### 핸들러

```python
@router.post("/verify", response_model=PurchaseVerifyResponse)
async def verify_purchase(
    request: PurchaseVerifyRequest,
    user = Depends(get_current_user)  # 034 의존성
):
    # 1. 영수증 검증 (Google API)
    iap_service = get_iap_service()
    verification = iap_service.verify_purchase(request.product_id, request.purchase_token)
    
    if not verification['valid']:
        raise HTTPException(400, "Invalid purchase")

    # 2. 중복 처리 방지 (Idempotency)
    # ✅ v1.2: order_id 또는 purchase_token 중 하나라도 이미 처리되면 "성공"으로 응답(멱등)
    # - DB에서 유니크 제약으로 보장하는 것을 권장한다.

    # 3. 코인 수량 조회 (SSOT: YAML)
    coins = get_coins_from_package(request.product_id)
    
    # 4. 트랜잭션 및 코인 지급 (Atomic)
    try:
        # 권장: 하나의 DB 트랜잭션 안에서
        # - payment_orders upsert(유니크: order_id, purchase_token)
        # - coin_transactions insert(유니크: reference_type='iap', reference_id=order_id)
        # 유니크 충돌이면 멱등 성공 처리
        result = process_iap_purchase_atomic(
            user_id=user.id,
            order_id=verification["order_id"],
            product_id=request.product_id,
            purchase_token=request.purchase_token,
            coins=coins,
            raw=verification.get("raw"),
        )
        return PurchaseVerifyResponse(success=True, coins_granted=result.coins_granted, already_processed=result.already_processed)
    except Exception as e:
        # 로그 기록 및 롤백 처리 필요
        raise HTTPException(500, "Payment processing failed")
```

- **에러 응답 일관성**: `400` Invalid purchase / 잘못된 product_id, `404` Unknown product_id(SSOT에 없음), `500` 처리 실패.

#### 원자 처리 반환 스펙 (설계 참고)

- `process_iap_purchase_atomic(...)` 반환 객체: `coins_granted: int`, `already_processed: bool` (멱등 시 True, 코인 0).

### 4.2 Helper 함수 (구현 상세)

```python
import yaml
from app.config import settings

def get_coins_from_package(product_id: str) -> int:
    """SSOT: coin_packages.yaml에서 코인 수량 조회"""
    with open(settings.COIN_PACKAGES_PATH, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
        for pkg in data.get('packages', []):
            if pkg['id'] == product_id:
                return pkg['coins']
    raise ValueError(f"Unknown product_id: {product_id}")
```

### 4.3 DB 모델(권장) 및 제약(멱등/중복방지 핵심)

#### `payment_orders`
- `id` (PK)
- `user_id`
- `order_id` (string, nullable; Google 응답에 있을 때만 저장)
- `purchase_token` (string)
- `product_id`
- `coins`
- `purchase_time`
- `status` (received/verified/granted/failed)
- `raw_payload` (JSON; PII/토큰 마스킹 고려)
- `created_at`
- **Unique**: `purchase_token` (필수)
- **Unique**: `order_id` — order_id가 NULL이 아닐 때만 유니크 적용(부분 유니크). DB에 따라 `UNIQUE (order_id) WHERE order_id IS NOT NULL` 형태로 구현.

#### `coin_transactions` (034와 동일 원장)
- **reference_id SSOT**: IAP 건은 **`reference_id = payment_orders.order_id`로 통일**. order_id가 없을 때만 `purchase_token`을 reference_id로 사용(단일 정의로 중복/혼동 방지).
- `reference_type='iap'`, `reference_id` (위 규칙)
- **Unique**: `(reference_type, reference_id)`

---

## 5. 프론트엔드 구현

### 5.1 IAP 서비스 (`iap_service.dart`)
- `in_app_purchase` 패키지 사용.
- 앱 시작 시 `InAppPurchase.instance.purchaseStream` 리스닝 필수.
- 구매 성공 시 백엔드 `/verify` API 호출.
- 백엔드 성공 응답 후 `InAppPurchase.instance.completePurchase(purchaseDetails)` 호출(acknowledge 처리).

### 5.2 UI (`coin_shop_screen.dart`)
- 상품 목록 표시.
- 구매 버튼 클릭 -> `buyConsumable` 호출.
- 가격 표시는 스토어 `ProductDetails.price`를 사용(SSOT 혼동 방지).

---

## 6. 환불/취소/이상 상황 정책

### 6.1 환불/차지백(정책 명시 필수)
- **권장(단순)**: 환불 발생 시에도 이미 사용된 코인은 회수하지 않는다(지원 비용/분쟁 최소화).  
  - 단, 악용 탐지 시 계정 제재는 별도 정책으로 처리.
- **대안(엄격)**: 환불 이벤트 수신 시 미사용 코인만큼 차감(원장에 음수 delta 기록).  
  - 구현 난이도↑ (코인 사용 추적 필요)

### 6.2 결제 성공 콜백 유실
- 앱이 종료되었거나 네트워크 문제로 `/verify`가 실패할 수 있음.
- 복구: purchaseStream에서 미완료 구매를 재시도하여 `/verify` 재호출(서버는 멱등 처리).

### 6.3 `purchase_token` 재사용/변조
- 서버는 Google API 검증 결과의 `productId/packageName/purchaseState` 등을 검증한다.
- 토큰 원문은 로그에 남기지 않는다.

---

## 7. 운영/보안/테스트

### 7.1 보안(필수)
- Google Play Developer API 호출용 **Service Account** 권한 최소화
- 환경별(Dev/Prod) packageName 분리 및 검증
- **레이트 리밋**: `/api/payments/verify` — user 기준 예: 10회/분, IP 기준 예: 30회/분 (구체값은 운영에서 조정)

### 7.2 테스트(최소 세트)
- 내부 테스트 트랙 결제(성공/중복/네트워크 실패/재시도)
- 서버 멱등: 같은 `purchase_token` 10회 호출해도 코인은 1회만 지급
- 잘못된 product_id는 400으로 거절

---

## 8. 구현 체크리스트

- [ ] **설정**: `coin_packages.yaml` 생성 및 배포 (SSOT)
- [ ] **백엔드**: `PaymentOrder` 모델 및 DB 마이그레이션
- [ ] **백엔드**: Google Play Developer API 연동 (Service Account)
- [ ] **백엔드**: `/verify` API 구현 (SSOT 로직 적용)
- [ ] **프론트**: IAP 패키지 연동 및 UI 구현
- [ ] **테스트**: 내부 테스트 트랙을 통한 결제 테스트

---

## 9. 원칙 검증 (중복방지/DRY/SSOT/KISS)

### 9.1 중복방지(Idempotency)
- [ ] `payment_orders.purchase_token` 유니크
- [ ] `coin_transactions(reference_type, reference_id)` 유니크로 코인 중복 지급 방지
- [ ] 중복 요청은 400이 아니라 **멱등 성공 응답**(클라이언트 재시도 친화)

### 9.2 DRY
- [ ] 코인 지급은 항상 `CoinService.grant_coins(..., reference_type, reference_id)` 단일 경로로만 수행

### 9.3 SSOT
- [ ] 상품→코인 매핑은 `coin_packages.yaml`
- [ ] 가격 표시는 스토어 ProductDetails(문서/코드에 하드코딩 금지)

### 9.4 KISS
- [ ] Phase 1은 “검증 + 지급 + completePurchase(클라)”로 단순 유지
- [ ] 환불 자동 차감은 Phase 2로 분리(정책 확정 후)

### 9.5 리팩토링 용이성
- [ ] 결제 검증·지급은 **단일 진입점** 유지: `process_iap_purchase_atomic` → `CoinService.grant_coins(..., reference_type='iap', reference_id=...)` 한 경로만 사용하여, 정책/원장 변경 시 수정 지점을 한 곳으로 제한
- [ ] 상품→코인 매핑 변경 시 `coin_packages.yaml`만 수정(코드 배포 없이 설정만 갱신 가능하도록 설계)

---

**관련 문서**:
- `034_OAuth_CoinWallet_Plan.md`: 인증
- `099_Coin_Pricing_Analysis.md`: 가격 정책 원본
