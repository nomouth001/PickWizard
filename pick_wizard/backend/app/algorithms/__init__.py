"""
알고리즘 로더 및 Factory

모든 알고리즘을 동적으로 로드하고 관리

2026-01-04 EST - 초기 생성
2026-01-08 03:25:00 EST - Algorithm 3, 4, 5 추가
2026-01-08 04:00:00 EST - 알고리즘 2, 3, 4 재설계 버전 추가
2026-01-08 06:00:00 EST - 레거시 주석 업데이트
2026-01-18 EST - 알고리즘 8 (AI Selection) 추가
"""

from typing import Dict, Optional
from loguru import logger

from app.algorithms.base import LottoAlgorithm
from app.algorithms.algorithm_01_random import RandomAlgorithm
from app.algorithms.algorithm_02_advanced_frequency import AdvancedFrequencyAlgorithm
from app.algorithms.algorithm_03_advanced_lstm import AdvancedLSTMAlgorithm
from app.algorithms.algorithm_04_advanced_pattern import AdvancedPatternAlgorithm
from app.algorithms.algorithm_05_weighted import WeightedAlgorithm
from app.algorithms.algorithm_06_frequency import FrequencyAlgorithm
from app.algorithms.algorithm_07_hot_cold import HotColdAlgorithm
from app.algorithms.algorithm_08_ai_selection import AISelectionAlgorithm
from app.algorithms.algorithm_09_monte_carlo_top6 import MonteCarloTop6Algorithm

# 038: 메뉴 표시 순서 (자동선택 아래, 출현번호 빈도 기반 선택 위)
ALGORITHM_DISPLAY_ORDER = [1, 9, 2, 3, 4, 5, 6, 7, 8]

# 레거시 알고리즘 (2026-01-08 재설계로 대체, z_Past_codes/Trial_Legacy/ 이동)
# - algorithm_03_ensemble.py → algorithm_03_advanced_lstm.py로 대체 (ID 3)
# - algorithm_04_pattern.py → algorithm_04_advanced_pattern.py로 대체 (ID 4)
# 복원 불가: ID 충돌로 인해 새 버전과 동시 사용 불가
# from app.algorithms.algorithm_03_ensemble import EnsembleAlgorithm
# from app.algorithms.algorithm_04_pattern import PatternAlgorithm


# 알고리즘 저장소
_algorithms: Dict[int, LottoAlgorithm] = {}


def load_all_algorithms() -> Dict[int, LottoAlgorithm]:
    """
    모든 알고리즘 인스턴스 생성 및 로드
    
    Returns:
        Dict[int, LottoAlgorithm]: 알고리즘 ID를 키로하는 딕셔너리
    """
    global _algorithms
    
    if _algorithms:
        return _algorithms
    
    # 알고리즘 인스턴스 생성
    # 2026-01-08 04:00:00 EST - 재설계 버전 알고리즘 추가
    # 2026-01-18 EST - 알고리즘 8 (AI Selection) 추가
    # 2026-02-15 - 038: 알고리즘 9 (몬테카를로 상위 6개) 추가
    algorithm_classes = [
        RandomAlgorithm,                  # 1: 순수 랜덤
        MonteCarloTop6Algorithm,          # 9: 몬테카를로 상위 6개 (표시 순서는 get_algorithm_list에서 적용)
        AdvancedFrequencyAlgorithm,       # 2: 고급 빈도 분석 (신규)
        AdvancedLSTMAlgorithm,            # 3: LSTM 고급 분석 (신규)
        AdvancedPatternAlgorithm,         # 4: 패턴 분석 (재설계)
        WeightedAlgorithm,                # 5: 가중치 기반
        FrequencyAlgorithm,               # 6: 기본 빈도 분석
        HotColdAlgorithm,                 # 7: Hot/Cold 분석
        AISelectionAlgorithm,             # 8: 인공지능 선택 (AI Selection)
    ]
    
    for AlgoClass in algorithm_classes:
        try:
            instance = AlgoClass()
            _algorithms[instance.algorithm_id] = instance
            logger.debug(f"알고리즘 로드: {instance.algorithm_id}. {instance.name}")
        except Exception as e:
            logger.error(f"알고리즘 로드 실패 ({AlgoClass.__name__}): {e}")
    
    logger.info(f"[INFO] 알고리즘 {len(_algorithms)}개 로드 완료")
    return _algorithms


def get_algorithm(algorithm_id: int) -> Optional[LottoAlgorithm]:
    """
    ID로 알고리즘 반환
    
    Args:
        algorithm_id: 알고리즘 ID
        
    Returns:
        LottoAlgorithm 인스턴스 또는 None
    """
    if not _algorithms:
        load_all_algorithms()
    
    return _algorithms.get(algorithm_id)


def get_algorithm_list() -> list:
    """
    모든 알고리즘의 정보 리스트 반환 (038: 표시 순서 적용)
    
    Returns:
        List[Dict]: 알고리즘 정보 딕셔너리 리스트
    """
    if not _algorithms:
        load_all_algorithms()

    # 038: 자동선택(1) 아래, 출현번호 빈도 기반(6) 위 → [1, 9, 2, 3, 4, 5, 6, 7, 8]
    order = [aid for aid in ALGORITHM_DISPLAY_ORDER if aid in _algorithms]
    return [_algorithms[aid].get_info() for aid in order]


__all__ = [
    "LottoAlgorithm",
    "load_all_algorithms",
    "get_algorithm",
    "get_algorithm_list",
]

