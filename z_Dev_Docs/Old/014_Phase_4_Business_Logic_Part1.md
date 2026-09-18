# Phase 4: 비즈니스 로직 구현
## 사용자 인증, 코인 시스템, 결제 연동

---

**Phase**: 4 - Business Logic Implementation  
**예상 기간**: 3-4일 (24-32시간)  
**선행 조건**: Phase 3 완료 (Flutter 앱 기본 구조)  
**목표**: 게스트 인증, 코인 시스템, 번호 생성에 코인 차감 통합

---

## 📋 Phase 개요

### 주요 산출물
- [x] 게스트 사용자 자동 생성 (device_id 기반)
- [x] 코인 지갑 시스템 (free_coins, paid_coins)
- [x] 코인 획득 API (일일 로그인, 광고 시청)
- [x] 번호 생성 API에 코인 차감 통합
- [x] Flutter 코인 UI (잔액, 스토어)
- [x] IAP 결제 연동 (선택)

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 4.1 사용자 인증 (게스트) | 6-8시간 | 6-8h |
| 4.2 코인 시스템 (백엔드) | 8-10시간 | 14-18h |
| 4.3 코인 시스템 (Flutter) | 4-6시간 | 18-24h |
| 4.4 결제 연동 (선택) | 6-8시간 | 24-32h |

---

## 작업 4.1: 사용자 인증 - 게스트 모드 (6-8시간)

### 목표
디바이스 ID 기반 게스트 사용자 자동 생성 및 관리

### Step 4.1.1: 백엔드 - 게스트 생성 API

**파일**: `backend/app/api/routes/auth.py`

```python
"""
인증 API 라우터

2026-01-07 EST - 초기 생성
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from uuid import UUID

from app.db.session import get_db
from app.db.models.user import User, AuthProvider
from app.db.models.coin_wallet import CoinWallet
from app.schemas.auth import (
    GuestCreateRequest,
    GuestCreateResponse,
    UserResponse,
)


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/guest", response_model=GuestCreateResponse)
async def create_guest_user(
    request: GuestCreateRequest,
    db: Session = Depends(get_db)
):
    """
    게스트 사용자 생성 또는 조회
    
    동일한 device_id가 이미 있으면 기존 사용자 반환
    """
    # 1. 기존 사용자 확인 (device_id 또는 user_id)
    existing_user = None
    
    if request.user_id:
        existing_user = db.query(User).filter(
            User.id == request.user_id
        ).first()
    
    if not existing_user and request.device_id:
        existing_user = db.query(User).filter(
            User.device_id == request.device_id,
            User.is_guest == True
        ).first()
    
    # 2. 기존 사용자가 있으면 반환
    if existing_user:
        wallet = db.query(CoinWallet).filter(
            CoinWallet.user_id == existing_user.id
        ).first()
        
        return GuestCreateResponse(
            user_id=existing_user.id,
            device_id=existing_user.device_id,
            is_new_user=False,
            total_coins=wallet.total_coins if wallet else 0
        )
    
    # 3. 새 게스트 사용자 생성
    new_user = User(
        device_id=request.device_id,
        auth_provider=AuthProvider.GUEST,
        is_guest=True,
        is_active=True
    )
    db.add(new_user)
    db.flush()  # user.id 생성
    
    # 4. 코인 지갑 생성 (웰컴 보너스: 100코인)
    wallet = CoinWallet(
        user_id=new_user.id,
        free_coins=100,
        paid_coins=0,
        total_earned=100,
        total_spent=0
    )
    db.add(wallet)
    
    db.commit()
    db.refresh(new_user)
    
    return GuestCreateResponse(
        user_id=new_user.id,
        device_id=new_user.device_id,
        is_new_user=True,
        total_coins=100
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """현재 사용자 정보 조회"""
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다"
        )
    
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == user.id
    ).first()
    
    return UserResponse(
        user_id=user.id,
        email=user.email,
        auth_provider=user.auth_provider.value,
        is_guest=user.is_guest,
        total_coins=wallet.total_coins if wallet else 0,
        created_at=user.created_at
    )
```

---

### Step 4.1.2: 백엔드 - Pydantic 스키마

**파일**: `backend/app/schemas/auth.py`

```python
"""
인증 관련 스키마

2026-01-07 EST - 초기 생성
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class GuestCreateRequest(BaseModel):
    """게스트 생성 요청"""
    device_id: str = Field(..., description="디바이스 ID (UUID)")
    user_id: Optional[UUID] = Field(None, description="기존 사용자 ID (재설치 시)")


class GuestCreateResponse(BaseModel):
    """게스트 생성 응답"""
    user_id: UUID
    device_id: Optional[str]
    is_new_user: bool
    total_coins: int


class UserResponse(BaseModel):
    """사용자 정보 응답"""
    user_id: UUID
    email: Optional[str]
    auth_provider: str
    is_guest: bool
    total_coins: int
    created_at: datetime
    
    class Config:
        from_attributes = True
```

---

### Step 4.1.3: Flutter - 디바이스 ID 가져오기

**pubspec.yaml에 추가**:
```yaml
dependencies:
  device_info_plus: ^9.1.1
  shared_preferences: ^2.2.2
```

**파일**: `lib/core/utils/device_info_helper.dart`

```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 디바이스 정보 헬퍼
/// 
/// 2026-01-07 EST - 초기 생성
class DeviceInfoHelper {
  static const String _deviceIdKey = 'device_id';
  
  /// 디바이스 ID 가져오기 (생성 또는 저장된 값 로드)
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 저장된 device_id 확인
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }
    
    // 새 device_id 생성
    deviceId = await _generateDeviceId();
    await prefs.setString(_deviceIdKey, deviceId);
    
    return deviceId;
  }
  
  /// 디바이스 ID 생성
  static Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    String identifier;
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      identifier = androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      identifier = iosInfo.identifierForVendor ?? ''; // IDFV
    } else {
      identifier = const Uuid().v4(); // Fallback
    }
    
    // UUID 형식으로 변환
    if (!_isValidUuid(identifier)) {
      identifier = const Uuid().v5(Uuid.NAMESPACE_URL, identifier);
    }
    
    return identifier;
  }
  
  /// UUID 형식 검증
  static bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }
  
  /// 저장된 사용자 ID 가져오기
  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  
  /// 사용자 ID 저장
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }
  
  /// 사용자 ID 삭제
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
```

---

### Step 4.1.4: Flutter - 인증 API

**파일**: `lib/data/data_sources/remote/auth_api.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

/// 인증 API
/// 
/// 2026-01-07 EST - 초기 생성
@RestApi(baseUrl: '')
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;
  
  /// 게스트 사용자 생성
  @POST('/api/auth/guest')
  Future<GuestCreateResponse> createGuestUser(
    @Body() GuestCreateRequest request,
  );
  
  /// 현재 사용자 정보 조회
  @GET('/api/auth/me')
  Future<UserResponse> getCurrentUser(
    @Query('user_id') String userId,
  );
}

/// 게스트 생성 요청
class GuestCreateRequest {
  final String deviceId;
  final String? userId;
  
  GuestCreateRequest({
    required this.deviceId,
    this.userId,
  });
  
  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    if (userId != null) 'user_id': userId,
  };
}

/// 게스트 생성 응답
class GuestCreateResponse {
  final String userId;
  final String? deviceId;
  final bool isNewUser;
  final int totalCoins;
  
  GuestCreateResponse({
    required this.userId,
    this.deviceId,
    required this.isNewUser,
    required this.totalCoins,
  });
  
  factory GuestCreateResponse.fromJson(Map<String, dynamic> json) {
    return GuestCreateResponse(
      userId: json['user_id'],
      deviceId: json['device_id'],
      isNewUser: json['is_new_user'],
      totalCoins: json['total_coins'],
    );
  }
}

/// 사용자 정보 응답
class UserResponse {
  final String userId;
  final String? email;
  final String authProvider;
  final bool isGuest;
  final int totalCoins;
  final DateTime createdAt;
  
  UserResponse({
    required this.userId,
    this.email,
    required this.authProvider,
    required this.isGuest,
    required this.totalCoins,
    required this.createdAt,
  });
  
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['user_id'],
      email: json['email'],
      authProvider: json['auth_provider'],
      isGuest: json['is_guest'],
      totalCoins: json['total_coins'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

---

### Step 4.1.5: Flutter - 인증 Provider

**파일**: `lib/presentation/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/utils/device_info_helper.dart';
import 'package:luckyai_645/data/data_sources/remote/auth_api.dart';
import 'package:luckyai_645/data/data_sources/remote/api_client.dart';

/// AuthApi Provider
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

/// 현재 사용자 ID Provider
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// 인증 초기화 Provider
final authInitializationProvider = FutureProvider<AuthState>((ref) async {
  try {
    // 1. 디바이스 ID 가져오기
    final deviceId = await DeviceInfoHelper.getDeviceId();
    
    // 2. 저장된 사용자 ID 확인
    final savedUserId = await DeviceInfoHelper.getSavedUserId();
    
    // 3. 게스트 사용자 생성 또는 조회
    final authApi = ref.read(authApiProvider);
    final response = await authApi.createGuestUser(
      GuestCreateRequest(
        deviceId: deviceId,
        userId: savedUserId,
      ),
    );
    
    // 4. 사용자 ID 저장
    await DeviceInfoHelper.saveUserId(response.userId);
    ref.read(currentUserIdProvider.notifier).state = response.userId;
    
    return AuthState(
      userId: response.userId,
      isNewUser: response.isNewUser,
      totalCoins: response.totalCoins,
    );
  } catch (e) {
    print('인증 초기화 실패: $e');
    rethrow;
  }
});

/// 인증 상태
class AuthState {
  final String userId;
  final bool isNewUser;
  final int totalCoins;
  
  AuthState({
    required this.userId,
    required this.isNewUser,
    required this.totalCoins,
  });
}
```

---

### Step 4.1.6: 앱 초기화에 인증 추가

**파일**: `lib/presentation/providers/app_initialization_provider.dart` (수정)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/presentation/providers/auth_provider.dart';
import 'package:luckyai_645/presentation/providers/lotto_provider.dart';

final appInitializationProvider = FutureProvider<AppInitStatus>((ref) async {
  try {
    // 1. 인증 초기화 (게스트 생성)
    final authState = await ref.read(authInitializationProvider.future);
    print('✅ 인증 완료: ${authState.userId}');
    
    // 2. 최신 회차 동기화
    ref.read(latestDrawProvider);
    
    // 3. 신규 사용자 웰컴 메시지
    if (authState.isNewUser) {
      print('🎉 신규 사용자! 웰컴 보너스 ${authState.totalCoins}코인');
    }
    
    return AppInitStatus.initialized;
  } catch (e) {
    print('❌ 앱 초기화 오류: $e');
    return AppInitStatus.error;
  }
});
```

### 완료 기준 체크리스트
- [ ] 백엔드 `/api/auth/guest` API 동작
- [ ] Flutter 앱 실행 시 게스트 자동 생성
- [ ] 디바이스 ID 로컬 저장 확인
- [ ] 사용자 ID SharedPreferences 저장
- [ ] 앱 재시작 시 기존 사용자 ID 로드

---

**(Phase 4 계속) 작업 4.2-4.4는 다음 파일에서 계속...**

---

**Phase 4 Part 1 문서 종료**

다음: [Phase 4 Part 2 - 코인 시스템](014_Phase_4_Business_Logic_Part2.md)

