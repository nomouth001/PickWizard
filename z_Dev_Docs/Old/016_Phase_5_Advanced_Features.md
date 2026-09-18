# Phase 5: 고급 기능 구현
## 내 번호 관리, 자동 당첨 확인, Celery

---

**Phase**: 5 - Advanced Features  
**예상 기간**: 2-3일 (16-24시간)  
**선행 조건**: Phase 4 완료 (코인 시스템)  
**목표**: 내 번호 저장, 자동 당첨 확인, Push 알림

---

## 📋 Phase 개요

### 주요 산출물
- [x] 내 번호 저장/조회 API
- [x] 당첨 확인 로직
- [x] Celery 백그라운드 작업
- [x] 자동 당첨 확인 스케줄
- [x] Push 알림 (Firebase)
- [x] Flutter 내 번호 화면

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 5.1 내 번호 관리 | 6-8시간 | 6-8h |
| 5.2 Celery & 자동 당첨 확인 | 8-10시간 | 14-18h |
| 5.3 Push 알림 | 2-4시간 | 16-22h |

---

## 작업 5.1: 내 번호 관리 (6-8시간)

### Step 5.1.1: DB 모델

**파일**: `backend/app/db/models/user_numbers.py`

```python
"""
사용자 번호 관리 모델

2026-01-08 EST - 초기 생성
"""

from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, ARRAY, Index, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from enum import Enum

from app.db.base import Base


class WinningRank(str, Enum):
    """당첨 등수"""
    RANK_1 = "1등"
    RANK_2 = "2등"
    RANK_3 = "3등"
    RANK_4 = "4등"
    RANK_5 = "5등"
    NO_WIN = "미당첨"


class UserGeneratedNumbers(Base):
    """사용자가 저장한 생성 번호"""
    __tablename__ = "user_generated_numbers"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    
    # 번호 정보
    numbers = Column(ARRAY(Integer), nullable=False, comment="당첨번호 6개")
    algorithm_id = Column(Integer, comment="생성 알고리즘 ID")
    algorithm_name = Column(String(100), comment="알고리즘 이름")
    
    # 당첨 확인
    is_checked = Column(Boolean, default=False, comment="당첨 확인 여부")
    checked_draw_no = Column(Integer, comment="확인한 회차")
    winning_rank = Column(SQLEnum(WinningRank), comment="당첨 등수")
    
    # 메모
    memo = Column(String(255), comment="사용자 메모")
    
    __table_args__ = (
        Index('idx_user_numbers', 'user_id', 'created_at'),
        Index('idx_unchecked', 'is_checked', 'user_id'),
    )


class WinningCheckResult(Base):
    """당첨 확인 결과"""
    __tablename__ = "winning_check_results"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id'), nullable=False)
    user_number_id = Column(Integer, ForeignKey('user_generated_numbers.id'), nullable=False)
    
    # 회차 정보
    draw_no = Column(Integer, nullable=False, comment="확인한 회차")
    winning_numbers = Column(ARRAY(Integer), nullable=False, comment="당첨번호")
    bonus_number = Column(Integer, nullable=False, comment="보너스 번호")
    
    # 결과
    matched_count = Column(Integer, nullable=False, comment="맞은 개수")
    has_bonus = Column(Boolean, default=False, comment="보너스 포함")
    winning_rank = Column(SQLEnum(WinningRank), nullable=False, comment="등수")
    
    # 알림
    notification_sent = Column(Boolean, default=False, comment="알림 전송 여부")
    
    __table_args__ = (
        Index('idx_user_results', 'user_id', 'created_at'),
        Index('idx_draw_results', 'draw_no', 'user_id'),
    )
```

---

### Step 5.1.2: 당첨 확인 로직

**파일**: `backend/app/services/winning_check_service.py`

```python
"""
당첨 확인 서비스

2026-01-08 EST - 초기 생성
"""

from typing import Tuple
from app.db.models.user_numbers import WinningRank


class WinningCheckService:
    """당첨 확인 서비스"""
    
    @staticmethod
    def judge_rank(
        user_numbers: list[int],
        winning_numbers: list[int],
        bonus_number: int
    ) -> Tuple[WinningRank, int, bool]:
        """
        당첨 등수 판정
        
        Returns:
            (등수, 맞은 개수, 보너스 포함 여부)
        """
        user_set = set(user_numbers)
        winning_set = set(winning_numbers)
        
        matched_count = len(user_set & winning_set)
        has_bonus = bonus_number in user_set
        
        # 등수 판정
        if matched_count == 6:
            return WinningRank.RANK_1, matched_count, False
        elif matched_count == 5 and has_bonus:
            return WinningRank.RANK_2, matched_count, True
        elif matched_count == 5:
            return WinningRank.RANK_3, matched_count, False
        elif matched_count == 4:
            return WinningRank.RANK_4, matched_count, False
        elif matched_count == 3:
            return WinningRank.RANK_5, matched_count, False
        else:
            return WinningRank.NO_WIN, matched_count, False
    
    @staticmethod
    def get_prize_description(rank: WinningRank) -> str:
        """당첨 설명 반환"""
        descriptions = {
            WinningRank.RANK_1: "🎉 1등 당첨! 축하합니다!",
            WinningRank.RANK_2: "🎊 2등 당첨! 축하합니다!",
            WinningRank.RANK_3: "🎈 3등 당첨! 축하합니다!",
            WinningRank.RANK_4: "👏 4등 당첨! 축하합니다!",
            WinningRank.RANK_5: "✨ 5등 당첨! 축하합니다!",
            WinningRank.NO_WIN: "다음 기회에...",
        }
        return descriptions.get(rank, "")
```

---

### Step 5.1.3: API 엔드포인트

**파일**: `backend/app/api/routes/my_numbers.py`

```python
"""
내 번호 API

2026-01-08 EST - 초기 생성
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from uuid import UUID
from typing import List

from app.db.session import get_db
from app.db.models.user_numbers import UserGeneratedNumbers, WinningCheckResult
from app.db.models.lotto_draw import LottoDraw
from app.services.winning_check_service import WinningCheckService
from app.schemas.my_numbers import (
    SaveNumberRequest,
    SaveNumberResponse,
    MyNumberResponse,
    CheckWinningResponse,
)


router = APIRouter(prefix="/my-numbers", tags=["My Numbers"])


@router.post("/save", response_model=SaveNumberResponse)
async def save_number(
    request: SaveNumberRequest,
    user_id: UUID,
    db: Session = Depends(get_db)
):
    """번호 저장"""
    # 번호 검증
    if len(request.numbers) != 6:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "번호는 6개여야 합니다")
    
    if not all(1 <= num <= 45 for num in request.numbers):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "번호는 1~45 사이여야 합니다")
    
    # 저장
    user_number = UserGeneratedNumbers(
        user_id=user_id,
        numbers=sorted(request.numbers),
        algorithm_id=request.algorithm_id,
        algorithm_name=request.algorithm_name,
        memo=request.memo
    )
    db.add(user_number)
    db.commit()
    db.refresh(user_number)
    
    return SaveNumberResponse(
        id=user_number.id,
        numbers=user_number.numbers,
        message="번호가 저장되었습니다"
    )


@router.get("/", response_model=List[MyNumberResponse])
async def get_my_numbers(
    user_id: UUID,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """내 번호 목록 조회"""
    numbers = db.query(UserGeneratedNumbers).filter(
        UserGeneratedNumbers.user_id == user_id
    ).order_by(
        UserGeneratedNumbers.created_at.desc()
    ).limit(limit).all()
    
    return [
        MyNumberResponse(
            id=n.id,
            numbers=n.numbers,
            algorithm_name=n.algorithm_name,
            is_checked=n.is_checked,
            winning_rank=n.winning_rank.value if n.winning_rank else None,
            memo=n.memo,
            created_at=n.created_at
        )
        for n in numbers
    ]


@router.post("/check", response_model=CheckWinningResponse)
async def check_winning(
    number_id: int,
    user_id: UUID,
    draw_no: int,
    db: Session = Depends(get_db)
):
    """당첨 확인"""
    # 1. 내 번호 조회
    user_number = db.query(UserGeneratedNumbers).filter(
        UserGeneratedNumbers.id == number_id,
        UserGeneratedNumbers.user_id == user_id
    ).first()
    
    if not user_number:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "번호를 찾을 수 없습니다")
    
    # 2. 당첨번호 조회
    draw = db.query(LottoDraw).filter(
        LottoDraw.draw_no == draw_no
    ).first()
    
    if not draw:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "회차를 찾을 수 없습니다")
    
    # 3. 당첨 확인
    winning_numbers = draw.get_numbers()
    rank, matched_count, has_bonus = WinningCheckService.judge_rank(
        user_number.numbers,
        winning_numbers,
        draw.bonus
    )
    
    # 4. 결과 저장
    result = WinningCheckResult(
        user_id=user_id,
        user_number_id=number_id,
        draw_no=draw_no,
        winning_numbers=winning_numbers,
        bonus_number=draw.bonus,
        matched_count=matched_count,
        has_bonus=has_bonus,
        winning_rank=rank
    )
    db.add(result)
    
    # 5. 내 번호 업데이트
    user_number.is_checked = True
    user_number.checked_draw_no = draw_no
    user_number.winning_rank = rank
    
    db.commit()
    
    return CheckWinningResponse(
        rank=rank.value,
        matched_count=matched_count,
        has_bonus=has_bonus,
        message=WinningCheckService.get_prize_description(rank)
    )
```

### 완료 기준 체크리스트
- [ ] 번호 저장 API 동작
- [ ] 내 번호 목록 조회 성공
- [ ] 당첨 확인 로직 정확성 (1~5등, 미당첨)
- [ ] DB에 결과 저장 확인

---

## 작업 5.2: Celery & 자동 당첨 확인 (8-10시간)

### Step 5.2.1: Celery 설정

**파일**: `backend/app/workers/celery_app.py`

```python
"""
Celery 애플리케이션

2026-01-08 EST - 초기 생성
"""

from celery import Celery
from celery.schedules import crontab

from app.config import settings


# Celery 앱 생성
celery_app = Celery(
    'luckyai_645',
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

# 설정
celery_app.conf.update(
    timezone=settings.CELERY_TIMEZONE,
    enable_utc=False,
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    task_track_started=True,
    task_time_limit=30 * 60,  # 30분
    worker_prefetch_multiplier=1,
)

# 스케줄 설정
# 2026-01-07 12:30:00 EST - CSV 백업 작업 추가
celery_app.conf.beat_schedule = {
    # 매주 토요일 21:30 - 최신 회차 업데이트
    'update-latest-draw': {
        'task': 'app.workers.tasks.update_latest_draw',
        'schedule': crontab(day_of_week=6, hour=21, minute=30),
    },
    # 매주 토요일 22:00 - 자동 당첨 확인
    'auto-check-winning': {
        'task': 'app.workers.tasks.auto_check_winning',
        'schedule': crontab(day_of_week=6, hour=22, minute=0),
    },
    # 매주 월요일 03:00 - CSV 백업 (DB → CSV export)
    'export-csv-backup': {
        'task': 'app.workers.tasks.export_csv_backup',
        'schedule': crontab(day_of_week=1, hour=3, minute=0),
    },
}

# Task autodiscover
celery_app.autodiscover_tasks(['app.workers'])
```

---

### Step 5.2.2: Celery Tasks

**파일**: `backend/app/workers/tasks.py`

```python
"""
Celery 백그라운드 작업

2026-01-08 EST - 초기 생성
"""

import asyncio
from loguru import logger

from app.workers.celery_app import celery_app
from app.core.crawler import LottoCrawler
from app.core.data_manager import DataManager
from app.db.session import get_db_context
from app.db.models.user_numbers import UserGeneratedNumbers, WinningCheckResult
from app.db.models.lotto_draw import LottoDraw
from app.services.winning_check_service import WinningCheckService


@celery_app.task(name='app.workers.tasks.update_latest_draw')
def update_latest_draw():
    """
    최신 회차 업데이트
    
    매주 토요일 21:30 실행
    """
    logger.info("🔄 최신 회차 업데이트 시작")
    
    try:
        # 비동기 함수 실행
        asyncio.run(_update_latest_draw_async())
        logger.success("✅ 최신 회차 업데이트 완료")
        return {'status': 'success'}
    except Exception as e:
        logger.error(f"❌ 최신 회차 업데이트 실패: {e}")
        return {'status': 'error', 'error': str(e)}


async def _update_latest_draw_async():
    """최신 회차 업데이트 (비동기)"""
    async with LottoCrawler() as crawler:
        # 1. 최신 회차 확인
        latest = await crawler.get_latest_draw_number()
        if not latest:
            raise Exception("최신 회차 조회 실패")
        
        # 2. DB 확인
        with get_db_context() as db:
            existing = db.query(LottoDraw).filter(
                LottoDraw.draw_no == latest
            ).first()
            
            if existing:
                logger.info(f"최신 회차 {latest}회는 이미 존재함")
                return
        
        # 3. 크롤링
        data = await crawler.crawl_single(latest)
        if not data:
            raise Exception(f"{latest}회 크롤링 실패")
        
        # 4. DB 저장
        with get_db_context() as db:
            draw = LottoDraw(**data)
            db.add(draw)
            db.commit()
            logger.success(f"✅ {latest}회 저장 완료")


@celery_app.task(name='app.workers.tasks.auto_check_winning')
def auto_check_winning():
    """
    자동 당첨 확인
    
    매주 토요일 22:00 실행
    """
    logger.info("🎰 자동 당첨 확인 시작")
    
    try:
        with get_db_context() as db:
            # 1. 최신 회차 조회
            latest_draw = db.query(LottoDraw).order_by(
                LottoDraw.draw_no.desc()
            ).first()
            
            if not latest_draw:
                logger.warning("최신 회차가 없음")
                return {'status': 'no_draw'}
            
            logger.info(f"최신 회차: {latest_draw.draw_no}회")
            
            # 2. 미확인 번호 조회
            unchecked_numbers = db.query(UserGeneratedNumbers).filter(
                UserGeneratedNumbers.is_checked == False
            ).all()
            
            logger.info(f"미확인 번호: {len(unchecked_numbers)}개")
            
            if not unchecked_numbers:
                return {'status': 'no_unchecked'}
            
            # 3. 당첨 확인
            winning_numbers = latest_draw.get_numbers()
            checked_count = 0
            won_count = 0
            
            for user_number in unchecked_numbers:
                rank, matched_count, has_bonus = WinningCheckService.judge_rank(
                    user_number.numbers,
                    winning_numbers,
                    latest_draw.bonus
                )
                
                # 결과 저장
                result = WinningCheckResult(
                    user_id=user_number.user_id,
                    user_number_id=user_number.id,
                    draw_no=latest_draw.draw_no,
                    winning_numbers=winning_numbers,
                    bonus_number=latest_draw.bonus,
                    matched_count=matched_count,
                    has_bonus=has_bonus,
                    winning_rank=rank
                )
                db.add(result)
                
                # 내 번호 업데이트
                user_number.is_checked = True
                user_number.checked_draw_no = latest_draw.draw_no
                user_number.winning_rank = rank
                
                checked_count += 1
                
                # 당첨자 카운트
                if rank.value != "미당첨":
                    won_count += 1
                    logger.success(
                        f"🎉 당첨자 발견! "
                        f"사용자={user_number.user_id}, 등수={rank.value}"
                    )
            
            db.commit()
            
            logger.success(
                f"✅ 자동 당첨 확인 완료: "
                f"{checked_count}개 확인, {won_count}명 당첨"
            )
            
            return {
                'status': 'success',
                'checked': checked_count,
                'won': won_count
            }
            
    except Exception as e:
        logger.error(f"❌ 자동 당첨 확인 실패: {e}")
        return {'status': 'error', 'error': str(e)}


@celery_app.task(name='app.workers.tasks.export_csv_backup')
def export_csv_backup():
    """
    DB 데이터를 CSV로 백업
    
    매주 월요일 03:00 실행
    
    2026-01-07 12:30:00 EST - CSV 백업 task 추가
    """
    logger.info("📤 CSV 백업 시작")
    
    try:
        from pathlib import Path
        from datetime import datetime
        
        data_manager = DataManager()
        
        # 백업 디렉토리 생성
        backup_dir = Path("backend/data/backup")
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        # 백업 파일명 (날짜 포함)
        timestamp = datetime.now().strftime("%Y%m%d")
        backup_path = backup_dir / f"lotto_data_{timestamp}.csv"
        
        # DB → CSV export
        result_path = data_manager.export_to_csv(backup_path)
        
        logger.success(f"✅ CSV 백업 완료: {result_path}")
        
        return {
            'status': 'success',
            'backup_path': str(result_path)
        }
        
    except Exception as e:
        logger.error(f"❌ CSV 백업 실패: {e}")
        return {'status': 'error', 'error': str(e)}
```

---

### Step 5.2.3: Celery 실행

```bash
# Worker 실행
celery -A app.workers.celery_app worker --loglevel=info

# Beat (스케줄러) 실행
celery -A app.workers.celery_app beat --loglevel=info

# 또는 통합 실행
celery -A app.workers.celery_app worker --beat --loglevel=info
```

---

### Step 5.2.4: 수동 Task 실행 (테스트)

```python
# Python REPL에서
from app.workers.tasks import update_latest_draw, auto_check_winning

# 즉시 실행
result = update_latest_draw.delay()
print(result.get())

result = auto_check_winning.delay()
print(result.get())
```

### 완료 기준 체크리스트
- [ ] Celery Worker 실행 성공
- [ ] Celery Beat 실행 성공
- [ ] `update_latest_draw` 작업 동작
- [ ] `auto_check_winning` 작업 동작
- [ ] 당첨자 발견 시 로그 출력

---

## 작업 5.3: Push 알림 (선택, 2-4시간)

### Step 5.3.1: Firebase 설정 (생략 가능)

**Firebase Console**:
1. 프로젝트 생성
2. Android/iOS 앱 추가
3. `google-services.json` / `GoogleService-Info.plist` 다운로드
4. 서버 키 복사

---

### Step 5.3.2: Flutter FCM 토큰 등록

**pubspec.yaml**:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
```

**파일**: `lib/core/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    
    // 권한 요청
    await messaging.requestPermission();
    
    // FCM 토큰 가져오기
    final token = await messaging.getToken();
    print('FCM Token: $token');
    
    // TODO: 백엔드에 토큰 전송
    
    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message: ${message.notification?.title}');
    });
  }
}
```

### 완료 기준 체크리스트
- [ ] Firebase 프로젝트 설정
- [ ] FCM 토큰 발급
- [ ] Push 알림 수신 테스트

---

## Phase 5 최종 통합 테스트

### 테스트 시나리오

1. **내 번호 저장**
   - [ ] 번호 생성 후 "내 번호로 저장" 버튼
   - [ ] 내 번호 목록에서 확인

2. **당첨 확인**
   - [ ] 특정 회차로 수동 확인
   - [ ] 당첨 등수 표시 (1~5등, 미당첨)

3. **자동 당첨 확인**
   - [ ] Celery Worker 실행
   - [ ] 수동으로 Task 실행
   - [ ] 미확인 번호 자동 확인
   - [ ] DB에 결과 저장

4. **Push 알림 (선택)**
   - [ ] 당첨 시 알림 수신

---

## 🧪 Phase 5 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `backend/tests/test_phase5_advanced.py`

```python
"""Phase 5 고급 기능 자동 테스트"""

import pytest
from app.services.winning_check_service import WinningCheckService
from app.db.models.user_numbers import WinningRank

def test_winning_rank_1st():
    """1등 판정 테스트"""
    rank, matched, has_bonus = WinningCheckService.judge_rank(
        [1, 2, 3, 4, 5, 6],
        [1, 2, 3, 4, 5, 6],
        7
    )
    assert rank == WinningRank.RANK_1
    assert matched == 6
    assert has_bonus == False

def test_winning_rank_2nd():
    """2등 판정 테스트"""
    rank, matched, has_bonus = WinningCheckService.judge_rank(
        [1, 2, 3, 4, 5, 7],  # 7이 보너스
        [1, 2, 3, 4, 5, 6],
        7
    )
    assert rank == WinningRank.RANK_2
    assert matched == 5
    assert has_bonus == True

def test_winning_rank_no_win():
    """미당첨 판정 테스트"""
    rank, matched, has_bonus = WinningCheckService.judge_rank(
        [10, 20, 30, 40, 41, 42],
        [1, 2, 3, 4, 5, 6],
        7
    )
    assert rank == WinningRank.NO_WIN
    assert matched == 0

if __name__ == '__main__':
    pytest.main([__file__, '-v'])
```

---

### 수동 테스트 체크리스트

#### 1. 내 번호 저장
**번호 생성 후**:
- [ ] "내 번호로 저장" 버튼 클릭
- [ ] 저장 성공 메시지
- [ ] "내 번호" 탭에서 확인 가능

#### 2. 수동 당첨 확인
**내 번호 목록에서**:
- [ ] 번호 선택 → "당첨 확인" 버튼
- [ ] 회차 선택
- [ ] 당첨 결과 표시 (1~5등, 미당첨)
- [ ] 맞은 개수 표시

#### 3. Celery 백그라운드 작업
**Worker 실행**:
```bash
celery -A app.workers.celery_app worker --loglevel=info
```
- [ ] Worker 시작 성공
- [ ] Task 등록 확인

**Beat 실행**:
```bash
celery -A app.workers.celery_app beat --loglevel=info
```
- [ ] Beat 시작 성공
- [ ] 스케줄 표시

**수동 Task 실행**:
```python
from app.workers.tasks import auto_check_winning
result = auto_check_winning.delay()
print(result.get())
```
- [ ] Task 실행 성공
- [ ] 미확인 번호 자동 확인
- [ ] 당첨 결과 DB 저장

#### 4. Push 알림 (선택)
- [ ] Firebase 설정 완료
- [ ] FCM 토큰 발급
- [ ] Push 알림 수신 테스트

---

**Phase 5 완료**

다음: [Phase 6 - 배포 준비](016_Phase_6_Deployment.md)

