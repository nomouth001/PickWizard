"""
데이터 매니저 - DB 중심 데이터 관리

2026-01-04 EST - 초기 생성
2026-01-07 12:30:00 EST - DB 중심 구조로 전면 재작성
    - CSV 전체 로드 제거 (성능 개선)
    - 날짜 기반 휴리스틱 판정 추가 (불필요한 온라인 조회 방지)
    - 증분 업데이트만 수행 (N+1 쿼리 문제 해결)
    - CSV는 초기 import 및 백업용으로만 사용
"""

import pandas as pd
from pathlib import Path
from typing import Optional, Dict, List, Tuple
from datetime import datetime, date, time, timedelta, timezone
from sqlalchemy import desc

from sqlalchemy.orm import Session
from loguru import logger

from app.db.session import get_db
from app.db.models.lotto_draw import LottoDraw
from app.core.crawler import LottoCrawler
from app.core.data_validator import DataValidator
from app.config import settings


class DataManager:
    """
    로또 데이터 통합 관리
    
    역할:
    - DB를 주 데이터 소스로 사용
    - 날짜 기반 휴리스틱으로 온라인 조회 최소화
    - 증분 업데이트만 수행 (차이나는 회차만 크롤링/저장)
    - CSV는 초기 import 및 백업용으로만 사용
    """
    
    def __init__(self):
        self.csv_path = settings.LOTTO_CSV_PATH
        self.csv_path.parent.mkdir(parents=True, exist_ok=True)
        self.validator = DataValidator()
    
    async def initialize(self) -> Dict:
        """
        데이터 매니저 초기화 (DB 중심)
        
        2026-01-07 12:30:00 EST - DB 중심 구조로 전면 재작성
        
        Phase 1: 로컬 상태 확인 (DB)
        Phase 2: 휴리스틱 판정 (날짜 기반)
        Phase 3: 온라인 확인 (필요 시에만)
        Phase 4: 증분 다운로드 (차이분만)
        Phase 5: DB 저장 (증분만)
        
        Returns:
            초기화 결과 딕셔너리
        """
        logger.info("[DATA] 데이터 매니저 초기화 시작")
        
        result = {
            'status': 'success',
            'total_draws': 0,
            'latest_draw': None,
            'updated': False,
            'skipped_online_check': False
        }
        
        try:
            # ===== Phase 1: 로컬 상태 확인 (DB) =====
            now_kst = self._get_kst_now()
            logger.info(f"[TIME] 현재 시간: {now_kst:%Y-%m-%d %H:%M:%S} ({self._get_weekday_kr(now_kst)})")
            
            # DB 최신 회차/날짜 확인 (1개 쿼리)
            db_latest = self._get_db_latest_draw()
            
            if db_latest is None:
                # DB 비어있음 → CSV에서 초기 import
                logger.warning("[WARN] DB 비어있음, CSV에서 초기 import 시작")
                await self._import_from_csv()
                db_latest = self._get_db_latest_draw()
                
                if db_latest is None:
                    result['status'] = 'error'
                    result['error'] = 'DB 및 CSV 모두 비어있음'
                    return result
            
            logger.info(f"[DB] DB 최신: {db_latest[0]}회 ({db_latest[1]})")
            
            # ===== Phase 2: 휴리스틱 판정 (날짜 기반) =====
            need_check, reason = self._need_online_check(db_latest[1], now_kst)
            logger.info(f"[CHECK] 판정: {reason}")
            
            if not need_check:
                # 온라인 확인 생략
                logger.success("[SUCCESS] 온라인 확인 생략 (최신 상태)")
                result['total_draws'] = self._get_db_count()
                result['latest_draw'] = db_latest[0]
                result['updated'] = False
                result['skipped_online_check'] = True
                return result
            
            # ===== Phase 3: 온라인 확인 (필요 시에만) =====
            logger.info("[ONLINE] 온라인 최신 회차 조회 중...")
            async with LottoCrawler() as crawler:
                online_latest = await crawler.get_latest_draw_number()
                
                if online_latest is None:
                    logger.error("[ERROR] 온라인 조회 실패")
                    result['status'] = 'error'
                    result['error'] = '온라인 조회 실패'
                    return result
                
                logger.info(f"   온라인 최신: {online_latest}회")
                
                # ===== Phase 4: 증분 다운로드 (차이분만) =====
                if online_latest > db_latest[0]:
                    missing_count = online_latest - db_latest[0]
                    logger.info(f"[DOWNLOAD] 누락된 {missing_count}개 회차 크롤링 시작...")
                    logger.info(f"   범위: {db_latest[0] + 1}회 ~ {online_latest}회")
                    
                    # 차이나는 회차만 크롤링
                    new_draws = await crawler.crawl_range(
                        db_latest[0] + 1,
                        online_latest
                    )
                    
                    if not new_draws:
                        logger.error("[ERROR] 크롤링 실패 또는 데이터 없음")
                        result['status'] = 'error'
                        result['error'] = '크롤링 실패'
                        return result
                    
                    logger.success(f"[SUCCESS] {len(new_draws)}개 회차 크롤링 완료")
                    
                    # ===== Phase 5: DB 저장 (증분만, 중복 체크 없음) =====
                    self._insert_to_db(new_draws)
                    
                    logger.success(f"[SUCCESS] {len(new_draws)}개 회차 DB 저장 완료")
                    
                    result['total_draws'] = self._get_db_count()
                    result['latest_draw'] = online_latest
                    result['updated'] = True
                    result['new_draws_count'] = len(new_draws)
                    
                else:
                    # 최신 상태
                    logger.success("[SUCCESS] 데이터 최신 상태 (온라인 = DB)")
                    result['total_draws'] = self._get_db_count()
                    result['latest_draw'] = db_latest[0]
                    result['updated'] = False
            
            logger.success(f"[SUCCESS] 데이터 매니저 초기화 완료: {result['total_draws']}회차")
            return result
            
        except Exception as e:
            logger.error(f"[ERROR] 데이터 매니저 초기화 오류: {e}")
            result['status'] = 'error'
            result['error'] = str(e)
            raise
    
    # ===== 헬퍼 메서드: 시간/날짜 관련 =====
    
    def _get_kst_now(self) -> datetime:
        """현재 KST 시간 반환"""
        return datetime.now(timezone(timedelta(hours=9)))
    
    def _get_weekday_kr(self, dt: datetime) -> str:
        """한글 요일 반환"""
        days = ['월', '화', '수', '목', '금', '토', '일']
        return days[dt.weekday()]
    
    # ===== 헬퍼 메서드: DB 접근 =====
    
    def _get_db_latest_draw(self) -> Optional[Tuple[int, date]]:
        """
        DB 최신 회차/날짜 확인 (1개 쿼리)
        
        Returns:
            (회차 번호, 추첨일) 또는 None
        """
        db: Session = next(get_db())
        try:
            result = db.query(
                LottoDraw.draw_no,
                LottoDraw.draw_date
            ).order_by(desc(LottoDraw.draw_no)).first()
            
            return (result[0], result[1]) if result else None
        finally:
            db.close()
    
    def _get_db_count(self) -> int:
        """DB 총 회차 개수 조회"""
        db: Session = next(get_db())
        try:
            return db.query(LottoDraw).count()
        finally:
            db.close()
    
    def get_dataframe(self) -> pd.DataFrame:
        """
        DB에서 모든 로또 데이터를 조회하여 DataFrame 반환
        
        알고리즘에서 과거 데이터 분석에 사용
        
        2026-01-08 06:25:00 EST - 추가 (DB 중심 리팩토링 후 누락된 메서드)
        
        Returns:
            pandas.DataFrame: 로또 회차 데이터 (draw_no, draw_date, num1~num6, bonus, ...)
        """
        db: Session = next(get_db())
        try:
            draws = db.query(LottoDraw).order_by(LottoDraw.draw_no).all()
            
            data = []
            for draw in draws:
                data.append({
                    'draw_no': draw.draw_no,
                    'draw_date': draw.draw_date,
                    'num1': draw.num1,
                    'num2': draw.num2,
                    'num3': draw.num3,
                    'num4': draw.num4,
                    'num5': draw.num5,
                    'num6': draw.num6,
                    'bonus': draw.bonus,
                    'first_prize_amount': draw.first_prize_amount,
                    'first_winner_count': draw.first_winner_count
                })
            
            df = pd.DataFrame(data)
            logger.debug(f"[DATA] DataFrame 생성: {len(df)}행")
            return df
            
        finally:
            db.close()
    
    def _insert_to_db(self, new_draws: List[Dict]) -> None:
        """
        신규 데이터만 DB에 INSERT
        
        중복 체크 없음 (이미 차이분만 크롤링했으므로 안전)
        
        2026-01-07 12:30:00 EST - N+1 쿼리 문제 해결
        2026-01-16 14:20:00 EST - draw_date 문자열을 date 객체로 변환 추가
        """
        if not new_draws:
            return
        
        # draw_date 문자열을 date 객체로 변환
        for draw in new_draws:
            if 'draw_date' in draw and isinstance(draw['draw_date'], str):
                draw['draw_date'] = datetime.strptime(draw['draw_date'], '%Y-%m-%d').date()
        
        db: Session = next(get_db())
        try:
            # Bulk Insert (한 번에)
            db.bulk_insert_mappings(LottoDraw, new_draws)
            db.commit()
            logger.info(f"[DB] INSERT: {len(new_draws)}건")
        except Exception as e:
            db.rollback()
            logger.error(f"[ERROR] DB 저장 실패: {e}")
            raise
        finally:
            db.close()
    
    # ===== 헬퍼 메서드: 휴리스틱 판정 =====
    
    def _need_online_check(
        self,
        db_latest_date: date,
        now: datetime
    ) -> Tuple[bool, str]:
        """
        날짜 기반 휴리스틱 판정: 온라인 확인이 필요한가?
        
        로또 추첨: 매주 토요일 20:35 KST
        
        2026-01-07 12:30:00 EST - 휴리스틱 판정 로직 추가
        
        Args:
            db_latest_date: DB 최신 회차의 추첨일
            now: 현재 KST 시간
            
        Returns:
            (필요 여부, 판정 이유)
        """
        current_date = now.date()
        current_weekday = now.weekday()  # 0=월, 5=토, 6=일
        current_time = now.time()
        
        # 경과 일수 계산
        days_elapsed = (current_date - db_latest_date).days
        
        # === 케이스 1: DB가 오늘 데이터 (최신 확정) ===
        if days_elapsed == 0:
            return (False, "DB가 오늘 데이터 (최신)")
        
        # === 케이스 2: DB가 어제 이후 & 토요일 20:35 전 ===
        if days_elapsed <= 1 and current_weekday == 5 and current_time < time(20, 35):
            return (False, "아직 추첨 전 (토요일 20:35 전)")
        
        # === 케이스 3: 마지막 토요일 이후 데이터인지 확인 ===
        # 이번 주 토요일 날짜 계산
        days_until_saturday = (5 - current_weekday) % 7
        this_saturday = current_date + timedelta(days=days_until_saturday)
        
        # 지난 주 토요일
        if days_until_saturday == 0 and current_time < time(20, 35):
            # 오늘이 토요일인데 아직 추첨 전
            last_saturday = this_saturday - timedelta(days=7)
        else:
            last_saturday = this_saturday if days_until_saturday > 0 else this_saturday - timedelta(days=7)
        
        # DB 최신 날짜가 지난 토요일 이후면 최신
        if db_latest_date >= last_saturday:
            return (False, f"DB가 최신 (마지막 추첨일 {last_saturday} 이후 데이터)")
        
        # === 케이스 4: 7일 이상 경과 → 확인 필요 ===
        if days_elapsed >= 7:
            return (True, f"{days_elapsed}일 경과 (새 회차 있을 가능성)")
        
        # === 케이스 5: 3일 이상 경과 → 확인 필요 ===
        if days_elapsed >= 3:
            return (True, f"{days_elapsed}일 경과 (확인 필요)")
        
        # === 기본: 확인 불필요 ===
        return (False, f"{days_elapsed}일 경과 (다음 추첨일 대기)")
    
    # ===== CSV 관련 (초기 import 및 백업용) =====
    
    async def _import_from_csv(self) -> None:
        """
        CSV에서 DB로 초기 데이터 import (1회만)
        
        2026-01-07 12:30:00 EST - CSV는 초기 import용으로만 사용
        """
        if not self.csv_path.exists():
            raise Exception(f"CSV 파일 없음: {self.csv_path}")
        
        logger.info(f"[FILE] CSV에서 데이터 로드 중: {self.csv_path}")
        df = pd.read_csv(self.csv_path, encoding='utf-8-sig')
        
        if df.empty:
            raise Exception("CSV 파일이 비어있음")
        
        logger.info(f"   {len(df)}개 회차 발견")
        
        # Bulk Insert
        records = df.to_dict('records')
        self._insert_to_db(records)
        
        logger.success(f"[SUCCESS] CSV에서 {len(df)}개 회차 import 완료")
    
    def export_to_csv(self, backup_path: Optional[Path] = None) -> Path:
        """
        DB 데이터를 CSV로 export (백업용)
        
        2026-01-07 12:30:00 EST - CSV 백업 export 기능 추가
        
        Args:
            backup_path: 백업 파일 경로 (None이면 기본 경로 사용)
            
        Returns:
            생성된 CSV 파일 경로
        """
        if backup_path is None:
            backup_path = self.csv_path
        
        logger.info(f"[EXPORT] DB 데이터를 CSV로 export 중...")
        
        db: Session = next(get_db())
        try:
            # DB 전체 데이터 조회
            draws = db.query(LottoDraw).order_by(LottoDraw.draw_no).all()
            
            if not draws:
                logger.warning("[WARN] DB에 데이터 없음")
                return backup_path
            
            # DataFrame 생성
            records = [
                {
                    'draw_no': d.draw_no,
                    'draw_date': d.draw_date,
                    'num1': d.num1,
                    'num2': d.num2,
                    'num3': d.num3,
                    'num4': d.num4,
                    'num5': d.num5,
                    'num6': d.num6,
                    'bonus': d.bonus,
                    'first_prize_amount': d.first_prize_amount,
                    'first_winner_count': d.first_winner_count
                }
                for d in draws
            ]
            
            df = pd.DataFrame(records)
            
            # CSV 저장
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(backup_path, index=False, encoding='utf-8-sig')
            
            logger.success(f"[SUCCESS] CSV export 완료: {backup_path} ({len(df)}개 회차)")
            return backup_path
            
        finally:
            db.close()
    
    async def check_for_updates(self) -> Dict:
        """
        최신 회차 확인 및 업데이트
        
        2026-01-07 12:30:00 EST - DB 중심으로 재작성
        
        Returns:
            업데이트 결과
        """
        result = {
            'has_update': False,
            'new_draws': [],
            'latest_draw': None
        }
        
        try:
            # DB 최신 확인
            db_latest = self._get_db_latest_draw()
            
            if db_latest is None:
                logger.warning("[WARN] DB 비어있음")
                result['has_update'] = False
                return result
            
            # 온라인 최신 확인
            async with LottoCrawler() as crawler:
                online_latest = await crawler.get_latest_draw_number()
                
                if online_latest and online_latest > db_latest[0]:
                    logger.info(f"[DOWNLOAD] 새 회차 발견: {db_latest[0] + 1} ~ {online_latest}")
                    
                    # 새 회차 크롤링
                    new_draws = await crawler.crawl_range(db_latest[0] + 1, online_latest)
                    
                    if new_draws:
                        # DB에 저장
                        self._insert_to_db(new_draws)
                        
                        result['has_update'] = True
                        result['new_draws'] = new_draws
                        result['latest_draw'] = online_latest
                        
                        logger.success(f"[SUCCESS] 업데이트 완료: {len(new_draws)}건")
                else:
                    logger.info("[SUCCESS] 이미 최신 상태")
            
            return result
            
        except Exception as e:
            logger.error(f"[ERROR] 업데이트 확인 오류: {e}")
            raise


# 전역 인스턴스
data_manager = DataManager()

