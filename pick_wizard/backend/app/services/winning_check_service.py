"""
당첨 확인 서비스

2026-01-16 04:15:00 EST - 초기 생성
"""

import json
from typing import Tuple, List
from app.db.models.user_numbers import WinningRank


class WinningCheckService:
    """당첨 확인 서비스"""
    
    @staticmethod
    def judge_rank(
        user_numbers: List[int],
        winning_numbers: List[int],
        bonus_number: int
    ) -> Tuple[str, int, bool]:
        """
        당첨 등수 판정
        
        Args:
            user_numbers: 사용자 번호 6개
            winning_numbers: 당첨 번호 6개
            bonus_number: 보너스 번호
            
        Returns:
            (등수, 맞은 개수, 보너스 포함 여부)
            
        당첨 규칙:
        - 1등: 6개 일치
        - 2등: 5개 일치 + 보너스
        - 3등: 5개 일치
        - 4등: 4개 일치
        - 5등: 3개 일치
        - 미당첨: 2개 이하
        """
        user_set = set(user_numbers)
        winning_set = set(winning_numbers)
        
        # 맞은 개수 계산
        matched_count = len(user_set & winning_set)
        
        # 보너스 포함 여부
        has_bonus = bonus_number in user_set
        
        # 등수 판정
        if matched_count == 6:
            rank = WinningRank.RANK_1.value
        elif matched_count == 5 and has_bonus:
            rank = WinningRank.RANK_2.value
        elif matched_count == 5:
            rank = WinningRank.RANK_3.value
        elif matched_count == 4:
            rank = WinningRank.RANK_4.value
        elif matched_count == 3:
            rank = WinningRank.RANK_5.value
        else:
            rank = WinningRank.NO_WIN.value
        
        return rank, matched_count, has_bonus
    
    @staticmethod
    def numbers_to_json(numbers: List[int]) -> str:
        """번호 리스트를 JSON 문자열로 변환"""
        return json.dumps(sorted(numbers))
    
    @staticmethod
    def json_to_numbers(json_str: str) -> List[int]:
        """JSON 문자열을 번호 리스트로 변환"""
        return json.loads(json_str)


# 싱글톤 인스턴스
winning_check_service = WinningCheckService()
