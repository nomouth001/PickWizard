"""
알고리즘 관련 Pydantic 스키마

2026-01-04 EST - 초기 생성
"""

from typing import Dict, Any, List
from pydantic import BaseModel, Field


class AlgorithmInfo(BaseModel):
    """알고리즘 정보"""
    id: int = Field(..., description="알고리즘 ID")
    name: str = Field(..., description="알고리즘 이름")
    description: str = Field(..., description="설명")
    version: str = Field(..., description="버전")
    cost_per_set: int = Field(..., description="세트당 코인 비용")
    parameters: Dict[str, Any] = Field(..., description="기본 파라미터")
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": 1,
                "name": "순수 랜덤",
                "description": "1~45 중 6개를 완전 무작위로 선택합니다.",
                "version": "1.0",
                "cost_per_set": 0,
                "parameters": {
                    "n_sets": 5,
                    "exclude_numbers": None,
                    "include_numbers": None
                }
            }
        }


class AlgorithmListResponse(BaseModel):
    """알고리즘 목록 응답"""
    total: int = Field(..., description="전체 알고리즘 수")
    algorithms: List[AlgorithmInfo] = Field(..., description="알고리즘 목록")
    
    class Config:
        json_schema_extra = {
            "example": {
                "total": 3,
                "algorithms": [
                    {
                        "id": 1,
                        "name": "순수 랜덤",
                        "description": "완전 무작위 선택",
                        "version": "1.0",
                        "cost_per_set": 0
                    }
                ]
            }
        }

