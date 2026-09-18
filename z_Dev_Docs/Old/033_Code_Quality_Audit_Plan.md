# 033 - 코드 품질 감사 및 리팩토링 계획

**작성일**: 2026-01-18 20:45:00 EST  
**작성자**: Cursor AI  
**문서 목적**: DRY, SSOT, KISS, 리팩토링 원칙에 의거한 전체 코드베이스 감사 및 수정 계획

---

## 📋 목차

1. [감사 개요](#1-감사-개요)
2. [적용 원칙](#2-적용-원칙)
3. [발견된 문제점](#3-발견된-문제점)
4. [우선순위별 수정 계획](#4-우선순위별-수정-계획)
5. [수정 상세 내역](#5-수정-상세-내역)
6. [검증 방법](#6-검증-방법)

---

## 1. 감사 개요

### 1.1 감사 범위

- **Backend**: Python 49개 파일
- **Frontend**: Dart 52개 파일
- **설정 파일**: YAML, JSON

### 1.2 감사 방법

1. **정적 분석**: 코드 패턴 검색 (grep, 수동 리뷰)
2. **원칙 체크리스트**: 각 원칙별 위반 사항 확인
3. **의존성 분석**: 중복 코드 및 지식 중복 탐지

### 1.3 감사 결과 요약 (마스터 검토 반영)

| 원칙 | 위반 건수 | 심각도 | 수정 여부 |
|------|----------|--------|----------|
| **SSOT** | 3건 | 🔴 높음 | ✅ 수정 |
| **DRY** | 1건 | 🟡 중간 | ✅ 수정 |
| **KISS** | 0건 | - | ❌ 유지 (의도적) |
| **매직 넘버** | 0건 | - | ❌ 유지 (설정값) |

**총 4건의 수정 필요 사항 (마스터 검토 후)**

### 1.4 마스터 검토 결정 사항

**✅ 수정 진행**:
1. AI 모델 gemini-2.5-flash로 통일
2. Gemini 비용 계산 (2026-01-18 가격표 반영)
3. Flutter "200회차" → API 값 사용
4. 로또 상수 중복 정리
5. 중복 파라미터 검증 통합

**❌ 수정 제외 (의도적 유지)**:
- 매직 넘버: 설정값이므로 흩어져 있어도 OK
- KISS 위반 (로깅): 서비스 분석용 메타데이터 유지
- 다국어 "1~45": 언어별 온전한 문장 유지
- 알고리즘 표시 순서: 일부러 설정한 순서

---

## 2. 적용 원칙

### 2.1 DRY (Don't Repeat Yourself)

> "모든 지식은 시스템 내에서 단일하고 명확하며 권위 있는 표현을 가져야 한다."

**검사 항목**:
- ✅ 중복 코드 (같은 로직이 여러 곳)
- ✅ 중복 데이터 (같은 값이 여러 곳)
- ✅ 중복 지식 (같은 개념이 다른 표현)

### 2.2 SSOT (Single Source of Truth)

> "각 데이터 요소는 시스템 내에서 정확히 한 곳에서만 정의되어야 한다."

**검사 항목**:
- ✅ 설정값이 여러 곳에 하드코딩
- ✅ 상수가 중복 정의
- ✅ 데이터 흐름 역방향 참조

### 2.3 KISS (Keep It Simple, Stupid)

> "불필요한 복잡성을 제거하고 가장 단순한 해결책을 선택한다."

**검사 항목**:
- ✅ 과도한 추상화
- ✅ 불필요한 레이어
- ✅ 복잡한 조건문

### 2.4 리팩토링 원칙

- 기능 변경 없이 구조 개선
- 테스트 가능성 향상
- 가독성 우선

---

## 3. 발견된 문제점

### 🔴 3.1 SSOT 위반 (Critical)

#### 문제 1: AI 모델 통일 (gemini-2.5-flash만 사용)

**마스터 결정**: gemini-2.5-flash만 사용, 다른 모델 고려 안 함

**위치**: 
- `config.py:111` - `AI_SELECTION_MODEL = "gemini-2.5-flash"` ✅
- `gemini_service.py:25` - `model: str = "gemini-2.0-flash-exp"` ❌

**문제**:
- 두 곳에 다른 모델명 존재
- gemini-2.0-flash-exp는 사용하지 않음

**영향도**: 🔴 **높음** - 모델 불일치

**수정 계획**:
```python
# gemini_service.py
def __init__(
    self,
    api_key: str,
    model: str,  # 기본값 제거, config.py에서만 관리
    temperature: float,
    ...
):
    if not model:
        raise ValueError("Model name is required")
    # gemini-2.5-flash로 통일

# algorithm_08_ai_selection.py에서 호출
self.gemini_service = GeminiService(
    api_key=settings.GOOGLE_API_KEY,
    model=settings.AI_SELECTION_MODEL,  # "gemini-2.5-flash"
    ...
)
```

**변경 사유**:
- SSOT 원칙: `config.py`만 모델명의 유일한 출처
- gemini-2.5-flash로 통일

---

#### 문제 2: Gemini 비용 계산 (2026-01-18 가격표 반영)

**마스터 결정**: 첨부된 공식 가격표 사용 (as-of-20260118)

**위치**: `gemini_service.py:94-96`

**현재 코드 (잘못됨)**:
```python
# 비용 계산 (Gemini 2.0 Flash 기준)
# 입력: $0.00001/1K 토큰, 출력: $0.00003/1K 토큰  ← 틀림!
cost = (input_tokens / 1000 * 0.00001) + (output_tokens / 1000 * 0.00003)
```

**실제 가격 (Google 공식, 2026-01-18)**:
- **Input**: $0.30 per 1M tokens (text/image/video)
- **Output**: $2.50 per 1M tokens (including thinking tokens)
- **Audio Input**: $1.00 per 1M tokens

**문제**:
- 현재 코드는 **100배 낮게** 계산됨
- 실제: $0.30/1M = $0.0003/1K
- 코드: $0.00001/1K ← 틀림!

**영향도**: 🔴 **높음** - 비용 계산 오류 (과소 계산)

**수정 계획**:
```python
# config.py에 추가
# 2026-01-18 EST - Google Gemini 2.5 Flash 공식 가격표 (as-of-20260118)
# Source: https://ai.google.dev/pricing
GEMINI_PRICING = {
    "gemini-2.5-flash": {
        "input_per_1m": 0.30,   # $/1M tokens (text/image/video)
        "output_per_1m": 2.50,  # $/1M tokens (including thinking tokens)
        "audio_input_per_1m": 1.00,  # $/1M tokens (audio)
        "updated": "2026-01-18"
    }
}

# gemini_service.py 수정
def _calculate_cost(self, input_tokens: int, output_tokens: int) -> float:
    """
    토큰 사용량 기반 비용 계산
    
    2026-01-18 EST - config.py의 GEMINI_PRICING 사용 (SSOT)
    as-of-20260118: gemini-2.5-flash 공식 가격표 반영
    """
    from app.config import settings
    
    pricing = settings.GEMINI_PRICING.get(self.model_name)
    if not pricing:
        raise ValueError(f"No pricing info for model {self.model_name}")
    
    # $/1M tokens 기준으로 계산
    cost = (
        (input_tokens / 1_000_000 * pricing["input_per_1m"]) +
        (output_tokens / 1_000_000 * pricing["output_per_1m"])
    )
    return cost
```

---

#### 문제 3: Flutter "200회차" 하드코딩 (부분 해결됨)
**위치**:
- `generate_screen.dart:517` - 로딩 모달
- `generate_screen.dart:2155` - 설명 텍스트
- `algorithm_help_data.dart:468` - 도움말

**현재 상태**:
- ✅ Backend API에 `window_size` 필드 추가 완료 (2026-01-18 20:30:00)
- ❌ Flutter에서 아직 사용하지 않음

**영향도**: 🟡 **중간** - Backend 설정 변경 시 불일치

**수정 계획**:
```dart
// Before
Text('200회차 데이터를 분석하고 있습니다...')

// After (API에서 받은 windowSize 사용)
Text('${algorithm.windowSize}회차 데이터를 분석하고 있습니다...')
```

---

#### 문제 4: 로또 게임 규칙 상수 중복

**마스터 결정**: 같은 의미의 상수가 여러 곳에 쓰이면 변수로 관리

**위치**:
- Backend: `constants.py` (✅ 이미 SSOT)
- Frontend: 여러 곳에 하드코딩 (`1~45`, `6개`)

**문제**:
- Flutter에서 `1`, `45`, `6` 등이 흩어져 있음
- Backend는 이미 잘 정리됨

**영향도**: 🟡 **중간** - Flutter에서 통합 필요

**수정 계획**:
```dart
// lib/core/constants/lotto_constants.dart 생성
class LottoConstants {
  // Backend constants.py와 동기화
  static const int minNumber = 1;
  static const int maxNumber = 45;
  static const int numbersPerDraw = 6;
  static const int bonusNumberCount = 1;
  static const int totalNumbers = 45;
  
  // 색상 구간 (기존 로직 유지)
  static const Map<String, Range> colorRanges = {
    'yellow': Range(1, 10),
    'blue': Range(11, 20),
    'red': Range(21, 30),
    'gray': Range(31, 40),
    'green': Range(41, 45),
  };
}
```

**사용 예시**:
```dart
// Before
if (number >= 1 && number <= 45) { ... }

// After
if (number >= LottoConstants.minNumber && number <= LottoConstants.maxNumber) { ... }
```

---

### 🟡 3.2 DRY 위반 (Medium)

#### 문제 5: 중복된 파라미터 검증

**마스터 결정**: 수정 필요

**위치**: 여러 알고리즘에서 유사한 검증 로직

**문제**:
- `base.py`에 `validate_parameters()` 있음
- 일부 알고리즘에서 추가 검증 중복
- `validation.py`도 존재하지만 일관성 부족

**영향도**: 🟡 **중간** - 유지보수성 저하

**수정 계획**:
```python
# validation.py를 SSOT로 확립
# 공통 검증 로직:
- validate_parameters() # base에서 사용
- validate_number_range()
- validate_exclude_include_overlap()

# 알고리즘별 특수 검증만 각 파일에 남김
```

---

### 🟢 3.3 수정 제외 (의도적 유지)

**마스터 검토 결정에 따라 다음 항목들은 수정하지 않습니다**:

#### ❌ 매직 넘버 (수정 안 함)
**사유**: 대부분 설정값이므로 흩어져 있어도 OK
- 자주 변경할 가능성 있는 것만 모아서 관리
- 변경 가능성 낮은 숫자는 현재 위치 유지

#### ❌ KISS 위반 - 과도한 로깅 (유지)
**사유**: 향후 서비스 분석용 메타데이터로 활용 가능
- `algorithm_08_ai_selection.py`의 상세 로그 유지

#### ❌ 다국어 "1~45" 표현 (유지)
**사유**: 언어별 온전한 문장으로 유지하는 편이 관리 편함
- 플레이스홀더 도입하지 않음

#### ❌ 알고리즘 표시 순서 하드코딩 (유지)
**사유**: 일부러 설정한 순서
- `lotto_provider.dart`의 `[1, 6, 7, 2, 5, 4, 3, 8]` 순서 유지

#### ❌ API 엔드포인트 중복 (현재 유지)
**사유**: OpenAPI/Swagger 도입은 향후 고려
- 현재 수동 관리 유지


---

## 4. 우선순위별 수정 계획

### 🔴 Phase 1: Critical (즉시 수정 필요)

**마스터 검토 반영 후 예상 소요**: 1.5시간

| 번호 | 문제 | 파일 | 작업 | 비고 |
|------|------|------|------|------|
| 1 | AI 모델 gemini-2.5-flash 통일 | `gemini_service.py`, `config.py` | 모델명 통일, 기본값 제거 | 🔴 Critical |
| 2 | Gemini 비용 계산 (2026-01-18 가격표) | `config.py`, `gemini_service.py` | 공식 가격표 반영 | 🔴 Critical |

**검증**:
- Backend 유닛 테스트 실행
- AI Selection 알고리즘 수동 테스트
- 비용 계산 정확성 검증 (100배 오류 수정 확인)

---

### 🟡 Phase 2: Important (우선 수정)

**마스터 검토 반영 후 예상 소요**: 2시간

| 번호 | 문제 | 파일 | 작업 | 비고 |
|------|------|------|------|------|
| 3 | Flutter "200회차" 하드코딩 | `generate_screen.dart`, `algorithm_help_data.dart` | API 값 사용 | 🟡 Important |
| 4 | 로또 상수 중복 | Flutter 전체 | `lotto_constants.dart` 생성 | 🟡 Important |
| 5 | 중복 파라미터 검증 | `validation.py`, 알고리즘들 | 공통 로직 통합 | 🟡 Important |

**검증**:
- Flutter 테스트 실행
- UI 수동 테스트
- Backend 검증 로직 테스트

---

### ❌ 수정 제외 (마스터 결정)

다음 항목들은 의도적으로 유지합니다:

| 항목 | 사유 |
|------|------|
| 매직 넘버 | 설정값이므로 흩어져 있어도 OK |
| 과도한 로깅 (KISS 위반) | 서비스 분석용 메타데이터 |
| 다국어 "1~45" | 언어별 온전한 문장 유지 |
| 알고리즘 표시 순서 | 일부러 설정한 순서 |
| API 엔드포인트 중복 | 현재 수동 관리 유지 |

---

## 5. 수정 상세 내역

### 5.1 Phase 1-1: AI 모델 gemini-2.5-flash 통일

#### 마스터 결정
- gemini-2.5-flash만 사용
- 다른 모델 고려 안 함 (gemini-2.0-flash-exp 제거)

#### 수정 파일
1. `backend/app/config.py`
2. `backend/app/services/gemini_service.py`
3. `backend/app/algorithms/algorithm_08_ai_selection.py`

#### 수정 내용

**Before**:
```python
# config.py:111
AI_SELECTION_MODEL: str = "gemini-2.5-flash"  # ✅

# gemini_service.py:25
def __init__(
    self,
    api_key: str,
    model: str = "gemini-2.0-flash-exp",  # ❌ 다른 모델
    ...
):
```

**After**:
```python
# config.py:111 (변경 없음)
AI_SELECTION_MODEL: str = "gemini-2.5-flash"  # ✅ 유지

# gemini_service.py:25
def __init__(
    self,
    api_key: str,
    model: str,  # ✅ 기본값 제거, config.py에서만 관리
    temperature: float,
    max_tokens: int,
    timeout: int
):
    if not api_key:
        raise ValueError("Google API key is required")
    if not model:
        raise ValueError("Model name is required")
    
    # 2026-01-18 EST - gemini-2.5-flash만 사용
    # config.py에서 전달받은 모델명 사용
    ...

# algorithm_08_ai_selection.py:46-52 (확인)
self.gemini_service = GeminiService(
    api_key=settings.GOOGLE_API_KEY,
    model=settings.AI_SELECTION_MODEL,  # "gemini-2.5-flash"
    temperature=settings.AI_SELECTION_TEMPERATURE,
    max_tokens=settings.AI_SELECTION_MAX_TOKENS,
    timeout=settings.AI_SELECTION_TIMEOUT
)
```

**변경 사유**:
- SSOT 원칙: `config.py`만 모델명의 유일한 출처
- gemini-2.5-flash로 통일 (마스터 결정)

---

### 5.2 Phase 1-2: Gemini 비용 계산 (2026-01-18 가격표 반영)

#### 마스터 결정
- 첨부된 Google 공식 가격표 사용
- as-of-20260118 주석 추가
- gemini-2.5-flash만 지원 (다른 모델 제거)

#### 현재 문제
```python
# gemini_service.py:94-96 (현재 코드)
# 입력: $0.00001/1K 토큰, 출력: $0.00003/1K 토큰  ← 틀림!
cost = (input_tokens / 1000 * 0.00001) + (output_tokens / 1000 * 0.00003)
# 실제 비용의 1/100로 계산됨!
```

#### Google 공식 가격표 (2026-01-18)
| 항목 | 가격 (per 1M tokens) |
|------|----------------------|
| Input (text/image/video) | $0.30 |
| Output (including thinking) | $2.50 |
| Audio Input | $1.00 |

#### 수정 파일
1. `backend/app/config.py`
2. `backend/app/services/gemini_service.py`

#### 수정 내용

**config.py 추가**:
```python
# === Google Gemini API 비용 설정 ===
# 2026-01-18 EST - Google Gemini 2.5 Flash 공식 가격표 (as-of-20260118)
# Source: https://ai.google.dev/pricing
# 
# Paid Tier, per 1M tokens in USD:
# - Input price: $0.30 (text/image/video), $1.00 (audio)
# - Output price: $2.50 (including thinking tokens)
GEMINI_PRICING = {
    "gemini-2.5-flash": {
        "input_per_1m": 0.30,         # $/1M tokens (text/image/video)
        "output_per_1m": 2.50,        # $/1M tokens (including thinking tokens)
        "audio_input_per_1m": 1.00,   # $/1M tokens (audio, if used)
        "updated": "2026-01-18"
    }
}
```

**gemini_service.py 수정**:
```python
def _calculate_cost(self, input_tokens: int, output_tokens: int) -> float:
    """
    토큰 사용량 기반 비용 계산
    
    2026-01-18 EST - config.py의 GEMINI_PRICING 사용 (SSOT)
    as-of-20260118: Google 공식 가격표 반영
    
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


# generate() 메서드에서 수정 (94-96줄)
# Before:
# cost = (input_tokens / 1000 * 0.00001) + (output_tokens / 1000 * 0.00003)

# After:
cost = self._calculate_cost(input_tokens, output_tokens)
```

**변경 사유**:
- 🔴 **Critical**: 현재 비용을 1/100로 잘못 계산 중
- SSOT 원칙: 비용 정보는 config.py에만 존재
- Google 공식 가격표 정확히 반영 (as-of-20260118)

---

### 5.3 Phase 2-1: Flutter "200회차" 동적화

#### 수정 파일
1. `mobile_app/lib/presentation/screens/generate/generate_screen.dart`
2. `mobile_app/lib/data/help/algorithm_help_data.dart`
3. `mobile_app/lib/data/models/algorithm_info.dart` (필요 시)

#### 수정 내용

**generate_screen.dart:517 수정**:
```dart
// Before
Text('200회차 데이터를 분석하고 있습니다...')

// After
Text('${selectedAlgorithm?.windowSize ?? 100}회차 데이터를 분석하고 있습니다...')
```

**generate_screen.dart:2155 수정**:
```dart
// Before
'AI가 최근 200회차의 당첨 번호를 분석하여 추천 번호를 생성합니다.',

// After
'AI가 최근 ${selectedAlgorithm?.windowSize ?? 100}회차의 당첨 번호를 분석하여 추천 번호를 생성합니다.',
```

**algorithm_help_data.dart:468 수정**:
```dart
// Before
howItWorks: '1. 최근 200회차의 당첨 번호 데이터를 AI에 전송합니다.\n'

// After (AlgorithmInfo에서 windowSize 전달 받아 사용)
// 또는 Backend API에서 help 텍스트도 동적 생성
```

**algorithm_info.dart 수정** (필요 시):
```dart
@freezed
class AlgorithmInfo with _$AlgorithmInfo {
  const factory AlgorithmInfo({
    required int id,
    required String name,
    required String description,
    required int costPerSet,
    int? windowSize,  // ← 추가 (알고리즘 8번만 사용)
    Map<String, dynamic>? parameters,
  }) = _AlgorithmInfo;
}
```

**변경 사유**:
- Backend `config.py`에서 `AI_SELECTION_WINDOW_SIZE` 변경 시 자동 반영
- 하드코딩 제거

---

### 5.4 Phase 2-2: 로또 상수 통합

#### 마스터 결정
- 같은 의미의 상수가 여러 곳에 쓰이면 변수로 관리
- Backend는 이미 잘 정리됨 (constants.py)
- Flutter 통합 필요

#### 수정 파일
1. `mobile_app/lib/core/constants/lotto_constants.dart` (신규)
2. Flutter 전체 파일 (매직 넘버 사용처)

#### 수정 내용

**lotto_constants.dart 생성**:
```dart
/// 로또 645 게임 규칙 상수
/// 
/// 2026-01-18 EST - SSOT 원칙 적용 (마스터 결정)
/// Backend constants.py와 동기화
class LottoConstants {
  // 번호 범위
  static const int minNumber = 1;
  static const int maxNumber = 45;
  static const int totalNumbers = 45;
  
  // 당첨 번호 구성
  static const int numbersPerDraw = 6;
  static const int bonusNumberCount = 1;
  
  // 색상 구간 (LottoBall 위젯용)
  // 기존 로직 유지
  static bool isYellow(int number) => number >= 1 && number <= 10;
  static bool isBlue(int number) => number >= 11 && number <= 20;
  static bool isRed(int number) => number >= 21 && number <= 30;
  static bool isGray(int number) => number >= 31 && number <= 40;
  static bool isGreen(int number) => number >= 41 && number <= 45;
}
```

**사용 예시**:
```dart
// Before
if (number >= 1 && number <= 45) { ... }

// After
if (number >= LottoConstants.minNumber && number <= LottoConstants.maxNumber) { ... }

// Before
if (number >= 1 && number <= 10) { color = Colors.yellow; }

// After
if (LottoConstants.isYellow(number)) { color = Colors.yellow; }
```

**변경 사유**:
- Flutter 전역에 흩어진 `1`, `45`, `6` 매직 넘버 통합
- Backend constants.py와 동기화

---

### 5.5 Phase 2-3: 중복 파라미터 검증 통합

#### 마스터 결정
- 수정 필요

#### 수정 파일
1. `backend/app/algorithms/validation.py` (SSOT로 확립)
2. `backend/app/algorithms/base.py`
3. 각 알고리즘 파일 (중복 제거)

#### 수정 내용

**validation.py를 SSOT로 확립**:
```python
# validation.py - 공통 검증 로직 통합
def validate_parameters(...):
    """모든 알고리즘에서 사용하는 공통 검증"""
    pass

def validate_number_range(...):
    """번호 범위 검증"""
    pass

def validate_exclude_include_overlap(...):
    """제외/포함 번호 겹침 검증"""
    pass

def validate_available_numbers_sufficient(...):
    """사용 가능한 번호 충분한지 검증"""
    pass
```

**base.py에서 사용**:
```python
# base.py
from app.algorithms.validation import validate_parameters as validate_params

class LottoAlgorithm(ABC):
    def validate_parameters(self, n_sets, exclude_numbers, include_numbers):
        # validation.py의 공통 검증 사용
        return validate_params(n_sets, exclude_numbers, include_numbers)
```

**알고리즘 파일에서 중복 제거**:
```python
# 각 algorithm_*.py
# 공통 검증은 base.validate_parameters() 사용
# 알고리즘별 특수 검증만 추가
```

**변경 사유**:
- DRY 원칙: 중복 검증 로직 제거
- validation.py를 SSOT로 확립

---

### ❌ Phase 3: 수정 제외 항목 (마스터 결정)

다음 항목들은 마스터 검토 결과 수정하지 않습니다:

### 5.6 ❌ 다국어 매직 넘버 제거 (수정 안 함)

#### 마스터 결정
**수정 안 함 - 언어별 온전한 문장으로 유지하는 편이 관리 편함**

**현재 상태 유지**:
```json
{
  "algorithm1Desc": "1~45 중 6개를 완전 무작위로 선택합니다."
}
```

**사유**:
- 플레이스홀더 도입보다 현재 방식이 더 관리하기 편함
- 번역자가 문맥을 이해하기 쉬움
- 게임 규칙 변경 가능성 매우 낮음

---

## 6. 검증 방법

### 6.1 자동 검증

#### Backend 테스트
```bash
# 유닛 테스트
pytest tests/

# 린터
flake8 app/
mypy app/

# 상수 사용 검증
grep -r "45\|1\|6" app/ --include="*.py" | grep -v "constants.py" | grep -v "test_"
```

#### Frontend 테스트
```bash
# Flutter 테스트
flutter test

# 린터
flutter analyze

# 매직 넘버 검증
grep -r "45\|200" lib/ --include="*.dart" | grep -v "constants/"
```

---

### 6.2 수동 검증

#### SSOT 체크리스트
- [ ] 각 데이터 요소가 정확히 한 곳에만 정의됨
- [ ] 설정 변경 시 1곳만 수정하면 전체 반영됨
- [ ] 중복 정의 없음

#### DRY 체크리스트
- [ ] 중복 코드 제거됨
- [ ] 공통 로직 추출됨
- [ ] 유틸리티 재사용됨

#### KISS 체크리스트
- [ ] 불필요한 추상화 제거됨
- [ ] 가독성 향상됨
- [ ] 복잡도 감소됨

---

### 6.3 회귀 테스트

#### 기능 테스트
1. **알고리즘 8번 (AI Selection)**
   - [ ] 정상 동작 (번호 생성)
   - [ ] 비용 계산 정확
   - [ ] 로그 정상 생성

2. **모든 알고리즘**
   - [ ] 번호 생성 정상
   - [ ] 비용 계산 정확
   - [ ] 파라미터 검증 동작

3. **Flutter UI**
   - [ ] 알고리즘 8번 선택 시 "100회차" 표시
   - [ ] config 변경 후 자동 반영 확인
   - [ ] 다국어 정상 표시

---

## 7. 예상 위험 및 대응

### 7.1 위험 요소

| 위험 | 확률 | 영향 | 대응책 |
|------|------|------|--------|
| API 응답 형식 변경으로 Flutter 오류 | 중간 | 높음 | API 버전 관리, 호환성 테스트 |
| 비용 계산 오류 | 낮음 | 중간 | 유닛 테스트 강화 |
| 다국어 플레이스홀더 오류 | 낮음 | 낮음 | 번역 테스트 |

### 7.2 롤백 계획

- Git 브랜치별 작업
- Phase별 커밋
- 문제 발생 시 이전 커밋으로 롤백

---

## 8. 완료 기준

### 8.1 Phase별 완료 조건

**Phase 1 (Critical)** - 즉시 수정:
- [ ] AI 모델 gemini-2.5-flash 통일
- [ ] Gemini 비용 계산 (2026-01-18 가격표 반영)
- [ ] 유닛 테스트 통과
- [ ] AI Selection 수동 테스트 통과
- [ ] **비용 계산 정확성 검증** (100배 오류 수정)

**Phase 2 (Important)** - 우선 수정:
- [ ] Flutter "회차" 동적화
- [ ] 로또 상수 통합 (`lotto_constants.dart` 생성)
- [ ] 중복 파라미터 검증 통합
- [ ] Flutter 테스트 통과
- [ ] UI 수동 테스트 통과

**수정 제외** (마스터 결정):
- ❌ 매직 넘버 (설정값이므로 유지)
- ❌ 과도한 로깅 (서비스 분석용)
- ❌ 다국어 "1~45" (온전한 문장 유지)
- ❌ 알고리즘 순서 (일부러 설정)

---

### 8.2 전체 프로젝트 완료 조건

- [ ] 모든 SSOT 위반 수정
- [ ] 주요 DRY 위반 수정
- [ ] 매직 넘버 90% 이상 상수화
- [ ] 자동 테스트 100% 통과
- [ ] 수동 회귀 테스트 통과
- [ ] 코드 리뷰 승인
- [ ] 문서 업데이트 (code_change_log.md)

---

## 9. 참고 자료

### 9.1 관련 문서
- `tlee-cursor-rules.mdc` - 코딩 규칙
- `code_change_log.md` - 변경 이력
- `010.1_Algorithm_Redesign.md` - 알고리즘 설계

### 9.2 원칙 가이드
- **DRY**: [The Pragmatic Programmer](https://pragprog.com/)
- **SSOT**: [Wikipedia](https://en.wikipedia.org/wiki/Single_source_of_truth)
- **KISS**: [Extreme Programming](http://www.extremeprogramming.org/)

---

## 10. 변경 이력

| 날짜 | 버전 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 2026-01-18 20:45:00 EST | 1.0 | 초안 작성 | Cursor AI |
| 2026-01-18 21:15:00 EST | 2.0 | 마스터 검토 반영, 수정 범위 조정 | Cursor AI |

### 버전 2.0 주요 변경사항

**마스터 검토 결과 반영**:
1. ✅ AI 모델: gemini-2.5-flash만 사용, gemini-2.0-flash-exp 제거
2. ✅ Gemini 비용: Google 공식 가격표 (2026-01-18) 반영
   - **Critical**: 현재 비용을 1/100로 잘못 계산 중 → 수정 필수
   - Input: $0.30/1M tokens (현재: $0.01/1M ← 틀림)
   - Output: $2.50/1M tokens (현재: $0.03/1M ← 틀림)
3. ✅ 중복 파라미터 검증: 통합 필요
4. ✅ 로또 상수 중복: Flutter 통합 필요

**수정 제외 (의도적 유지)**:
- ❌ 매직 넘버: 설정값이므로 흩어져 있어도 OK
- ❌ KISS 위반 (로깅): 서비스 분석용 메타데이터 유지
- ❌ 다국어 "1~45": 언어별 온전한 문장 유지
- ❌ 알고리즘 표시 순서: 일부러 설정한 순서
- ❌ API 엔드포인트 중복: 현재 수동 관리 유지

**수정 범위 축소**:
- 총 40건 → 5건 (마스터 검토 후)
- 예상 소요: 12시간 → 3.5시간

---

**문서 끝**
