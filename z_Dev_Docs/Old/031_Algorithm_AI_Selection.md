# 알고리즘 설계 명세서 - 인공지능 선택 (AI Selection)

**문서 버전**: v1.0  
**작성일**: 2026-01-17 EST  
**작성자**: AI Assistant  
**상태**: 설계 완료 → 구현 대기

---

## 📑 목차

1. [개요](#1-개요)
2. [기술 스펙](#2-기술-스펙)
3. [프롬프트 설계](#3-프롬프트-설계)
4. [응답 파싱](#4-응답-파싱)
5. [로깅 시스템](#5-로깅-시스템)
6. [Config 설정](#6-config-설정)
7. [백엔드 구현 계획](#7-백엔드-구현-계획)
8. [프론트엔드 구현 계획](#8-프론트엔드-구현-계획)
9. [도움말 텍스트](#9-도움말-텍스트)
10. [테스트 계획](#10-테스트-계획)
11. [구현 체크리스트](#11-구현-체크리스트)

---

## 1. 개요

### 1.1 알고리즘 정의

- **알고리즘 ID**: 8
- **이름 (한글)**: 인공지능 선택
- **이름 (영문)**: AI Selection
- **설명**: Large Language Model이 과거 당첨 번호 데이터를 분석하여 번호를 추천하는 알고리즘

### 1.2 핵심 특징

1. **외부 LLM API 연동**: Google Gemini API를 사용하여 번호 생성
2. **프롬프트 기반**: 별도 `.txt` 파일로 관리되는 프롬프트를 사용하여 튜닝 용이
3. **풀 컨텍스트 분석**: 최근 N회차의 전체 당첨 번호 데이터를 LLM에 전송
4. **디버그 로깅**: 모든 API 요청/응답을 타임스탬프와 user_id와 함께 로그 파일로 저장
5. **JSON 응답 파싱**: 구조화된 JSON 형식으로 응답받아 안정적으로 파싱

### 1.3 사용 시나리오

```
사용자 → "인공지능 선택" 알고리즘 선택
      → 생성 개수 입력 (예: 5세트)
      → "번호 생성" 버튼 클릭
      → Backend: 과거 200회차 당첨 번호 CSV 로드
      → Backend: 프롬프트 템플릿 로드 + 변수 치환
      → Backend: Gemini API 호출
      → Backend: JSON 응답 파싱
      → Backend: 로그 저장 (프롬프트 + 응답)
      → Frontend: 생성된 번호 표시
```

### 1.4 다른 알고리즘과의 차이점

| 특징 | 기존 알고리즘 | 인공지능 선택 |
|------|--------------|--------------|
| 처리 방식 | 로컬 계산 (규칙 기반) | 외부 API 호출 (LLM 추론) |
| 속도 | 빠름 (< 1초) | 느림 (3~10초) |
| 비용 | 낮음 (0~3코인) | 높음 (5코인/세트) |
| 설명 가능성 | 높음 (알고리즘 로직 명확) | 낮음 (블랙박스) |
| 확장성 | 제한적 (코드 수정 필요) | 높음 (프롬프트 수정만) |
| 디버깅 | 로컬 디버거 사용 | 로그 파일 분석 |

---

## 2. 기술 스펙

### 2.1 알고리즘 기본 정보

```python
AlgorithmInfo(
    algorithm_id=8,
    name="인공지능 선택 (AI Selection)",
    description="AI가 과거 당첨 번호를 분석하여 추천합니다",
    category="advanced",
    cost_per_set=5,  # pricing_config.yaml에서 관리
    is_premium=True,
    requires_api=True,
    average_duration_seconds=5.0
)
```

### 2.2 LLM API 스펙

```yaml
Provider: Google Gemini
Model: gemini-2.5-flash-latest
Temperature: 0.7 (약간의 창의성)
Max Output Tokens: 1000
Response Format: JSON

Retry Policy:
  max_retries: 1
  timeout: 30초
  exponential_backoff: false

Error Handling:
  - API 실패 시: 에러 메시지 표시
  - 환불: Phase 6 (IAP 구현 시)에서 처리
```

### 2.3 비용 정책

```yaml
cost_per_set: 5코인
pricing_examples:
  - 1세트: 5코인
  - 5세트: 25코인
  - 10세트: 50코인

# 참고: 딥러닝 선택(3코인)보다 비싸지만,
# LLM의 설명력과 창의성으로 차별화
```

### 2.4 파라미터

| 파라미터 | 타입 | 기본값 | 범위 | 설명 |
|----------|------|--------|------|------|
| `n_sets` | int | 5 | 1~10 | 생성할 번호 세트 수 |
| `window_size` | int | 200 | - | 분석할 과거 회차 수 (Config) |

**UI 노출**: `n_sets`만 노출 (기존 "생성 개수" 입력 사용)  
**UI 비노출**: `window_size`는 자동 적용 (사용자가 선택 불가)

---

## 3. 프롬프트 설계

### 3.1 프롬프트 파일 위치

```
backend/app/prompts/ai_selection_prompt.txt
```

### 3.2 프롬프트 템플릿

```text
You are a professional lottery number analyst specializing in Korean Lotto 645.

## Task
Analyze the provided historical lottery winning numbers and generate {n_sets} sets of recommended numbers.

## Rules
1. Each set must contain exactly 6 unique numbers
2. All numbers must be between 1 and 45 (inclusive)
3. Consider patterns in the historical data, but maintain randomness
4. Output ONLY valid JSON format (no extra text)

## Historical Data
The following CSV contains the last {window_size} draws of Lotto 645:
- Format: draw_no,date,num1,num2,num3,num4,num5,num6,bonus
- Most recent draw is at the bottom

{csv_data}

## Output Format
Return a JSON object with the following structure:
{
  "numbers": [
    [1, 2, 3, 4, 5, 6],
    [7, 8, 9, 10, 11, 12]
  ],
  "confidence": 0.75,
  "reasoning": "Brief explanation of why these numbers were selected (2-3 sentences, in Korean)"
}

## Important
- "numbers": Array of {n_sets} number sets (each set has 6 integers)
- "confidence": Float between 0.0 and 1.0 (your confidence in this prediction)
- "reasoning": String in Korean explaining your analysis approach
- Ensure all numbers are valid (1-45) and sets have no duplicates

Generate {n_sets} number sets now.
```

### 3.3 변수 치환

프롬프트 내의 플레이스홀더를 실제 값으로 치환:

```python
prompt_template = load_prompt_template("ai_selection_prompt.txt")

prompt = prompt_template.format(
    n_sets=5,
    window_size=200,
    csv_data=historical_csv_string
)
```

### 3.4 CSV 데이터 형식

```csv
draw_no,date,num1,num2,num3,num4,num5,num6,bonus
1100,2023-12-30,3,12,15,23,34,38,7
1101,2024-01-06,5,11,18,27,33,42,9
1102,2024-01-13,2,8,19,25,31,44,12
...
1150,2024-06-15,7,14,21,28,35,41,3
```

**토큰 추정**:
- 200회차 × 평균 40자/회차 ≈ 8,000자
- 토큰: ~2,000 (입력)
- 프롬프트: ~500 토큰
- 응답: ~200 토큰
- **총계: ~2,700 토큰/요청**

**비용 추정** (Gemini 2.5 Flash):
- 입력: 2,500 토큰 × $0.00001 = $0.000025
- 출력: 200 토큰 × $0.00003 = $0.000006
- **총 비용: $0.000031/요청 ≈ ₩0.04원**
- 사용자 과금: 5코인/세트 → 실제 비용은 극히 낮음 (마진 매우 높음)

---

## 4. 응답 파싱

### 4.1 응답 JSON 구조

```json
{
  "numbers": [
    [3, 12, 18, 27, 35, 42],
    [5, 11, 19, 28, 34, 41],
    [7, 14, 21, 30, 37, 44],
    [2, 9, 16, 25, 33, 40],
    [4, 13, 20, 29, 36, 43]
  ],
  "confidence": 0.68,
  "reasoning": "최근 200회차 데이터를 분석한 결과, 중간 범위(11-35) 번호가 평균 3.2개씩 출현하는 패턴을 발견했습니다. 또한 연속 번호(consecutive)가 평균 1.5개 포함되는 경향이 있어 이를 반영했습니다."
}
```

### 4.2 파싱 로직

```python
def parse_ai_response(response_text: str, n_sets: int) -> List[List[int]]:
    """
    Gemini API 응답을 파싱하여 번호 세트 리스트 반환
    
    Args:
        response_text: Gemini API 응답 텍스트
        n_sets: 기대하는 세트 수
        
    Returns:
        List[List[int]]: 번호 세트 리스트
        
    Raises:
        ValueError: 파싱 실패 또는 유효성 검증 실패
    """
    try:
        # JSON 파싱
        data = json.loads(response_text)
        
        # 필수 필드 확인
        if "numbers" not in data:
            raise ValueError("Response missing 'numbers' field")
        
        number_sets = data["numbers"]
        
        # 세트 수 확인
        if len(number_sets) != n_sets:
            raise ValueError(f"Expected {n_sets} sets, got {len(number_sets)}")
        
        # 각 세트 검증
        for i, number_set in enumerate(number_sets):
            # 길이 확인
            if len(number_set) != 6:
                raise ValueError(f"Set {i+1} has {len(number_set)} numbers (expected 6)")
            
            # 중복 확인
            if len(number_set) != len(set(number_set)):
                raise ValueError(f"Set {i+1} contains duplicate numbers")
            
            # 범위 확인
            for num in number_set:
                if not isinstance(num, int) or num < 1 or num > 45:
                    raise ValueError(f"Invalid number {num} in set {i+1}")
            
            # 정렬 (UI 표시용)
            number_set.sort()
        
        return number_sets
        
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON response: {e}")
    except Exception as e:
        raise ValueError(f"Response parsing failed: {e}")
```

### 4.3 에러 처리

```python
# Case 1: JSON 파싱 실패
response_text = "I think numbers 1, 2, 3..."
→ ValueError: Invalid JSON response

# Case 2: 잘못된 번호 범위
{"numbers": [[1, 2, 3, 4, 5, 50]]}
→ ValueError: Invalid number 50 in set 1

# Case 3: 중복 번호
{"numbers": [[1, 2, 3, 4, 5, 5]]}
→ ValueError: Set 1 contains duplicate numbers

# Case 4: 불완전한 응답
{"numbers": [[1, 2, 3, 4, 5]]}
→ ValueError: Set 1 has 5 numbers (expected 6)
```

---

## 5. 로깅 시스템

### 5.1 로그 파일 구조

```
backend/results/logs/ai_selection/
├── 20260117_143025_user1001.txt
├── 20260117_143156_user1002.txt
├── 20260117_144312_user1001.txt
└── ...
```

**파일명 형식**: `YYYYMMDD_HHMMSS_user{user_id}.txt`

### 5.2 로그 파일 내용

```text
===============================================
AI Selection Algorithm - Debug Log
===============================================

[REQUEST INFO]
Timestamp: 2026-01-17T14:30:25.123456Z
User ID: 1001
Algorithm ID: 8
N Sets: 5
Window Size: 200

[PROMPT]
-------------------------------------------
You are a professional lottery number analyst...
(전체 프롬프트 내용)
-------------------------------------------

[CSV DATA] (First 5 rows)
draw_no,date,num1,num2,num3,num4,num5,num6,bonus
1146,2024-05-18,4,11,19,26,34,42,8
1147,2024-05-25,6,13,21,29,36,43,5
1148,2024-06-01,3,10,18,27,35,41,12
1149,2024-06-08,5,12,20,28,37,44,7
(... 196 more rows)

[API CALL]
Model: gemini-2.5-flash-latest
Temperature: 0.7
Max Tokens: 1000
Timeout: 30s

[RESPONSE]
Status: SUCCESS
Duration: 4.23 seconds
Input Tokens: 2,534
Output Tokens: 187
Total Tokens: 2,721
Cost: $0.000031

Raw Response:
-------------------------------------------
{
  "numbers": [
    [3, 12, 18, 27, 35, 42],
    [5, 11, 19, 28, 34, 41],
    [7, 14, 21, 30, 37, 44],
    [2, 9, 16, 25, 33, 40],
    [4, 13, 20, 29, 36, 43]
  ],
  "confidence": 0.68,
  "reasoning": "최근 200회차 데이터를 분석..."
}
-------------------------------------------

[PARSING]
Status: SUCCESS
Parsed Sets: 5
Validation: PASS

[RESULT]
Set 1: [3, 12, 18, 27, 35, 42]
Set 2: [5, 11, 19, 28, 34, 41]
Set 3: [7, 14, 21, 30, 37, 44]
Set 4: [2, 9, 16, 25, 33, 40]
Set 5: [4, 13, 20, 29, 36, 43]

Confidence: 0.68
Reasoning: 최근 200회차 데이터를 분석한 결과...

[END]
===============================================
```

### 5.3 실패 시 로그

```text
[RESPONSE]
Status: FAILURE
Duration: 1.52 seconds
Error Type: APIError
Error Message: Connection timeout

[RETRY]
Attempt: 1/1
Status: FAILURE
Duration: 1.48 seconds
Error Type: APIError
Error Message: Connection timeout

[FINAL RESULT]
Status: FAILED
User Notified: YES
Error Message: "AI 서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요."

[NOTE]
코인 환불: N/A (Phase 6에서 구현 예정)

[END]
===============================================
```

### 5.4 로깅 함수

```python
def save_ai_selection_log(
    user_id: int,
    prompt: str,
    csv_data: str,
    response: Optional[str],
    result: Optional[List[List[int]]],
    metadata: dict,
    error: Optional[Exception] = None
) -> Path:
    """
    AI Selection 알고리즘 디버그 로그 저장
    
    Args:
        user_id: 사용자 ID
        prompt: 전송한 프롬프트
        csv_data: CSV 데이터 (일부만 로그에 기록)
        response: API 응답 (성공 시)
        result: 파싱된 번호 세트 (성공 시)
        metadata: 메타데이터 (duration, tokens, cost 등)
        error: 에러 객체 (실패 시)
        
    Returns:
        Path: 생성된 로그 파일 경로
    """
    # 타임스탬프
    now = datetime.now(timezone.utc)
    timestamp = now.strftime("%Y%m%d_%H%M%S")
    
    # 로그 디렉토리 생성
    log_dir = Path("backend/results/logs/ai_selection")
    log_dir.mkdir(parents=True, exist_ok=True)
    
    # 파일명
    filename = f"{timestamp}_user{user_id}.txt"
    filepath = log_dir / filename
    
    # 로그 내용 생성
    with open(filepath, "w", encoding="utf-8") as f:
        f.write("=" * 47 + "\n")
        f.write("AI Selection Algorithm - Debug Log\n")
        f.write("=" * 47 + "\n\n")
        
        # Request Info
        f.write("[REQUEST INFO]\n")
        f.write(f"Timestamp: {now.isoformat()}\n")
        f.write(f"User ID: {user_id}\n")
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
    
    return filepath
```

---

## 6. Config 설정

### 6.1 `.env` 파일 추가

```bash
# ===================================================================
# Google Gemini API Configuration
# ===================================================================
# AI Selection 알고리즘에서 사용
# API 키 발급: https://makersuite.google.com/app/apikey
GOOGLE_API_KEY=your-api-key-here

# AI Selection 기본 설정
AI_SELECTION_MODEL=gemini-2.5-flash-latest
AI_SELECTION_TEMPERATURE=0.7
AI_SELECTION_MAX_TOKENS=1000
AI_SELECTION_TIMEOUT=30
AI_SELECTION_WINDOW_SIZE=200
```

### 6.2 `app/config.py` 수정

```python
class Settings(BaseSettings):
    # ... 기존 설정 ...
    
    # === Google Gemini API ===
    GOOGLE_API_KEY: Optional[str] = None
    
    # === AI Selection Algorithm ===
    AI_SELECTION_MODEL: str = "gemini-2.5-flash-latest"
    AI_SELECTION_TEMPERATURE: float = 0.7
    AI_SELECTION_MAX_TOKENS: int = 1000
    AI_SELECTION_TIMEOUT: int = 30
    AI_SELECTION_WINDOW_SIZE: int = 200
```

### 6.3 `app/config/pricing_config.yaml` 수정

```yaml
policies:
  standard:
    algorithm_costs:
      1: 0    # 자동선택
      2: 2    # 출현 번호 빈도 기반 선택 (고급)
      3: 3    # 딥러닝 선택
      4: 2    # 출현 번호 패턴 기반 선택
      5: 3    # 가중치 조합 선택
      6: 1    # 출현 번호 빈도 기반 선택
      7: 1    # 핫/콜드 넘버 선택
      8: 5    # 인공지능 선택 (신규)
```

---

## 7. 백엔드 구현 계획

### 7.1 파일 구조

```
backend/app/
├── algorithms/
│   ├── algorithm_08_ai_selection.py  # 신규
│   └── ...
├── prompts/
│   └── ai_selection_prompt.txt       # 신규
├── services/
│   └── gemini_service.py             # 신규 (Gemini API 클라이언트)
├── utils/
│   └── logging_utils.py              # 로깅 유틸리티 (기존 확장)
└── config.py                          # 수정

backend/results/logs/
└── ai_selection/                      # 신규 디렉토리
```

### 7.2 `algorithm_08_ai_selection.py`

```python
"""
알고리즘 8: 인공지능 선택 (AI Selection)

LLM이 과거 당첨 번호를 분석하여 번호 추천

2026-01-17 EST - 초기 생성
"""

import json
import logging
from pathlib import Path
from typing import List, Optional
from datetime import datetime, timezone

import pandas as pd

from ..algorithms.base import BaseAlgorithm
from ..services.gemini_service import GeminiService
from ..config import settings

logger = logging.getLogger(__name__)


class AISelectionAlgorithm(BaseAlgorithm):
    """
    인공지능 선택 알고리즘
    
    Google Gemini API를 사용하여 과거 당첨 번호를 분석하고
    번호를 추천합니다.
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=8,
            name="인공지능 선택 (AI Selection)",
            description="AI가 과거 당첨 번호를 분석하여 추천합니다",
            category="advanced",
            cost_per_set=5,
            is_premium=True
        )
        
        # Gemini 서비스 초기화
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
        
        Args:
            historical_data: 과거 당첨 번호 데이터프레임
            
        Returns:
            str: CSV 형식 문자열
        """
        # 최근 N회차만 사용
        recent_data = historical_data.tail(self.window_size)
        
        # CSV 문자열 생성
        csv_string = recent_data.to_csv(index=False)
        
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
        
        Args:
            response_text: API 응답 텍스트
            n_sets: 기대하는 세트 수
            
        Returns:
            tuple: (번호 세트 리스트, 메타데이터)
            
        Raises:
            ValueError: 파싱 실패 또는 유효성 검증 실패
        """
        try:
            # JSON 파싱
            data = json.loads(response_text)
            
            # 필수 필드 확인
            if "numbers" not in data:
                raise ValueError("Response missing 'numbers' field")
            
            number_sets = data["numbers"]
            
            # 세트 수 확인
            if len(number_sets) != n_sets:
                raise ValueError(f"Expected {n_sets} sets, got {len(number_sets)}")
            
            # 각 세트 검증
            for i, number_set in enumerate(number_sets):
                # 길이 확인
                if len(number_set) != 6:
                    raise ValueError(f"Set {i+1} has {len(number_set)} numbers (expected 6)")
                
                # 중복 확인
                if len(number_set) != len(set(number_set)):
                    raise ValueError(f"Set {i+1} contains duplicate numbers")
                
                # 범위 확인
                for num in number_set:
                    if not isinstance(num, int) or num < 1 or num > 45:
                        raise ValueError(f"Invalid number {num} in set {i+1}")
                
                # 정렬 (UI 표시용)
                number_set.sort()
            
            # 메타데이터 추출
            metadata = {
                "confidence": data.get("confidence", 0.5),
                "reasoning": data.get("reasoning", "")
            }
            
            return number_sets, metadata
            
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON response: {e}")
        except Exception as e:
            raise ValueError(f"Response parsing failed: {e}")
    
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
        log_dir = Path("backend/results/logs/ai_selection")
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
        import time
        
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


# 알고리즘 등록
def get_algorithm():
    """알고리즘 인스턴스 반환"""
    return AISelectionAlgorithm()
```

### 7.3 `services/gemini_service.py` (신규)

```python
"""
Google Gemini API 서비스

2026-01-17 EST - 초기 생성
"""

import logging
from typing import Optional, Dict, Any

import google.generativeai as genai

logger = logging.getLogger(__name__)


class GeminiService:
    """
    Google Gemini API 클라이언트
    """
    
    def __init__(
        self,
        api_key: str,
        model: str = "gemini-2.5-flash-latest",
        temperature: float = 0.7,
        max_tokens: int = 1000,
        timeout: int = 30
    ):
        """
        Args:
            api_key: Google API 키
            model: 모델 이름
            temperature: 샘플링 온도 (0.0~1.0)
            max_tokens: 최대 출력 토큰 수
            timeout: 타임아웃 (초)
        """
        if not api_key:
            raise ValueError("Google API key is required")
        
        # API 키 설정
        genai.configure(api_key=api_key)
        
        # 설정 저장
        self.model_name = model
        self.temperature = temperature
        self.max_tokens = max_tokens
        self.timeout = timeout
        
        # 모델 초기화
        self.model = genai.GenerativeModel(
            model_name=model,
            generation_config={
                "temperature": temperature,
                "max_output_tokens": max_tokens,
                "response_mime_type": "application/json"
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
            input_tokens = usage.get('prompt_token_count', 0)
            output_tokens = usage.get('candidates_token_count', 0)
            total_tokens = input_tokens + output_tokens
            
            # 비용 계산 (Gemini 2.5 Flash 기준)
            # 입력: $0.00001/1K 토큰, 출력: $0.00003/1K 토큰
            cost = (input_tokens / 1000 * 0.00001) + (output_tokens / 1000 * 0.00003)
            
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


# 테스트 함수
if __name__ == "__main__":
    import os
    
    api_key = os.getenv("GOOGLE_API_KEY")
    service = GeminiService(api_key=api_key)
    
    test_prompt = """
    You are a lottery number generator.
    Generate 3 sets of lottery numbers (6 numbers each, from 1-45).
    Output as JSON: {"numbers": [[1,2,3,4,5,6], ...]}
    """
    
    response = service.generate(test_prompt)
    print(f"Response: {response['text']}")
    print(f"Tokens: {response['total_tokens']}")
    print(f"Cost: ${response['cost']:.6f}")
```

### 7.4 `prompts/ai_selection_prompt.txt` (신규)

이미 [3.2절](#32-프롬프트-템플릿)에 작성되어 있음.

---

## 8. 프론트엔드 구현 계획

### 8.1 ARB 키 추가

**`app_ko.arb`**:
```json
{
  "algorithm8Name": "인공지능 선택",
  "algorithm8Description": "AI가 과거 당첨 번호를 분석하여 추천합니다",
  "algorithm8HelpTitle": "인공지능 선택이란?",
  "algorithm8HelpOverview": "대규모 언어 모델(AI)이 과거 당첨 번호 데이터를 학습하고 패턴을 분석하여 번호를 추천하는 알고리즘입니다.",
  "algorithm8HelpHowItWorks": "1. 최근 200회차의 당첨 번호 데이터를 AI에 전송합니다.\n2. AI가 통계적 패턴, 빈도, 분포 등을 종합적으로 분석합니다.\n3. 분석 결과를 바탕으로 추천 번호를 생성합니다.",
  "algorithm8HelpWhenToUse": "• AI의 창의적인 분석을 원할 때\n• 다른 알고리즘과 다른 접근을 시도하고 싶을 때\n• 복합적인 패턴 분석을 기대할 때",
  "algorithm8HelpNote": "주의: AI 응답 생성에 3~10초가 소요될 수 있습니다. 네트워크 상태에 따라 실패할 수 있으니 안정적인 인터넷 연결이 필요합니다."
}
```

**`app_en.arb`**:
```json
{
  "algorithm8Name": "AI Selection",
  "algorithm8Description": "AI analyzes past winning numbers and recommends numbers",
  "algorithm8HelpTitle": "What is AI Selection?",
  "algorithm8HelpOverview": "An algorithm where a Large Language Model (AI) learns from historical winning number data and analyzes patterns to recommend numbers.",
  "algorithm8HelpHowItWorks": "1. Send the last 200 draws of winning number data to the AI.\n2. The AI comprehensively analyzes statistical patterns, frequencies, distributions, etc.\n3. Generate recommended numbers based on the analysis results.",
  "algorithm8HelpWhenToUse": "• When you want creative AI analysis\n• When you want to try a different approach from other algorithms\n• When you expect complex pattern analysis",
  "algorithm8HelpNote": "Note: AI response generation may take 3-10 seconds. A stable internet connection is required as it may fail depending on network conditions."
}
```

### 8.2 알고리즘 표시 순서 업데이트

**`lotto_provider.dart`** 수정:

```dart
// 2026-01-17 EST - 알고리즘 8 추가 및 순서 업데이트
const displayOrder = [
  1,  // 자동선택
  6,  // 빈도 기반
  7,  // 핫/콜드
  2,  // 고급 빈도
  5,  // 가중치 조합
  4,  // 패턴 분석
  3,  // 딥러닝 선택
  8,  // 인공지능 선택 (신규)
];
```

### 8.3 UI 구현

**알고리즘 8은 파라미터가 없음** → 확장 섹션에 아무것도 표시하지 않음.

```dart
// generate_screen.dart 내부

Widget _buildAISelectionParameters() {
  // 파라미터 없음 - 빈 Container 반환
  return Container(
    padding: const EdgeInsets.all(16),
    child: Text(
      context.l10n.algorithm8HelpNote,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[700],
        height: 1.5,
      ),
    ),
  );
}
```

### 8.4 로딩 인디케이터

AI 선택은 3~10초가 걸리므로 로딩 인디케이터가 중요:

```dart
// API 호출 시작
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Center(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              context.l10n.aiSelectionProcessing,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              context.l10n.aiSelectionPleaseWait,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ),
  ),
);

// API 응답 후
Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
```

ARB 키 추가:
```json
{
  "aiSelectionProcessing": "AI가 번호를 분석하고 있습니다...",
  "aiSelectionPleaseWait": "3~10초 정도 소요될 수 있습니다",
  "aiSelectionProcessing_en": "AI is analyzing numbers...",
  "aiSelectionPleaseWait_en": "This may take 3-10 seconds"
}
```

---

## 9. 도움말 텍스트

### 9.1 한글 도움말

```dart
// algorithm_help_data.dart

AlgorithmHelp _getAISelectionHelp() {
  return AlgorithmHelp(
    algorithmId: 8,
    algorithmName: '인공지능 선택',
    overview: '대규모 언어 모델(AI)이 과거 당첨 번호 데이터를 학습하고 패턴을 분석하여 '
        '번호를 추천하는 알고리즘입니다. 복잡한 통계적 관계와 패턴을 AI가 자동으로 발견하고 '
        '이를 바탕으로 번호를 생성합니다.',
    howItWorks: '''
1. **데이터 수집**: 최근 200회차의 당첨 번호 데이터를 준비합니다.

2. **AI 분석**: 대규모 언어 모델에게 데이터를 전송하고 다음을 분석하도록 요청합니다:
   • 번호별 출현 빈도
   • 번호 간 동시 출현 패턴
   • 번호 구간별 분포
   • 시간에 따른 추세 변화
   • 기타 복잡한 통계적 관계

3. **번호 생성**: AI가 분석 결과를 종합하여 추천 번호를 생성합니다.

4. **결과 반환**: 생성된 번호를 사용자에게 전달합니다.
''',
    whenToUse: '''
• **AI의 창의적 분석을 원할 때**: 규칙 기반 알고리즘과 다른 접근을 시도하고 싶을 때 유용합니다.

• **복합적인 패턴 분석을 기대할 때**: 여러 변수를 동시에 고려하는 AI의 능력을 활용하고 싶을 때 적합합니다.

• **새로운 시각을 얻고 싶을 때**: 딥러닝이나 패턴 분석과 다른 AI 기반 추천을 원할 때 선택하세요.
''',
    tips: '''
• AI 응답 생성에는 3~10초가 소요될 수 있습니다.
• 네트워크 상태에 따라 실패할 수 있으니 안정적인 인터넷 연결이 필요합니다.
• 같은 데이터를 분석해도 AI가 약간 다른 결과를 생성할 수 있습니다 (창의성).
• 비용이 높은 알고리즘이므로(5코인/세트) 신중하게 사용하세요.
''',
    parameters: [],  // 파라미터 없음
  );
}
```

### 9.2 영문 도움말

```dart
AlgorithmHelp _getAISelectionHelpEn() {
  return AlgorithmHelp(
    algorithmId: 8,
    algorithmName: 'AI Selection',
    overview: 'An algorithm where a Large Language Model (AI) learns from historical '
        'winning number data and analyzes patterns to recommend numbers. The AI automatically '
        'discovers complex statistical relationships and patterns to generate numbers.',
    howItWorks: '''
1. **Data Collection**: Prepare the last 200 draws of winning number data.

2. **AI Analysis**: Send the data to a large language model and request analysis of:
   • Frequency of each number
   • Co-occurrence patterns between numbers
   • Distribution across number ranges
   • Trend changes over time
   • Other complex statistical relationships

3. **Number Generation**: The AI generates recommended numbers based on the analysis results.

4. **Return Results**: Deliver the generated numbers to the user.
''',
    whenToUse: '''
• **When you want creative AI analysis**: Useful when trying a different approach from rule-based algorithms.

• **When expecting complex pattern analysis**: Suitable when you want to leverage the AI's ability to consider multiple variables simultaneously.

• **When seeking a new perspective**: Choose this when you want AI-based recommendations different from deep learning or pattern analysis.
''',
    tips: '''
• AI response generation may take 3-10 seconds.
• A stable internet connection is required as it may fail depending on network conditions.
• The AI may generate slightly different results even when analyzing the same data (creativity).
• This is a high-cost algorithm (5 coins/set), so use it carefully.
''',
    parameters: [],  // No parameters
  );
}
```

---

## 10. 테스트 계획

### 10.1 단위 테스트

**`tests/test_algorithms/test_algorithm_08_ai_selection.py`**:

```python
"""
알고리즘 8 테스트: 인공지능 선택

2026-01-17 EST - 초기 생성
"""

import pytest
import pandas as pd
from unittest.mock import Mock, patch, MagicMock

from app.algorithms.algorithm_08_ai_selection import AISelectionAlgorithm


@pytest.fixture
def algorithm():
    """알고리즘 인스턴스"""
    with patch('app.algorithms.algorithm_08_ai_selection.GeminiService'):
        algo = AISelectionAlgorithm()
        return algo


@pytest.fixture
def historical_data():
    """테스트용 과거 데이터"""
    data = {
        'draw_no': list(range(1, 251)),
        'date': pd.date_range('2020-01-01', periods=250, freq='W'),
        'num1': [1] * 250,
        'num2': [2] * 250,
        'num3': [3] * 250,
        'num4': [4] * 250,
        'num5': [5] * 250,
        'num6': [6] * 250,
        'bonus': [7] * 250
    }
    return pd.DataFrame(data)


def test_algorithm_info(algorithm):
    """알고리즘 기본 정보 테스트"""
    assert algorithm.algorithm_id == 8
    assert "인공지능" in algorithm.name
    assert algorithm.cost_per_set == 5
    assert algorithm.is_premium is True


def test_prepare_csv_data(algorithm, historical_data):
    """CSV 데이터 준비 테스트"""
    csv_string = algorithm._prepare_csv_data(historical_data)
    
    # CSV 형식 확인
    assert "draw_no,date,num1,num2" in csv_string
    
    # 최근 200회차만 포함 확인
    lines = csv_string.strip().split('\n')
    assert len(lines) == 201  # 헤더 + 200 데이터 행


def test_build_prompt(algorithm, historical_data):
    """프롬프트 생성 테스트"""
    csv_data = algorithm._prepare_csv_data(historical_data)
    prompt = algorithm._build_prompt(n_sets=5, csv_data=csv_data)
    
    # 변수 치환 확인
    assert "{n_sets}" not in prompt
    assert "{window_size}" not in prompt
    assert "{csv_data}" not in prompt
    assert "5" in prompt
    assert "200" in prompt


def test_parse_response_success(algorithm):
    """응답 파싱 성공 테스트"""
    response_text = '''
    {
      "numbers": [
        [1, 2, 3, 4, 5, 6],
        [7, 8, 9, 10, 11, 12]
      ],
      "confidence": 0.75,
      "reasoning": "테스트 분석"
    }
    '''
    
    number_sets, metadata = algorithm._parse_response(response_text, n_sets=2)
    
    assert len(number_sets) == 2
    assert number_sets[0] == [1, 2, 3, 4, 5, 6]
    assert number_sets[1] == [7, 8, 9, 10, 11, 12]
    assert metadata["confidence"] == 0.75
    assert metadata["reasoning"] == "테스트 분석"


def test_parse_response_invalid_json(algorithm):
    """잘못된 JSON 파싱 테스트"""
    response_text = "This is not JSON"
    
    with pytest.raises(ValueError, match="Invalid JSON"):
        algorithm._parse_response(response_text, n_sets=2)


def test_parse_response_missing_numbers_field(algorithm):
    """numbers 필드 누락 테스트"""
    response_text = '{"confidence": 0.5}'
    
    with pytest.raises(ValueError, match="missing 'numbers' field"):
        algorithm._parse_response(response_text, n_sets=2)


def test_parse_response_wrong_set_count(algorithm):
    """세트 수 불일치 테스트"""
    response_text = '''
    {
      "numbers": [[1, 2, 3, 4, 5, 6]]
    }
    '''
    
    with pytest.raises(ValueError, match="Expected 2 sets, got 1"):
        algorithm._parse_response(response_text, n_sets=2)


def test_parse_response_invalid_number_count(algorithm):
    """번호 개수 오류 테스트"""
    response_text = '''
    {
      "numbers": [[1, 2, 3, 4, 5]]
    }
    '''
    
    with pytest.raises(ValueError, match="Set 1 has 5 numbers"):
        algorithm._parse_response(response_text, n_sets=1)


def test_parse_response_duplicate_numbers(algorithm):
    """중복 번호 테스트"""
    response_text = '''
    {
      "numbers": [[1, 2, 3, 4, 5, 5]]
    }
    '''
    
    with pytest.raises(ValueError, match="duplicate numbers"):
        algorithm._parse_response(response_text, n_sets=1)


def test_parse_response_out_of_range(algorithm):
    """범위 초과 번호 테스트"""
    response_text = '''
    {
      "numbers": [[1, 2, 3, 4, 5, 50]]
    }
    '''
    
    with pytest.raises(ValueError, match="Invalid number 50"):
        algorithm._parse_response(response_text, n_sets=1)


def test_generate_numbers_success(algorithm, historical_data):
    """번호 생성 성공 테스트"""
    # Mock Gemini 서비스 응답
    mock_response = {
        "text": '''
        {
          "numbers": [
            [3, 12, 18, 27, 35, 42],
            [5, 11, 19, 28, 34, 41]
          ],
          "confidence": 0.68,
          "reasoning": "테스트 분석"
        }
        ''',
        "input_tokens": 2500,
        "output_tokens": 180,
        "total_tokens": 2680,
        "cost": 0.000031
    }
    
    algorithm.gemini_service.generate = Mock(return_value=mock_response)
    
    # 번호 생성
    with patch.object(algorithm, '_save_debug_log'):
        number_sets = algorithm.generate_numbers(
            historical_data=historical_data,
            n_sets=2,
            user_id=1001
        )
    
    assert len(number_sets) == 2
    assert number_sets[0] == [3, 12, 18, 27, 35, 42]
    assert number_sets[1] == [5, 11, 19, 28, 34, 41]


def test_generate_numbers_with_retry(algorithm, historical_data):
    """재시도 후 성공 테스트"""
    # 첫 번째 호출은 실패, 두 번째는 성공
    mock_response = {
        "text": '''
        {
          "numbers": [[3, 12, 18, 27, 35, 42]],
          "confidence": 0.5,
          "reasoning": "재시도 성공"
        }
        ''',
        "input_tokens": 2500,
        "output_tokens": 150,
        "total_tokens": 2650,
        "cost": 0.00003
    }
    
    algorithm.gemini_service.generate = Mock(
        side_effect=[
            Exception("Connection timeout"),
            mock_response
        ]
    )
    
    # 번호 생성 (재시도 후 성공)
    with patch.object(algorithm, '_save_debug_log'):
        number_sets = algorithm.generate_numbers(
            historical_data=historical_data,
            n_sets=1,
            user_id=1002
        )
    
    assert len(number_sets) == 1
    assert algorithm.gemini_service.generate.call_count == 2


def test_generate_numbers_complete_failure(algorithm, historical_data):
    """완전 실패 테스트"""
    # 두 번 모두 실패
    algorithm.gemini_service.generate = Mock(
        side_effect=Exception("API Error")
    )
    
    # 번호 생성 실패
    with patch.object(algorithm, '_save_debug_log'):
        with pytest.raises(ValueError, match="AI 서버 연결에 실패"):
            algorithm.generate_numbers(
                historical_data=historical_data,
                n_sets=1,
                user_id=1003
            )
    
    assert algorithm.gemini_service.generate.call_count == 2


def test_save_debug_log_creates_file(algorithm, historical_data, tmp_path):
    """디버그 로그 파일 생성 테스트"""
    # 임시 디렉토리 사용
    with patch('app.algorithms.algorithm_08_ai_selection.Path') as mock_path:
        mock_log_dir = tmp_path / "ai_selection"
        mock_log_dir.mkdir()
        mock_path.return_value = mock_log_dir
        
        # 로그 저장
        algorithm._save_debug_log(
            user_id=1001,
            prompt="Test prompt",
            csv_data="draw_no,date,num1\n1,2024-01-01,1",
            response='{"numbers": [[1,2,3,4,5,6]]}',
            result=[[1, 2, 3, 4, 5, 6]],
            metadata={
                "n_sets": 1,
                "window_size": 200,
                "model": "gemini-2.5-flash-latest",
                "duration": 3.5,
                "confidence": 0.7,
                "reasoning": "테스트"
            },
            error=None
        )
        
        # 로그 파일이 생성되었는지 확인
        log_files = list(mock_log_dir.glob("*.txt"))
        assert len(log_files) > 0
```

### 10.2 통합 테스트

```python
"""
인공지능 선택 통합 테스트

실제 Gemini API 호출 (API 키 필요)
"""

import os
import pytest
from app.algorithms.algorithm_08_ai_selection import AISelectionAlgorithm
from app.utils.data_manager import DataManager


@pytest.mark.skipif(
    not os.getenv("GOOGLE_API_KEY"),
    reason="GOOGLE_API_KEY not set"
)
def test_real_api_call():
    """실제 API 호출 테스트"""
    # 데이터 로드
    data_manager = DataManager()
    historical_data = data_manager.get_dataframe()
    
    # 알고리즘 생성
    algorithm = AISelectionAlgorithm()
    
    # 번호 생성
    number_sets = algorithm.generate_numbers(
        historical_data=historical_data,
        n_sets=3,
        user_id=9999
    )
    
    # 검증
    assert len(number_sets) == 3
    for number_set in number_sets:
        assert len(number_set) == 6
        assert all(1 <= n <= 45 for n in number_set)
        assert len(set(number_set)) == 6  # 중복 없음
    
    print(f"\n생성된 번호:")
    for i, nums in enumerate(number_sets, 1):
        print(f"  Set {i}: {nums}")
```

### 10.3 프론트엔드 테스트

```dart
// test/algorithm_ai_selection_test.dart

void main() {
  group('AI Selection Algorithm', () {
    test('알고리즘 정보 확인', () {
      // API 모킹 필요
    });
    
    test('로딩 인디케이터 표시', () {
      // UI 테스트
    });
    
    test('에러 처리', () {
      // 에러 시나리오 테스트
    });
  });
}
```

---

## 11. 구현 체크리스트

### Phase 1: 백엔드 기본 구현 ✅❌

- [ ] **Config 설정**
  - [ ] `.env` 파일 작성 (`GOOGLE_API_KEY` 등)
  - [ ] `app/config.py`에 AI Selection 설정 추가
  - [ ] `pricing_config.yaml`에 알고리즘 8 추가 (5코인)

- [ ] **Gemini 서비스 구현**
  - [ ] `services/gemini_service.py` 작성
  - [ ] API 키 유효성 검증
  - [ ] 타임아웃 및 재시도 로직
  - [ ] 토큰 사용량 및 비용 계산

- [ ] **프롬프트 템플릿**
  - [ ] `prompts/ai_selection_prompt.txt` 작성
  - [ ] 변수 치환 로직 구현
  - [ ] 프롬프트 로드 함수

- [ ] **알고리즘 구현**
  - [ ] `algorithm_08_ai_selection.py` 작성
  - [ ] `generate_numbers()` 메서드 구현
  - [ ] CSV 데이터 준비 로직
  - [ ] 응답 파싱 로직
  - [ ] 재시도 로직

- [ ] **로깅 시스템**
  - [ ] `results/logs/ai_selection/` 디렉토리 생성
  - [ ] 디버그 로그 저장 함수 구현
  - [ ] 로그 파일명 형식 (YYYYMMDD_HHMMSS_userXXX.txt)
  - [ ] 프롬프트/응답/메타데이터 기록

### Phase 2: 테스트 ✅❌

- [ ] **단위 테스트**
  - [ ] 프롬프트 생성 테스트
  - [ ] CSV 데이터 준비 테스트
  - [ ] 응답 파싱 테스트 (성공/실패)
  - [ ] 유효성 검증 테스트
  - [ ] 재시도 로직 테스트
  - [ ] 로깅 함수 테스트

- [ ] **통합 테스트**
  - [ ] 실제 API 호출 테스트 (수동)
  - [ ] 전체 플로우 테스트
  - [ ] 에러 시나리오 테스트

- [ ] **부하 테스트**
  - [ ] 동시 요청 처리 테스트
  - [ ] 타임아웃 시나리오 테스트

### Phase 3: 프론트엔드 구현 ✅❌

- [ ] **다국어 지원**
  - [ ] `app_ko.arb`에 키 추가 (algorithm8xxx)
  - [ ] `app_en.arb`에 영문 번역 추가
  - [ ] 중국어/베트남어/태국어 추가 (선택)

- [ ] **알고리즘 등록**
  - [ ] `lotto_provider.dart`에 표시 순서 업데이트 (ID 8 추가)

- [ ] **UI 구현**
  - [ ] `generate_screen.dart`에 알고리즘 8 케이스 추가
  - [ ] `_buildAISelectionParameters()` 함수 (빈 컨테이너)
  - [ ] 로딩 인디케이터 구현 (3~10초 대기)
  - [ ] 에러 메시지 다이얼로그

- [ ] **도움말**
  - [ ] `algorithm_help_data.dart`에 알고리즘 8 도움말 추가
  - [ ] 한글 도움말 텍스트
  - [ ] 영문 도움말 텍스트

### Phase 4: 문서화 및 배포 ✅❌

- [ ] **문서 업데이트**
  - [x] `031_Algorithm_AI_Selection.md` 작성 (본 문서)
  - [ ] `README.md` 업데이트
  - [ ] API 문서 업데이트

- [ ] **코드 변경 로그**
  - [ ] `code_change_log.md` 업데이트

- [ ] **Git 커밋**
  - [ ] Backend 변경사항 커밋
  - [ ] Frontend 변경사항 커밋
  - [ ] 문서 커밋

### Phase 5: 검증 및 최적화 ✅❌

- [ ] **성능 검증**
  - [ ] 평균 응답 시간 측정 (목표: < 10초)
  - [ ] 성공률 측정 (목표: > 95%)
  - [ ] 비용 검증 (목표: < $0.0001/요청)

- [ ] **사용성 테스트**
  - [ ] 실제 사용자 테스트
  - [ ] 피드백 수집 및 반영

- [ ] **모니터링 설정**
  - [ ] API 호출 성공/실패율 추적
  - [ ] 평균 응답 시간 모니터링
  - [ ] 비용 추적 대시보드

### Phase 6: 미래 개선 사항 (Optional) ✅❌

- [ ] **환불 시스템**
  - [ ] API 실패 시 자동 환불 로직
  - [ ] 환불 트랜잭션 기록
  - [ ] 사용자 알림

- [ ] **프롬프트 최적화**
  - [ ] A/B 테스트 (여러 프롬프트 버전)
  - [ ] 사용자 만족도 기반 튜닝

- [ ] **캐싱**
  - [ ] 동일한 n_sets에 대한 응답 캐싱 (1시간)
  - [ ] 비용 절감

- [ ] **다중 모델 지원**
  - [ ] GPT-4o 옵션 추가 (프리미엄)
  - [ ] Claude 옵션 추가
  - [ ] 사용자 모델 선택 가능

---

## 12. 예상 문제 및 해결책

### 12.1 API 호출 실패율 높음

**문제**: 네트워크 불안정, API 다운타임 등으로 실패율이 높을 수 있음

**해결책**:
1. 재시도 로직 (현재 1회 → 2회로 증가 고려)
2. 타임아웃 시간 조정 (30초 → 45초)
3. 폴백: 실패 시 자동으로 "자동선택" 알고리즘으로 대체 (선택적)

### 12.2 응답 파싱 오류

**문제**: LLM이 JSON 형식을 정확히 지키지 않을 수 있음

**해결책**:
1. 프롬프트에서 JSON 형식 강조 (이미 구현됨)
2. Gemini의 `response_mime_type="application/json"` 설정 (이미 구현됨)
3. 파싱 실패 시 재시도

### 12.3 비용 폭증

**문제**: 사용자가 반복적으로 호출하여 Gemini API 비용 증가

**해결책**:
1. 사용자당 일일 호출 제한 (예: 10회)
2. 쿨다운 타이머 (1분 대기)
3. 5코인으로 높은 장벽 설정 (이미 구현됨)

### 12.4 느린 응답 속도

**문제**: 사용자가 3~10초 대기를 불편하게 느낄 수 있음

**해결책**:
1. 로딩 인디케이터에 진행 상황 표시
2. 예상 소요 시간 안내
3. 백그라운드 처리 + 푸시 알림 (Phase 6)

### 12.5 프롬프트 누출

**문제**: 디버그 로그에서 프롬프트가 노출될 수 있음

**해결책**:
1. 로그 디렉토리 접근 권한 제한 (서버 관리자만)
2. 프로덕션 환경에서는 로그 암호화 고려
3. 로그 파일 자동 삭제 (7일 후)

---

## 13. 결론

### 13.1 구현 난이도

- **난이도**: 중
- **예상 소요 시간**: 8~12시간
  - Backend: 5~7시간
  - Frontend: 2~3시간
  - 테스트: 1~2시간

### 13.2 핵심 가치

1. **차별화**: 다른 알고리즘과 완전히 다른 AI 기반 접근
2. **확장성**: 프롬프트 파일만 수정하면 튜닝 가능
3. **디버깅**: 모든 요청/응답이 로그로 기록되어 문제 추적 용이
4. **수익성**: 실제 비용($0.00003) 대비 높은 과금(5코인 = 약 $0.50?)으로 마진 확보

### 13.3 다음 단계

1. **마스터 승인 대기**
2. Phase 1 구현 시작 (Config + Gemini Service)
3. 프롬프트 템플릿 작성 및 테스트
4. 알고리즘 구현 및 단위 테스트
5. 프론트엔드 통합
6. 최종 검증 및 배포

---

**문서 종료**

