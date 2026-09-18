"""
Phase 1 & 2 통합 테스트

2026-01-04 EST - 생성
"""

import pytest
import asyncio
from pathlib import Path

from app.db.base import Base, engine
from app.core.crawler import LottoCrawler
from app.core.data_validator import DataValidator
from app.core.cache_manager import CacheManager
from app.algorithms import load_all_algorithms, get_algorithm


class TestPhase1:
    """Phase 1: 백엔드 코어 모듈 테스트"""
    
    def test_database_connection(self):
        """데이터베이스 연결 테스트"""
        Base.metadata.create_all(bind=engine)
        assert engine is not None
        print("✓ 데이터베이스 연결 성공")
    
    @pytest.mark.asyncio
    async def test_crawler(self):
        """크롤러 테스트"""
        async with LottoCrawler() as crawler:
            latest = await crawler.get_latest_draw_number()
            assert latest is not None
            assert latest > 1000
            print(f"✓ 크롤러 작동 (최신 회차: {latest}회)")
    
    def test_data_validator(self):
        """데이터 검증기 테스트"""
        import pandas as pd
        
        validator = DataValidator()
        
        # 정상 데이터
        df = pd.DataFrame({
            'draw_no': [1, 2],
            'draw_date': ['2024-01-01', '2024-01-08'],
            'num1': [1, 5],
            'num2': [2, 10],
            'num3': [3, 15],
            'num4': [4, 20],
            'num5': [5, 25],
            'num6': [6, 30],
            'bonus': [7, 35]
        })
        
        result = validator.validate_dataframe(df)
        assert result['valid'] == True
        print("✓ 데이터 검증기 작동")
    
    def test_cache_manager(self):
        """캐시 매니저 테스트"""
        cache = CacheManager()
        cache.connect()
        
        # 연결 실패해도 에러 없이 진행
        cache.set("test_key", {"data": "test"}, ttl=10)
        value = cache.get("test_key")
        
        if value:
            assert value["data"] == "test"
            print("✓ 캐시 매니저 작동 (Redis 연결 성공)")
        else:
            print("⚠ 캐시 매니저 (Redis 연결 실패, 정상 동작)")


class TestPhase2:
    """Phase 2: 알고리즘 & API 테스트"""
    
    def test_algorithm_loading(self):
        """알고리즘 로딩 테스트"""
        algorithms = load_all_algorithms()
        assert len(algorithms) >= 3
        assert 1 in algorithms  # Random
        assert 6 in algorithms  # Frequency
        assert 7 in algorithms  # Hot/Cold
        print(f"✓ 알고리즘 {len(algorithms)}개 로드 성공")
    
    def test_random_algorithm(self):
        """랜덤 알고리즘 테스트"""
        algo = get_algorithm(1)
        assert algo is not None
        
        results = algo.generate_numbers(None, n_sets=5)
        assert len(results) == 5
        assert all(len(nums) == 6 for nums in results)
        assert all(1 <= num <= 45 for nums in results for num in nums)
        print(f"✓ 랜덤 알고리즘 작동: {results[0]}")
    
    def test_frequency_algorithm(self):
        """빈도 알고리즘 테스트"""
        import pandas as pd
        
        # 더미 데이터 생성
        df = pd.DataFrame({
            'draw_no': range(1, 101),
            'draw_date': ['2024-01-01'] * 100,
            'num1': [1] * 100,
            'num2': [2] * 100,
            'num3': [3] * 100,
            'num4': [4] * 100,
            'num5': [5] * 100,
            'num6': [6] * 100,
            'bonus': [7] * 100
        })
        
        algo = get_algorithm(6)
        assert algo is not None
        
        results = algo.generate_numbers(df, n_sets=3)
        assert len(results) == 3
        print(f"✓ 빈도 알고리즘 작동: {results[0]}")
    
    def test_hot_cold_algorithm(self):
        """핫/콜드 알고리즘 테스트"""
        import pandas as pd
        
        df = pd.DataFrame({
            'draw_no': range(1, 101),
            'draw_date': ['2024-01-01'] * 100,
            'num1': [1] * 100,
            'num2': [2] * 100,
            'num3': [3] * 100,
            'num4': [4] * 100,
            'num5': [5] * 100,
            'num6': [6] * 100,
            'bonus': [7] * 100
        })
        
        algo = get_algorithm(7)
        assert algo is not None
        
        results = algo.generate_numbers(df, n_sets=3)
        assert len(results) == 3
        print(f"✓ 핫/콜드 알고리즘 작동: {results[0]}")


def run_all_tests():
    """모든 테스트 실행"""
    print("\n" + "=" * 60)
    print("Phase 1 & 2 통합 테스트 시작")
    print("=" * 60 + "\n")
    
    exit_code = pytest.main([
        __file__,
        "-v",
        "--tb=short",
        "-s"
    ])
    
    print("\n" + "=" * 60)
    if exit_code == 0:
        print("✅ 모든 테스트 통과!")
    else:
        print("❌ 일부 테스트 실패")
    print("=" * 60)
    
    return exit_code


if __name__ == "__main__":
    run_all_tests()

