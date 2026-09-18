"""
알고리즘 정보 API 라우터

2026-01-04 EST - 초기 생성
2026-01-08 03:36:00 EST - Pricing Service 통합
"""

from fastapi import APIRouter, HTTPException

from app.algorithms import get_algorithm, get_algorithm_list
from app.schemas import AlgorithmInfo, AlgorithmListResponse
from app.services.pricing_service import get_pricing_service


router = APIRouter()


@router.get("/", response_model=AlgorithmListResponse)
async def list_algorithms():
    """
    모든 알고리즘 목록 조회
    
    사용 가능한 모든 알고리즘의 정보를 반환합니다.
    가격은 pricing_config.yaml에서 동적으로 로드됩니다.
    """
    algorithms = get_algorithm_list()
    
    # 2026-01-08 03:36:00 EST - Pricing Service로 가격 업데이트
    pricing_service = get_pricing_service()
    
    for algo in algorithms:
        # 설정 파일의 가격으로 덮어쓰기
        algo_id = algo.get('id')
        current_cost = pricing_service.get_algorithm_cost(algo_id)
        algo['cost_per_set'] = current_cost
    
    return AlgorithmListResponse(
        total=len(algorithms),
        algorithms=algorithms
    )


@router.get("/{algorithm_id}", response_model=AlgorithmInfo)
async def get_algorithm_info(algorithm_id: int):
    """
    특정 알고리즘 정보 조회
    
    알고리즘 ID로 상세 정보를 조회합니다.
    가격은 pricing_config.yaml에서 동적으로 로드됩니다.
    
    2026-01-18 20:30:00 EST - AI Selection(8번) 알고리즘에 window_size 필드 추가
    """
    algorithm = get_algorithm(algorithm_id)
    
    if not algorithm:
        raise HTTPException(
            status_code=404,
            detail=f"알고리즘 {algorithm_id}를 찾을 수 없습니다"
        )
    
    # 2026-01-08 03:37:00 EST - Pricing Service로 가격 업데이트
    info = algorithm.get_info()
    pricing_service = get_pricing_service()
    info['cost_per_set'] = pricing_service.get_algorithm_cost(algorithm_id)
    
    # 2026-01-18 20:30:00 EST - AI Selection(8번) 알고리즘에 window_size 추가
    if algorithm_id == 8:
        from app.config import settings
        info['window_size'] = settings.AI_SELECTION_WINDOW_SIZE
    
    return info

