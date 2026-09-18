# 설계 오류 및 개선 필요 사항 보고서
## Design Issues and Improvements Report

**문서**: `005_Implementation_Logic_and_Module_Design.md`  
**검토일**: 2025-01-02 19:30:00 EST  
**검토자**: AI Assistant  
**심각도 분류**: 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 CRITICAL: 치명적 설계 오류

### 1. 코인 차감과 번호 생성의 분리 (Race Condition)

**위치**: 섹션 14.2, 21.4

**문제**:
```python
# 번호 생성 API (섹션 14.2)
@router.post("/", response_model=GenerationResponse)
async def generate_numbers(
    request_data: GenerationRequest,
    req: Request,
    current_user = Depends(get_current_user)
):
    # 코인 차감 로직 없음!
    result = await service.generate(...)
    return GenerationResponse(...)

# 코인 차감 API (섹션 21.4)
@router.post("/spend")
async def spend_coins(
    algorithm_id: int,
    n_sets: int,
    ...
):
    # 번호 생성 로직 없음!
    wallet.balance -= total_cost
    ...
```

**위험**:
1. **Race Condition**: 사용자가 코인 차감 없이 번호 생성 가능
2. **부정 사용**: `/api/generate`를 직접 호출하면 무료로 번호 생성
3. **데이터 불일치**: 코인 잔액과 실제 생성 기록 불일치

**해결책**:
```python
# 올바른 설계
@router.post("/generate", response_model=GenerationResponse)
async def generate_numbers(
    request_data: GenerationRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. 코인 잔액 확인 및 차감 (트랜잭션 시작)
    wallet = db.query(CoinWallet).filter(...).with_for_update().first()
    
    cost = calculate_cost(request_data.algorithm_id, request_data.n_sets)
    if not wallet.has_enough(cost):
        raise HTTPException(402, "코인 부족")
    
    wallet.balance -= cost
    
    # 2. 번호 생성
    result = await service.generate(...)
    
    # 3. 거래 기록 (성공 시에만)
    transaction = CoinTransaction(...)
    db.add(transaction)
    
    # 4. 커밋 (원자성 보장)
    db.commit()
    
    return GenerationResponse(...)
```

**영향도**: 🔴 **매우 높음** - 수익 모델 핵심 기능 무력화

---

### 2. 광고 시청 보상의 서버 검증 부재

**위치**: 섹션 21.4 (`/api/coins/watch-ad`)

**문제**:
```python
@router.post("/watch-ad")
async def watch_ad_reward(...):
    # 광고 시청 여부를 서버에서 검증하지 않음!
    coins_earned = 5
    wallet.balance += coins_earned
    ...
```

**위험**:
1. **부정 획득**: 광고를 보지 않고도 API 직접 호출로 코인 획득
2. **봇 공격**: 자동화 스크립트로 무한 코인 생성
3. **수익 손실**: 광고 수익 없이 코인만 지급

**해결책**:
```python
@router.post("/watch-ad")
async def watch_ad_reward(
    ad_verification_token: str,  # 광고 SDK에서 발급
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. 광고 SDK 서버에 검증 요청
    is_valid = await verify_ad_completion(
        ad_verification_token,
        current_user.id
    )
    
    if not is_valid:
        raise HTTPException(400, "광고 시청 검증 실패")
    
    # 2. 중복 검증 (동일 토큰 재사용 방지)
    if await is_token_already_used(ad_verification_token):
        raise HTTPException(400, "이미 사용된 보상")
    
    # 3. 코인 지급
    ...
```

**영향도**: 🔴 **매우 높음** - 무료 코인 시스템 악용 가능

---

## 🟠 HIGH: 높은 우선순위 개선 필요

### 3. 코인 지갑의 동시성 제어 부재

**위치**: 섹션 21.3 (`CoinWallet` 모델)

**문제**:
- `balance` 업데이트 시 **낙관적/비관적 락** 없음
- 동시 요청 시 잔액 불일치 발생 가능

**시나리오**:
```
사용자 잔액: 100코인

[요청 1] 번호 생성 (30코인) → 잔액 조회: 100 → 차감: 70
[요청 2] 번호 생성 (30코인) → 잔액 조회: 100 → 차감: 70

결과: 60코인이 차감되어야 하나 30코인만 차감됨
```

**해결책**:
```python
# 비관적 락 (권장)
wallet = db.query(CoinWallet).filter(
    CoinWallet.user_id == current_user.id
).with_for_update().first()

# 또는 낙관적 락
class CoinWallet(Base):
    version = Column(Integer, default=1)  # 버전 컬럼 추가
    
    def update_balance(self, amount: int):
        self.balance += amount
        self.version += 1
```

**영향도**: 🟠 **높음** - 재무 데이터 무결성

---

### 4. IAP 영수증 검증 로직 미구현

**위치**: 섹션 21.4 (`/api/coins/purchase`)

**문제**:
```python
payment_result = await payment_service.verify_iap(
    provider=request.payment_provider,
    receipt=request.payment_id,
    expected_product_id=request.package_id
)
# PaymentService가 실제로 구현되지 않음
```

**필요 구현**:
1. **Apple IAP 검증**: App Store 서버 API 호출
2. **Google IAP 검증**: Google Play Billing API 호출
3. **중복 결제 방지**: 동일 영수증 재사용 차단
4. **환불 처리**: 환불 시 코인 회수

**해결책**:
```python
class PaymentService:
    async def verify_apple_receipt(self, receipt: str):
        # 1. App Store 서버 검증
        response = await aiohttp.post(
            'https://buy.itunes.apple.com/verifyReceipt',
            json={'receipt-data': receipt}
        )
        
        # 2. 영수증 파싱 및 검증
        data = await response.json()
        if data['status'] != 0:
            return {'success': False, 'error': 'Invalid receipt'}
        
        # 3. 중복 검증
        transaction_id = data['receipt']['transaction_id']
        if await self.is_transaction_used(transaction_id):
            return {'success': False, 'error': 'Already used'}
        
        return {'success': True, 'transaction_id': transaction_id}
```

**영향도**: 🟠 **높음** - 결제 사기 방지 필수

---

### 5. 게스트 사용자의 코인 지갑 생성 누락

**위치**: 섹션 20.4 (`/api/auth/guest/create`)

**문제**:
```python
@router.post("/guest/create")
async def create_guest_user(...):
    guest_user = User(...)
    db.add(guest_user)
    db.flush()
    
    wallet = CoinWallet(user_id=guest_user.id, balance=100)
    db.add(wallet)
    # 하지만 게스트는 유료 코인 구매 불가로 설계됨
```

**모순**:
- 게스트는 유료 구매 불가인데 코인 지갑 생성
- 게스트 → 정식 전환 시 지갑 병합 로직 없음

**해결책**:
```python
@router.post("/upgrade-from-guest")
async def upgrade_from_guest(...):
    # 게스트의 기존 지갑 유지 (병합 불필요)
    current_user.is_guest = False
    
    # 또는 지갑을 새로 생성하고 기존 잔액 이전
    old_wallet = current_user.coin_wallet
    old_balance = old_wallet.balance
    
    # 전환 보너스 추가
    old_wallet.balance += 100
```

**영향도**: 🟠 **높음** - 데이터 일관성

---

## 🟡 MEDIUM: 중요도 중간

### 6. 연속 로그인 보상 계산 오류

**위치**: 섹션 21.3 (`CoinWallet.check_consecutive_login()`)

**문제**:
```python
if self.consecutive_login_days == 7:
    return 35  # 5 + 30 보너스
elif self.consecutive_login_days == 30:
    return 205  # 5 + 200 보너스
```

**버그**:
- 30일 연속 시에도 7일 보너스가 이미 지급되었으므로 중복
- 7일, 14일, 21일, 28일에도 보너스 없음 (오직 7과 30만)

**개선안**:
```python
def check_consecutive_login(self):
    ...
    base_reward = 5
    bonus = 0
    
    if self.consecutive_login_days % 7 == 0:
        # 7일마다 보너스
        bonus = 30
    
    if self.consecutive_login_days == 30:
        # 30일 특별 보너스 (추가)
        bonus += 200
    
    return base_reward + bonus
```

**영향도**: 🟡 **중간** - 사용자 경험

---

### 7. 코인 소멸 정책 미구현

**위치**: 섹션 22.4.2 (Churn 방지)

**언급만 있고 구현 없음**:
```yaml
코인 소멸 정책:
  - 1년 미사용 코인 자동 소멸 (사전 알림)
  - 소멸 30일 전 푸시: "500코인이 곧 사라져요!"
```

**필요 구현**:
1. Celery 주기적 작업
2. 마지막 활동 시각 추적
3. 소멸 전 알림 발송
4. 소멸 실행 및 로깅

**영향도**: 🟡 **중간** - 장기 사용자 관리

---

### 8. 알고리즘별 코인 비용 하드코딩

**위치**: 섹션 21.4 (`/api/coins/spend`)

**문제**:
```python
coin_costs = {
    1: 5,   # 랜덤
    2: 15,  # 짝수 우대
    ...
}
```

**위험**:
- 비용 변경 시 코드 수정 필요
- A/B 테스트 불가능
- 사용자별 차등 가격 불가능

**개선안**:
```python
# DB에 저장
class AlgorithmPricing(Base):
    algorithm_id = Column(Integer, primary_key=True)
    base_price = Column(Integer, nullable=False)
    premium_price = Column(Integer, nullable=True)
    is_active = Column(Boolean, default=True)

# 동적 조회
pricing = db.query(AlgorithmPricing).filter(
    AlgorithmPricing.algorithm_id == algorithm_id
).first()

cost = pricing.base_price
```

**영향도**: 🟡 **중간** - 유연성 및 확장성

---

## 🟢 LOW: 낮은 우선순위

### 9. 환율 변동 대응 부재

**위치**: 섹션 21.2.2 (코인 패키지)

**문제**:
- 가격이 ₩(원화)로 고정
- 글로벌 진출 시 환율 변동 반영 불가

**개선안**:
```python
class CoinPackage(Base):
    package_id = Column(String, primary_key=True)
    base_price_usd = Column(Numeric, nullable=False)
    bonus_percent = Column(Integer, default=0)
    
    def get_local_price(self, currency: str):
        # 환율 API 호출 또는 캐시된 환율 사용
        return convert_currency(self.base_price_usd, 'USD', currency)
```

**영향도**: 🟢 **낮음** - Phase 3 이후

---

### 10. 코인 거래 감사 로그 부족

**위치**: 섹션 21.3 (`CoinTransaction`)

**문제**:
- IP 주소, 기기 정보 미기록
- 부정 거래 추적 어려움

**개선안**:
```python
class CoinTransaction(Base):
    ...
    ip_address = Column(String(45))  # IPv6 지원
    device_id = Column(String(255))
    user_agent = Column(Text)
```

**영향도**: 🟢 **낮음** - 보안 강화

---

## 📊 우선순위 매트릭스

| 순위 | 문제 | 심각도 | 구현 난이도 | 권장 Phase |
|------|------|--------|-------------|-----------|
| 1 | 코인 차감과 번호 생성 분리 | 🔴 Critical | Medium | **즉시** |
| 2 | 광고 검증 부재 | 🔴 Critical | High | **즉시** |
| 3 | 동시성 제어 부재 | 🟠 High | Low | Phase 1 |
| 4 | IAP 영수증 검증 | 🟠 High | High | Phase 1 |
| 5 | 게스트 지갑 병합 | 🟠 High | Medium | Phase 1 |
| 6 | 연속 로그인 버그 | 🟡 Medium | Low | Phase 2 |
| 7 | 코인 소멸 정책 | 🟡 Medium | Medium | Phase 2 |
| 8 | 비용 하드코딩 | 🟡 Medium | Low | Phase 2 |
| 9 | 환율 대응 | 🟢 Low | Medium | Phase 3 |
| 10 | 감사 로그 | 🟢 Low | Low | Phase 3 |

---

## 🎯 즉시 수정 필요 (Critical)

### 수정 계획

```yaml
Phase 0 (즉시):
  1. 번호 생성 API에 코인 차감 통합
  2. 광고 검증 토큰 추가
  3. DB 트랜잭션 원자성 보장

Phase 1 (2주 이내):
  4. IAP 영수증 검증 구현
  5. 동시성 제어 (비관적 락)
  6. 게스트 전환 로직 정리

Phase 2 (1개월 이내):
  7-8. 로직 개선 및 DB 리팩터링

Phase 3 (3개월 이내):
  9-10. 글로벌화 및 보안 강화
```

---

## 📝 결론

### 현재 설계 상태
- ✅ **아키텍처 구조**: 훌륭함 (Flutter + FastAPI + PostgreSQL)
- ✅ **모듈 분리**: 명확함 (레이어 구조 우수)
- ⚠️ **보안 및 무결성**: **치명적 결함 존재**
- ⚠️ **비즈니스 로직**: **수익 모델 보호 부족**

### 권장사항
1. **🔴 Critical 이슈 2개는 개발 착수 전 필수 수정**
2. Phase 1까지 모든 🟠 High 이슈 해결
3. 보안 감사 및 부하 테스트 필수

### 전체 평가
**설계 품질**: ⭐⭐⭐☆☆ (3/5)
- 구조는 우수하나 세부 구현에서 치명적 보안 결함 존재
- 수정 후 ⭐⭐⭐⭐⭐ 달성 가능

---

**보고서 작성**: 2025-01-02 19:30:00 EST  
**검토자**: AI Assistant  
**다음 단계**: 마스터 승인 후 수정 작업 진행

