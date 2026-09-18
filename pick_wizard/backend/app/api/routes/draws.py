"""
회차 정보 API 라우터

2026-01-04 EST - 초기 생성
"""

from typing import Optional

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.db.models.lotto_draw import LottoDraw
from app.schemas import DrawInfo, DrawListResponse


router = APIRouter()


@router.get("/latest", response_model=DrawInfo)
async def get_latest_draw():
    """최신 회차 정보 조회"""
    db: Session = next(get_db())
    
    try:
        draw = db.query(LottoDraw).order_by(LottoDraw.draw_no.desc()).first()
        
        if not draw:
            raise HTTPException(status_code=404, detail="회차 데이터가 없습니다")
        
        return DrawInfo(
            draw_no=draw.draw_no,
            draw_date=draw.draw_date,
            numbers=[draw.num1, draw.num2, draw.num3, draw.num4, draw.num5, draw.num6],
            bonus=draw.bonus,
            first_prize_amount=draw.first_prize_amount,
            first_winner_count=draw.first_winner_count,
            created_at=draw.created_at
        )
    finally:
        db.close()


@router.get("/{draw_no}", response_model=DrawInfo)
async def get_draw_by_number(draw_no: int):
    """특정 회차 정보 조회"""
    db: Session = next(get_db())
    
    try:
        draw = db.query(LottoDraw).filter_by(draw_no=draw_no).first()
        
        if not draw:
            raise HTTPException(status_code=404, detail=f"{draw_no}회 데이터를 찾을 수 없습니다")
        
        return DrawInfo(
            draw_no=draw.draw_no,
            draw_date=draw.draw_date,
            numbers=[draw.num1, draw.num2, draw.num3, draw.num4, draw.num5, draw.num6],
            bonus=draw.bonus,
            first_prize_amount=draw.first_prize_amount,
            first_winner_count=draw.first_winner_count,
            created_at=draw.created_at
        )
    finally:
        db.close()


@router.get("/", response_model=DrawListResponse)
async def get_draws(
    skip: int = Query(0, ge=0, description="건너뛸 개수"),
    limit: int = Query(20, ge=1, le=100, description="가져올 개수 (최대 100)")
):
    """
    회차 목록 조회
    
    최신 회차부터 역순으로 반환
    """
    db: Session = next(get_db())
    
    try:
        # 전체 개수
        total = db.query(LottoDraw).count()
        
        # 페이징
        draws = db.query(LottoDraw)\
            .order_by(LottoDraw.draw_no.desc())\
            .offset(skip)\
            .limit(limit)\
            .all()
        
        draw_list = [
            DrawInfo(
                draw_no=d.draw_no,
                draw_date=d.draw_date,
                numbers=[d.num1, d.num2, d.num3, d.num4, d.num5, d.num6],
                bonus=d.bonus,
                first_prize_amount=d.first_prize_amount,
                first_winner_count=d.first_winner_count,
                created_at=d.created_at
            )
            for d in draws
        ]
        
        return DrawListResponse(total=total, draws=draw_list)
    finally:
        db.close()

