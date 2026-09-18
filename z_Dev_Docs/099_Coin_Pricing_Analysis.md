# 099. 코인 가격 정책 분석 및 비즈니스 모델 수립

**작성일**: 2026-01-19  
**버전**: 1.0  
**대상**: LuckyAI 645 로또 번호 생성 앱

---

## 📋 목차

1. [배경 및 문제 정의](#1-배경-및-문제-정의)
2. [API 비용 분석](#2-api-비용-분석)
3. [가격 시나리오 비교](#3-가격-시나리오-비교)
4. [최종 권장안](#4-최종-권장안)
5. [구현 계획](#5-구현-계획)

---

## 1. 배경 및 문제 정의

### 1.1 현재 상황

**기술적 구현**:
- ✅ Gemini 2.5 Flash API 통합 완료
- ✅ AI Selection 알고리즘 (Algorithm 8) 구현
- ✅ 코인 시스템 백엔드 구현 완료 (`coin_service.py`)
- ✅ `pricing_config.yaml` SSOT 적용

**가격 정책 고민**:
- 초기 계획: **15,000원 = 103코인** (코인당 145.6원)
- AI Selection 5세트 = 5코인 = **728원**
- 문제 제기: "번호 생성기 비용 700원은 너무 비싸다"
- 적정 가격: **150~200원** 정도

---

## 2. API 비용 분석

### 2.1 Gemini 2.5 Flash 공식 가격 (2026-01-18)

**출처**: https://ai.google.dev/pricing

```
Paid Tier (per 1M tokens, USD):
- Input price:  $0.30 (text/image/video)
- Output price: $2.50 (including thinking tokens)
```

### 2.2 실제 API 비용 측정

**실제 로그** (`20260118_235731_guest.txt`):
```
AI Selection 10세트 생성:
- Input Tokens:  7,201
- Output Tokens: 168
- Total Tokens:  7,369
- Cost: $0.0025803
```

**5세트 생성 시 추정**:
```
입력 토큰: 약 7,200 (고정, 100회차 데이터)
출력 토큰: 약 84 (5세트 × 16.8토큰/세트)

Input Cost  = (7,200 / 1,000,000) × $0.30 = $0.00216
Output Cost = (84 / 1,000,000) × $2.50   = $0.00021
─────────────────────────────────────────────────────
Total Cost  = $0.00237 (≈ $0.0024)
```

**원화 환산** (1 USD = 1,300 KRW):
```
API 비용 (5세트) = $0.00237 × 1,300 = 약 3.08원
```

### 2.3 비용 구조 분석

**핵심 인사이트**:
1. **입력 토큰 (7,200개) = 고정 비용** 
   - 비용: $0.00216 (약 2.8원)
   - **전체 비용의 84%** 차지

2. **출력 토큰 (세트당 ~17개) = 변동 비용**
   - 5세트: 84토큰 → $0.00021 (0.27원)
   - 10세트: 168토큰 → $0.00042 (0.55원)
   - **전체 비용의 16%** 차지

**중요한 발견**:
- API 비용은 매우 저렴함 (5세트당 **3.08원**)
- **마진율 98% 이상** 가능
- 비용 압박이 거의 없음

---

## 3. 가격 시나리오 비교

### 3.1 시나리오 A: 현재 계획 (보수적)

```
코인 패키지: 15,000원 = 103코인
코인당 가격: 145.6원
```

**AI Selection 5세트 비용**:
```
사용자 과금: 5코인 × 145.6원 = 728원
API 실비용: 3.08원
마진율: (728 - 3.08) / 728 = 99.6%
```

**문제점**:
- 사용자가 "비싸다"고 느낌
- 실제 로또 5게임(5,000원)의 14.6%
- 심리적 저항감 높음

---

### 3.2 시나리오 B: 대용량 패키지 (적극적)

```
코인 패키지: 15,000원 = 500코인
코인당 가격: 30원
```

**AI Selection 5세트 비용**:
```
사용자 과금: 5코인 × 30원 = 150원
API 실비용: 3.08원
마진율: (150 - 3.08) / 150 = 98.0%
```

**장점**:
- 사용자 만족도 높음 (로또 5게임의 3%)
- 여전히 98% 마진
- 프리미엄 이미지 (대용량 패키지)

**단점**:
- 코인 가치가 너무 낮을 수 있음
- 프리미엄 기능의 가치 하락 우려

---

### 3.3 시나리오 C: 중간 패키지 (균형)

```
코인 패키지: 15,000원 = 375코인
코인당 가격: 40원
```

**AI Selection 5세트 비용**:
```
사용자 과금: 5코인 × 40원 = 200원
API 실비용: 3.08원
마진율: (200 - 3.08) / 200 = 98.5%
```

**장점**:
- ✅ 사용자 적정 가격 (로또 5게임의 4%)
- ✅ 충분한 마진 (98.5%)
- ✅ 코인 가치 적정
- ✅ 다양한 기능 사용 가능

---

### 3.4 시나리오 D: 프리미엄 (현실적)

```
코인 패키지: 15,000원 = 300코인
코인당 가격: 50원
```

**AI Selection 5세트 비용**:
```
사용자 과금: 5코인 × 50원 = 250원
API 실비용: 3.08원
마진율: (250 - 3.08) / 250 = 98.8%
```

**장점**:
- 사용자 수용 가능 (로또 5게임의 5%)
- 코인 가치 적정
- 다양한 패키지 구성 가능

---

## 4. 최종 권장안

### 4.1 추천: Option 3 - 프리미엄 중심 전략

**핵심 패키지**:
```
프리미엄 패키지 (추천):
15,000원 = 375코인 (코인당 40원)

→ AI Selection 5세트 생성 = 5코인 = 200원 ✅
→ 로또 5게임(5,000원) 대비 4% = 합리적!
→ API 실비용(3.08원) 대비 65배 = 충분한 마진!
```

### 4.2 전체 패키지 구조

| 패키지 | 가격 | 코인 개수 | 코인당 가격 | AI 5세트 비용 | 특징 |
|--------|------|----------|-----------|-------------|------|
| 체험 | 1,000원 | 10개 | 100원 | **500원** | 신규 유저 |
| 스타터 | 5,000원 | 75개 | 66.7원 | **333원** | 소량 구매 |
| 베이직 | 10,000원 | 175개 | 57.1원 | **286원** | 일반 |
| **프리미엄** | **15,000원** | **375개** | **40원** | **200원** | **인기** ⭐ |
| 메가 | 30,000원 | 900개 | 33.3원 | **167원** | 헤비 유저 |

### 4.3 알고리즘별 코인 소비 (참고)

**`pricing_config.yaml` 기준**:
```yaml
algorithm_costs:
  1: 0    # 순수 랜덤 (무료)
  6: 1    # 기본 빈도 분석 (1코인/세트)
  7: 1    # 핫/콜드 (1코인/세트)
  8: 1    # AI Selection (1코인/세트) ⭐
  4: 2    # 패턴 분석 (2코인/세트)
  2: 2    # 고급 빈도 분석 (2코인/세트)
  3: 3    # LSTM 고급 분석 (3코인/세트)
  5: 3    # 가중치 조합 (3코인/세트)
```

**프리미엄 패키지 (375코인) 활용 예시**:
```
- AI Selection 5세트:    5코인 × 75회 = 375회 사용 가능
- 또는 혼합 사용:
  - AI Selection 50회 = 250코인
  - LSTM 분석 30회 = 90코인
  - 기본 알고리즘은 무료/저렴
```

---

## 5. 구현 계획

### 5.1 현재 구현 상태

**백엔드**:
- ✅ `coin_service.py`: 코인 지급/차감 로직 완료
- ✅ `pricing_config.yaml`: 알고리즘별 코인 소비량 정의
- ✅ API 라우트: `/api/users/{user_id}/coins` 구현

**프론트엔드**:
- 🔄 코인 구매 화면 미구현 (IAP 연동 필요)
- 🔄 패키지 옵션 UI 미구현

### 5.2 구현 작업

#### Phase 1: 코인 패키지 정의 (Backend)

**파일 생성**: `backend/app/config/coin_packages.yaml`

```yaml
# 코인 패키지 정의
# 2026-01-19 - 최종 가격 정책 반영

default_package: "premium"

packages:
  trial:
    id: "coins_10"
    name: "체험 패키지"
    description: "처음 사용하시나요? 소량 체험"
    coins: 10
    price_krw: 1000
    price_usd: 0.77
    discount_rate: 0.0
    badge: "신규"
    
  starter:
    id: "coins_75"
    name: "스타터 패키지"
    description: "가볍게 시작하기"
    coins: 75
    price_krw: 5000
    price_usd: 3.85
    discount_rate: 0.0
    badge: null
    
  basic:
    id: "coins_175"
    name: "베이직 패키지"
    description: "꾸준히 사용하시는 분께"
    coins: 175
    price_krw: 10000
    price_usd: 7.69
    discount_rate: 14.3
    badge: "14% 할인"
    
  premium:
    id: "coins_375"
    name: "프리미엄 패키지"
    description: "가장 인기 있는 선택"
    coins: 375
    price_krw: 15000
    price_usd: 11.54
    discount_rate: 20.0
    badge: "인기"
    recommended: true
    
  mega:
    id: "coins_900"
    name: "메가 패키지"
    description: "헤비 유저를 위한 대용량"
    coins: 900
    price_krw: 30000
    price_usd: 23.08
    discount_rate: 33.3
    badge: "최대 33% 할인"

# 신규 가입 보너스
welcome_bonus:
  enabled: true
  coins: 5
  message: "가입을 환영합니다! 5코인을 드립니다."

# 친구 추천 보너스 (미래)
referral_bonus:
  enabled: false
  referrer_coins: 10
  referee_coins: 5
```

#### Phase 2: IAP 상품 등록 (Google Play Console)

**Play Console > 수익 창출 > 인앱 상품**:

| 상품 ID | 상품명 | 가격 | 설명 |
|---------|--------|------|------|
| `coins_10` | 체험 패키지 | ₩1,000 | 코인 10개 |
| `coins_75` | 스타터 패키지 | ₩5,000 | 코인 75개 |
| `coins_175` | 베이직 패키지 | ₩10,000 | 코인 175개 (14% 할인) |
| `coins_375` | 프리미엄 패키지 | ₩15,000 | 코인 375개 (20% 할인) ⭐ |
| `coins_900` | 메가 패키지 | ₩30,000 | 코인 900개 (최대 33% 할인) |

#### Phase 3: 프론트엔드 코인샵 UI (Flutter)

**파일 생성**: `mobile_app/lib/presentation/screens/coin_shop_screen.dart`

```dart
// 코인샵 화면
// 2026-01-19 - 최종 가격 정책 적용

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinShopScreen extends StatefulWidget {
  @override
  _CoinShopScreenState createState() => _CoinShopScreenState();
}

class _CoinShopScreenState extends State<CoinShopScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  
  // 패키지 ID 목록
  final Set<String> _productIds = {
    'coins_10',
    'coins_75',
    'coins_175',
    'coins_375',
    'coins_900',
  };
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    
    setState(() {
      _products = response.productDetails;
      // 가격 순으로 정렬
      _products.sort((a, b) => 
        double.parse(a.rawPrice.toString())
          .compareTo(double.parse(b.rawPrice.toString()))
      );
    });
  }
  
  Future<void> _buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = 
        PurchaseParam(productDetails: product);
    
    await _iap.buyConsumable(
      purchaseParam: purchaseParam,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('코인 충전'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return CoinPackageCard(
            product: product,
            onPurchase: () => _buyProduct(product),
          );
        },
      ),
    );
  }
}

class CoinPackageCard extends StatelessWidget {
  final ProductDetails product;
  final VoidCallback onPurchase;
  
  const CoinPackageCard({
    required this.product,
    required this.onPurchase,
  });
  
  @override
  Widget build(BuildContext context) {
    // 코인 개수 추출 (예: coins_375 → 375)
    final coins = int.parse(product.id.replaceAll('coins_', ''));
    final isRecommended = product.id == 'coins_375';
    
    return Card(
      elevation: isRecommended ? 8 : 2,
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onPurchase,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품명
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRecommended)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '인기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              
              // 코인 개수
              Text(
                '🪙 $coins 코인',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
              SizedBox(height: 4),
              
              // 설명
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
              
              // 가격 및 구매 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.price,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onPurchase,
                    child: Text('구매'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? Colors.blue
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 5.3 마케팅 전략

#### 신규 사용자 유도

```
첫 구매 혜택:
- 신규 가입: 5코인 무료 증정
- 첫 구매 시: 20% 추가 지급
  예: 프리미엄 패키지 구매 → 375 + 75 = 450코인
```

#### 프로모션 이벤트

```yaml
# 시즌별 프로모션 (미래)
spring_event:
  name: "봄맞이 특가"
  period: "2026-03-01 ~ 2026-03-31"
  discount: 30%
  target_packages: ["premium", "mega"]
```

---

## 6. 수익 예측

### 6.1 예상 MAU 및 전환율

**보수적 시나리오**:
```
MAU (월간 활성 사용자): 1,000명
코인 구매 전환율: 5%
월간 구매자 수: 50명
평균 구매 금액: 15,000원 (프리미엄 패키지)

월간 매출: 50명 × 15,000원 = 750,000원
연간 매출: 9,000,000원
```

**낙관적 시나리오**:
```
MAU: 10,000명
전환율: 10%
월간 구매자: 1,000명
평균 구매: 15,000원

월간 매출: 15,000,000원
연간 매출: 180,000,000원
```

### 6.2 비용 분석

```
월간 API 비용 (낙관적 시나리오):
- 총 AI 생성 요청: 10,000회 (월간)
- 평균 5세트 생성 가정
- API 비용: 10,000 × $0.0024 = $24 (약 31,200원)

기타 비용:
- AWS 서버: 50,000원
- 도메인: 2,000원
- 마케팅: 변동

총 운영 비용: 약 100,000원/월

순이익 (낙관적): 15,000,000 - 100,000 = 14,900,000원/월
```

---

## 7. 결론

### 7.1 최종 권장 가격

```
✅ 프리미엄 패키지 (추천):
15,000원 = 375코인 (코인당 40원)

→ AI Selection 5세트 = 200원
→ 사용자 만족도 ⬆
→ 충분한 마진 (98.5%)
→ 지속 가능한 비즈니스 모델
```

### 7.2 핵심 포인트

1. **API 비용은 매우 저렴함** (5세트당 3.08원)
2. **어떤 가격도 98% 이상 마진 가능**
3. **사용자 심리가 핵심**: 150~200원이 적정
4. **다양한 패키지로 선택권 제공**
5. **프리미엄 패키지를 메인으로 마케팅**

### 7.3 다음 단계

1. ✅ 이 문서 검토 및 승인
2. 🔄 `coin_packages.yaml` 생성
3. 🔄 Google Play Console IAP 상품 등록
4. 🔄 Flutter 코인샵 UI 구현
5. 🔄 결제 플로우 테스트
6. 🔄 프로덕션 출시

---

**작성자**: AI Assistant  
**검토자**: (검토 대기)  
**승인자**: (승인 대기)  
**최종 업데이트**: 2026-01-19

---

**관련 문서**:
- `033_Code_Quality_Audit_Plan.md` - 코드 품질 감사
- `034_OAuth_CoinWallet_Plan.md` - 계정 연동 및 코인지갑 (welcome_bonus 참조)
- `035_IAP_Implementation_Plan.md` - IAP 구현 계획 (coin_packages SSOT)
- `036_AdMob_AdRaven_Implementation_Plan.md` - 광고 수익 모델
