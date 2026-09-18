"""
백테스트 스키마

2026-02-14 EST - 036 설계안 구현
"""

from typing import Dict, List, Optional, Any

from pydantic import BaseModel, Field, model_validator


class BacktestRunRequest(BaseModel):
    """POST /api/admin/backtest/run 요청 (036 §5.2)"""
    algorithm_id: int = Field(..., description="알고리즘 ID")
    start_draw: int = Field(..., ge=1, description="시작 회차")
    end_draw: int = Field(..., ge=1, description="종료 회차")
    n_sets: int = Field(5, ge=1, le=20, description="회차당 세트 수")
    enable_detailed_log: bool = Field(False, description="상세 로그 포함")
    enable_cumulative_series: bool = Field(True, description="회차별 누적 당첨률 시계열 포함")
    algorithm_params: Optional[Dict[str, Any]] = Field(None, description="알고리즘 파라미터")
    exclude_numbers: Optional[List[int]] = Field(None, description="제외 번호")
    include_numbers: Optional[List[int]] = Field(None, description="포함 번호")

    @model_validator(mode="after")
    def check_draw_range(self):
        if self.start_draw > self.end_draw:
            raise ValueError("start_draw must be <= end_draw")
        return self


class BacktestRunGridRequest(BaseModel):
    """POST /api/admin/backtest/run-grid 요청 (036 §5.6)"""
    algorithm_id: int = Field(..., description="알고리즘 ID")
    start_draw: int = Field(..., ge=1, description="시작 회차")
    end_draw: int = Field(..., ge=1, description="종료 회차")
    n_sets: int = Field(5, ge=1, le=20, description="회차당 세트 수")
    grid: Dict[str, List[Any]] = Field(..., description="그리드 파라미터 {param: [values]}")
    max_combinations: int = Field(300, ge=1, le=300, description="조합 수 상한")
    enable_detailed_log: bool = Field(False, description="상세 로그 포함")
    enable_cumulative_series: bool = Field(True, description="회차별 누적 당첨률 시계열 포함")
    exclude_numbers: Optional[List[int]] = Field(None, description="제외 번호")
    include_numbers: Optional[List[int]] = Field(None, description="포함 번호")

    @model_validator(mode="after")
    def check_draw_range(self):
        if self.start_draw > self.end_draw:
            raise ValueError("start_draw must be <= end_draw")
        return self

