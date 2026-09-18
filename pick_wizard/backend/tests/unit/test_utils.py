"""
Backend 유틸리티 모듈 단위 테스트

2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
"""

import pytest
import pandas as pd
import numpy as np
from collections import Counter

from app.algorithms import utils
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER, LOTTO_NUMBERS_PER_DRAW
)


class TestFrequencyToProbability:
    """frequency_to_probability 테스트"""
    
    def test_normal_mode(self):
        """정확률 모드 테스트"""
        frequency = {1: 10, 2: 20, 3: 30}
        probs = utils.frequency_to_probability(frequency, mode='normal')
        
        assert pytest.approx(probs[1]) == 10 / 60
        assert pytest.approx(probs[2]) == 20 / 60
        assert pytest.approx(probs[3]) == 30 / 60
        assert pytest.approx(sum(probs.values())) == 1.0
    
    def test_inverse_mode(self):
        """역확률 모드 테스트"""
        frequency = {1: 10, 2: 20, 3: 30}
        probs = utils.frequency_to_probability(frequency, mode='inverse')
        
        # 역확률: max(30) - freq + 1
        # 1: 30-10+1=21, 2: 30-20+1=11, 3: 30-30+1=1
        # total = 33
        assert pytest.approx(probs[1]) == 21 / 33
        assert pytest.approx(probs[2]) == 11 / 33
        assert pytest.approx(probs[3]) == 1 / 33
        assert pytest.approx(sum(probs.values())) == 1.0
    
    def test_zero_frequency(self):
        """빈도 0일 때 균등 분포"""
        frequency = {1: 0, 2: 0, 3: 0}
        probs = utils.frequency_to_probability(frequency, mode='normal')
        
        assert probs[1] == pytest.approx(1 / 3)
        assert probs[2] == pytest.approx(1 / 3)
        assert probs[3] == pytest.approx(1 / 3)
    
    def test_unknown_mode(self):
        """잘못된 모드 예외"""
        frequency = {1: 10}
        with pytest.raises(ValueError, match="Unknown mode"):
            utils.frequency_to_probability(frequency, mode='invalid')


class TestNormalizeWeights:
    """normalize_weights 테스트"""
    
    def test_basic_normalization(self):
        """기본 정규화"""
        weights = {1: 10, 2: 20, 3: 30}
        normalized = utils.normalize_weights(weights)
        
        assert pytest.approx(normalized[1]) == 10 / 60
        assert pytest.approx(normalized[2]) == 20 / 60
        assert pytest.approx(normalized[3]) == 30 / 60
        assert pytest.approx(sum(normalized.values())) == 1.0
    
    def test_zero_total(self):
        """가중치 합이 0일 때 균등 분포"""
        weights = {1: 0, 2: 0, 3: 0}
        normalized = utils.normalize_weights(weights)
        
        assert normalized[1] == pytest.approx(1 / 3)
        assert normalized[2] == pytest.approx(1 / 3)
        assert normalized[3] == pytest.approx(1 / 3)
    
    def test_single_weight(self):
        """단일 가중치"""
        weights = {1: 100}
        normalized = utils.normalize_weights(weights)
        
        assert normalized[1] == pytest.approx(1.0)


class TestCalculateEntropy:
    """calculate_entropy 테스트"""
    
    def test_uniform_distribution(self):
        """균등 분포 엔트로피 (최대값)"""
        probs = {i: 1/45 for i in range(1, 46)}
        entropy = utils.calculate_entropy(probs)
        
        # log2(45) ≈ 5.49
        assert entropy > 5.4
        assert entropy < 5.5
    
    def test_single_outcome(self):
        """단일 결과 엔트로피 (0)"""
        probs = {1: 1.0, 2: 0.0, 3: 0.0}
        entropy = utils.calculate_entropy(probs)
        
        assert entropy == pytest.approx(0.0)
    
    def test_binary_distribution(self):
        """이진 분포 엔트로피"""
        probs = {1: 0.5, 2: 0.5}
        entropy = utils.calculate_entropy(probs)
        
        assert entropy == pytest.approx(1.0)  # log2(2) = 1


class TestApplyTemperature:
    """apply_temperature 테스트 (utils 모듈)"""
    
    def test_temperature_1_no_change(self):
        """온도 1.0: 변경 없음"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        result = utils.apply_temperature(probs, 1.0)
        
        assert result == probs
    
    def test_temperature_low_sharpens(self):
        """낮은 온도: 확률 차이 극대화"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        result = utils.apply_temperature(probs, 0.5)
        
        # 0.7의 비중이 더 증가해야 함
        assert result[3] > probs[3]
        assert result[1] < probs[1]
        assert pytest.approx(sum(result.values())) == 1.0
    
    def test_temperature_high_flattens(self):
        """높은 온도: 확률 차이 완화"""
        probs = {1: 0.1, 2: 0.2, 3: 0.7}
        result = utils.apply_temperature(probs, 2.0)
        
        # 균등 분포에 가까워져야 함
        assert result[3] < probs[3]
        assert result[1] > probs[1]
        assert pytest.approx(sum(result.values())) == 1.0


class TestApplyRecentDrawPenalty:
    """apply_recent_draw_penalty 테스트 (utils 모듈)"""
    
    @pytest.fixture
    def sample_data(self):
        """샘플 과거 데이터"""
        return pd.DataFrame({
            'draw_no': [1100, 1101, 1102],
            'num1': [5, 10, 15],
            'num2': [12, 18, 23],
            'num3': [23, 25, 31],
            'num4': [31, 32, 38],
            'num5': [38, 40, 42],
            'num6': [42, 43, 45]
        })
    
    def test_basic_penalty(self, sample_data):
        """직전 회차 번호 확률 할인"""
        probs = {i: 1/45 for i in range(1, 46)}
        result = utils.apply_recent_draw_penalty(probs, sample_data, 0.5)
        
        # 직전 회차 번호: 15, 23, 31, 38, 42, 45
        latest_numbers = [15, 23, 31, 38, 42, 45]
        
        for num in latest_numbers:
            assert result[num] < probs[num]
        
        # 다른 번호는 상대적으로 증가
        assert result[1] > probs[1]
        assert pytest.approx(sum(result.values())) == 1.0
    
    def test_empty_dataframe(self):
        """빈 데이터프레임: 변경 없음"""
        probs = {1: 0.5, 2: 0.5}
        empty_df = pd.DataFrame()
        result = utils.apply_recent_draw_penalty(probs, empty_df, 0.5)
        
        assert result == probs


class TestSamplingFunctions:
    """샘플링 유틸리티 테스트"""
    
    def test_weighted_sample_with_replacement(self):
        """가중치 기반 복원 샘플링"""
        numbers = [1, 2, 3]
        weights = {1: 0.1, 2: 0.2, 3: 0.7}
        
        # 1000번 샘플링
        samples = []
        for _ in range(1000):
            sample = utils.weighted_sample_with_replacement(numbers, weights, 1)
            samples.extend(sample)
        
        # 3번이 가장 많이 나와야 함
        counter = Counter(samples)
        assert counter[3] > counter[2] > counter[1]
    
    def test_weighted_sample_without_replacement(self):
        """가중치 기반 비복원 샘플링"""
        numbers = list(range(1, 46))
        weights = {i: 1/45 for i in numbers}
        
        sample = utils.weighted_sample_without_replacement(numbers, weights, 6)
        
        assert len(sample) == 6
        assert len(set(sample)) == 6  # 중복 없음
        assert all(num in numbers for num in sample)


class TestValidationFunctions:
    """검증 유틸리티 테스트"""
    
    def test_validate_lotto_number_valid(self):
        """유효한 로또 번호"""
        assert utils.validate_lotto_number(1) is True
        assert utils.validate_lotto_number(45) is True
        assert utils.validate_lotto_number(23) is True
    
    def test_validate_lotto_number_invalid(self):
        """유효하지 않은 로또 번호"""
        assert utils.validate_lotto_number(0) is False
        assert utils.validate_lotto_number(46) is False
        assert utils.validate_lotto_number(-5) is False
    
    def test_validate_lotto_set_valid(self):
        """유효한 로또 세트"""
        assert utils.validate_lotto_set([1, 2, 3, 4, 5, 6]) is True
        assert utils.validate_lotto_set([5, 12, 23, 31, 38, 42]) is True
    
    def test_validate_lotto_set_invalid_count(self):
        """잘못된 개수"""
        assert utils.validate_lotto_set([1, 2, 3, 4, 5]) is False
        assert utils.validate_lotto_set([1, 2, 3, 4, 5, 6, 7]) is False
    
    def test_validate_lotto_set_duplicates(self):
        """중복 번호"""
        assert utils.validate_lotto_set([1, 1, 3, 4, 5, 6]) is False
    
    def test_validate_lotto_set_out_of_range(self):
        """범위 밖 번호"""
        assert utils.validate_lotto_set([0, 2, 3, 4, 5, 6]) is False
        assert utils.validate_lotto_set([1, 2, 3, 4, 5, 46]) is False


@pytest.mark.integration
class TestUtilsIntegration:
    """유틸리티 통합 테스트"""
    
    def test_full_workflow(self):
        """전체 워크플로우: 빈도 → 확률 → 온도 → 샘플링"""
        # 1. 빈도 계산 (이미 있다고 가정)
        frequency = {i: i for i in range(1, 11)}  # 1:1, 2:2, ..., 10:10
        
        # 2. 확률 변환 (역확률)
        probs = utils.frequency_to_probability(frequency, mode='inverse')
        assert probs[1] > probs[10]  # 낮은 빈도가 높은 확률
        
        # 3. 온도 적용
        probs = utils.apply_temperature(probs, 0.8)
        assert pytest.approx(sum(probs.values())) == 1.0
        
        # 4. 엔트로피 계산
        entropy = utils.calculate_entropy(probs)
        assert entropy > 0
        
        # 5. 샘플링
        numbers = list(frequency.keys())
        sample = utils.weighted_sample_without_replacement(numbers, probs, 6)
        assert len(sample) == 6
        assert utils.validate_lotto_set(sample) is True
