"""
로또 당첨번호 크롤러 (JSON API 방식)

동행복권 API에서 당첨번호 수집

2026-01-04 EST - JSON API 방식으로 재작성
"""

import asyncio
from datetime import datetime
from typing import Dict, List, Optional

import aiohttp
from loguru import logger

from app.config import settings


class LottoCrawler:
    """
    로또 당첨번호 크롤러 (JSON API)
    
    동행복권 JSON API에서 회차별 당첨번호 크롤링
    """
    
    def __init__(self):
        # 새로운 API 엔드포인트
        self.api_url = "https://dhlottery.co.kr/lt645/selectPstLt645Info.do"
        self.timeout = aiohttp.ClientTimeout(total=settings.CRAWLER_TIMEOUT)
        self.retry_count = settings.CRAWLER_RETRY
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def __aenter__(self):
        """비동기 컨텍스트 매니저 진입"""
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://dhlottery.co.kr/',
            'Accept': 'application/json'
        }
        self.session = aiohttp.ClientSession(timeout=self.timeout, headers=headers)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """비동기 컨텍스트 매니저 종료"""
        if self.session:
            await self.session.close()
    
    async def get_latest_draw_number(self) -> Optional[int]:
        """
        최신 회차 번호 조회
        
        Returns:
            최신 회차 번호 또는 None (실패 시)
        """
        try:
            # 최신 1개만 조회 (끝 번호를 충분히 크게)
            # API가 존재하는 회차만 반환함
            params = {
                'srchStrLtEpsd': '1200',  # 시작 (최근 회차 근처)
                'srchEndLtEpsd': '9999',  # 끝 (충분히 큰 값)
                '_': str(int(datetime.now().timestamp() * 1000))
            }
            
            if not self.session:
                self.session = aiohttp.ClientSession(timeout=self.timeout)
            
            async with self.session.get(self.api_url, params=params) as response:
                if response.status == 200:
                    data = await response.json()
                    
                    if data.get('data') and data['data'].get('list'):
                        draws = data['data']['list']
                        # 첫 번째가 최신 회차
                        latest_draw = draws[0]['ltEpsd']
                        logger.info(f"[SUCCESS] 최신 회차: {latest_draw}회")
                        return latest_draw
                    else:
                        logger.error("[ERROR] API 응답에 데이터 없음")
                        return None
                else:
                    logger.error(f"[ERROR] HTTP {response.status} 오류")
                    return None
                    
        except asyncio.TimeoutError:
            logger.error("[ERROR] 최신 회차 조회 타임아웃")
            return None
        except Exception as e:
            logger.error(f"[ERROR] 최신 회차 조회 실패: {e}")
            return None
    
    async def crawl_single(self, draw_no: int) -> Optional[Dict]:
        """
        단일 회차 크롤링
        
        Args:
            draw_no: 회차 번호
            
        Returns:
            Dict: 당첨번호 데이터
        """
        for attempt in range(self.retry_count):
            try:
                if not self.session:
                    self.session = aiohttp.ClientSession(timeout=self.timeout)
                
                # 해당 회차만 조회
                params = {
                    'srchStrLtEpsd': str(draw_no),
                    'srchEndLtEpsd': str(draw_no),
                    '_': str(int(datetime.now().timestamp() * 1000))
                }
                
                async with self.session.get(self.api_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        if data.get('data') and data['data'].get('list'):
                            draws = data['data']['list']
                            if draws:
                                result = self._parse_draw_data(draws[0])
                                if result:
                                    logger.debug(f"[SUCCESS] {draw_no}회 크롤링 성공")
                                    return result
                        
                        logger.warning(f"[WARN] {draw_no}회 데이터 없음")
                        return None
                            
            except asyncio.TimeoutError:
                logger.warning(
                    f"[WARN] {draw_no}회 타임아웃 "
                    f"(시도 {attempt + 1}/{self.retry_count})"
                )
            except Exception as e:
                logger.warning(
                    f"[WARN] {draw_no}회 크롤링 오류 "
                    f"(시도 {attempt + 1}/{self.retry_count}): {e}"
                )
            
            # Exponential backoff
            if attempt < self.retry_count - 1:
                await asyncio.sleep(2 ** attempt)
        
        logger.error(f"[ERROR] {draw_no}회 크롤링 최종 실패")
        return None
    
    def _parse_draw_data(self, item: Dict) -> Optional[Dict]:
        """
        JSON 데이터를 파싱
        
        Args:
            item: API 응답의 단일 아이템
            
        Returns:
            Dict: 당첨번호 데이터
        """
        try:
            draw_no = item['ltEpsd']
            
            # 당첨번호 6개
            numbers = [
                item['tm1WnNo'],
                item['tm2WnNo'],
                item['tm3WnNo'],
                item['tm4WnNo'],
                item['tm5WnNo'],
                item['tm6WnNo']
            ]
            
            # 번호 유효성 검증
            for num in numbers:
                if not 1 <= num <= 45:
                    logger.error(f"{draw_no}회: 범위 초과 번호 {num}")
                    return None
            
            # 보너스 번호
            bonus = item['bnsWnNo']
            if not 1 <= bonus <= 45:
                logger.error(f"{draw_no}회: 범위 초과 보너스 {bonus}")
                return None
            
            # 추첨일 파싱 (20260103 → 2026-01-03)
            draw_date_str = item['ltRflYmd']
            draw_date = f"{draw_date_str[:4]}-{draw_date_str[4:6]}-{draw_date_str[6:8]}"
            
            # 당첨금 정보
            first_prize_amount = item.get('rnk1WnAmt')
            first_winner_count = item.get('rnk1WnNope')
            
            return {
                'draw_no': draw_no,
                'draw_date': draw_date,
                'num1': numbers[0],
                'num2': numbers[1],
                'num3': numbers[2],
                'num4': numbers[3],
                'num5': numbers[4],
                'num6': numbers[5],
                'bonus': bonus,
                'first_prize_amount': first_prize_amount,
                'first_winner_count': first_winner_count,
            }
            
        except KeyError as e:
            logger.error(f"JSON 키 누락: {e}")
            return None
        except Exception as e:
            logger.error(f"데이터 파싱 실패: {e}")
            return None
    
    async def crawl_range(
        self,
        start_draw: int,
        end_draw: int,
        batch_size: int = 50
    ) -> List[Dict]:
        """
        범위 크롤링 (배치 처리)
        
        Args:
            start_draw: 시작 회차
            end_draw: 종료 회차
            batch_size: 한 번에 요청할 개수 (최대 50 권장)
            
        Returns:
            List[Dict]: 크롤링된 데이터 리스트
        """
        results = []
        total = end_draw - start_draw + 1
        
        logger.info(f"[DOWNLOAD] 범위 크롤링 시작: {start_draw}~{end_draw}회 (총 {total}회)")
        
        for batch_start in range(start_draw, end_draw + 1, batch_size):
            batch_end = min(batch_start + batch_size - 1, end_draw)
            
            try:
                if not self.session:
                    self.session = aiohttp.ClientSession(timeout=self.timeout)
                
                # API는 범위로 한 번에 조회 가능!
                params = {
                    'srchStrLtEpsd': str(batch_start),
                    'srchEndLtEpsd': str(batch_end),
                    '_': str(int(datetime.now().timestamp() * 1000))
                }
                
                async with self.session.get(self.api_url, params=params) as response:
                    if response.status == 200:
                        data = await response.json()
                        
                        if data.get('data') and data['data'].get('list'):
                            draws = data['data']['list']
                            
                            for item in draws:
                                parsed = self._parse_draw_data(item)
                                if parsed:
                                    results.append(parsed)
                            
                            success_count = len(draws)
                            logger.info(
                                f"  배치 완료: {batch_start}~{batch_end}회 "
                                f"({success_count}개 성공)"
                            )
                        else:
                            logger.warning(f"  배치 {batch_start}~{batch_end}회 데이터 없음")
                    else:
                        logger.error(f"  배치 {batch_start}~{batch_end}회 HTTP {response.status} 오류")
                
                # 과부하 방지 딜레이
                await asyncio.sleep(0.5)
                
            except Exception as e:
                logger.error(f"  배치 {batch_start}~{batch_end}회 오류: {e}")
        
        logger.success(f"[SUCCESS] 범위 크롤링 완료: {len(results)}/{total}개 성공")
        return results
