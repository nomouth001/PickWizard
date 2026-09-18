"""
알고리즘 8: 인공지능 선택 (AI Selection)

LLM이 과거 당첨 번호를 분석하여 번호 추천

2026-01-18 EST - 초기 생성
"""

import json
import logging
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
import time

import pandas as pd

from app.algorithms.base import LottoAlgorithm
from app.services.gemini_service import GeminiService
from app.config import settings

logger = logging.getLogger(__name__)


class AISelectionAlgorithm(LottoAlgorithm):
    """
    인공지능 선택 알고리즘
    
    Google Gemini API를 사용하여 과거 당첨 번호를 분석하고
    번호를 추천합니다.
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=8,
            name="인공지능 선택 (AI Selection)",
            description="AI가 과거 당첨 번호를 분석하여 추천합니다"
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=1  # 2026-01-18 EST - 5세트당 5코인 = 1세트당 1코인
        )
        
        # Gemini 서비스 초기화
        if not settings.GOOGLE_API_KEY:
            logger.warning("GOOGLE_API_KEY가 설정되지 않았습니다. AI Selection 알고리즘을 사용할 수 없습니다.")
            self.gemini_service = None
        else:
            self.gemini_service = GeminiService(
                api_key=settings.GOOGLE_API_KEY,
                model=settings.AI_SELECTION_MODEL,
                temperature=settings.AI_SELECTION_TEMPERATURE,
                max_tokens=settings.AI_SELECTION_MAX_TOKENS,
                timeout=settings.AI_SELECTION_TIMEOUT
            )
        
        # 프롬프트 템플릿 로드
        self.prompt_template = self._load_prompt_template()
        
        # 분석 범위 (회차 수)
        self.window_size = settings.AI_SELECTION_WINDOW_SIZE
    
    def _load_prompt_template(self) -> str:
        """프롬프트 템플릿 파일 로드"""
        prompt_path = Path(__file__).parent.parent / "prompts" / "ai_selection_prompt.txt"
        
        if not prompt_path.exists():
            raise FileNotFoundError(f"Prompt template not found: {prompt_path}")
        
        with open(prompt_path, "r", encoding="utf-8") as f:
            return f.read()
    
    def _prepare_csv_data(self, historical_data: pd.DataFrame) -> str:
        """
        과거 당첨 번호를 CSV 문자열로 변환
        
        2026-01-18 EST - 프롬프트용 데이터 간소화 (토큰 절약)
        필요: draw_no, draw_date, num1~num6
        불필요: bonus, first_prize_amount, first_winner_count
        
        2026-01-18 EST - 빈 줄 제거 (토큰 추가 절약)
        
        Args:
            historical_data: 과거 당첨 번호 데이터프레임
            
        Returns:
            str: CSV 형식 문자열 (간소화됨, 빈 줄 없음)
        """
        # 최근 N회차만 사용
        recent_data = historical_data.tail(self.window_size)
        
        # 프롬프트에 필요한 컬럼만 선택 (토큰 절약)
        columns_to_use = ['draw_no', 'draw_date', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6']
        recent_data = recent_data[columns_to_use]
        
        # CSV 문자열 생성 (lineterminator로 빈 줄 제거)
        csv_string = recent_data.to_csv(index=False, lineterminator='\n')
        
        return csv_string
    
    def _build_prompt(self, n_sets: int, csv_data: str) -> str:
        """
        프롬프트 템플릿에 변수 치환
        
        Args:
            n_sets: 생성할 세트 수
            csv_data: CSV 형식의 과거 데이터
            
        Returns:
            str: 완성된 프롬프트
        """
        prompt = self.prompt_template.format(
            n_sets=n_sets,
            window_size=self.window_size,
            csv_data=csv_data
        )
        
        return prompt
    
    def _parse_response(self, response_text: str, n_sets: int) -> tuple[List[List[int]], dict]:
        """
        Gemini API 응답 파싱
        
        2026-01-18 EST - 단순 텍스트 형식으로 변경 (JSON 제거)
        형식: 한 줄에 6개 숫자, 콤마 구분
        
        Args:
            response_text: API 응답 텍스트
            n_sets: 기대하는 세트 수
            
        Returns:
            tuple: (번호 세트 리스트, 메타데이터)
            
        Raises:
            ValueError: 파싱 실패 또는 유효성 검증 실패
        """
        try:
            # 응답 텍스트 정리
            response_text = response_text.strip()
            
            # 줄 단위로 분리
            lines = response_text.split('\n')
            number_sets = []
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                
                # 콤마로 분리하여 숫자 추출
                try:
                    numbers = [int(x.strip()) for x in line.split(',')]
                    
                    # 6개 숫자인 경우만 처리
                    if len(numbers) == 6:
                        # 범위 검증
                        if all(1 <= num <= 45 for num in numbers):
                            # 중복 검증
                            if len(set(numbers)) == 6:
                                # 정렬
                                number_sets.append(sorted(numbers))
                except (ValueError, AttributeError):
                    # 숫자로 변환 실패한 줄은 무시
                    continue
            
            # 세트 수 확인
            if len(number_sets) < n_sets:
                raise ValueError(f"Expected {n_sets} sets, got only {len(number_sets)}")
            
            # 요청한 개수만큼만 반환
            number_sets = number_sets[:n_sets]
            
            # 메타데이터 (비어있음)
            metadata = {
                "confidence": 0.0,
                "reasoning": ""
            }
            
            return number_sets, metadata
            
        except Exception as e:
            raise ValueError(f"Response parsing failed: {e}\nResponse text: {response_text[:500]}")
    
    def _save_debug_log(
        self,
        user_id: Optional[int],
        prompt: str,
        csv_data: str,
        response: Optional[str],
        result: Optional[List[List[int]]],
        metadata: dict,
        error: Optional[Exception] = None
    ) -> None:
        """디버그 로그 저장"""
        # 타임스탬프
        now = datetime.now(timezone.utc)
        timestamp = now.strftime("%Y%m%d_%H%M%S")
        
        # user_id가 없으면 'guest' 사용
        user_str = f"user{user_id}" if user_id else "guest"
        
        # 로그 디렉토리 생성
        log_dir = Path("results/logs/ai_selection")
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # 파일명
        filename = f"{timestamp}_{user_str}.txt"
        filepath = log_dir / filename
        
        # 로그 내용 생성
        with open(filepath, "w", encoding="utf-8") as f:
            f.write("=" * 47 + "\n")
            f.write("AI Selection Algorithm - Debug Log\n")
            f.write("=" * 47 + "\n\n")
            
            # Request Info
            f.write("[REQUEST INFO]\n")
            f.write(f"Timestamp: {now.isoformat()}\n")
            f.write(f"User ID: {user_id or 'Guest'}\n")
            f.write(f"Algorithm ID: 8\n")
            f.write(f"N Sets: {metadata.get('n_sets', 'N/A')}\n")
            f.write(f"Window Size: {metadata.get('window_size', 'N/A')}\n\n")
            
            # Prompt
            f.write("[PROMPT]\n")
            f.write("-" * 43 + "\n")
            f.write(prompt + "\n")
            f.write("-" * 43 + "\n\n")
            
            # CSV Data (처음 5줄만)
            csv_lines = csv_data.split("\n")
            f.write(f"[CSV DATA] (First 5 rows)\n")
            f.write("\n".join(csv_lines[:6]) + "\n")
            f.write(f"(... {len(csv_lines) - 6} more rows)\n\n")
            
            # API Call Info
            f.write("[API CALL]\n")
            f.write(f"Model: {metadata.get('model', 'N/A')}\n")
            f.write(f"Temperature: {metadata.get('temperature', 'N/A')}\n")
            f.write(f"Max Tokens: {metadata.get('max_tokens', 'N/A')}\n")
            f.write(f"Timeout: {metadata.get('timeout', 'N/A')}s\n\n")
            
            # Response
            f.write("[RESPONSE]\n")
            if error:
                f.write(f"Status: FAILURE\n")
                f.write(f"Duration: {metadata.get('duration', 'N/A')} seconds\n")
                f.write(f"Error Type: {type(error).__name__}\n")
                f.write(f"Error Message: {str(error)}\n\n")
                
                # Retry 정보
                if metadata.get('retry_attempted'):
                    f.write("[RETRY]\n")
                    f.write(f"Attempt: {metadata.get('retry_count', 0)}/1\n")
                    f.write(f"Status: {metadata.get('retry_status', 'N/A')}\n\n")
            else:
                f.write(f"Status: SUCCESS\n")
                f.write(f"Duration: {metadata.get('duration', 'N/A')} seconds\n")
                f.write(f"Input Tokens: {metadata.get('input_tokens', 'N/A')}\n")
                f.write(f"Output Tokens: {metadata.get('output_tokens', 'N/A')}\n")
                f.write(f"Total Tokens: {metadata.get('total_tokens', 'N/A')}\n")
                f.write(f"Cost: ${metadata.get('cost', 'N/A')}\n\n")
                
                f.write("Raw Response:\n")
                f.write("-" * 43 + "\n")
                f.write(response + "\n")
                f.write("-" * 43 + "\n\n")
            
            # Parsing
            if result:
                f.write("[PARSING]\n")
                f.write("Status: SUCCESS\n")
                f.write(f"Parsed Sets: {len(result)}\n")
                f.write("Validation: PASS\n\n")
                
                f.write("[RESULT]\n")
                for i, number_set in enumerate(result, 1):
                    f.write(f"Set {i}: {number_set}\n")
                f.write(f"\nConfidence: {metadata.get('confidence', 'N/A')}\n")
                f.write(f"Reasoning: {metadata.get('reasoning', 'N/A')}\n\n")
            
            f.write("[END]\n")
            f.write("=" * 47 + "\n")
        
        logger.info(f"Debug log saved: {filepath}")
    
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        user_id: Optional[int] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        인공지능 기반 번호 생성
        
        Args:
            historical_data: 과거 당첨 번호 데이터프레임
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호 (현재 미지원)
            include_numbers: 포함할 번호 (현재 미지원)
            user_id: 사용자 ID (로그용)
            
        Returns:
            List[List[int]]: 생성된 번호 세트 리스트
            
        Raises:
            ValueError: API 호출 실패 또는 파싱 실패
        """
        # Gemini 서비스 체크
        if not self.gemini_service:
            raise ValueError("Google API 키가 설정되지 않았습니다. AI Selection 알고리즘을 사용할 수 없습니다.")
        
        # 메타데이터 초기화
        metadata = {
            "n_sets": n_sets,
            "window_size": self.window_size,
            "model": settings.AI_SELECTION_MODEL,
            "temperature": settings.AI_SELECTION_TEMPERATURE,
            "max_tokens": settings.AI_SELECTION_MAX_TOKENS,
            "timeout": settings.AI_SELECTION_TIMEOUT,
        }
        
        # CSV 데이터 준비
        csv_data = self._prepare_csv_data(historical_data)
        
        # 프롬프트 생성
        prompt = self._build_prompt(n_sets, csv_data)
        
        # API 호출
        start_time = time.time()
        try:
            # 첫 번째 시도
            response = self.gemini_service.generate(prompt)
            duration = time.time() - start_time
            
            metadata.update({
                "duration": round(duration, 2),
                "input_tokens": response.get("input_tokens", 0),
                "output_tokens": response.get("output_tokens", 0),
                "total_tokens": response.get("total_tokens", 0),
                "cost": response.get("cost", 0.0)
            })
            
            # 응답 파싱
            response_text = response["text"]
            number_sets, parse_metadata = self._parse_response(response_text, n_sets)
            
            metadata.update(parse_metadata)
            
            # 로그 저장
            self._save_debug_log(
                user_id=user_id,
                prompt=prompt,
                csv_data=csv_data,
                response=response_text,
                result=number_sets,
                metadata=metadata,
                error=None
            )
            
            logger.info(f"AI Selection 성공: {n_sets}세트 생성, {duration:.2f}초 소요")
            return number_sets
            
        except Exception as first_error:
            duration = time.time() - start_time
            metadata["duration"] = round(duration, 2)
            
            logger.warning(f"AI Selection 첫 번째 시도 실패: {first_error}")
            
            # 재시도
            metadata["retry_attempted"] = True
            metadata["retry_count"] = 1
            
            try:
                retry_start = time.time()
                response = self.gemini_service.generate(prompt)
                retry_duration = time.time() - retry_start
                
                metadata["retry_status"] = "SUCCESS"
                metadata["retry_duration"] = round(retry_duration, 2)
                metadata.update({
                    "duration": round(duration + retry_duration, 2),
                    "input_tokens": response.get("input_tokens", 0),
                    "output_tokens": response.get("output_tokens", 0),
                    "total_tokens": response.get("total_tokens", 0),
                    "cost": response.get("cost", 0.0)
                })
                
                # 응답 파싱
                response_text = response["text"]
                number_sets, parse_metadata = self._parse_response(response_text, n_sets)
                
                metadata.update(parse_metadata)
                
                # 로그 저장
                self._save_debug_log(
                    user_id=user_id,
                    prompt=prompt,
                    csv_data=csv_data,
                    response=response_text,
                    result=number_sets,
                    metadata=metadata,
                    error=None
                )
                
                logger.info(f"AI Selection 재시도 성공: {n_sets}세트 생성")
                return number_sets
                
            except Exception as retry_error:
                retry_duration = time.time() - retry_start
                metadata["retry_status"] = "FAILURE"
                metadata["retry_duration"] = round(retry_duration, 2)
                metadata["duration"] = round(duration + retry_duration, 2)
                
                # 실패 로그 저장
                self._save_debug_log(
                    user_id=user_id,
                    prompt=prompt,
                    csv_data=csv_data,
                    response=None,
                    result=None,
                    metadata=metadata,
                    error=retry_error
                )
                
                logger.error(f"AI Selection 재시도 실패: {retry_error}")
                raise ValueError("AI 서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.")
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터 반환"""
        return {
            "n_sets": 5,
            "window_size": self.window_size
        }


# 알고리즘 등록
def get_algorithm():
    """알고리즘 인스턴스 반환"""
    return AISelectionAlgorithm()
