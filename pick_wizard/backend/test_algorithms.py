"""
알고리즘 테스트 스크립트

새로 구현된 알고리즘 2, 3, 4의 기본 동작 검증

2026-01-08 04:15:00 EST - 초기 생성
"""

import sys
import os

# UTF-8 인코딩 설정
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# 경로 설정
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

import pandas as pd
import numpy as np
from app.algorithms import load_all_algorithms, get_algorithm


def create_dummy_data(n_rounds: int = 100) -> pd.DataFrame:
    """테스트용 더미 데이터 생성"""
    data = []
    for i in range(1, n_rounds + 1):
        numbers = sorted(np.random.choice(range(1, 46), size=6, replace=False))
        row = {'round': i}
        for j, num in enumerate(numbers, 1):
            row[f'num{j}'] = num
        data.append(row)
    
    return pd.DataFrame(data)


def test_algorithm_2():
    """알고리즘 2 (고급 빈도 분석) 테스트"""
    print("\n" + "="*60)
    print("알고리즘 2: 고급 빈도 분석 테스트")
    print("="*60)
    
    algo = get_algorithm(2)
    if algo is None:
        print("❌ 알고리즘 2를 찾을 수 없습니다")
        return False
    
    print(f"✓ 알고리즘 로드: {algo.name}")
    
    # 더미 데이터 생성
    data = create_dummy_data(100)
    print(f"✓ 테스트 데이터: {len(data)}회차")
    
    # 테스트 1: 기본 설정
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=3
        )
        print(f"✓ 테스트 1 (기본): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 1 실패: {e}")
        return False
    
    # 테스트 2: 역확률 모드
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=2,
            probability_mode='inverse'
        )
        print(f"✓ 테스트 2 (역확률): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 2 실패: {e}")
        return False
    
    # 테스트 3: 필터 적용
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=2,
            exclude_consecutive_2=True,
            exclude_frequent=True,
            frequent_lookback=10,
            frequent_threshold=5
        )
        print(f"✓ 테스트 3 (필터): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 3 실패: {e}")
        return False
    
    print("✅ 알고리즘 2 테스트 통과\n")
    return True


def test_algorithm_3():
    """알고리즘 3 (LSTM 고급 분석) 테스트"""
    print("\n" + "="*60)
    print("알고리즘 3: LSTM 고급 분석 테스트")
    print("="*60)
    
    algo = get_algorithm(3)
    if algo is None:
        print("❌ 알고리즘 3을 찾을 수 없습니다")
        return False
    
    print(f"✓ 알고리즘 로드: {algo.name}")
    
    # PyTorch 확인
    try:
        import torch
        print(f"✓ PyTorch 버전: {torch.__version__}")
    except ImportError:
        print("⚠️  PyTorch가 설치되지 않았습니다. LSTM 테스트 스킵")
        return True
    
    # 더미 데이터 생성 (LSTM은 더 많은 데이터 필요)
    data = create_dummy_data(150)
    print(f"✓ 테스트 데이터: {len(data)}회차")
    
    # 테스트 1: Non-Cumulative + Normal (간단한 학습)
    try:
        print("테스트 1 (Non-Cumulative, epochs=10)...")
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=2,
            learning_mode='non-cumulative',
            probability_mode='normal',
            window_size=20,
            num_epochs=10,
            hidden_size=32
        )
        print(f"✓ 테스트 1: {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 1 실패: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    print("✅ 알고리즘 3 테스트 통과\n")
    return True


def test_algorithm_4():
    """알고리즘 4 (패턴 분석) 테스트"""
    print("\n" + "="*60)
    print("알고리즘 4: 패턴 분석 테스트")
    print("="*60)
    
    algo = get_algorithm(4)
    if algo is None:
        print("❌ 알고리즘 4를 찾을 수 없습니다")
        return False
    
    print(f"✓ 알고리즘 로드: {algo.name}")
    
    # 더미 데이터 생성
    data = create_dummy_data(100)
    print(f"✓ 테스트 데이터: {len(data)}회차")
    
    # 테스트 1: 범위 패턴
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=3,
            pattern_type='range',
            range_divisions=5
        )
        print(f"✓ 테스트 1 (범위 패턴): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 1 실패: {e}")
        return False
    
    # 테스트 2: 순위 패턴
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=2,
            pattern_type='rank',
            rank_combo_size=3
        )
        print(f"✓ 테스트 2 (순위 패턴): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 2 실패: {e}")
        return False
    
    # 테스트 3: 역확률 모드
    try:
        results = algo.generate_numbers(
            historical_data=data,
            n_sets=2,
            pattern_type='range',
            in_pattern_probability='inverse'
        )
        print(f"✓ 테스트 3 (역확률): {len(results)}세트 생성")
        for i, nums in enumerate(results, 1):
            print(f"  세트 {i}: {nums}")
    except Exception as e:
        print(f"❌ 테스트 3 실패: {e}")
        return False
    
    print("✅ 알고리즘 4 테스트 통과\n")
    return True


def main():
    """메인 테스트 실행"""
    print("\n" + "="*60)
    print("알고리즘 재설계 버전 테스트 시작")
    print("="*60)
    
    # 알고리즘 로드
    print("\n알고리즘 로딩...")
    algorithms = load_all_algorithms()
    print(f"✓ 총 {len(algorithms)}개 알고리즘 로드됨")
    for algo_id, algo in algorithms.items():
        print(f"  - {algo_id}: {algo.name}")
    
    # 각 알고리즘 테스트
    results = []
    
    results.append(("알고리즘 2", test_algorithm_2()))
    results.append(("알고리즘 3", test_algorithm_3()))
    results.append(("알고리즘 4", test_algorithm_4()))
    
    # 결과 요약
    print("\n" + "="*60)
    print("테스트 결과 요약")
    print("="*60)
    
    for name, passed in results:
        status = "✅ 통과" if passed else "❌ 실패"
        print(f"{name}: {status}")
    
    all_passed = all(result[1] for result in results)
    
    if all_passed:
        print("\n🎉 모든 테스트 통과!")
    else:
        print("\n⚠️  일부 테스트 실패")
    
    return all_passed


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

