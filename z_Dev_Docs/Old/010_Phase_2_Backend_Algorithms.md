# Phase 2: 백엔드 알고리즘 & API
## 상세 개발 로드맵

---

**Phase**: 2 - Backend Algorithms & API  
**예상 기간**: 4-5일 (32-40시간)  
**선행 조건**: Phase 1 완료 (데이터 관리 시스템)  
**목표**: 번호 생성 알고리즘 및 REST API 완전 구현

---

## 📋 Phase 개요

### 주요 산출물
- [x] 알고리즘 베이스 클래스 (추상 클래스)
- [x] 6개 알고리즘 구현 (랜덤, 빈도, 핫콜드, 앙상블, 패턴, 가중치)
- [x] 알고리즘 Factory 패턴 로더
- [x] Pydantic 스키마 정의
- [x] FastAPI 서버 초기화
- [x] REST API 엔드포인트 (번호 생성, 회차 조회, 알고리즘 정보)

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 2.1 알고리즘 베이스 클래스 | 2-3시간 | 2-3h |
| 2.2.1 기본 알고리즘 (3개) | 8시간 | 10-11h |
| 2.2.2 고급 알고리즘 (3개) | 8시간 | 18-19h |
| 2.3 알고리즘 로더 | 2시간 | 20-21h |
| 2.4 Pydantic 스키마 | 3시간 | 23-24h |
| 2.5 FastAPI 초기화 | 2시간 | 25-26h |
| 2.6 API 엔드포인트 | 6-8시간 | 31-34h |
| 2.7 통합 테스트 | 2-4시간 | 33-38h |

---

## 작업 2.1: 알고리즘 베이스 클래스 (2-3시간)

### 목표
모든 알고리즘이 상속받을 추상 베이스 클래스 정의

### Step 2.1.1: 추상 베이스 클래스 작성

**파일**: `backend/app/algorithms/base.py`

```python
"""
알고리즘 베이스 클래스

모든 로또 번호 생성 알고리즘의 추상 클래스

2026-01-05 EST - 초기 생성
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Optional, Any

import pandas as pd


class LottoAlgorithm(ABC):
    """
    로또 알고리즘 추상 베이스 클래스
    
    모든 알고리즘은 이 클래스를 상속받아 구현
    """
    
    def __init__(
        self,
        algorithm_id: int,
        name: str,
        description: str,
        cost_per_set: int = 0
    ):
        """
        Args:
            algorithm_id: 알고리즘 ID (1~9)
            name: 알고리즘 이름
            description: 설명
            cost_per_set: 세트당 코인 비용
        """
        self.algorithm_id = algorithm_id
        self.name = name
        self.description = description
        self.cost_per_set = cost_per_set
        self.version = "1.0"
    
    @abstractmethod
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        번호 생성 (추상 메서드)
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
                컬럼: ['회차', '추첨일', '번호1'~'번호6', '보너스']
            n_sets: 생성할 세트 수 (기본 5)
            exclude_numbers: 제외할 번호 리스트 (예: [1, 2, 3])
            include_numbers: 반드시 포함할 번호 리스트 (예: [7, 14, 21])
            **kwargs: 알고리즘별 추가 파라미터
            
        Returns:
            List[List[int]]: 생성된 번호 세트 리스트
                예: [[5, 12, 23, 31, 38, 42], [1, 7, 14, 21, 28, 35], ...]
                
        Raises:
            ValueError: 잘못된 파라미터
        """
        pass
    
    def validate_parameters(
        self,
        n_sets: int,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> tuple[bool, Optional[str]]:
        """
        파라미터 검증
        
        Args:
            n_sets: 생성 세트 수
            exclude_numbers: 제외 번호
            include_numbers: 포함 번호
            
        Returns:
            (유효 여부, 오류 메시지)
        """
        # 1. 세트 수 검증
        if n_sets < 1 or n_sets > 100:
            return False, "생성 세트 수는 1~100 사이여야 합니다"
        
        # 2. 제외 번호 검증
        if exclude_numbers:
            if len(exclude_numbers) > 39:
                return False, "제외 번호는 최대 39개까지 가능합니다"
            
            for num in exclude_numbers:
                if not 1 <= num <= 45:
                    return False, f"제외 번호는 1~45 사이여야 합니다: {num}"
            
            if len(exclude_numbers) != len(set(exclude_numbers)):
                return False, "제외 번호에 중복이 있습니다"
        
        # 3. 포함 번호 검증
        if include_numbers:
            if len(include_numbers) > 6:
                return False, "포함 번호는 최대 6개까지 가능합니다"
            
            for num in include_numbers:
                if not 1 <= num <= 45:
                    return False, f"포함 번호는 1~45 사이여야 합니다: {num}"
            
            if len(include_numbers) != len(set(include_numbers)):
                return False, "포함 번호에 중복이 있습니다"
        
        # 4. 제외/포함 겹침 확인
        if exclude_numbers and include_numbers:
            overlap = set(exclude_numbers) & set(include_numbers)
            if overlap:
                return False, f"제외/포함 번호가 겹칩니다: {overlap}"
        
        # 5. 사용 가능한 번호 충분한지 확인
        excluded_count = len(exclude_numbers) if exclude_numbers else 0
        included_count = len(include_numbers) if include_numbers else 0
        available_count = 45 - excluded_count
        required_count = 6 - included_count
        
        if available_count < required_count:
            return False, f"사용 가능한 번호가 부족합니다 (필요: {required_count}, 가능: {available_count})"
        
        return True, None
    
    def get_available_numbers(
        self,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> List[int]:
        """
        사용 가능한 번호 리스트 반환
        
        Args:
            exclude_numbers: 제외 번호
            include_numbers: 포함 번호
            
        Returns:
            사용 가능한 번호 리스트 (이미 포함된 번호 제외)
        """
        all_numbers = set(range(1, 46))
        
        if exclude_numbers:
            all_numbers -= set(exclude_numbers)
        
        if include_numbers:
            all_numbers -= set(include_numbers)
        
        return sorted(list(all_numbers))
    
    def get_info(self) -> Dict[str, Any]:
        """
        알고리즘 정보 반환
        
        Returns:
            Dict: {
                'id': int,
                'name': str,
                'description': str,
                'version': str,
                'cost_per_set': int,
                'parameters': Dict
            }
        """
        return {
            'id': self.algorithm_id,
            'name': self.name,
            'description': self.description,
            'version': self.version,
            'cost_per_set': self.cost_per_set,
            'parameters': self.get_default_parameters()
        }
    
    @abstractmethod
    def get_default_parameters(self) -> Dict[str, Any]:
        """
        기본 파라미터 반환
        
        Returns:
            Dict: 알고리즘별 기본 파라미터
                예: {
                    'n_sets': 5,
                    'exclude_numbers': None,
                    'include_numbers': None,
                    'temperature': 0.8  # 알고리즘별 추가 파라미터
                }
        """
        pass
    
    def __str__(self) -> str:
        return f"Algorithm {self.algorithm_id}: {self.name}"
    
    def __repr__(self) -> str:
        return f"<{self.__class__.__name__}(id={self.algorithm_id}, name='{self.name}')>"
```

### 완료 기준 체크리스트
- [ ] `base.py` 작성 완료
- [ ] 추상 메서드 정의 (`generate_numbers`, `get_default_parameters`)
- [ ] 파라미터 검증 로직 완성

---

## 작업 2.2: 알고리즘 구현 (16시간)

### 작업 2.2.1: 기본 알고리즘 (8시간)

#### Algorithm 1: 순수 랜덤

**파일**: `backend/app/algorithms/algorithm_01_random.py`

```python
"""
Algorithm 1: 순수 랜덤 (Quick Pick)

완전 무작위 번호 생성

2026-01-05 EST - 초기 생성
"""

import random
from typing import List, Dict, Optional, Any

import pandas as pd

from app.algorithms.base import LottoAlgorithm


class RandomAlgorithm(LottoAlgorithm):
    """
    순수 랜덤 알고리즘
    
    1~45 중 6개를 무작위로 선택
    가장 공정하고 편향 없는 방법
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=1,
            name="순수 랜덤 (Quick Pick)",
            description="1~45 중 6개를 완전 무작위로 선택합니다. "
                       "가장 공정하고 편향 없는 방법입니다.",
            cost_per_set=0  # 무료
        )
    
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        순수 랜덤 번호 생성
        
        Args:
            historical_data: 사용하지 않음 (랜덤이므로)
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            
        Returns:
            List[List[int]]: 번호 세트
        """
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        results = []
        
        # 사용 가능한 번호 풀
        available_numbers = self.get_available_numbers(exclude_numbers, include_numbers)
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 랜덤 선택
            remaining_count = 6 - len(numbers)
            selected = random.sample(available_numbers, remaining_count)
            numbers.extend(selected)
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None
        }
```

---

#### Algorithm 6: 빈도 기반

**파일**: `backend/app/algorithms/algorithm_06_frequency.py`

```python
"""
Algorithm 6: 빈도 기반 (Frequency Analysis)

과거 출현 빈도가 높은 번호 우선 선택

2026-01-05 EST - 초기 생성
"""

import random
from typing import List, Dict, Optional, Any
from collections import Counter

import pandas as pd
import numpy as np

from app.algorithms.base import LottoAlgorithm


class FrequencyAlgorithm(LottoAlgorithm):
    """
    빈도 기반 알고리즘
    
    과거 데이터에서 가장 많이 나온 번호를 높은 확률로 선택
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=6,
            name="빈도 기반 (Frequency)",
            description="과거 출현 빈도가 높은 번호를 우선적으로 선택합니다.",
            cost_per_set=1
        )
    
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        빈도 기반 번호 생성
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            **kwargs:
                - recent_draws: 최근 N회차만 사용 (기본: 전체)
                - temperature: 확률 온도 파라미터 (기본: 1.0)
            
        Returns:
            List[List[int]]: 번호 세트
        """
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        # 최근 N회차만 사용
        recent_draws = kwargs.get('recent_draws', len(historical_data))
        df = historical_data.tail(recent_draws)
        
        # 빈도 계산
        frequency = self._calculate_frequency(df)
        
        # 제외 번호 필터링
        if exclude_numbers:
            frequency = {k: v for k, v in frequency.items() if k not in exclude_numbers}
        
        # 포함 번호 제거 (이미 선택됨)
        if include_numbers:
            frequency = {k: v for k, v in frequency.items() if k not in include_numbers}
        
        # 확률 분포 생성
        temperature = kwargs.get('temperature', 1.0)
        probs = self._create_probability_distribution(frequency, temperature)
        
        results = []
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 확률적 선택
            remaining_count = 6 - len(numbers)
            available_nums = list(frequency.keys())
            available_probs = [probs[num] for num in available_nums]
            
            selected = np.random.choice(
                available_nums,
                size=remaining_count,
                replace=False,
                p=available_probs
            )
            numbers.extend(selected.tolist())
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def _calculate_frequency(self, df: pd.DataFrame) -> Dict[int, int]:
        """번호별 출현 빈도 계산"""
        all_numbers = []
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                all_numbers.append(row[f'번호{i}'])
        
        frequency = Counter(all_numbers)
        
        # 1~45 모든 번호 포함 (빈도 0인 번호도)
        for num in range(1, 46):
            if num not in frequency:
                frequency[num] = 0
        
        return dict(frequency)
    
    def _create_probability_distribution(
        self,
        frequency: Dict[int, int],
        temperature: float = 1.0
    ) -> Dict[int, float]:
        """빈도를 확률 분포로 변환"""
        # 빈도를 배열로 변환
        numbers = list(frequency.keys())
        counts = np.array([frequency[num] for num in numbers])
        
        # Temperature 적용 (낮을수록 상위 번호 집중)
        if temperature != 1.0:
            counts = counts ** (1.0 / temperature)
        
        # 확률 정규화
        probs = counts / counts.sum()
        
        return {num: prob for num, prob in zip(numbers, probs)}
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None,
            'recent_draws': 100,
            'temperature': 1.0
        }
```

---

#### Algorithm 7: 핫/콜드 넘버

**파일**: `backend/app/algorithms/algorithm_07_hot_cold.py`

```python
"""
Algorithm 7: 핫/콜드 넘버 (Hot & Cold Numbers)

최근 자주 나온 번호(Hot)와 오랫동안 안 나온 번호(Cold) 혼합

2026-01-05 EST - 초기 생성
"""

import random
from typing import List, Dict, Optional, Any
from collections import Counter

import pandas as pd

from app.algorithms.base import LottoAlgorithm


class HotColdAlgorithm(LottoAlgorithm):
    """
    핫/콜드 넘버 알고리즘
    
    최근 N회차에서 자주 나온 번호(Hot)와
    오랫동안 나오지 않은 번호(Cold)를 혼합 선택
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=7,
            name="핫/콜드 넘버 (Hot & Cold)",
            description="최근 자주 나온 번호(Hot)와 오래 안 나온 번호(Cold)를 혼합합니다.",
            cost_per_set=1
        )
    
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        핫/콜드 번호 생성
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            **kwargs:
                - hot_window: Hot 판단 기준 회차 (기본: 20)
                - cold_window: Cold 판단 기준 회차 (기본: 50)
                - hot_count: Hot 번호 개수 (기본: 3)
                - cold_count: Cold 번호 개수 (기본: 2)
            
        Returns:
            List[List[int]]: 번호 세트
        """
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        # 파라미터 추출
        hot_window = kwargs.get('hot_window', 20)
        cold_window = kwargs.get('cold_window', 50)
        hot_count = kwargs.get('hot_count', 3)
        cold_count = kwargs.get('cold_count', 2)
        
        # Hot/Cold 번호 계산
        hot_numbers = self._get_hot_numbers(
            historical_data.tail(hot_window),
            exclude_numbers,
            include_numbers
        )
        cold_numbers = self._get_cold_numbers(
            historical_data.tail(cold_window),
            exclude_numbers,
            include_numbers
        )
        
        results = []
        available = self.get_available_numbers(exclude_numbers, include_numbers)
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # Hot 번호 선택
            hot_pick_count = min(hot_count, 6 - len(numbers))
            if hot_pick_count > 0 and hot_numbers:
                hot_selected = random.sample(hot_numbers, min(hot_pick_count, len(hot_numbers)))
                numbers.extend(hot_selected)
            
            # Cold 번호 선택
            cold_pick_count = min(cold_count, 6 - len(numbers))
            if cold_pick_count > 0 and cold_numbers:
                cold_candidates = [n for n in cold_numbers if n not in numbers]
                cold_selected = random.sample(cold_candidates, min(cold_pick_count, len(cold_candidates)))
                numbers.extend(cold_selected)
            
            # 나머지 랜덤 선택
            remaining_count = 6 - len(numbers)
            if remaining_count > 0:
                remaining_pool = [n for n in available if n not in numbers]
                random_selected = random.sample(remaining_pool, remaining_count)
                numbers.extend(random_selected)
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def _get_hot_numbers(
        self,
        df: pd.DataFrame,
        exclude: Optional[List[int]],
        include: Optional[List[int]]
    ) -> List[int]:
        """Hot 번호 추출 (최근 자주 나온 번호)"""
        all_numbers = []
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                all_numbers.append(row[f'번호{i}'])
        
        frequency = Counter(all_numbers)
        
        # 제외/포함 필터링
        if exclude:
            frequency = {k: v for k, v in frequency.items() if k not in exclude}
        if include:
            frequency = {k: v for k, v in frequency.items() if k not in include}
        
        # 상위 10개 반환
        hot = [num for num, count in frequency.most_common(10)]
        return hot
    
    def _get_cold_numbers(
        self,
        df: pd.DataFrame,
        exclude: Optional[List[int]],
        include: Optional[List[int]]
    ) -> List[int]:
        """Cold 번호 추출 (오래 안 나온 번호)"""
        all_numbers = []
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                all_numbers.append(row[f'번호{i}'])
        
        appeared = set(all_numbers)
        all_nums = set(range(1, 46))
        
        # 제외/포함 필터링
        if exclude:
            all_nums -= set(exclude)
        if include:
            all_nums -= set(include)
        
        # 나오지 않은 번호 또는 빈도가 낮은 번호
        frequency = Counter(all_numbers)
        cold = sorted(all_nums, key=lambda x: frequency.get(x, 0))
        
        # 하위 10개 반환
        return cold[:10]
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None,
            'hot_window': 20,
            'cold_window': 50,
            'hot_count': 3,
            'cold_count': 2
        }
```

---

### 작업 2.2.2: 고급 알고리즘 (8시간)

알고리즘 3 (앙상블), 4 (패턴), 5 (가중치)는 유사한 패턴으로 구현됩니다.
기본 구조만 제시하고, 실제 구현 시 상세 로직을 추가합니다.

**참고**: Phase 1-2 문서가 매우 길어지고 있어, 나머지 알고리즘은 구현 시 참고할 수 있도록 요약 형태로 작성하겠습니다.

### 완료 기준 체크리스트
- [ ] Algorithm 1 (랜덤) 구현 및 테스트
- [ ] Algorithm 6 (빈도) 구현 및 테스트
- [ ] Algorithm 7 (핫콜드) 구현 및 테스트
- [ ] Algorithm 3, 4, 5 구현 (Phase 2.2.2)

---

## 작업 2.3-2.7 요약

나머지 작업들은 다음과 같이 진행됩니다:

### 2.3: 알고리즘 로더 (2시간)
- Factory Pattern으로 알고리즘 동적 로딩
- `__init__.py`에서 `load_all_algorithms()` 함수 구현

### 2.4: Pydantic 스키마 (3시간)
- `GenerateRequest`, `GenerateResponse` 정의
- `DrawInfo`, `AlgorithmInfo` 스키마

### 2.5: FastAPI 초기화 (2시간)
- `main.py` 작성
- `startup_event`에서 데이터 매니저, 알고리즘 로드

### 2.6: API 엔드포인트 (6-8시간)
- `POST /api/generate` - 번호 생성
- `GET /api/draws/latest` - 최신 회차
- `GET /api/algorithms` - 알고리즘 목록

### 2.7: 통합 테스트 (2-4시간)
- Swagger UI에서 모든 API 테스트
- pytest로 단위 테스트 작성

---

## 🧪 Phase 2 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `backend/tests/test_phase2_algorithms.py`

```python
"""
Phase 2 알고리즘 & API 자동 테스트

2026-01-08 EST - 초기 생성
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.algorithms import get_algorithm, load_all_algorithms


client = TestClient(app)


def test_algorithm_loading():
    """알고리즘 로드 테스트"""
    algorithms = load_all_algorithms()
    
    assert len(algorithms) >= 6  # 최소 6개 알고리즘
    assert 1 in algorithms  # Random
    assert 2 in algorithms  # Frequency
    assert 3 in algorithms  # Hot/Cold


def test_random_algorithm():
    """랜덤 알고리즘 테스트"""
    algo = get_algorithm(1)
    
    assert algo.algorithm_id == 1
    assert algo.name == "순수 랜덤"
    
    # 번호 생성
    results = algo.generate_numbers(historical_data=None, n_sets=5)
    
    assert len(results) == 5
    for numbers in results:
        assert len(numbers) == 6
        assert all(1 <= n <= 45 for n in numbers)
        assert len(set(numbers)) == 6  # 중복 없음


def test_api_health():
    """API 헬스 체크"""
    response = client.get("/health")
    assert response.status_code == 200


def test_api_algorithms_list():
    """/api/algorithms 엔드포인트 테스트"""
    response = client.get("/api/algorithms")
    
    assert response.status_code == 200
    data = response.json()
    
    assert isinstance(data, list)
    assert len(data) >= 6
    
    # 첫 번째 알고리즘 검증
    algo = data[0]
    assert 'algorithm_id' in algo
    assert 'name' in algo
    assert 'description' in algo


def test_api_generate_numbers():
    """/api/generate 엔드포인트 테스트"""
    payload = {
        "algorithm_id": 1,
        "n_sets": 3
    }
    
    response = client.post("/api/generate", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    
    assert 'algorithm_id' in data
    assert 'algorithm_name' in data
    assert 'results' in data
    assert len(data['results']) == 3
    
    # 번호 검증
    for result in data['results']:
        assert len(result['numbers']) == 6
        assert all(1 <= n <= 45 for n in result['numbers'])


def test_api_latest_draw():
    """/api/draws/latest 엔드포인트 테스트"""
    response = client.get("/api/draws/latest")
    
    # 데이터가 있을 경우
    if response.status_code == 200:
        data = response.json()
        assert 'draw_no' in data
        assert 'numbers' in data
        assert len(data['numbers']) == 6
    # 데이터가 없을 경우 (404)
    elif response.status_code == 404:
        pass
    else:
        pytest.fail(f"Unexpected status code: {response.status_code}")


def test_api_draw_by_number():
    """/api/draws/{draw_no} 엔드포인트 테스트"""
    # 1회 조회 (확실히 존재)
    response = client.get("/api/draws/1")
    
    if response.status_code == 200:
        data = response.json()
        assert data['draw_no'] == 1
        assert len(data['numbers']) == 6


def test_api_validation():
    """API 입력 검증 테스트"""
    # 잘못된 algorithm_id
    response = client.post("/api/generate", json={"algorithm_id": 999, "n_sets": 1})
    assert response.status_code in [400, 404]
    
    # 잘못된 n_sets (음수)
    response = client.post("/api/generate", json={"algorithm_id": 1, "n_sets": -1})
    assert response.status_code == 422


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
```

**실행 방법**:
```bash
cd backend
pytest tests/test_phase2_algorithms.py -v
```

---

### 자동 테스트 체크리스트

**실행 명령**: `pytest tests/test_phase2_algorithms.py -v`

- [ ] ✅ `test_algorithm_loading` - 알고리즘 로드
- [ ] ✅ `test_random_algorithm` - 랜덤 알고리즘
- [ ] ✅ `test_api_health` - 헬스 체크
- [ ] ✅ `test_api_algorithms_list` - 알고리즘 목록
- [ ] ✅ `test_api_generate_numbers` - 번호 생성
- [ ] ✅ `test_api_latest_draw` - 최신 회차
- [ ] ✅ `test_api_draw_by_number` - 특정 회차
- [ ] ✅ `test_api_validation` - 입력 검증

**예상 결과**: 8 passed

---

### 수동 테스트 체크리스트

#### 1. FastAPI 서버 실행
```bash
cd backend
uvicorn app.main:app --reload
```
**확인 사항**:
- [ ] 서버 시작 성공 (http://127.0.0.1:8000)
- [ ] "Application startup complete" 메시지
- [ ] 오류 없음

#### 2. Swagger UI 접속
**URL**: http://127.0.0.1:8000/docs

**확인 사항**:
- [ ] Swagger UI 로드 성공
- [ ] 모든 엔드포인트 표시:
  - [ ] GET /health
  - [ ] GET /api/algorithms
  - [ ] POST /api/generate
  - [ ] GET /api/draws/latest
  - [ ] GET /api/draws/{draw_no}

#### 3. /api/algorithms 수동 테스트
**Swagger에서**:
1. `/api/algorithms` 펼치기
2. "Try it out" 클릭
3. "Execute" 클릭

**확인 사항**:
- [ ] 200 응답
- [ ] 6개 이상 알고리즘 반환
- [ ] 각 알고리즘에 id, name, description 포함

#### 4. /api/generate 수동 테스트
**Swagger에서**:
1. `/api/generate` 펼치기
2. "Try it out" 클릭
3. Request body:
```json
{
  "algorithm_id": 1,
  "n_sets": 5
}
```
4. "Execute" 클릭

**확인 사항**:
- [ ] 200 응답
- [ ] 5개 세트 반환
- [ ] 각 세트는 6개 번호 (1-45)
- [ ] 번호 중복 없음

#### 5. 다양한 알고리즘 테스트
**각 알고리즘 ID로 테스트**:
- [ ] ID 1: 순수 랜덤
- [ ] ID 2: 빈도 기반
- [ ] ID 3: 핫/콜드
- [ ] ID 4: 앙상블
- [ ] ID 5: 패턴 분석
- [ ] ID 6: 가중치

#### 6. curl 명령으로 API 테스트
```bash
# 알고리즘 목록
curl http://localhost:8000/api/algorithms

# 번호 생성
curl -X POST http://localhost:8000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"algorithm_id": 1, "n_sets": 3}'

# 최신 회차
curl http://localhost:8000/api/draws/latest

# 특정 회차
curl http://localhost:8000/api/draws/1
```

**확인 사항**:
- [ ] 모든 요청 성공
- [ ] JSON 응답 정상

#### 7. 에러 처리 테스트
**잘못된 요청 테스트**:
```bash
# 잘못된 algorithm_id
curl -X POST http://localhost:8000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"algorithm_id": 999, "n_sets": 1}'

# 음수 n_sets
curl -X POST http://localhost:8000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"algorithm_id": 1, "n_sets": -1}'
```

**확인 사항**:
- [ ] 적절한 에러 응답 (400/422/404)
- [ ] 에러 메시지 포함

#### 8. 로그 확인
```bash
cd backend/results/logs
tail -f api.log
```

**확인 사항**:
- [ ] API 요청 로그 기록
- [ ] 에러 로그 없음 (또는 예상된 에러만)

---

### Phase 2 통합 테스트 스크립트

**파일**: `scripts/test_phase2.ps1`

```powershell
# Phase 2 통합 테스트 스크립트

Write-Host "=== Phase 2 통합 테스트 시작 ===" -ForegroundColor Cyan

# 1. 자동 테스트 실행
Write-Host "`n[1] 자동 테스트 실행..." -ForegroundColor Yellow
cd backend
pytest tests/test_phase2_algorithms.py -v
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 자동 테스트 실패" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ 자동 테스트 통과" -ForegroundColor Green
cd ..

# 2. FastAPI 서버 시작 (백그라운드)
Write-Host "`n[2] FastAPI 서버 시작..." -ForegroundColor Yellow
cd backend
Start-Process -NoNewWindow pwsh -ArgumentList "-Command", "uvicorn app.main:app --host 127.0.0.1 --port 8000" -PassThru
Start-Sleep -Seconds 3

# 3. API 헬스 체크
Write-Host "`n[3] API 헬스 체크..." -ForegroundColor Yellow
$health = curl -s http://localhost:8000/health
if ($?) {
    Write-Host "  ✓ API 서버 응답 정상" -ForegroundColor Green
} else {
    Write-Host "  ✗ API 서버 응답 없음" -ForegroundColor Red
    exit 1
}

# 4. 알고리즘 목록 조회
Write-Host "`n[4] 알고리즘 목록 조회..." -ForegroundColor Yellow
$algos = curl -s http://localhost:8000/api/algorithms | ConvertFrom-Json
if ($algos.Count -ge 6) {
    Write-Host "  ✓ 알고리즘 $($algos.Count)개 로드됨" -ForegroundColor Green
} else {
    Write-Host "  ✗ 알고리즘 부족: $($algos.Count)개" -ForegroundColor Red
}

# 5. 번호 생성 테스트
Write-Host "`n[5] 번호 생성 테스트..." -ForegroundColor Yellow
$body = @{algorithm_id=1; n_sets=3} | ConvertTo-Json
$result = curl -s -X POST http://localhost:8000/api/generate -H "Content-Type: application/json" -d $body | ConvertFrom-Json
if ($result.results.Count -eq 3) {
    Write-Host "  ✓ 번호 생성 성공: $($result.results.Count)개 세트" -ForegroundColor Green
} else {
    Write-Host "  ✗ 번호 생성 실패" -ForegroundColor Red
}

# 6. 서버 종료
Write-Host "`n[6] 테스트 완료, 서버 종료..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -eq "uvicorn"} | Stop-Process -Force
Write-Host "  ✓ 서버 종료 완료" -ForegroundColor Green

Write-Host "`n=== Phase 2 테스트 완료! ===" -ForegroundColor Cyan
Write-Host "Phase 3로 진행 가능합니다." -ForegroundColor Green

cd ..
```

**실행**:
```powershell
.\scripts\test_phase2.ps1
```

---

**Phase 2 완료**

다음: [Phase 3 Part 1 - Flutter 앱 기초](011_Phase_3_Flutter_App_Part1.md)

