"""
base.py 공통 헬퍼 메서드 테스트

2026-01-08 06:35:00 EST - 초기 생성
"""

import pytest
import pandas as pd
from app.algorithms.base import LottoAlgorithm
from app.algorithms.algorithm_01_random import RandomAlgorithm


class TestCalculateFrequency:
    """calculate_frequency() 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_frequency(self, small_lotto_data):
        """기본 빈도 계산"""
        algo = RandomAlgorithm()
        
        frequency = algo.calculate_frequency(small_lotto_data)
        
        # 검증
        assert isinstance(frequency, dict)
        assert len(frequency) == 45  # 1~45 모든 번호
        assert frequency[1] == 3  # 1번이 3회 출현 (round 1, 2, 10)
        assert frequency[2] == 4  # 2번이 4회 출현 (round 1, 2, 3, 10)
        assert frequency[40] == 0  # 40번은 0회 출현
    
    @pytest.mark.unit
    def test_zero_frequency_included(self, small_lotto_data):
        """0회 출현 번호 포함 여부"""
        algo = RandomAlgorithm()
        
        # include_zero_freq=True (기본값)
        freq_with_zero = algo.calculate_frequency(small_lotto_data, include_zero_freq=True)
        assert len(freq_with_zero) == 45
        assert all(num in freq_with_zero for num in range(1, 46))
        
        # include_zero_freq=False
        freq_without_zero = algo.calculate_frequency(small_lotto_data, include_zero_freq=False)
        assert len(freq_without_zero) < 45  # 0회 출현 번호 제외
        assert 40 not in freq_without_zero  # 출현하지 않은 번호
    
    @pytest.mark.unit
    def test_empty_dataframe(self):
        """빈 DataFrame 처리"""
        algo = RandomAlgorithm()
        empty_df = pd.DataFrame(columns=['num1', 'num2', 'num3', 'num4', 'num5', 'num6'])
        
        frequency = algo.calculate_frequency(empty_df)
        
        # 모든 번호가 0회
        assert all(freq == 0 for freq in frequency.values())
    
    @pytest.mark.unit
    def test_frequency_sum(self, sample_lotto_data):
        """빈도 합계 검증"""
        algo = RandomAlgorithm()
        
        frequency = algo.calculate_frequency(sample_lotto_data)
        
        # 100회차 × 6개 번호 = 600
        total_draws = len(sample_lotto_data)
        assert sum(frequency.values()) == total_draws * 6


class TestGenerateRandomSets:
    """generate_random_sets() 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_generation(self):
        """기본 랜덤 생성"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(5)
        
        # 검증
        assert len(results) == 5  # 5세트 생성
        for numbers in results:
            assert len(numbers) == 6  # 각 세트 6개
            assert all(1 <= n <= 45 for n in numbers)  # 1~45 범위
            assert len(set(numbers)) == 6  # 중복 없음
            assert numbers == sorted(numbers)  # 정렬됨
    
    @pytest.mark.unit
    def test_with_exclude_numbers(self, exclude_numbers):
        """제외 번호 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=10,
            exclude_numbers=exclude_numbers
        )
        
        # 제외 번호가 포함되지 않음
        for numbers in results:
            for excluded in exclude_numbers:
                assert excluded not in numbers
    
    @pytest.mark.unit
    def test_with_include_numbers(self, include_numbers):
        """포함 번호 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=10,
            include_numbers=include_numbers
        )
        
        # 포함 번호가 모두 포함됨
        for numbers in results:
            for included in include_numbers:
                assert included in numbers
    
    @pytest.mark.unit
    def test_with_both_exclude_and_include(self, exclude_numbers, include_numbers):
        """제외 + 포함 동시 적용"""
        algo = RandomAlgorithm()
        
        results = algo.generate_random_sets(
            n_sets=5,
            exclude_numbers=exclude_numbers,
            include_numbers=include_numbers
        )
        
        for numbers in results:
            # 포함 번호는 모두 포함
            for included in include_numbers:
                assert included in numbers
            
            # 제외 번호는 포함되지 않음
            for excluded in exclude_numbers:
                assert excluded not in numbers
    
    @pytest.mark.unit
    def test_edge_case_minimal_available(self):
        """최소 사용 가능 번호 (경계 조건)"""
        algo = RandomAlgorithm()
        
        # 39개 제외 + 6개 포함 = 정확히 6개만 선택 가능
        exclude = list(range(1, 40))
        include = list(range(40, 46))
        
        results = algo.generate_random_sets(
            n_sets=3,
            exclude_numbers=exclude,
            include_numbers=include
        )
        
        # 모든 세트가 40~45 번호만 포함
        for numbers in results:
            assert set(numbers) == set(include)


class TestApplyTemperature:
    """apply_temperature() 정적 메서드 테스트"""
    
    @pytest.mark.unit
    def test_temperature_1_no_change(self):
        """온도 1.0 (변경 없음)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 1.0)
        
        assert result == probs  # 완전히 동일
    
    @pytest.mark.unit
    def test_temperature_low_sharpens(self):
        """온도 < 1.0 (날카로운 분포)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 0.5)
        
        # 높은 확률이 더 강조됨
        assert result[3] > probs[3]
        assert result[1] < probs[1]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_temperature_high_flattens(self):
        """온도 > 1.0 (평탄한 분포)"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        
        result = LottoAlgorithm.apply_temperature(probs, 2.0)
        
        # 확률 차이가 완화됨
        assert result[3] < probs[3]
        assert result[1] > probs[1]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_uniform_distribution(self):
        """균등 분포 처리"""
        probs = {i: 1/45 for i in range(1, 46)}
        
        result = LottoAlgorithm.apply_temperature(probs, 0.5)
        
        # 균등 분포는 온도 적용해도 변화 없음
        for i in range(1, 46):
            assert abs(result[i] - probs[i]) < 1e-9


class TestApplyRecentDrawPenalty:
    """apply_recent_draw_penalty() 정적 메서드 테스트"""
    
    @pytest.mark.unit
    def test_basic_penalty(self, small_lotto_data):
        """기본 패널티 적용"""
        probs = {n: 1/45 for n in range(1, 46)}
        
        result = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.5
        )
        
        # 직전 회차 번호 (round 10: 1, 2, 3, 4, 5, 6)
        for num in [1, 2, 3, 4, 5, 6]:
            assert result[num] < probs[num]  # 확률 감소
        
        # 다른 번호는 상대적으로 증가
        assert result[7] > probs[7]
        
        # 합계는 여전히 1
        assert abs(sum(result.values()) - 1.0) < 1e-9
    
    @pytest.mark.unit
    def test_different_penalty_rates(self, small_lotto_data):
        """다양한 할인율"""
        probs = {n: 1/45 for n in range(1, 46)}
        
        # 50% 할인
        result_50 = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.5
        )
        
        # 33% 할인 (더 강한 페널티)
        result_33 = LottoAlgorithm.apply_recent_draw_penalty(
            probs, small_lotto_data, penalty_rate=0.33
        )
        
        # 더 강한 페널티가 더 큰 감소
        assert result_33[1] < result_50[1]
    
    @pytest.mark.unit
    def test_empty_dataframe(self):
        """빈 DataFrame 처리"""
        empty_df = pd.DataFrame(columns=['num1', 'num2', 'num3', 'num4', 'num5', 'num6'])
        probs = {n: 1/45 for n in range(1, 46)}
        
        result = LottoAlgorithm.apply_recent_draw_penalty(
            probs, empty_df, penalty_rate=0.5
        )
        
        # 변화 없음
        assert result == probs


class TestIntegration:
    """통합 테스트 (여러 메서드 조합)"""
    
    @pytest.mark.integration
    def test_full_workflow(self, sample_lotto_data):
        """전체 워크플로우"""
        algo = RandomAlgorithm()
        
        # 1. 빈도 계산
        frequency = algo.calculate_frequency(sample_lotto_data)
        
        # 2. 확률 분포 생성
        total = sum(frequency.values())
        probs = {num: freq / total for num, freq in frequency.items()}
        
        # 3. 온도 적용
        probs = LottoAlgorithm.apply_temperature(probs, 0.7)
        
        # 4. 직전 회차 패널티
        probs = LottoAlgorithm.apply_recent_draw_penalty(
            probs, sample_lotto_data, 0.5
        )
        
        # 검증
        assert abs(sum(probs.values()) - 1.0) < 1e-9
        assert all(0 <= p <= 1 for p in probs.values())

