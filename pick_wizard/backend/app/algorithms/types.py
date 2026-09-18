"""
알고리즘 타입 정의

2026-01-08 06:45:00 EST - 초기 생성
"""

from typing import TypeAlias, List, Dict, Optional, Literal, Any
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

