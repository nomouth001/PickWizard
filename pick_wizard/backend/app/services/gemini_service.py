"""
Google Gemini API 서비스

2026-01-18 EST - 초기 생성 (AI Selection 알고리즘용)
"""

import logging
from typing import Optional, Dict, Any

import google.generativeai as genai

logger = logging.getLogger(__name__)


class GeminiService:
    """
    Google Gemini API 클라이언트
    
    AI Selection 알고리즘에서 LLM 기반 번호 추천에 사용
    """
    
    def __init__(
        self,
        api_key: str,
        model: str,  # 2026-01-18 21:30:00 EST - 기본값 제거, config.py에서만 관리 (SSOT)
        temperature: float = 0.7,
        max_tokens: int = 1000,
        timeout: int = 30
    ):
        """
        Args:
            api_key: Google API 키
            model: 모델 이름 (gemini-2.5-flash)
            temperature: 샘플링 온도 (0.0~1.0)
            max_tokens: 최대 출력 토큰 수
            timeout: 타임아웃 (초)
        """
        if not api_key:
            raise ValueError("Google API key is required")
        if not model:
            raise ValueError("Model name is required")  # 2026-01-18 21:30:00 EST - 필수 검증 추가
        
        # API 키 설정
        genai.configure(api_key=api_key)
        
        # 설정 저장
        self.model_name = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.timeout = timeout
        
        # 모델 초기화
        # 2026-01-18 EST - response_mime_type 제거 (작동 안함)
        # 대신 프롬프트로 JSON 형식 요청 → 텍스트로 받아서 파싱
        self.model = genai.GenerativeModel(
            model_name=model,
            generation_config={
                "temperature": temperature,
                "max_output_tokens": max_tokens,
            }
        )
        
        logger.info(f"Gemini service initialized: model={model}, temperature={temperature}")
    
    def generate(self, prompt: str) -> Dict[str, Any]:
        """
        프롬프트를 전송하고 응답 받기
        
        Args:
            prompt: 입력 프롬프트
            
        Returns:
            Dict: 응답 데이터
                - text: 응답 텍스트
                - input_tokens: 입력 토큰 수
                - output_tokens: 출력 토큰 수
                - total_tokens: 총 토큰 수
                - cost: 비용 ($)
                
        Raises:
            Exception: API 호출 실패
        """
        try:
            # API 호출
            response = self.model.generate_content(
                prompt,
                request_options={"timeout": self.timeout}
            )
            
            # 토큰 사용량 (Gemini는 usage_metadata 제공)
            usage = response.usage_metadata if hasattr(response, 'usage_metadata') else {}
            input_tokens = usage.prompt_token_count if hasattr(usage, 'prompt_token_count') else 0
            output_tokens = usage.candidates_token_count if hasattr(usage, 'candidates_token_count') else 0
            total_tokens = input_tokens + output_tokens
            
            # 비용 계산
            # 2026-01-18 21:30:00 EST - config.py의 GEMINI_PRICING 사용 (SSOT, as-of-20260118)
            cost = self._calculate_cost(input_tokens, output_tokens)
            
            # 응답 텍스트
            text = response.text
            
            logger.info(f"Gemini API 성공: {total_tokens} 토큰, ${cost:.6f}")
            
            return {
                "text": text,
                "input_tokens": input_tokens,
                "output_tokens": output_tokens,
                "total_tokens": total_tokens,
                "cost": cost
            }
            
        except Exception as e:
            logger.error(f"Gemini API 실패: {e}")
            raise
    
    def _calculate_cost(self, input_tokens: int, output_tokens: int) -> float:
        """
        토큰 사용량 기반 비용 계산
        
        2026-01-18 21:30:00 EST - config.py의 GEMINI_PRICING 사용 (SSOT)
        as-of-20260118: Google 공식 가격표 반영
        
        ⚠️ 이전 오류 수정:
        - 이전: (input_tokens / 1000 * 0.00001) + (output_tokens / 1000 * 0.00003)
        - 문제: 실제 비용의 1/100로 계산됨
        - 수정: $/1M tokens 기준으로 정확히 계산
        
        Args:
            input_tokens: 입력 토큰 수
            output_tokens: 출력 토큰 수 (thinking tokens 포함)
        
        Returns:
            float: 비용 (USD)
        """
        from app.config import settings
        
        pricing = settings.GEMINI_PRICING.get(self.model_name)
        if not pricing:
            raise ValueError(
                f"No pricing info for model {self.model_name}. "
                f"Only gemini-2.5-flash is supported."
            )
        
        # $/1M tokens 기준으로 계산
        cost = (
            (input_tokens / 1_000_000 * pricing["input_per_1m"]) +
            (output_tokens / 1_000_000 * pricing["output_per_1m"])
        )
        return cost


# 테스트 함수
if __name__ == "__main__":
    import os
    
    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        print("GOOGLE_API_KEY 환경 변수가 설정되지 않았습니다.")
        exit(1)
    
    service = GeminiService(api_key=api_key)
    
    test_prompt = """
    You are a lottery number generator.
    Generate 3 sets of lottery numbers (6 numbers each, from 1-45).
    Output as JSON: {"numbers": [[1,2,3,4,5,6], ...]}
    """
    
    try:
        response = service.generate(test_prompt)
        print(f"Response: {response['text']}")
        print(f"Tokens: {response['total_tokens']}")
        print(f"Cost: ${response['cost']:.6f}")
    except Exception as e:
        print(f"Error: {e}")
