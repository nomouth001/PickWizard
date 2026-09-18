"""
번호 생성 API 라우터

2026-01-04 EST - 초기 생성
2026-01-08 03:35:00 EST - Pricing Service 통합
2026-01-08 08:20:00 EST - 코인 차감 로직 통합
"""

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from loguru import logger

from app.schemas import GenerateRequest, GenerateResponse, NumberSet
from app.algorithms import get_algorithm
from app.config import settings
from app.core.data_manager import data_manager
from app.services.pricing_service import get_pricing_service
from app.db.session import get_db
from app.db.models.coin_wallet import CoinWallet, CoinTransaction, CoinTransactionType


router = APIRouter()


@router.post("/", response_model=GenerateResponse)
async def generate_numbers(request: GenerateRequest, db: Session = Depends(get_db)):
    """
    로또 번호 생성 (코인 차감)
    
    **알고리즘 ID**:
    - 1: 순수 랜덤 (무료)
    - 2: 고급 빈도 분석 (2코인/세트)
    - 3: LSTM 고급 분석 (3코인/세트)
    - 4: 고급 패턴 (2코인/세트)
    - 5: 가중 조합 (3코인/세트)
    - 6: 기본 빈도 (1코인/세트)
    - 7: 핫/콜드 넘버 (1코인/세트)
    
    **파라미터**:
    - `user_id`: 사용자 ID (필수, 코인 차감용)
    - `algorithm_id`: 사용할 알고리즘 ID
    - `n_sets`: 생성할 세트 수 (1~100)
    - `exclude_numbers`: 제외할 번호 (최대 39개)
    - `include_numbers`: 반드시 포함할 번호 (최대 6개)
    """
    try:
        # 1. 알고리즘 가져오기
        algorithm = get_algorithm(request.algorithm_id)
        if not algorithm:
            raise HTTPException(status_code=404, detail=f"알고리즘 {request.algorithm_id}를 찾을 수 없습니다")
        
        # 2. 비용 계산
        pricing_service = get_pricing_service()
        cost_info = pricing_service.calculate_total_cost(
            algorithm_id=algorithm.algorithm_id,
            n_sets=request.n_sets,
            user_subscription=None
        )
        total_cost = cost_info['final_cost']
        
        # 3. 코인 차감 (043: COIN_WALLET_ENABLED일 때만, 무료가 아니고 user_id 있는 경우)
        if settings.COIN_WALLET_ENABLED and total_cost > 0 and request.user_id:
            wallet = db.query(CoinWallet).filter(CoinWallet.user_id == request.user_id).first()
            
            if not wallet:
                raise HTTPException(
                    status_code=404,
                    detail="코인 지갑을 찾을 수 없습니다"
                )
            
            if wallet.total_coins < total_cost:
                raise HTTPException(
                    status_code=402,
                    detail=f"코인이 부족합니다 (필요: {total_cost}, 보유: {wallet.total_coins})"
                )
            
            if not wallet.deduct_coins(total_cost):
                raise HTTPException(
                    status_code=500,
                    detail="코인 차감에 실패했습니다"
                )
            
            transaction = CoinTransaction(
                user_id=request.user_id,
                type=CoinTransactionType.NUMBER_GENERATION.value,
                amount=-total_cost,
                balance_after=wallet.total_coins,
                description=f"{algorithm.name} - {request.n_sets}세트 생성",
                extra_data=f'{{"algorithm_id": {algorithm.algorithm_id}, "n_sets": {request.n_sets}}}'
            )
            db.add(transaction)
            db.commit()
            db.refresh(wallet)
            logger.info(f"코인 차감: user_id={request.user_id}, cost={total_cost}, 잔액={wallet.total_coins}")
        elif not settings.COIN_WALLET_ENABLED:
            total_cost = 0  # 043: 비활성화 시 비용 0으로 응답
        
        # 4. 과거 데이터 로드
        historical_df = data_manager.get_dataframe()
        
        # 5. 번호 생성
        number_sets = algorithm.generate_numbers(
            historical_data=historical_df,
            n_sets=request.n_sets,
            exclude_numbers=request.exclude_numbers,
            include_numbers=request.include_numbers
        )
        
        # 6. 응답 생성
        results = [
            NumberSet(set_no=idx + 1, numbers=nums)
            for idx, nums in enumerate(number_sets)
        ]
        
        response = GenerateResponse(
            algorithm_id=algorithm.algorithm_id,
            algorithm_name=algorithm.name,
            results=results,
            cost=total_cost
        )
        
        logger.info(f"번호 생성 완료: 알고리즘 {algorithm.algorithm_id}, {len(results)}세트, 비용 {total_cost}코인")
        return response
        
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"번호 생성 오류: {e}")
        raise HTTPException(status_code=500, detail="번호 생성 중 오류가 발생했습니다")

