"""
가격 정책 관리 API (관리자용)

2026-01-08 03:39:00 EST - 초기 생성
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any

from app.services.pricing_service import get_pricing_service, reload_pricing_config


router = APIRouter()


class PricingPolicyResponse(BaseModel):
    """가격 정책 정보 응답"""
    name: str
    description: str
    algorithm_costs: Dict[int, int]
    version: str
    last_updated: str


class CostCalculationRequest(BaseModel):
    """비용 계산 요청"""
    algorithm_id: int
    n_sets: int
    user_subscription: str | None = None


class CostCalculationResponse(BaseModel):
    """비용 계산 응답"""
    base_cost: int
    discount_amount: int
    final_cost: int
    discount_reason: str | None
    breakdown: Dict[str, Any]


@router.get("/policy", response_model=PricingPolicyResponse)
async def get_current_policy():
    """
    현재 활성화된 가격 정책 조회
    
    현재 사용 중인 가격 정책의 상세 정보를 반환합니다.
    """
    pricing_service = get_pricing_service()
    policy_info = pricing_service.get_policy_info()
    
    return PricingPolicyResponse(**policy_info)


@router.get("/policies")
async def list_all_policies():
    """
    모든 가격 정책 목록 조회
    
    사용 가능한 모든 가격 정책의 목록을 반환합니다.
    """
    pricing_service = get_pricing_service()
    policies = pricing_service.get_all_policies()
    
    return {
        "total": len(policies),
        "policies": policies
    }


@router.post("/calculate", response_model=CostCalculationResponse)
async def calculate_cost(request: CostCalculationRequest):
    """
    비용 미리 계산 (시뮬레이션)
    
    실제 번호 생성 없이 비용만 계산합니다.
    할인, 이벤트 가격 등이 모두 적용된 최종 비용을 확인할 수 있습니다.
    """
    pricing_service = get_pricing_service()
    
    cost_info = pricing_service.calculate_total_cost(
        algorithm_id=request.algorithm_id,
        n_sets=request.n_sets,
        user_subscription=request.user_subscription
    )
    
    return CostCalculationResponse(**cost_info)


@router.post("/reload")
async def reload_config():
    """
    가격 설정 파일 재로드 (Hot-reload)
    
    pricing_config.yaml 파일을 수정한 후 이 API를 호출하면
    서버 재시작 없이 새로운 가격 정책이 적용됩니다.
    
    [WARNING] 관리자 전용 API (인증 필요 - Phase 4에서 구현)
    """
    try:
        reload_pricing_config()
        
        pricing_service = get_pricing_service()
        policy_info = pricing_service.get_policy_info()
        
        return {
            "status": "success",
            "message": "가격 설정이 재로드되었습니다",
            "current_policy": policy_info['name']
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"설정 재로드 실패: {str(e)}"
        )


@router.post("/switch-policy")
async def switch_policy(policy_name: str):
    """
    가격 정책 전환
    
    다른 가격 정책으로 전환합니다.
    예: standard → promotion_2026_01
    
    [WARNING] 관리자 전용 API (인증 필요 - Phase 4에서 구현)
    """
    pricing_service = get_pricing_service()
    
    success = pricing_service.switch_policy(policy_name)
    
    if not success:
        raise HTTPException(
            status_code=404,
            detail=f"정책 '{policy_name}'을 찾을 수 없습니다"
        )
    
    policy_info = pricing_service.get_policy_info()
    
    return {
        "status": "success",
        "message": f"정책이 '{policy_name}'(으)로 전환되었습니다",
        "current_policy": policy_info
    }

