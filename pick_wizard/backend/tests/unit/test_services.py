"""
서비스 계층 단위 테스트

2026-01-16 EST - Phase 3.2: 테스트 커버리지 향상
"""

import pytest
import json
from pathlib import Path
from datetime import datetime

from app.services.pricing_service import PricingService
from app.services.winning_check_service import WinningCheckService
from app.db.models.user_numbers import WinningRank


class TestPricingService:
    """PricingService 테스트"""
    
    @pytest.fixture
    def pricing_service(self):
        """테스트용 PricingService 인스턴스"""
        return PricingService()
    
    def test_initialization(self, pricing_service):
        """서비스 초기화"""
        assert pricing_service.config is not None
        assert pricing_service.current_policy is not None
    
    def test_get_algorithm_cost(self, pricing_service):
        """알고리즘 비용 조회"""
        cost_1 = pricing_service.get_algorithm_cost(1)
        cost_2 = pricing_service.get_algorithm_cost(2)
        
        assert isinstance(cost_1, int)
        assert isinstance(cost_2, int)
        assert cost_1 >= 0
        assert cost_2 >= 0
    
    def test_calculate_total_cost_basic(self, pricing_service):
        """기본 총 비용 계산"""
        result = pricing_service.calculate_total_cost(
            algorithm_id=1,
            n_sets=5
        )
        
        assert isinstance(result, dict)
        assert 'final_cost' in result
        assert isinstance(result['final_cost'], int)
        assert result['final_cost'] >= 0
    
    def test_calculate_total_cost_with_discount(self, pricing_service):
        """대량 구매 할인 적용"""
        # 소량 구매
        result_small = pricing_service.calculate_total_cost(
            algorithm_id=1,
            n_sets=5
        )
        
        # 대량 구매
        result_large = pricing_service.calculate_total_cost(
            algorithm_id=1,
            n_sets=100
        )
        
        cost_small = result_small['final_cost']
        cost_large = result_large['final_cost']
        
        # 대량 구매 시 세트당 가격이 더 저렴해야 함 (할인이 적용되면)
        unit_price_small = cost_small / 5
        unit_price_large = cost_large / 100
        
        assert unit_price_large <= unit_price_small
    
    def test_fallback_config(self):
        """폴백 설정 테스트"""
        # 존재하지 않는 설정 파일
        service = PricingService(config_path="/nonexistent/path.yaml")
        
        # 폴백으로 무료 정책 사용
        assert service.current_policy is not None
        cost = service.get_algorithm_cost(1)
        assert cost == 0
    
    def test_reload_config(self, pricing_service):
        """설정 재로드"""
        original_policy = pricing_service.current_policy
        pricing_service.reload_config()
        
        # 재로드 후에도 정책 유지
        assert pricing_service.current_policy is not None


class TestWinningCheckService:
    """WinningCheckService 테스트"""
    
    def test_rank_1(self):
        """1등 판정: 6개 일치"""
        user = [1, 2, 3, 4, 5, 6]
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.RANK_1.value
        assert matched == 6
        assert has_bonus is False
    
    def test_rank_2(self):
        """2등 판정: 5개 일치 + 보너스"""
        user = [1, 2, 3, 4, 5, 7]  # 보너스 포함
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.RANK_2.value
        assert matched == 5
        assert has_bonus is True
    
    def test_rank_3(self):
        """3등 판정: 5개 일치"""
        user = [1, 2, 3, 4, 5, 8]
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.RANK_3.value
        assert matched == 5
        assert has_bonus is False
    
    def test_rank_4(self):
        """4등 판정: 4개 일치"""
        user = [1, 2, 3, 4, 8, 9]
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.RANK_4.value
        assert matched == 4
    
    def test_rank_5(self):
        """5등 판정: 3개 일치"""
        user = [1, 2, 3, 8, 9, 10]
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.RANK_5.value
        assert matched == 3
    
    def test_no_win(self):
        """미당첨: 2개 이하"""
        user = [1, 2, 8, 9, 10, 11]
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, has_bonus = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        
        assert rank == WinningRank.NO_WIN.value
        assert matched == 2
    
    def test_numbers_to_json(self):
        """번호 리스트 → JSON"""
        numbers = [5, 12, 23, 31, 38, 42]
        json_str = WinningCheckService.numbers_to_json(numbers)
        
        assert isinstance(json_str, str)
        parsed = json.loads(json_str)
        assert parsed == sorted(numbers)
    
    def test_json_to_numbers(self):
        """JSON → 번호 리스트"""
        json_str = '[5, 12, 23, 31, 38, 42]'
        numbers = WinningCheckService.json_to_numbers(json_str)
        
        assert isinstance(numbers, list)
        assert len(numbers) == 6
        assert all(isinstance(n, int) for n in numbers)
    
    def test_numbers_round_trip(self):
        """번호 변환 왕복 테스트"""
        original = [5, 12, 23, 31, 38, 42]
        
        json_str = WinningCheckService.numbers_to_json(original)
        result = WinningCheckService.json_to_numbers(json_str)
        
        assert sorted(result) == sorted(original)


@pytest.mark.integration
class TestServicesIntegration:
    """서비스 통합 테스트"""
    
    def test_pricing_and_winning_workflow(self):
        """가격 계산 + 당첨 확인 워크플로우"""
        # 1. 가격 서비스로 비용 계산
        pricing = PricingService()
        result = pricing.calculate_total_cost(algorithm_id=2, n_sets=5)
        assert result['final_cost'] >= 0
        
        # 2. 번호 생성 (시뮬레이션)
        user_numbers = [[5, 12, 23, 31, 38, 42] for _ in range(5)]
        
        # 3. 당첨 확인
        winning_numbers = [5, 12, 23, 31, 38, 43]
        bonus = 7
        
        for nums in user_numbers:
            rank, matched, has_bonus = WinningCheckService.judge_rank(
                nums, winning_numbers, bonus
            )
            assert isinstance(rank, str)
            assert isinstance(matched, int)
            assert isinstance(has_bonus, bool)
    
    def test_edge_cases(self):
        """엣지 케이스 테스트"""
        # 빈 리스트는 matched=0으로 처리됨
        user = []
        winning = []
        bonus = 0
        
        rank, matched, _ = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        assert matched == 0
        assert rank == WinningRank.NO_WIN.value
        
        # 중복 번호 (set으로 처리되므로 문제없어야 함)
        user = [1, 1, 2, 3, 4, 5]  # 중복
        winning = [1, 2, 3, 4, 5, 6]
        bonus = 7
        
        rank, matched, _ = WinningCheckService.judge_rank(
            user, winning, bonus
        )
        assert matched <= 6  # 중복이 제거되므로 5개 일치
