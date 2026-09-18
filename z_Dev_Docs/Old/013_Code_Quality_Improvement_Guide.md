# 코드 품질 개선 가이드 (Phase 5)

**작성일**: 2026-01-08 06:10:00 EST  
**기반**: 012.3_Refactoring_Completion_Report.md  
**목적**: 리팩토링 이후 추가 코드 품질 개선

---

## 📋 개요

리팩토링(Phase 4)을 통해 DRY 원칙을 적용하고 중복 코드를 제거했습니다. 이제 다음 단계로 코드 품질을 더욱 향상시키기 위한 5가지 개선 작업을 진행합니다.

### 개선 항목

**즉시 조치**:
1. 단위 테스트 프레임워크 도입
2. base.py 공통 메서드 테스트 작성

**중장기 개선**:
3. 매직 넘버 상수화
4. 타입 힌트 강화
5. 공통 유틸리티 모듈 생성

---

## 🎯 Part 1: 단위 테스트 프레임워크 도입

### 목적 및 필요성

**현재 상황**:
- ✅ 통합 테스트만 존재 (`test_algorithms.py`)
- ❌ 단위 테스트 없음
- ❌ 테스트 자동화 없음
- ❌ 커버리지 측정 불가능

**개선 후**:
- ✅ pytest 기반 단위 테스트
- ✅ CI/CD 통합 가능
- ✅ 커버리지 80% 목표
- ✅ 리그레션 자동 감지

### 구현 방법

#### Step 1: 의존성 설치

**파일**: `luckyai_645/backend/requirements.txt`

```txt
# 기존 의존성...
pandas>=2.0.0
numpy>=1.24.0

# 테스트 프레임워크 추가 (2026-01-08)
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-mock>=3.11.0
pytest-asyncio>=0.21.0
```

**설치 명령**:
```bash
cd luckyai_645/backend
pip install pytest pytest-cov pytest-mock pytest-asyncio
```

#### Step 2: pytest 설정 파일 생성

**파일**: `luckyai_645/backend/pytest.ini`

```ini
[pytest]
# pytest 설정 파일
# 2026-01-08 06:10:00 EST - 초기 생성

# 테스트 검색 경로
testpaths = tests

# 테스트 파일 패턴
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# 출력 옵션
addopts = 
    -v                          # verbose
    --strict-markers            # 등록되지 않은 marker 오류
    --tb=short                  # traceback 짧게
    --cov=app                   # 커버리지 측정 (app 폴더)
    --cov-report=term-missing   # 누락된 라인 표시
    --cov-report=html           # HTML 리포트 생성
    --cov-fail-under=70         # 70% 미만 시 실패

# 마커 등록
markers =
    unit: 단위 테스트 (빠름)
    integration: 통합 테스트 (느림)
    slow: 느린 테스트 (LSTM 학습 등)
    
# 커버리지 제외 경로
[coverage:run]
omit = 
    */tests/*
    */migrations/*
    */__pycache__/*
    */venv/*
```

#### Step 3: 테스트 폴더 구조 생성

**구조**:
```
luckyai_645/backend/
├── app/
│   └── algorithms/
│       ├── base.py
│       ├── algorithm_01_random.py
│       └── ...
├── tests/
│   ├── __init__.py
│   ├── conftest.py                    # pytest 설정 및 fixture
│   ├── unit/                          # 단위 테스트
│   │   ├── __init__.py
│   │   ├── test_base_helpers.py      # base.py 공통 메서드
│   │   ├── test_algorithm_01.py
│   │   ├── test_algorithm_02.py
│   │   └── ...
│   └── integration/                   # 통합 테스트
│       ├── __init__.py
│       └── test_algorithms_full.py   # 기존 test_algorithms.py 이동
├── pytest.ini
└── requirements.txt
```

**생성 명령**:
```bash
cd luckyai_645/backend
mkdir -p tests/unit tests/integration
touch tests/__init__.py tests/conftest.py
touch tests/unit/__init__.py tests/integration/__init__.py
```

#### Step 4: conftest.py 작성

**파일**: `luckyai_645/backend/tests/conftest.py`

```python
"""
pytest 설정 및 공통 fixture

2026-01-08 06:10:00 EST - 초기 생성
"""

import pytest
import pandas as pd
import numpy as np


@pytest.fixture
def sample_lotto_data():
    """
    테스트용 샘플 로또 데이터 (100회차)
    
    Returns:
        pd.DataFrame: 당첨번호 DataFrame
    """
    np.random.seed(42)
    data = []
    
    for round_num in range(1, 101):
        # 랜덤하게 6개 번호 생성 (정렬)
        numbers = sorted(np.random.choice(range(1, 46), size=6, replace=False))
        data.append({
            'round': round_num,
            'num1': numbers[0],
            'num2': numbers[1],
            'num3': numbers[2],
            'num4': numbers[3],
            'num5': numbers[4],
            'num6': numbers[5],
        })
    
    return pd.DataFrame(data)


@pytest.fixture
def small_lotto_data():
    """
    테스트용 소규모 로또 데이터 (10회차)
    
    Returns:
        pd.DataFrame: 당첨번호 DataFrame
    """
    return pd.DataFrame({
        'round': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        'num1': [1, 1, 2, 3, 5, 8, 13, 21, 34, 1],
        'num2': [2, 2, 3, 4, 6, 9, 14, 22, 35, 2],
        'num3': [3, 3, 4, 5, 7, 10, 15, 23, 36, 3],
        'num4': [4, 4, 5, 6, 8, 11, 16, 24, 37, 4],
        'num5': [5, 5, 6, 7, 9, 12, 17, 25, 38, 5],
        'num6': [6, 6, 7, 8, 10, 13, 18, 26, 39, 6],
    })


@pytest.fixture
def empty_lotto_data():
    """
    빈 DataFrame (fallback 테스트용)
    
    Returns:
        pd.DataFrame: 빈 DataFrame
    """
    return pd.DataFrame(columns=['round', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6'])


@pytest.fixture
def exclude_numbers():
    """제외 번호 예시"""
    return [1, 2, 3, 40, 41, 42]


@pytest.fixture
def include_numbers():
    """포함 번호 예시"""
    return [7, 14, 21]


@pytest.fixture
def mock_algorithm_params():
    """알고리즘 파라미터 예시"""
    return {
        'n_sets': 5,
        'window_type': 'all',
        'probability_mode': 'normal',
        'temperature': 1.0,
    }
```

#### Step 5: 테스트 실행 스크립트

**파일**: `luckyai_645/backend/run_tests.sh` (Linux/Mac)

```bash
#!/bin/bash
# 테스트 실행 스크립트
# 2026-01-08 06:10:00 EST

echo "=========================================="
echo "단위 테스트 실행"
echo "=========================================="

# 단위 테스트만 실행 (빠름)
pytest tests/unit -m unit -v

echo ""
echo "=========================================="
echo "통합 테스트 실행"
echo "=========================================="

# 통합 테스트 실행 (느림)
pytest tests/integration -m integration -v

echo ""
echo "=========================================="
echo "전체 테스트 + 커버리지"
echo "=========================================="

# 전체 테스트 + 커버리지 리포트
pytest tests/ --cov=app --cov-report=html --cov-report=term-missing

echo ""
echo "✅ 테스트 완료!"
echo "📊 커버리지 리포트: htmlcov/index.html"
```

**파일**: `luckyai_645/backend/run_tests.ps1` (Windows)

```powershell
# 테스트 실행 스크립트 (PowerShell)
# 2026-01-08 06:10:00 EST

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "단위 테스트 실행" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 단위 테스트만 실행 (빠름)
pytest tests/unit -m unit -v

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "통합 테스트 실행" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 통합 테스트 실행 (느림)
pytest tests/integration -m integration -v

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "전체 테스트 + 커버리지" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 전체 테스트 + 커버리지 리포트
pytest tests/ --cov=app --cov-report=html --cov-report=term-missing

Write-Host ""
Write-Host "✅ 테스트 완료!" -ForegroundColor Green
Write-Host "📊 커버리지 리포트: htmlcov/index.html" -ForegroundColor Yellow
```

### 예상 효과

**정량적 효과**:
- 테스트 자동화: 수동 → 자동 (100%)
- 버그 조기 발견: 배포 후 → 개발 중 (80% 빠름)
- 리그레션 방지: 0% → 95%

**정성적 효과**:
- ✅ 코드 신뢰도 향상
- ✅ 리팩토링 안전성 확보
- ✅ CI/CD 파이프라인 구축 가능

### 체크리스트

- [ ] pytest 및 관련 패키지 설치
- [ ] `pytest.ini` 설정 파일 생성
- [ ] `tests/` 폴더 구조 생성
- [ ] `conftest.py` fixture 작성
- [ ] 테스트 실행 스크립트 작성
- [ ] `.gitignore`에 `htmlcov/` 추가
- [ ] 첫 테스트 케이스 작성 및 실행

---

## 🧪 Part 2: base.py 공통 메서드 테스트 작성

### 목적 및 필요성

**테스트 대상**:
- ✅ `calculate_frequency()` - 빈도 계산
- ✅ `generate_random_sets()` - 랜덤 생성
- ✅ `apply_temperature()` - 온도 조정
- ✅ `apply_recent_draw_penalty()` - 직전 회차 패널티

**중요성**:
- 🔴 **Critical**: 7개 알고리즘이 모두 사용
- 🔴 **High Impact**: 버그 발생 시 전체 영향
- 🟢 **Easy to Test**: 순수 함수 (side effect 없음)

### 구현 방법

#### 전체 테스트 파일

**파일**: `luckyai_645/backend/tests/unit/test_base_helpers.py`

```python
"""
base.py 공통 헬퍼 메서드 테스트

2026-01-08 06:10:00 EST - 초기 생성
"""

import pytest
import pandas as pd
from app.algorithms.base import LottoAlgorithm
from app.algorithms.algorithm_01_random import RandomAlgorithm


class TestCalculateFrequency:
    """calculate_frequency() 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_frequency(self, small_lotto_data):
        """기본 빈도 계산"""
        algo = RandomAlgorithm()
        
        frequency = algo.calculate_frequency(small_lotto_data)
        
        # 검증
        assert isinstance(frequency, dict)
        assert len(frequency) == 45  # 1~45 모든 번호
        assert frequency[1] == 2  # 1번이 2회 출현
        assert frequency[2] == 3  # 2번이 3회 출현
        assert frequency[40] == 0  # 40번은 0회 출현
    
    @pytest.mark.unit
    def test_zero_frequency_included(self, small_lotto_data):
        """0회 출현 번호 포함 여부"""
        algo = RandomAlgorithm()
        
        # include_zero_freq=True (기본값)
        freq_with_zero = algo.calculate_frequency(small_lotto_data, include_zero_freq=True)
        assert len(freq_with_zero) == 45
        assert all(num in freq_with_zero for num in range(1, 46))
        
        # include_zero_freq=False
        freq_without_zero = algo.calculate_frequency(small_lotto_data, include_zero_freq=False)
        assert len(freq_without_zero) < 45  # 0회 출현 번호 제외
        assert 40 not in freq_without_zero  # 출현하지 않은 번호
    
    @pytest.mark.unit
    def test_empty_dataframe(self):
        """빈 DataFrame 처리"""
        algo = RandomAlgorithm()
        empty_df = pd.DataFrame(columns=['num1', 'num2', 'num3', 'num4', 'num5', 'num6'])
        
        frequency = algo.calculate_frequency(empty_df)
        
        # 모든 번호가 0회
        assert all(freq == 0 for freq in frequency.values())
    
    @pytest.mark.unit
    def test_frequency_sum(self, sample_lotto_data):
        """빈도 합계 검증"""
        algo = RandomAlgorithm()
        
        frequency = algo.calculate_frequency(sample_lotto_data)
        
        # 100회차 × 6개 번호 = 600
        total_draws = len(sample_lotto_data)
        assert sum(frequency.values()) == total_draws * 6


class TestGenerateRandomSets:
    """generate_random_sets() 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_generation(self):
        """기본 랜덤 생성"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(5)
        
        # 검증
        assert len(results) == 5  # 5세트 생성
        for numbers in results:
            assert len(numbers) == 6  # 각 세트 6개
            assert all(1 <= n <= 45 for n in numbers)  # 1~45 범위
            assert len(set(numbers)) == 6  # 중복 없음
            assert numbers == sorted(numbers)  # 정렬됨
    
    @pytest.mark.unit
    def test_with_exclude_numbers(self, exclude_numbers):
        """제외 번호 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=10,
            exclude_numbers=exclude_numbers
        )
        
        # 제외 번호가 포함되지 않음
        for numbers in results:
            for excluded in exclude_numbers:
                assert excluded not in numbers
    
    @pytest.mark.unit
    def test_with_include_numbers(self, include_numbers):
        """포함 번호 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=10,
            include_numbers=include_numbers
        )
        
        # 포함 번호가 모두 포함됨
        for numbers in results:
            for included in include_numbers:
                assert included in numbers
    
    @pytest.mark.unit
    def test_with_both_exclude_and_include(self, exclude_numbers, include_numbers):
        """제외 + 포함 동시 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=5,
            exclude_numbers=exclude_numbers,
            include_numbers=include_numbers
        )
        
        for numbers in results:
            # 포함 번호는 모두 포함
            for included in include_numbers:
                assert included in numbers
            
            # 제외 번호는 포함되지 않음
            for excluded in exclude_numbers:
                assert excluded not in numbers
    
    @pytest.mark.unit
    def test_edge_case_minimal_available(self):
        """최소 사용 가능 번호 (경계 조건)"""
        algo = RandomAlgorithm()
        
        # 39개 제외 + 6개 포함 = 정확히 6개만 선택 가능
        exclude = list(range(1, 40))
        include = list(range(40, 46))
        
        results = algo.generate_random_sets(
            n_sets=3,
            exclude_numbers=exclude,
            include_numbers=include
        )
        
        # 모든 세트가 40~45 번호만 포함
        for numbers in results:
            assert set(numbers) == set(include)


class TestApplyTemperature:
    """apply_temperature() 정적 메서드 테스트"""
    
    @pytest.mark.unit
    def test_temperature_1_no_change(self):
        """온도 1.0 (변경 없음)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 1.0)
        
        assert result == probs  # 완전히 동일
    
    @pytest.mark.unit
    def test_temperature_low_sharpens(self):
        """온도 < 1.0 (날카로운 분포)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 0.5)
        
        # 높은 확률이 더 강조됨
        assert result[3] > probs[3]
        assert result[1] < probs[1]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_temperature_high_flattens(self):
        """온도 > 1.0 (평탄한 분포)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 2.0)
        
        # 확률 차이가 완화됨
        assert result[3] < probs[3]
        assert result[1] > probs[1]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_uniform_distribution(self):
        """균등 분포 처리"""
        probs = {i: 1/45 for i in range(1, 46)}
        
        result = LottoAlgorithm.apply_temperature(probs, 0.5)
        
        # 균등 분포는 온도 적용해도 변화 없음
        for i in range(1, 46):
            assert abs(result[i] - probs[i]) < 1e-9


class TestApplyRecentDrawPenalty:
    """apply_recent_draw_penalty() 정적 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_penalty(self, small_lotto_data):
        """기본 패널티 적용"""
        probs = {n: 1/45 for n in range(1, 46)}
        
        result = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.5
        )
        
        # 직전 회차 번호 (round 10: 1, 2, 3, 4, 5, 6)
        for num in [1, 2, 3, 4, 5, 6]:
            assert result[num] < probs[num]  # 확률 감소
        
        # 다른 번호는 상대적으로 증가
        assert result[7] > probs[7]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_different_penalty_rates(self, small_lotto_data):
        """다양한 할인율"""
        probs = {n: 1/45 for n in range(1, 46)}
        
        # 50% 할인
        result_50 = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.5
        )
        
        # 33% 할인 (더 강한 페널티)
        result_33 = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.33
        )
        
        # 더 강한 페널티가 더 큰 감소
        assert result_33[1] < result_50[1]
    
    @pytest.mark.unit
    def test_empty_dataframe(self):
        """빈 DataFrame 처리"""
        empty_df = pd.DataFrame(columns=['num1', 'num2', 'num3', 'num4', 'num5', 'num6'])
        probs = {n: 1/45 for n in range(1, 46)}
        
        result = LottoAlgorithm.apply_recent_draw_penalty(
            probs, empty_df, penalty_rate=0.5
        )
        
        # 변화 없음
        assert result == probs


class TestIntegration:
    """통합 테스트 (여러 메서드 조합)"""
    
    @pytest.mark.integration
    def test_full_workflow(self, sample_lotto_data):
        """전체 워크플로우"""
        algo = RandomAlgorithm()
        
        # 1. 빈도 계산
        frequency = algo.calculate_frequency(sample_lotto_data)
        
        # 2. 확률 분포 생성
        total = sum(frequency.values())
        probs = {num: freq / total for num, freq in frequency.items()}
        
        # 3. 온도 적용
        probs = LottoAlgorithm.apply_temperature(probs, 0.7)
        
        # 4. 직전 회차 패널티
        probs = LottoAlgorithm.apply_recent_draw_penalty(
            probs, sample_lotto_data, 0.5
        )
        
        # 검증
        assert abs(sum(probs.values()) - 1.0) < 1e-9
        assert all(0 <= p <= 1 for p in probs.values())
```

### 테스트 실행

```bash
# 단위 테스트만 실행
pytest tests/unit/test_base_helpers.py -v

# 커버리지 포함
pytest tests/unit/test_base_helpers.py --cov=app.algorithms.base --cov-report=term-missing

# 특정 테스트 클래스만
pytest tests/unit/test_base_helpers.py::TestCalculateFrequency -v
```

### 예상 커버리지

| 메서드 | 테스트 케이스 수 | 예상 커버리지 |
|--------|-----------------|--------------|
| `calculate_frequency` | 4개 | 100% |
| `generate_random_sets` | 5개 | 100% |
| `apply_temperature` | 4개 | 100% |
| `apply_recent_draw_penalty` | 3개 | 100% |
| **전체** | **16개** | **100%** |

### 체크리스트

- [ ] `tests/unit/test_base_helpers.py` 파일 생성
- [ ] `TestCalculateFrequency` 클래스 작성 (4개 테스트)
- [ ] `TestGenerateRandomSets` 클래스 작성 (5개 테스트)
- [ ] `TestApplyTemperature` 클래스 작성 (4개 테스트)
- [ ] `TestApplyRecentDrawPenalty` 클래스 작성 (3개 테스트)
- [ ] 모든 테스트 실행 및 통과 확인
- [ ] 커버리지 100% 달성 확인

---

## 🔢 Part 3: 매직 넘버 상수화

### 목적 및 필요성

**현재 문제**:
```python
# 여러 곳에서 하드코딩
for i in range(1, 7):  # 6개 번호
for num in range(1, 46):  # 45개 번호
if len(numbers) == 6:
```

**개선 후**:
```python
# 상수로 명확화
for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1):
for num in range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1):
if len(numbers) == LOTTO_NUMBERS_PER_DRAW:
```

**장점**:
- ✅ 가독성 향상
- ✅ 유지보수 용이 (숫자 변경 시 한 곳만 수정)
- ✅ 의도 명확화

### 구현 방법

#### Step 1: 상수 정의 파일 생성

**파일**: `luckyai_645/backend/app/algorithms/constants.py`

```python
"""
알고리즘 공통 상수

2026-01-08 06:10:00 EST - 초기 생성
"""

# ============================================================================
# 로또 게임 규칙
# ============================================================================

# 번호 범위
LOTTO_MIN_NUMBER = 1
"""로또 최소 번호"""

LOTTO_MAX_NUMBER = 45
"""로또 최대 번호"""

LOTTO_TOTAL_NUMBERS = LOTTO_MAX_NUMBER - LOTTO_MIN_NUMBER + 1
"""전체 번호 개수 (45개)"""

# 당첨 번호 구성
LOTTO_NUMBERS_PER_DRAW = 6
"""한 세트당 번호 개수"""

LOTTO_BONUS_NUMBER_COUNT = 1
"""보너스 번호 개수"""

# ============================================================================
# DataFrame 컬럼 인덱스
# ============================================================================

LOTTO_NUMBER_COLUMNS = [f'num{i}' for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1)]
"""당첨번호 컬럼명 리스트: ['num1', 'num2', 'num3', 'num4', 'num5', 'num6']"""

LOTTO_ROUND_COLUMN = 'round'
"""회차 컬럼명"""

LOTTO_DATE_COLUMN = 'date'
"""추첨일 컬럼명"""

# ============================================================================
# 알고리즘 파라미터 기본값
# ============================================================================

# 분석 범위
DEFAULT_WINDOW_SIZE = 50
"""기본 분석 윈도우 크기 (회차)"""

DEFAULT_RECENT_DRAWS = 100
"""기본 최근 회차 수"""

# 확률 조정
DEFAULT_TEMPERATURE = 1.0
"""기본 온도 파라미터 (1.0 = 변화 없음)"""

DEFAULT_PENALTY_RATE = 0.5
"""기본 직전 회차 패널티 비율 (0.5 = 50% 할인)"""

# 필터
DEFAULT_FREQUENT_LOOKBACK = 10
"""고빈도 필터 기본 lookback 회차"""

DEFAULT_FREQUENT_THRESHOLD = 5
"""고빈도 필터 기본 임계값 (5회 이상 출현)"""

# ============================================================================
# LSTM 하이퍼파라미터
# ============================================================================

DEFAULT_LSTM_HIDDEN_SIZE = 128
"""LSTM 은닉층 크기"""

DEFAULT_LSTM_NUM_LAYERS = 2
"""LSTM 레이어 수"""

DEFAULT_LSTM_SEQUENCE_LENGTH = 10
"""LSTM 시퀀스 길이"""

DEFAULT_LSTM_EPOCHS = 50
"""LSTM 학습 에폭 수"""

DEFAULT_LSTM_LEARNING_RATE = 0.001
"""LSTM 학습률"""

DEFAULT_LSTM_BATCH_SIZE = 16
"""LSTM 배치 크기"""

# ============================================================================
# 패턴 분석
# ============================================================================

DEFAULT_RANGE_DIVISIONS = 5
"""범위 패턴 기본 구간 수 (A-E)"""

DEFAULT_RANK_COMBO_SIZE = 3
"""순위 패턴 기본 조합 크기"""

DEFAULT_TOP_PATTERNS = 10
"""상위 패턴 개수"""

# ============================================================================
# 검증 규칙
# ============================================================================

MAX_EXCLUDE_NUMBERS = 39
"""최대 제외 번호 개수"""

MAX_INCLUDE_NUMBERS = LOTTO_NUMBERS_PER_DRAW
"""최대 포함 번호 개수"""

MIN_SETS = 1
"""최소 생성 세트 수"""

MAX_SETS = 100
"""최대 생성 세트 수"""

# ============================================================================
# 모델 저장 경로
# ============================================================================

LSTM_MODEL_DIR = "models/lstm"
"""LSTM 모델 저장 디렉토리"""

LSTM_MODEL_FILE_PATTERN = "lstm_model_round_{round}.pt"
"""LSTM 모델 파일명 패턴"""
```

#### Step 2: 기존 코드 수정

**변경 전** (`base.py`):
```python
def validate_parameters(self, n_sets, exclude_numbers, include_numbers):
    if n_sets < 1 or n_sets > 100:
        return False, "생성 세트 수는 1~100 사이여야 합니다"
    
    if exclude_numbers:
        if len(exclude_numbers) > 39:
            return False, "제외 번호는 최대 39개까지 가능합니다"
        
        for num in exclude_numbers:
            if not 1 <= num <= 45:
                return False, f"제외 번호는 1~45 사이여야 합니다: {num}"
```

**변경 후**:
```python
# 2026-01-08 06:20:00 EST - 매직 넘버 상수화
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    MAX_EXCLUDE_NUMBERS,
    MIN_SETS,
    MAX_SETS,
)

def validate_parameters(self, n_sets, exclude_numbers, include_numbers):
    if n_sets < MIN_SETS or n_sets > MAX_SETS:
        return False, f"생성 세트 수는 {MIN_SETS}~{MAX_SETS} 사이여야 합니다"
    
    if exclude_numbers:
        if len(exclude_numbers) > MAX_EXCLUDE_NUMBERS:
            return False, f"제외 번호는 최대 {MAX_EXCLUDE_NUMBERS}개까지 가능합니다"
        
        for num in exclude_numbers:
            if not LOTTO_MIN_NUMBER <= num <= LOTTO_MAX_NUMBER:
                return False, f"제외 번호는 {LOTTO_MIN_NUMBER}~{LOTTO_MAX_NUMBER} 사이여야 합니다: {num}"
```

#### Step 3: 일괄 변경 스크립트

**파일**: `luckyai_645/backend/scripts/replace_magic_numbers.py`

```python
"""
매직 넘버 자동 치환 스크립트

2026-01-08 06:10:00 EST - 초기 생성

주의: 실행 전 Git commit 권장
"""

import os
import re
from pathlib import Path


def replace_magic_numbers(file_path: Path) -> tuple[int, list[str]]:
    """
    파일의 매직 넘버를 상수로 치환
    
    Returns:
        (변경 횟수, 변경 내용 목록)
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    changes = []
    
    # 치환 규칙 (순서 중요!)
    replacements = [
        # range(1, 46) → range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1)
        (
            r'range\(1,\s*46\)',
            'range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1)',
            'range(1, 46)'
        ),
        # range(1, 7) → range(1, LOTTO_NUMBERS_PER_DRAW + 1)
        (
            r'range\(1,\s*7\)',
            'range(1, LOTTO_NUMBERS_PER_DRAW + 1)',
            'range(1, 7)'
        ),
        # len(...) == 6 → len(...) == LOTTO_NUMBERS_PER_DRAW
        (
            r'len\((\w+)\)\s*==\s*6',
            r'len(\1) == LOTTO_NUMBERS_PER_DRAW',
            'len(x) == 6'
        ),
        # n_sets < 1 or n_sets > 100
        (
            r'n_sets\s*<\s*1\s*or\s*n_sets\s*>\s*100',
            'n_sets < MIN_SETS or n_sets > MAX_SETS',
            'n_sets range check'
        ),
    ]
    
    for pattern, replacement, description in replacements:
        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replacement, content)
            changes.append(f"- {description}: {len(matches)}회")
    
    # 변경 사항이 있으면 파일 저장
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
    
    return len(changes), changes


def main():
    """메인 실행"""
    algorithms_dir = Path('app/algorithms')
    
    print("=" * 60)
    print("매직 넘버 상수화 스크립트")
    print("=" * 60)
    print()
    
    total_files = 0
    total_changes = 0
    
    for py_file in algorithms_dir.glob('*.py'):
        if py_file.name == 'constants.py':
            continue  # 상수 파일은 제외
        
        count, changes = replace_magic_numbers(py_file)
        
        if count > 0:
            total_files += 1
            total_changes += count
            
            print(f"📝 {py_file.name}")
            for change in changes:
                print(f"   {change}")
            print()
    
    print("=" * 60)
    print(f"✅ 완료: {total_files}개 파일, {total_changes}개 변경")
    print("=" * 60)


if __name__ == '__main__':
    main()
```

### 변경 대상 파일

| 파일 | 예상 변경 수 | 우선순위 |
|------|-------------|---------|
| `base.py` | ~10회 | 🔴 High |
| `algorithm_02_advanced_frequency.py` | ~8회 | 🟡 Medium |
| `algorithm_03_advanced_lstm.py` | ~15회 | 🟡 Medium |
| `algorithm_04_advanced_pattern.py` | ~12회 | 🟡 Medium |
| `algorithm_05_weighted.py` | ~5회 | 🟢 Low |
| `algorithm_06_frequency.py` | ~8회 | 🟢 Low |
| `algorithm_07_hot_cold.py` | ~6회 | 🟢 Low |

### 체크리스트

- [ ] `constants.py` 파일 생성
- [ ] 모든 상수 정의 완료
- [ ] `base.py`부터 단계별 적용
- [ ] 각 파일 수정 후 테스트 실행
- [ ] import 문 추가 확인
- [ ] 전체 테스트 통과 확인
- [ ] Git commit

---

## 🏷️ Part 4: 타입 힌트 강화

### 목적 및 필요성

**현재 상황**:
```python
def calculate_frequency(self, data, include_zero_freq=True):  # 타입 불명확
    frequency = {}  # dict? Dict[int, int]?
    ...
```

**개선 후**:
```python
def calculate_frequency(
    self,
    data: pd.DataFrame,
    include_zero_freq: bool = True
) -> Dict[int, int]:
    frequency: Dict[int, int] = {}
    ...
```

**장점**:
- ✅ IDE 자동완성 향상
- ✅ 타입 오류 조기 발견
- ✅ 코드 가독성 향상
- ✅ 문서화 효과

### 구현 방법

#### Step 1: mypy 설정

**파일**: `luckyai_645/backend/mypy.ini`

```ini
[mypy]
# mypy 설정 파일
# 2026-01-08 06:10:00 EST - 초기 생성

# 검사 대상
files = app/algorithms

# 기본 설정
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True

# 엄격도 (점진적으로 증가)
check_untyped_defs = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True

# 서드파티 라이브러리
[mypy-pandas.*]
ignore_missing_imports = True

[mypy-numpy.*]
ignore_missing_imports = True

[mypy-torch.*]
ignore_missing_imports = True

[mypy-pytest.*]
ignore_missing_imports = True
```

**설치**:
```bash
pip install mypy
```

#### Step 2: base.py 타입 힌트 강화

**변경 전**:
```python
def calculate_frequency(self, data, include_zero_freq=True):
    frequency = {}
    ...
    return frequency
```

**변경 후**:
```python
# 2026-01-08 06:25:00 EST - 타입 힌트 강화
from typing import Dict, List, Optional, Any
import pandas as pd

def calculate_frequency(
    self,
    data: pd.DataFrame,
    include_zero_freq: bool = True
) -> Dict[int, int]:
    """
    번호별 출현 빈도 계산
    
    Args:
        data: 과거 당첨번호 DataFrame
        include_zero_freq: 0회 출현 번호 포함 여부
    
    Returns:
        {번호: 출현 횟수} 딕셔너리
    """
    frequency: Dict[int, int] = {}
    
    for _, row in data.iterrows():
        for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1):
            num: int = row[f'num{i}']
            frequency[num] = frequency.get(num, 0) + 1
    
    if include_zero_freq:
        for num in range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1):
            if num not in frequency:
                frequency[num] = 0
    
    return frequency
```

#### Step 3: 복잡한 타입 정의

**파일**: `luckyai_645/backend/app/algorithms/types.py`

```python
"""
알고리즘 타입 정의

2026-01-08 06:10:00 EST - 초기 생성
"""

from typing import TypeAlias, List, Dict, Optional, Literal
import pandas as pd

# ============================================================================
# 기본 타입
# ============================================================================

LottoNumbers: TypeAlias = List[int]
"""로또 번호 리스트 (6개)"""

LottoNumberSet: TypeAlias = List[LottoNumbers]
"""로또 번호 세트 리스트 (여러 개의 6개 번호)"""

FrequencyDict: TypeAlias = Dict[int, int]
"""빈도 딕셔너리 {번호: 출현 횟수}"""

ProbabilityDict: TypeAlias = Dict[int, float]
"""확률 딕셔너리 {번호: 확률}"""

# ============================================================================
# DataFrame 타입
# ============================================================================

LottoDataFrame: TypeAlias = pd.DataFrame
"""
로또 당첨번호 DataFrame

Required Columns:
    - round: int (회차)
    - num1~num6: int (당첨번호)
    
Optional Columns:
    - date: datetime (추첨일)
    - bonus: int (보너스 번호)
"""

# ============================================================================
# 알고리즘 파라미터 타입
# ============================================================================

WindowType: TypeAlias = Literal['all', 'recent']
"""분석 범위 타입"""

ProbabilityMode: TypeAlias = Literal['normal', 'inverse']
"""확률 모드 타입"""

LearningMode: TypeAlias = Literal['non_cumulative', 'cumulative']
"""학습 모드 타입"""

PatternType: TypeAlias = Literal['range', 'rank']
"""패턴 타입"""

# ============================================================================
# 설정 타입
# ============================================================================

AlgorithmParams: TypeAlias = Dict[str, Any]
"""알고리즘 파라미터 딕셔너리"""

ValidationResult: TypeAlias = tuple[bool, Optional[str]]
"""검증 결과 (성공 여부, 오류 메시지)"""
```

#### Step 4: 전체 파일 타입 힌트 적용

**우선순위**:
1. 🔴 `base.py` - 모든 공통 메서드
2. 🟡 `algorithm_02_advanced_frequency.py`
3. 🟡 `algorithm_03_advanced_lstm.py`
4. 🟡 `algorithm_04_advanced_pattern.py`
5. 🟢 나머지 알고리즘 파일들

**적용 규칙**:
- 모든 함수/메서드에 타입 힌트
- 복잡한 타입은 `types.py`에 정의
- 제네릭 타입 적극 활용
- Optional vs Union 명확히 구분

#### Step 5: mypy 실행

```bash
# 전체 검사
mypy app/algorithms

# 특정 파일만
mypy app/algorithms/base.py

# 리포트 생성
mypy app/algorithms --html-report mypy-report
```

### 예상 효과

**정량적**:
- 타입 오류 조기 발견: 예상 10~20개
- IDE 자동완성 정확도: 30% 향상

**정성적**:
- ✅ 코드 안정성 향상
- ✅ 리팩토링 안전성 확보
- ✅ 신규 개발자 온보딩 개선

### 체크리스트

- [ ] `mypy` 설치 및 설정
- [ ] `types.py` 타입 정의 파일 생성
- [ ] `base.py` 타입 힌트 적용
- [ ] 알고리즘 2, 3, 4 타입 힌트 적용
- [ ] 나머지 파일 타입 힌트 적용
- [ ] mypy 실행 및 오류 수정
- [ ] 테스트 전체 통과 확인

---

## 📦 Part 5: 공통 유틸리티 모듈 생성

### 목적 및 필요성

**현재 상황**:
- base.py에 모든 공통 로직 집중
- 순수 함수들이 클래스 메서드로 존재
- 재사용 가능한 로직이 분산

**개선 후**:
- utils.py에 순수 함수 분리
- base.py는 추상 클래스 역할만
- 모듈화 및 테스트 용이성 향상

### 구현 방법

#### 전체 구조

```
luckyai_645/backend/app/algorithms/
├── base.py                    # 추상 베이스 클래스
├── constants.py               # 상수 정의
├── types.py                   # 타입 정의
├── utils.py                   # 공통 유틸리티 (NEW)
├── validation.py              # 검증 로직 (NEW)
├── sampling.py                # 샘플링 로직 (NEW)
├── algorithm_01_random.py
└── ...
```

#### utils.py

**파일**: `luckyai_645/backend/app/algorithms/utils.py`

```python
"""
알고리즘 공통 유틸리티

순수 함수로 구성하여 테스트 및 재사용 용이

2026-01-08 06:10:00 EST - 초기 생성
"""

from typing import Dict, List
from collections import Counter
import pandas as pd

from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
)
from app.algorithms.types import (
    FrequencyDict,
    ProbabilityDict,
    LottoDataFrame,
)


# ============================================================================
# 빈도 계산
# ============================================================================

def calculate_frequency(
    data: LottoDataFrame,
    include_zero_freq: bool = True
) -> FrequencyDict:
    """
    번호별 출현 빈도 계산
    
    Args:
        data: 과거 당첨번호 DataFrame
        include_zero_freq: 0회 출현 번호 포함 여부
    
    Returns:
        {번호: 출현 횟수}
    """
    frequency: FrequencyDict = Counter()
    
    for _, row in data.iterrows():
        for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1):
            frequency[row[f'num{i}']] += 1
    
    if include_zero_freq:
        for num in range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1):
            if num not in frequency:
                frequency[num] = 0
    
    return dict(frequency)


def frequency_to_probability(
    frequency: FrequencyDict,
    mode: str = 'normal'
) -> ProbabilityDict:
    """
    빈도를 확률로 변환
    
    Args:
        frequency: 빈도 딕셔너리
        mode: 'normal' (정확률) 또는 'inverse' (역확률)
    
    Returns:
        확률 딕셔너리
    """
    if mode == 'normal':
        total = sum(frequency.values())
        if total == 0:
            return {num: 1.0 / len(frequency) for num in frequency}
        return {num: count / total for num, count in frequency.items()}
    
    elif mode == 'inverse':
        max_freq = max(frequency.values())
        inverse = {num: max_freq - count + 1 for num, count in frequency.items()}
        total = sum(inverse.values())
        return {num: inv / total for num, inv in inverse.items()}
    
    else:
        raise ValueError(f"Unknown mode: {mode}")


# ============================================================================
# 확률 조정
# ============================================================================

def apply_temperature(
    probabilities: ProbabilityDict,
    temperature: float
) -> ProbabilityDict:
    """
    확률 분포에 온도 파라미터 적용
    
    Args:
        probabilities: 원본 확률 분포
        temperature: 온도 (0.1~3.0)
            - < 1.0: 날카로운 분포
            - = 1.0: 원본 유지
            - > 1.0: 평탄한 분포
    
    Returns:
        조정된 확률 분포
    """
    if temperature == 1.0:
        return probabilities
    
    adjusted = {
        num: p ** (1 / temperature)
        for num, p in probabilities.items()
    }
    
    total = sum(adjusted.values())
    if total > 0:
        return {num: adj / total for num, adj in adjusted.items()}
    
    return probabilities


def apply_recent_draw_penalty(
    probabilities: ProbabilityDict,
    historical_data: LottoDataFrame,
    penalty_rate: float
) -> ProbabilityDict:
    """
    직전 회차 출현 번호 확률 할인
    
    Args:
        probabilities: 원본 확률 분포
        historical_data: 과거 당첨번호
        penalty_rate: 할인율 (0.1~1.0)
    
    Returns:
        조정된 확률 분포
    """
    if len(historical_data) < 1:
        return probabilities
    
    latest_draw = historical_data.tail(1).iloc[0]
    latest_numbers = {latest_draw[f'num{i}'] for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1)}
    
    adjusted = probabilities.copy()
    for num in latest_numbers:
        if num in adjusted:
            adjusted[num] *= penalty_rate
    
    total = sum(adjusted.values())
    if total > 0:
        adjusted = {num: prob / total for num, prob in adjusted.items()}
    
    return adjusted


# ============================================================================
# 번호 필터링
# ============================================================================

def get_consecutive_numbers(
    historical_data: LottoDataFrame,
    n_consecutive: int = 2
) -> List[int]:
    """
    연속 출현 번호 추출
    
    Args:
        historical_data: 과거 당첨번호
        n_consecutive: 연속 출현 회차 수
    
    Returns:
        연속 출현 번호 리스트
    """
    if len(historical_data) < n_consecutive:
        return []
    
    recent_draws = historical_data.tail(n_consecutive)
    
    # 각 회차의 번호 set 생성
    number_sets = []
    for _, row in recent_draws.iterrows():
        numbers = {row[f'num{i}'] for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1)}
        number_sets.append(numbers)
    
    # 교집합 (모든 회차에 출현)
    consecutive = set.intersection(*number_sets)
    
    return sorted(list(consecutive))


def get_frequent_numbers(
    data: LottoDataFrame,
    lookback: int,
    threshold: int
) -> List[int]:
    """
    고빈도 출현 번호 추출
    
    Args:
        data: 과거 당첨번호
        lookback: 분석 회차 수
        threshold: 임계값 (이상이면 고빈도)
    
    Returns:
        고빈도 번호 리스트
    """
    if len(data) < lookback:
        lookback = len(data)
    
    recent = data.tail(lookback)
    frequency = calculate_frequency(recent, include_zero_freq=False)
    
    return [num for num, count in frequency.items() if count >= threshold]


# ============================================================================
# 데이터 변환
# ============================================================================

def normalize_probabilities(
    probabilities: Dict[int, float]
) -> ProbabilityDict:
    """
    확률 합계를 1로 정규화
    
    Args:
        probabilities: 원본 확률 딕셔너리
    
    Returns:
        정규화된 확률 딕셔너리
    """
    total = sum(probabilities.values())
    
    if total == 0:
        # 모두 0이면 균등 분포
        n = len(probabilities)
        return {num: 1.0 / n for num in probabilities}
    
    return {num: prob / total for num, prob in probabilities.items()}


def merge_probabilities(
    prob1: ProbabilityDict,
    prob2: ProbabilityDict,
    weight1: float = 0.5,
    weight2: float = 0.5
) -> ProbabilityDict:
    """
    두 확률 분포 병합
    
    Args:
        prob1: 첫 번째 확률 분포
        prob2: 두 번째 확률 분포
        weight1: 첫 번째 가중치
        weight2: 두 번째 가중치
    
    Returns:
        병합된 확률 분포
    """
    all_numbers = set(prob1.keys()) | set(prob2.keys())
    
    merged = {}
    for num in all_numbers:
        p1 = prob1.get(num, 0)
        p2 = prob2.get(num, 0)
        merged[num] = p1 * weight1 + p2 * weight2
    
    return normalize_probabilities(merged)
```

#### validation.py

**파일**: `luckyai_645/backend/app/algorithms/validation.py`

```python
"""
입력 검증 유틸리티

2026-01-08 06:10:00 EST - 초기 생성
"""

from typing import List, Optional
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
    MAX_EXCLUDE_NUMBERS,
    MAX_INCLUDE_NUMBERS,
    MIN_SETS,
    MAX_SETS,
)
from app.algorithms.types import ValidationResult


def validate_n_sets(n_sets: int) -> ValidationResult:
    """세트 수 검증"""
    if not isinstance(n_sets, int):
        return False, "세트 수는 정수여야 합니다"
    
    if n_sets < MIN_SETS or n_sets > MAX_SETS:
        return False, f"세트 수는 {MIN_SETS}~{MAX_SETS} 사이여야 합니다"
    
    return True, None


def validate_numbers(
    numbers: List[int],
    name: str = "번호"
) -> ValidationResult:
    """번호 리스트 검증"""
    if not isinstance(numbers, list):
        return False, f"{name}는 리스트여야 합니다"
    
    for num in numbers:
        if not isinstance(num, int):
            return False, f"{name}는 정수여야 합니다: {num}"
        
        if not LOTTO_MIN_NUMBER <= num <= LOTTO_MAX_NUMBER:
            return False, f"{name}는 {LOTTO_MIN_NUMBER}~{LOTTO_MAX_NUMBER} 사이여야 합니다: {num}"
    
    if len(numbers) != len(set(numbers)):
        return False, f"{name}에 중복이 있습니다"
    
    return True, None


def validate_exclude_numbers(
    exclude_numbers: Optional[List[int]]
) -> ValidationResult:
    """제외 번호 검증"""
    if exclude_numbers is None:
        return True, None
    
    if len(exclude_numbers) > MAX_EXCLUDE_NUMBERS:
        return False, f"제외 번호는 최대 {MAX_EXCLUDE_NUMBERS}개까지 가능합니다"
    
    return validate_numbers(exclude_numbers, "제외 번호")


def validate_include_numbers(
    include_numbers: Optional[List[int]]
) -> ValidationResult:
    """포함 번호 검증"""
    if include_numbers is None:
        return True, None
    
    if len(include_numbers) > MAX_INCLUDE_NUMBERS:
        return False, f"포함 번호는 최대 {MAX_INCLUDE_NUMBERS}개까지 가능합니다"
    
    return validate_numbers(include_numbers, "포함 번호")


def validate_parameters(
    n_sets: int,
    exclude_numbers: Optional[List[int]] = None,
    include_numbers: Optional[List[int]] = None
) -> ValidationResult:
    """
    전체 파라미터 검증
    
    Returns:
        (유효 여부, 오류 메시지)
    """
    # 세트 수
    valid, error_msg = validate_n_sets(n_sets)
    if not valid:
        return False, error_msg
    
    # 제외 번호
    valid, error_msg = validate_exclude_numbers(exclude_numbers)
    if not valid:
        return False, error_msg
    
    # 포함 번호
    valid, error_msg = validate_include_numbers(include_numbers)
    if not valid:
        return False, error_msg
    
    # 겹침 확인
    if exclude_numbers and include_numbers:
        overlap = set(exclude_numbers) & set(include_numbers)
        if overlap:
            return False, f"제외/포함 번호가 겹칩니다: {overlap}"
    
    # 사용 가능한 번호 충분한지 확인
    excluded_count = len(exclude_numbers) if exclude_numbers else 0
    included_count = len(include_numbers) if include_numbers else 0
    available_count = (LOTTO_MAX_NUMBER - LOTTO_MIN_NUMBER + 1) - excluded_count
    required_count = LOTTO_NUMBERS_PER_DRAW - included_count
    
    if available_count < required_count:
        return False, "사용 가능한 번호가 부족합니다"
    
    return True, None
```

#### sampling.py

**파일**: `luckyai_645/backend/app/algorithms/sampling.py`

```python
"""
샘플링 유틸리티

2026-01-08 06:10:00 EST - 초기 생성
"""

import random
from typing import List, Optional
import numpy as np

from app.algorithms.constants import LOTTO_NUMBERS_PER_DRAW
from app.algorithms.types import (
    LottoNumbers,
    LottoNumberSet,
    ProbabilityDict,
)


def sample_with_probability(
    probabilities: ProbabilityDict,
    n_samples: int,
    exclude: Optional[List[int]] = None
) -> List[int]:
    """
    확률 기반 샘플링
    
    Args:
        probabilities: 확률 딕셔너리
        n_samples: 샘플링할 개수
        exclude: 제외할 번호 (이미 선택된 번호 등)
    
    Returns:
        샘플링된 번호 리스트
    """
    # 제외 번호 필터링
    if exclude:
        probabilities = {
            num: prob
            for num, prob in probabilities.items()
            if num not in exclude
        }
    
    # 확률 정규화
    total = sum(probabilities.values())
    if total == 0:
        # 모든 확률이 0이면 균등 분포
        numbers = list(probabilities.keys())
        return sorted(random.sample(numbers, n_samples))
    
    probabilities = {num: prob / total for num, prob in probabilities.items()}
    
    # numpy로 샘플링
    numbers = list(probabilities.keys())
    probs = list(probabilities.values())
    
    sampled = np.random.choice(
        numbers,
        size=n_samples,
        replace=False,
        p=probs
    )
    
    return sorted(sampled.tolist())


def generate_random_sets(
    n_sets: int,
    available_numbers: List[int],
    include_numbers: Optional[List[int]] = None
) -> LottoNumberSet:
    """
    순수 랜덤 번호 생성
    
    Args:
        n_sets: 생성할 세트 수
        available_numbers: 사용 가능한 번호 리스트
        include_numbers: 반드시 포함할 번호
    
    Returns:
        생성된 번호 세트 리스트
    """
    results: LottoNumberSet = []
    
    for _ in range(n_sets):
        numbers: LottoNumbers = []
        
        # 포함 번호 먼저 추가
        if include_numbers:
            numbers.extend(include_numbers)
        
        # 나머지 번호 랜덤 선택
        remaining_count = LOTTO_NUMBERS_PER_DRAW - len(numbers)
        selected = random.sample(available_numbers, remaining_count)
        numbers.extend(selected)
        
        results.append(sorted(numbers))
    
    return results
```

### base.py 리팩토링

**변경 후**:
```python
"""
알고리즘 베이스 클래스 - 리팩토링 버전

2026-01-08 06:30:00 EST - 유틸리티 모듈 분리
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Optional, Any

import pandas as pd

# 공통 유틸리티 import
from app.algorithms import utils, validation, sampling
from app.algorithms.constants import LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER
from app.algorithms.types import LottoNumbers, LottoNumberSet


class LottoAlgorithm(ABC):
    """
    로또 알고리즘 추상 베이스 클래스
    
    공통 로직은 utils 모듈 사용
    """
    
    def __init__(self, algorithm_id: int, name: str, description: str, cost_per_set: int = 0):
        self.algorithm_id = algorithm_id
        self.name = name
        self.description = description
        self.cost_per_set = cost_per_set
        self.version = "2.0"  # 리팩토링 버전
    
    @abstractmethod
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> LottoNumberSet:
        """번호 생성 (추상 메서드)"""
        pass
    
    def validate_parameters(
        self,
        n_sets: int,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> tuple[bool, Optional[str]]:
        """
        파라미터 검증 (validation 모듈 사용)
        """
        return validation.validate_parameters(n_sets, exclude_numbers, include_numbers)
    
    def get_available_numbers(
        self,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> List[int]:
        """사용 가능한 번호 리스트 반환"""
        all_numbers = set(range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1))
        
        if exclude_numbers:
            all_numbers -= set(exclude_numbers)
        
        if include_numbers:
            all_numbers -= set(include_numbers)
        
        return sorted(list(all_numbers))
    
    # ========================================
    # 공통 헬퍼 메서드 (utils 모듈 래핑)
    # ========================================
    
    def calculate_frequency(self, *args, **kwargs):
        """빈도 계산 (utils 모듈)"""
        return utils.calculate_frequency(*args, **kwargs)
    
    def generate_random_sets(self, *args, **kwargs):
        """랜덤 생성 (sampling 모듈)"""
        available = self.get_available_numbers(
            kwargs.get('exclude_numbers'),
            kwargs.get('include_numbers')
        )
        return sampling.generate_random_sets(args[0], available, kwargs.get('include_numbers'))
    
    @staticmethod
    def apply_temperature(*args, **kwargs):
        """온도 조정 (utils 모듈)"""
        return utils.apply_temperature(*args, **kwargs)
    
    @staticmethod
    def apply_recent_draw_penalty(*args, **kwargs):
        """직전 회차 패널티 (utils 모듈)"""
        return utils.apply_recent_draw_penalty(*args, **kwargs)
```

### 체크리스트

- [ ] `constants.py` 생성
- [ ] `types.py` 생성
- [ ] `utils.py` 생성 (빈도, 확률 변환)
- [ ] `validation.py` 생성 (검증 로직)
- [ ] `sampling.py` 생성 (샘플링 로직)
- [ ] `base.py` 리팩토링 (유틸리티 모듈 사용)
- [ ] 각 알고리즘 파일 수정 (import 경로 변경)
- [ ] 테스트 전체 통과 확인
- [ ] 문서 업데이트

---

## 📋 전체 체크리스트

### Part 1: 단위 테스트 프레임워크 도입
- [ ] pytest, pytest-cov 설치
- [ ] pytest.ini 설정
- [ ] tests/ 폴더 구조 생성
- [ ] conftest.py fixture 작성
- [ ] 테스트 실행 스크립트 작성

### Part 2: base.py 공통 메서드 테스트
- [ ] test_base_helpers.py 생성
- [ ] 16개 테스트 케이스 작성
- [ ] 커버리지 100% 달성

### Part 3: 매직 넘버 상수화
- [ ] constants.py 생성
- [ ] 7개 알고리즘 파일 수정
- [ ] 자동 치환 스크립트 작성 (선택)

### Part 4: 타입 힌트 강화
- [ ] mypy 설치 및 설정
- [ ] types.py 타입 정의
- [ ] base.py 타입 힌트 적용
- [ ] 알고리즘 파일 타입 힌트 적용

### Part 5: 공통 유틸리티 모듈
- [ ] utils.py 생성
- [ ] validation.py 생성
- [ ] sampling.py 생성
- [ ] base.py 리팩토링

### 최종 검증
- [ ] 전체 테스트 통과
- [ ] mypy 검사 통과
- [ ] 커버리지 80% 이상
- [ ] 문서 업데이트

---

## 📊 예상 효과

| 항목 | 현재 | 개선 후 | 효과 |
|------|------|---------|------|
| 테스트 커버리지 | 0% | 80%+ | +80% |
| 타입 안정성 | 낮음 | 높음 | +70% |
| 코드 가독성 | 70/100 | 90/100 | +20점 |
| 유지보수 시간 | 100% | 60% | -40% |
| 버그 발견 시간 | 배포 후 | 개발 중 | -80% |

---

**작성**: 2026-01-08 06:10:00 EST  
**예상 소요 시간**: 8~12시간  
**우선순위**: Part 1, 2 → Part 3 → Part 4, 5

