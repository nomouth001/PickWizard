"""
내 번호 관리 API 라우터

2026-01-16 04:25:00 EST - 초기 생성
"""

from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.db.session import get_db
from app.db.models.user_numbers import UserSavedNumber, WinningCheckResult
from app.db.models.lotto_draw import LottoDraw
from app.schemas.my_numbers import (
    SaveNumberRequest,
    SaveNumberResponse,
    UserNumberResponse,
    CheckWinningRequest,
    CheckWinningResponse,
    WinningCheckDetail,
    MyNumbersListResponse,
)
from app.services.winning_check_service import winning_check_service

router = APIRouter(prefix="/my-numbers", tags=["My Numbers"])


@router.post("/save", response_model=SaveNumberResponse, status_code=status.HTTP_201_CREATED)
async def save_number(
    request: SaveNumberRequest,
    db: Session = Depends(get_db)
):
    """
    번호 저장
    """
    # 번호를 JSON으로 변환
    numbers_json = winning_check_service.numbers_to_json(request.numbers)
    
    # 새 번호 생성
    new_number = UserSavedNumber(
        user_id=request.user_id,
        numbers=numbers_json,
        algorithm_id=request.algorithm_id,
        algorithm_name=request.algorithm_name,
        memo=request.memo
    )
    
    db.add(new_number)
    db.commit()
    db.refresh(new_number)
    
    return SaveNumberResponse(
        id=new_number.id,
        user_id=new_number.user_id,
        numbers=request.numbers,
        algorithm_id=new_number.algorithm_id,
        algorithm_name=new_number.algorithm_name,
        memo=new_number.memo,
        created_at=new_number.created_at
    )


@router.get("/list", response_model=MyNumbersListResponse)
async def get_my_numbers(
    user_id: str,
    limit: int = Query(default=20, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db)
):
    """
    내 번호 목록 조회
    """
    try:
        user_uuid = UUID(user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="잘못된 사용자 ID 형식입니다"
        )
    
    # 총 개수
    total = db.query(UserSavedNumber).filter(
        UserSavedNumber.user_id == user_uuid
    ).count()
    
    # 번호 목록 조회 (최신순)
    saved_numbers = db.query(UserSavedNumber).filter(
        UserSavedNumber.user_id == user_uuid
    ).order_by(
        desc(UserSavedNumber.created_at)
    ).offset(offset).limit(limit).all()
    
    # 응답 생성
    numbers = []
    for sn in saved_numbers:
        numbers.append(UserNumberResponse(
            id=sn.id,
            user_id=sn.user_id,
            numbers=winning_check_service.json_to_numbers(sn.numbers),
            algorithm_id=sn.algorithm_id,
            algorithm_name=sn.algorithm_name,
            memo=sn.memo,
            is_checked=sn.is_checked,
            checked_draw_no=sn.checked_draw_no,
            winning_rank=sn.winning_rank,
            matched_count=sn.matched_count,
            created_at=sn.created_at
        ))
    
    return MyNumbersListResponse(
        total=total,
        numbers=numbers
    )


@router.delete("/{number_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_number(
    number_id: int,
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    번호 삭제
    """
    try:
        user_uuid = UUID(user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="잘못된 사용자 ID 형식입니다"
        )
    
    # 번호 조회
    saved_number = db.query(UserSavedNumber).filter(
        UserSavedNumber.id == number_id,
        UserSavedNumber.user_id == user_uuid
    ).first()
    
    if not saved_number:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="번호를 찾을 수 없습니다"
        )
    
    # 삭제
    db.delete(saved_number)
    db.commit()


@router.post("/check-winning", response_model=CheckWinningResponse)
async def check_winning(
    request: CheckWinningRequest,
    db: Session = Depends(get_db)
):
    """
    당첨 확인
    
    해당 회차의 당첨 번호와 사용자가 저장한 모든 번호를 비교하여 당첨 여부를 확인
    """
    # 1. 당첨 번호 조회
    draw = db.query(LottoDraw).filter(
        LottoDraw.draw_no == request.draw_no
    ).first()
    
    if not draw:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"회차 {request.draw_no}를 찾을 수 없습니다"
        )
    
    # 당첨 번호 추출
    winning_numbers = draw.get_numbers()  # [num1, num2, num3, num4, num5, num6]
    bonus_number = draw.bonus
    
    # 2. 사용자의 미확인 번호 조회
    user_numbers = db.query(UserSavedNumber).filter(
        UserSavedNumber.user_id == request.user_id,
        UserSavedNumber.is_checked == False
    ).all()
    
    if not user_numbers:
        return CheckWinningResponse(
            draw_no=request.draw_no,
            winning_numbers=winning_numbers,
            bonus_number=bonus_number,
            total_checked=0,
            results=[]
        )
    
    # 3. 각 번호 확인
    results = []
    
    for user_number in user_numbers:
        numbers = winning_check_service.json_to_numbers(user_number.numbers)
        
        # 당첨 판정
        rank, matched_count, has_bonus = winning_check_service.judge_rank(
            numbers, winning_numbers, bonus_number
        )
        
        # 결과 저장
        user_number.is_checked = True
        user_number.checked_draw_no = request.draw_no
        user_number.winning_rank = rank
        user_number.matched_count = matched_count
        
        # 당첨 확인 결과 기록 생성
        check_result = WinningCheckResult(
            user_id=request.user_id,
            user_number_id=user_number.id,
            draw_no=request.draw_no,
            winning_numbers=winning_check_service.numbers_to_json(winning_numbers),
            bonus_number=bonus_number,
            matched_count=matched_count,
            has_bonus=has_bonus,
            winning_rank=rank
        )
        
        db.add(check_result)
        
        # 응답에 추가
        results.append(WinningCheckDetail(
            number_id=user_number.id,
            numbers=numbers,
            memo=user_number.memo,
            matched_count=matched_count,
            has_bonus=has_bonus,
            winning_rank=rank
        ))
    
    db.commit()
    
    return CheckWinningResponse(
        draw_no=request.draw_no,
        winning_numbers=winning_numbers,
        bonus_number=bonus_number,
        total_checked=len(results),
        results=results
    )
