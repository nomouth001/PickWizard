# Phase 4 Part 2: 코인 시스템
## 백엔드 & Flutter 코인 관리

---

**Phase**: 4 Part 2 - Coin System  
**예상 기간**: 1.5-2일 (12-16시간)  
**선행 조건**: Phase 4 Part 1 완료 (게스트 인증)  
**목표**: 코인 시스템 완성 및 번호 생성 통합

---

## 작업 4.2: 백엔드 코인 시스템 (8-10시간)

### Step 4.2.1: 코인 지갑 모델

**파일**: `backend/app/db/models/coin_wallet.py`

```python
"""
코인 지갑 모델

2026-01-07 EST - 초기 생성
"""

from sqlalchemy import Column, Integer, BigInteger, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class CoinWallet(Base):
    """사용자 코인 지갑"""
    __tablename__ = "coin_wallets"
    
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id'),
        primary_key=True,
        comment="사용자 ID"
    )
    
    free_coins = Column(Integer, nullable=False, default=0, comment="무료 코인")
    paid_coins = Column(Integer, nullable=False, default=0, comment="유료 코인")
    total_earned = Column(BigInteger, nullable=False, default=0, comment="누적 획득")
    total_spent = Column(BigInteger, nullable=False, default=0, comment="누적 소비")
    
    # 관계
    user = relationship("User", back_populates="wallet")
    
    @property
    def total_coins(self) -> int:
        """총 코인 (무료 + 유료)"""
        return self.free_coins + self.paid_coins
    
    def deduct_coins(self, amount: int) -> bool:
        """
        코인 차감 (무료 코인 먼저 사용)
        
        Returns:
            성공 여부
        """
        if self.total_coins < amount:
            return False
        
        remaining = amount
        
        # 1. 무료 코인 먼저 차감
        if self.free_coins > 0:
            deduct_free = min(self.free_coins, remaining)
            self.free_coins -= deduct_free
            remaining -= deduct_free
        
        # 2. 유료 코인 차감
        if remaining > 0:
            self.paid_coins -= remaining
        
        self.total_spent += amount
        return True
    
    def add_free_coins(self, amount: int):
        """무료 코인 추가"""
        self.free_coins += amount
        self.total_earned += amount
    
    def add_paid_coins(self, amount: int):
        """유료 코인 추가"""
        self.paid_coins += amount
        self.total_earned += amount


class CoinTransaction(Base):
    """코인 거래 내역"""
    __tablename__ = "coin_transactions"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    amount = Column(Integer, nullable=False, comment="금액 (+ or -)")
    balance_after = Column(Integer, nullable=False, comment="거래 후 잔액")
    transaction_type = Column(String(50), nullable=False, comment="거래 유형")
    description = Column(String(255), comment="설명")
    
    __table_args__ = (
        Index('idx_user_transactions', 'user_id', 'created_at'),
    )
```

---

### Step 4.2.2: 코인 획득 API

**파일**: `backend/app/api/routes/coins.py`

```python
"""
코인 API 라우터

2026-01-07 EST - 초기 생성
"""

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.db.session import get_db
from app.db.models.coin_wallet import CoinWallet, CoinTransaction
from app.schemas.coins import (
    CoinBalanceResponse,
    DailyLoginResponse,
    WatchAdResponse,
)


router = APIRouter(prefix="/coins", tags=["Coins"])


@router.get("/balance", response_model=CoinBalanceResponse)
async def get_coin_balance(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """코인 잔액 조회"""
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == user_id
    ).first()
    
    if not wallet:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "지갑을 찾을 수 없습니다")
    
    return CoinBalanceResponse(
        total_coins=wallet.total_coins,
        free_coins=wallet.free_coins,
        paid_coins=wallet.paid_coins
    )


@router.post("/daily-login", response_model=DailyLoginResponse)
async def claim_daily_login(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """일일 로그인 보상"""
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == user_id
    ).with_for_update().first()
    
    if not wallet:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "지갑을 찾을 수 없습니다")
    
    # 1. 오늘 이미 받았는지 확인
    today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    existing = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == user_id,
        CoinTransaction.transaction_type == 'daily_login',
        CoinTransaction.created_at >= today_start
    ).first()
    
    if existing:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "오늘 이미 받으셨습니다")
    
    # 2. 보상 지급 (5코인)
    reward = 5
    wallet.add_free_coins(reward)
    
    # 3. 거래 기록
    transaction = CoinTransaction(
        user_id=user_id,
        amount=reward,
        balance_after=wallet.total_coins,
        transaction_type='daily_login',
        description='일일 로그인 보상'
    )
    db.add(transaction)
    db.commit()
    
    return DailyLoginResponse(
        reward=reward,
        total_coins=wallet.total_coins
    )


@router.post("/watch-ad", response_model=WatchAdResponse)
async def claim_ad_reward(
    user_id: UUID,
    ad_type: str,  # 'rewarded_video'
    db: Session = Depends(get_db)
):
    """광고 시청 보상"""
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == user_id
    ).with_for_update().first()
    
    if not wallet:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "지갑을 찾을 수 없습니다")
    
    # 1. 오늘 광고 시청 횟수 확인 (최대 5회)
    today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    count_today = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == user_id,
        CoinTransaction.transaction_type == 'ad_reward',
        CoinTransaction.created_at >= today_start
    ).count()
    
    if count_today >= 5:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "일일 광고 시청 한도 초과")
    
    # 2. 보상 지급 (5코인)
    reward = 5
    wallet.add_free_coins(reward)
    
    # 3. 거래 기록
    transaction = CoinTransaction(
        user_id=user_id,
        amount=reward,
        balance_after=wallet.total_coins,
        transaction_type='ad_reward',
        description=f'광고 시청 보상 ({count_today + 1}/5)'
    )
    db.add(transaction)
    db.commit()
    
    return WatchAdResponse(
        reward=reward,
        total_coins=wallet.total_coins,
        remaining_today=5 - count_today - 1
    )
```

---

### Step 4.2.3: 번호 생성 API에 코인 차감 통합

**파일**: `backend/app/api/routes/generate.py` (수정)

```python
"""
번호 생성 API (코인 차감 통합)

2026-01-07 EST - 코인 차감 추가
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID

from app.db.session import get_db
from app.db.models.coin_wallet import CoinWallet, CoinTransaction
from app.db.models.algorithm_pricing import AlgorithmPricing
from app.algorithms import get_algorithm
from app.schemas.generation import GenerateRequest, GenerateResponse


router = APIRouter(prefix="/generate", tags=["Generation"])


@router.post("/", response_model=GenerateResponse)
async def generate_numbers(
    request: GenerateRequest,
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """
    번호 생성 (코인 차감 통합)
    """
    # 1. 알고리즘 비용 조회
    pricing = db.query(AlgorithmPricing).filter(
        AlgorithmPricing.algorithm_id == request.algorithm_id
    ).first()
    
    if not pricing:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "알고리즘을 찾을 수 없습니다")
    
    total_cost = pricing.final_cost * request.n_sets
    
    # 2. 코인 지갑 조회 (비관적 락)
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == user_id
    ).with_for_update().first()
    
    if not wallet:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "지갑을 찾을 수 없습니다")
    
    # 3. 잔액 확인
    if wallet.total_coins < total_cost:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail=f"코인이 부족합니다 (필요: {total_cost}, 보유: {wallet.total_coins})"
        )
    
    # 4. 코인 차감
    success = wallet.deduct_coins(total_cost)
    if not success:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "코인 차감 실패")
    
    # 5. 거래 기록
    transaction = CoinTransaction(
        user_id=user_id,
        amount=-total_cost,
        balance_after=wallet.total_coins,
        transaction_type='number_generation',
        description=f'{pricing.algorithm_name} {request.n_sets}세트 생성'
    )
    db.add(transaction)
    
    # 6. 번호 생성
    try:
        algorithm = get_algorithm(request.algorithm_id)
        # 데이터 매니저에서 과거 데이터 로드
        from app.core.data_manager import data_manager
        historical_data = data_manager.get_dataframe()
        
        numbers = algorithm.generate_numbers(
            historical_data=historical_data,
            n_sets=request.n_sets,
            exclude_numbers=request.exclude_numbers,
            include_numbers=request.include_numbers
        )
        
        db.commit()
        
        return GenerateResponse(
            algorithm_id=algorithm.algorithm_id,
            algorithm_name=algorithm.name,
            results=[
                {'numbers': nums, 'set_no': i + 1}
                for i, nums in enumerate(numbers)
            ],
            timestamp=datetime.now(),
            total_cost=total_cost
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, str(e))
```

### 완료 기준 체크리스트
- [ ] CoinWallet 모델 DB 저장
- [ ] `/api/coins/daily-login` API 동작
- [ ] `/api/coins/watch-ad` API 동작 (일일 5회 제한)
- [ ] `/api/generate` 코인 차감 동작
- [ ] 잔액 부족 시 402 에러 반환

---

## 작업 4.3: Flutter 코인 시스템 (4-6시간)

### Step 4.3.1: 코인 API 클라이언트

**파일**: `lib/data/data_sources/remote/coin_api.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'coin_api.g.dart';

@RestApi(baseUrl: '')
abstract class CoinApi {
  factory CoinApi(Dio dio, {String baseUrl}) = _CoinApi;
  
  @GET('/api/coins/balance')
  Future<CoinBalanceResponse> getBalance(@Query('user_id') String userId);
  
  @POST('/api/coins/daily-login')
  Future<DailyLoginResponse> claimDailyLogin(@Query('user_id') String userId);
  
  @POST('/api/coins/watch-ad')
  Future<WatchAdResponse> claimAdReward(
    @Query('user_id') String userId,
    @Query('ad_type') String adType,
  );
}

class CoinBalanceResponse {
  final int totalCoins;
  final int freeCoins;
  final int paidCoins;
  
  CoinBalanceResponse({
    required this.totalCoins,
    required this.freeCoins,
    required this.paidCoins,
  });
  
  factory CoinBalanceResponse.fromJson(Map<String, dynamic> json) {
    return CoinBalanceResponse(
      totalCoins: json['total_coins'],
      freeCoins: json['free_coins'],
      paidCoins: json['paid_coins'],
    );
  }
}

class DailyLoginResponse {
  final int reward;
  final int totalCoins;
  
  DailyLoginResponse({required this.reward, required this.totalCoins});
  
  factory DailyLoginResponse.fromJson(Map<String, dynamic> json) {
    return DailyLoginResponse(
      reward: json['reward'],
      totalCoins: json['total_coins'],
    );
  }
}

class WatchAdResponse {
  final int reward;
  final int totalCoins;
  final int remainingToday;
  
  WatchAdResponse({
    required this.reward,
    required this.totalCoins,
    required this.remainingToday,
  });
  
  factory WatchAdResponse.fromJson(Map<String, dynamic> json) {
    return WatchAdResponse(
      reward: json['reward'],
      totalCoins: json['total_coins'],
      remainingToday: json['remaining_today'],
    );
  }
}
```

---

### Step 4.3.2: 코인 Provider

**파일**: `lib/presentation/providers/coin_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/data/data_sources/remote/coin_api.dart';
import 'package:luckyai_645/data/data_sources/remote/api_client.dart';
import 'package:luckyai_645/presentation/providers/auth_provider.dart';

/// CoinApi Provider
final coinApiProvider = Provider<CoinApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CoinApi(dio);
});

/// 코인 잔액 Provider
final coinBalanceProvider = FutureProvider<CoinBalanceResponse>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw Exception('로그인 필요');
  
  final api = ref.watch(coinApiProvider);
  return await api.getBalance(userId);
});

/// 일일 로그인 보상 Provider
final dailyLoginProvider = StateNotifierProvider<DailyLoginNotifier, AsyncValue<String?>>((ref) {
  return DailyLoginNotifier(ref);
});

class DailyLoginNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;
  
  DailyLoginNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> claim() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(coinApiProvider);
      final response = await api.claimDailyLogin(userId);
      
      // 잔액 갱신
      ref.invalidate(coinBalanceProvider);
      
      state = AsyncValue.data('${response.reward}코인을 받았습니다!');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 광고 시청 보상 Provider
final watchAdProvider = StateNotifierProvider<WatchAdNotifier, AsyncValue<String?>>((ref) {
  return WatchAdNotifier(ref);
});

class WatchAdNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref ref;
  
  WatchAdNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> claim() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(coinApiProvider);
      final response = await api.claimAdReward(userId, 'rewarded_video');
      
      // 잔액 갱신
      ref.invalidate(coinBalanceProvider);
      
      state = AsyncValue.data(
        '${response.reward}코인을 받았습니다! (오늘 남은 횟수: ${response.remainingToday})'
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}
```

---

### Step 4.3.3: 코인 잔액 위젯

**파일**: `lib/presentation/widgets/coin_balance_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';
import 'package:luckyai_645/presentation/providers/coin_provider.dart';
import 'package:luckyai_645/presentation/screens/coin_store/coin_store_screen.dart';

class CoinBalanceWidget extends ConsumerWidget {
  const CoinBalanceWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(coinBalanceProvider);
    
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CoinStoreScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 4),
            balanceAsync.when(
              data: (balance) => Text(
                '${balance.totalCoins}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Text('-'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 4.3.4: 코인 스토어 화면

**파일**: `lib/presentation/screens/coin_store/coin_store_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';
import 'package:luckyai_645/presentation/providers/coin_provider.dart';

class CoinStoreScreen extends ConsumerWidget {
  const CoinStoreScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(coinBalanceProvider);
    final dailyLoginState = ref.watch(dailyLoginProvider);
    final watchAdState = ref.watch(watchAdProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('코인 스토어'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 잔액 카드
          balanceAsync.when(
            data: (balance) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('보유 코인', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${balance.totalCoins}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('무료: ${balance.freeCoins}'),
                        const SizedBox(width: 16),
                        Text('유료: ${balance.paidCoins}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Card(child: Text('오류')),
          ),
          
          const SizedBox(height: 24),
          const Text('무료 코인 받기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // 일일 로그인
          _buildDailyLoginCard(context, ref, dailyLoginState),
          
          const SizedBox(height: 12),
          
          // 광고 시청
          _buildWatchAdCard(context, ref, watchAdState),
          
          const SizedBox(height: 24),
          const Text('코인 구매', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // TODO: IAP 코인 패키지
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('코인 패키지는 추후 추가 예정입니다'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyLoginCard(BuildContext context, WidgetRef ref, AsyncValue state) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.success),
        title: const Text('일일 로그인 보상'),
        subtitle: const Text('5코인 획득'),
        trailing: state.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  await ref.read(dailyLoginProvider.notifier).claim();
                  
                  state.whenData((message) {
                    if (message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      ref.read(dailyLoginProvider.notifier).reset();
                    }
                  });
                  
                  state.whenOrNull(
                    error: (error, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                      ref.read(dailyLoginProvider.notifier).reset();
                    },
                  );
                },
                child: const Text('받기'),
              ),
      ),
    );
  }
  
  Widget _buildWatchAdCard(BuildContext context, WidgetRef ref, AsyncValue state) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, color: AppColors.warning),
        title: const Text('광고 시청'),
        subtitle: const Text('5코인 획득 (일일 최대 5회)'),
        trailing: state.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  // TODO: 실제 광고 SDK 연동
                  await ref.read(watchAdProvider.notifier).claim();
                  
                  state.whenData((message) {
                    if (message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      ref.read(watchAdProvider.notifier).reset();
                    }
                  });
                  
                  state.whenOrNull(
                    error: (error, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                      ref.read(watchAdProvider.notifier).reset();
                    },
                  );
                },
                child: const Text('시청'),
              ),
      ),
    );
  }
}
```

---

### Step 4.3.5: 홈 화면에 코인 잔액 추가

**파일**: `lib/presentation/screens/home/home_screen.dart` (수정)

```dart
// AppBar actions에 추가
AppBar(
  title: const Text(AppStrings.homeTitle),
  actions: [
    const CoinBalanceWidget(),  // 추가
    const SizedBox(width: 8),
  ],
)
```

### 완료 기준 체크리스트
- [ ] 코인 잔액 위젯 표시
- [ ] 일일 로그인 보상 받기 성공
- [ ] 광고 시청 보상 받기 성공 (5회 제한)
- [ ] 코인 부족 시 번호 생성 실패 (402 에러)
- [ ] 코인 차감 후 잔액 갱신

---

## Phase 4 최종 통합 테스트

### 테스트 시나리오

1. **게스트 계정 생성**
   - [ ] 앱 첫 실행 시 자동 생성
   - [ ] 웰컴 보너스 100코인 지급

2. **코인 획득**
   - [ ] 일일 로그인 보상 (5코인)
   - [ ] 광고 시청 보상 (5코인 x 5회)

3. **번호 생성 (코인 차감)**
   - [ ] 무료 알고리즘 (0코인) 생성 성공
   - [ ] 유료 알고리즘 (1코인) 생성 후 잔액 감소
   - [ ] 잔액 부족 시 오류 메시지

4. **데이터 영속성**
   - [ ] 앱 재시작 후 코인 잔액 유지
   - [ ] 사용자 ID 유지

---

## 🧪 Phase 4 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `backend/tests/test_phase4_business.py`

```python
"""Phase 4 비즈니스 로직 자동 테스트"""

import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_guest_user_creation():
    """게스트 사용자 생성 테스트"""
    response = client.post("/api/auth/guest/create", json={
        "device_id": "test_device_123"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert 'user_id' in data
    assert 'token' in data
    assert data['coin_balance'] == 100  # 웰컴 보너스

def test_daily_login_reward():
    """일일 로그인 보상 테스트"""
    # 1. 게스트 생성
    guest_resp = client.post("/api/auth/guest/create", json={"device_id": "test_device_456"})
    user_id = guest_resp.json()['user_id']
    
    # 2. 일일 로그인 보상
    response = client.post(f"/api/coins/daily-login?user_id={user_id}")
    
    assert response.status_code == 200
    data = response.json()
    assert data['reward'] == 5
    assert data['total_coins'] == 105  # 100 + 5

def test_coin_deduction():
    """코인 차감 테스트"""
    # 1. 게스트 생성
    guest_resp = client.post("/api/auth/guest/create", json={"device_id": "test_device_789"})
    user_id = guest_resp.json()['user_id']
    
    # 2. 번호 생성 (1코인 차감)
    response = client.post("/api/generate", json={
        "algorithm_id": 2,  # 1코인 알고리즘
        "n_sets": 1,
        "user_id": user_id
    })
    
    assert response.status_code == 200
    data = response.json()
    assert data['total_cost'] == 1
    
    # 3. 잔액 확인
    balance_resp = client.get(f"/api/coins/balance?user_id={user_id}")
    assert balance_resp.json()['total_coins'] == 99

if __name__ == '__main__':
    pytest.main([__file__, '-v'])
```

---

### 수동 테스트 체크리스트

#### 1. 게스트 계정 생성
**앱 첫 실행**:
- [ ] 자동으로 게스트 계정 생성
- [ ] 웰컴 보너스 100코인 지급
- [ ] 코인 잔액 표시 (우측 상단)

#### 2. 코인 획득
**일일 로그인**:
- [ ] 코인 스토어 → 일일 로그인 버튼
- [ ] 5코인 획득 성공
- [ ] "오늘 이미 받으셨습니다" 메시지 (재시도 시)

**광고 시청**:
- [ ] 코인 스토어 → 광고 시청 버튼
- [ ] 5코인 획득 성공
- [ ] 일일 5회 제한 동작

#### 3. 번호 생성 & 코인 차감
**유료 알고리즘**:
- [ ] 빈도 기반 (1코인) 선택
- [ ] 번호 생성 성공
- [ ] 코인 1개 차감 확인
- [ ] 잔액 부족 시 오류 메시지

#### 4. 데이터 영속성
**앱 재시작**:
- [ ] 코인 잔액 유지
- [ ] 사용자 ID 유지
- [ ] 생성 이력 유지

---

**Phase 4 완료**

다음: [Phase 5 - 고급 기능](015_Phase_5_Advanced_Features.md)

