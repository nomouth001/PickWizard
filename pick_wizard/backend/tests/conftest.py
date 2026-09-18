"""
pytest 설정 및 공통 fixture

2026-01-08 06:35:00 EST - 초기 생성
"""

import pytest
import pandas as pd
import numpy as np


@pytest.fixture
def sample_lotto_data():
    """
    테스트용 샘플 로또 데이터 (100회차)
    
    Returns:
        pd.DataFrame: 당첨번호 DataFrame
    """
    np.random.seed(42)
    data = []
    
    for round_num in range(1, 101):
        # 랜덤하게 6개 번호 생성 (정렬)
        numbers = sorted(np.random.choice(range(1, 46), size=6, replace=False))
        data.append({
            'round': round_num,
            'num1': numbers[0],
            'num2': numbers[1],
            'num3': numbers[2],
            'num4': numbers[3],
            'num5': numbers[4],
            'num6': numbers[5],
        })
    
    return pd.DataFrame(data)


@pytest.fixture
def small_lotto_data():
    """
    테스트용 소규모 로또 데이터 (10회차)
    
    Returns:
        pd.DataFrame: 당첨번호 DataFrame
    """
    return pd.DataFrame({
        'round': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        'num1': [1, 1, 2, 3, 5, 8, 13, 21, 34, 1],
        'num2': [2, 2, 3, 4, 6, 9, 14, 22, 35, 2],
        'num3': [3, 3, 4, 5, 7, 10, 15, 23, 36, 3],
        'num4': [4, 4, 5, 6, 8, 11, 16, 24, 37, 4],
        'num5': [5, 5, 6, 7, 9, 12, 17, 25, 38, 5],
        'num6': [6, 6, 7, 8, 10, 13, 18, 26, 39, 6],
    })


@pytest.fixture
def empty_lotto_data():
    """
    빈 DataFrame (fallback 테스트용)
    
    Returns:
        pd.DataFrame: 빈 DataFrame
    """
    return pd.DataFrame(columns=['round', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6'])


@pytest.fixture
def exclude_numbers():
    """제외 번호 예시"""
    return [1, 2, 3, 40, 41, 42]


@pytest.fixture
def include_numbers():
    """포함 번호 예시"""
    return [7, 14, 21]


@pytest.fixture
def mock_algorithm_params():
    """알고리즘 파라미터 예시"""
    return {
        'n_sets': 5,
        'window_type': 'all',
        'probability_mode': 'normal',
        'temperature': 1.0,
    }

