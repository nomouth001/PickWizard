"""
Phase 3: Flutter API 통합 테스트 스크립트

백엔드 API와 Flutter 앱 간의 통합을 테스트합니다.

2026-01-08 07:30:00 EST - 초기 생성
"""

import requests
import json
from datetime import datetime
from typing import Dict, List, Any, Optional

# ============================================================================
# 테스트 설정
# ============================================================================

BASE_URL = "http://localhost:8000"
TEST_RESULTS = []

class TestResult:
    """테스트 결과 클래스"""
    def __init__(self, name: str, passed: bool, message: str = "", response_time: float = 0.0):
        self.name = name
        self.passed = passed
        self.message = message
        self.response_time = response_time
        self.timestamp = datetime.now()

def log_result(result: TestResult):
    """테스트 결과 로깅"""
    TEST_RESULTS.append(result)
    status = "✅ PASS" if result.passed else "❌ FAIL"
    time_str = f"({result.response_time:.3f}s)" if result.response_time > 0 else ""
    print(f"{status} {result.name} {time_str}")
    if result.message:
        print(f"     {result.message}")

# ============================================================================
# 테스트 1: 최신 회차 조회
# ============================================================================

def test_get_latest_draw():
    """최신 회차 조회 API 테스트"""
    print("\n[TEST 1] 최신 회차 조회")
    print("=" * 60)
    
    try:
        start_time = datetime.now()
        response = requests.get(f"{BASE_URL}/api/draws/latest", timeout=10)
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 필수 필드 검증 (백엔드 응답 형식: draw_no, numbers, bonus)
            required_fields = ['draw_no', 'draw_date', 'numbers', 'bonus']
            missing = [f for f in required_fields if f not in data]
            
            if missing:
                log_result(TestResult(
                    "최신 회차 조회",
                    False,
                    f"필수 필드 누락: {missing}",
                    elapsed
                ))
            else:
                # 번호 범위 검증
                numbers = data['numbers']  # 리스트로 반환됨
                bonus = data['bonus']
                
                if len(numbers) == 6 and all(1 <= n <= 45 for n in numbers) and 1 <= bonus <= 45:
                    log_result(TestResult(
                        "최신 회차 조회",
                        True,
                        f"회차: {data['draw_no']}, 번호: {numbers}, 보너스: {bonus}",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "최신 회차 조회",
                        False,
                        f"번호 범위 오류: {numbers + [bonus]}",
                        elapsed
                    ))
        else:
            log_result(TestResult(
                "최신 회차 조회",
                False,
                f"HTTP {response.status_code}: {response.text}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("최신 회차 조회", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 2: 알고리즘 목록 조회
# ============================================================================

def test_get_algorithms():
    """알고리즘 목록 조회 API 테스트"""
    print("\n[TEST 2] 알고리즘 목록 조회")
    print("=" * 60)
    
    try:
        start_time = datetime.now()
        response = requests.get(f"{BASE_URL}/api/algorithms", timeout=10)
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 응답 구조 검증
            if 'total' in data and 'algorithms' in data:
                algorithms = data['algorithms']
                total = data['total']
                
                if len(algorithms) == total:
                    # 각 알고리즘 필드 검증
                    all_valid = True
                    for algo in algorithms:
                        required = ['id', 'name', 'description', 'cost_per_set']
                        if not all(f in algo for f in required):
                            all_valid = False
                            break
                    
                    if all_valid:
                        algo_names = [f"{a['id']}. {a['name']}" for a in algorithms]
                        log_result(TestResult(
                            "알고리즘 목록 조회",
                            True,
                            f"총 {total}개 알고리즘: {', '.join(algo_names[:3])}...",
                            elapsed
                        ))
                    else:
                        log_result(TestResult(
                            "알고리즘 목록 조회",
                            False,
                            "알고리즘 필드 누락",
                            elapsed
                        ))
                else:
                    log_result(TestResult(
                        "알고리즘 목록 조회",
                        False,
                        f"total({total})과 실제 개수({len(algorithms)}) 불일치",
                        elapsed
                    ))
            else:
                log_result(TestResult(
                    "알고리즘 목록 조회",
                    False,
                    "응답 구조 오류: 'total' 또는 'algorithms' 필드 누락",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "알고리즘 목록 조회",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("알고리즘 목록 조회", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 3: 번호 생성 (알고리즘 1 - 순수 랜덤)
# ============================================================================

def test_generate_numbers_random():
    """번호 생성 API 테스트 (순수 랜덤)"""
    print("\n[TEST 3] 번호 생성 - 순수 랜덤")
    print("=" * 60)
    
    try:
        payload = {
            "algorithm_id": 1,
            "n_sets": 3
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/generation",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 필수 필드 검증
            required = ['algorithm_id', 'algorithm_name', 'results', 'timestamp', 'cost']
            missing = [f for f in required if f not in data]
            
            if missing:
                log_result(TestResult(
                    "번호 생성 (랜덤)",
                    False,
                    f"필수 필드 누락: {missing}",
                    elapsed
                ))
            else:
                results = data['results']
                
                # 결과 개수 검증
                if len(results) == 3:
                    # 각 세트 검증
                    all_valid = True
                    for r in results:
                        if 'numbers' not in r or 'set_no' not in r:
                            all_valid = False
                            break
                        if len(r['numbers']) != 6:
                            all_valid = False
                            break
                        if not all(1 <= n <= 45 for n in r['numbers']):
                            all_valid = False
                            break
                    
                    if all_valid:
                        first_set = results[0]['numbers']
                        log_result(TestResult(
                            "번호 생성 (랜덤)",
                            True,
                            f"3세트 생성 완료, 첫 번째 세트: {first_set}",
                            elapsed
                        ))
                    else:
                        log_result(TestResult(
                            "번호 생성 (랜덤)",
                            False,
                            "번호 세트 검증 실패",
                            elapsed
                        ))
                else:
                    log_result(TestResult(
                        "번호 생성 (랜덤)",
                        False,
                        f"요청 3세트, 응답 {len(results)}세트",
                        elapsed
                    ))
        else:
            log_result(TestResult(
                "번호 생성 (랜덤)",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("번호 생성 (랜덤)", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 4: 번호 생성 (알고리즘 2 - 고급 빈도)
# ============================================================================

def test_generate_numbers_frequency():
    """번호 생성 API 테스트 (고급 빈도)"""
    print("\n[TEST 4] 번호 생성 - 고급 빈도")
    print("=" * 60)
    
    try:
        payload = {
            "algorithm_id": 2,
            "n_sets": 2,
            "window_type": "all",
            "probability_mode": "normal",
            "temperature": 1.0
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/generation",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            results = data.get('results', [])
            
            if len(results) == 2:
                all_valid = all(
                    len(r.get('numbers', [])) == 6 and 
                    all(1 <= n <= 45 for n in r['numbers'])
                    for r in results
                )
                
                if all_valid:
                    log_result(TestResult(
                        "번호 생성 (고급 빈도)",
                        True,
                        f"2세트 생성 완료, 비용: {data.get('cost', 0)}코인",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "번호 생성 (고급 빈도)",
                        False,
                        "번호 세트 검증 실패",
                        elapsed
                    ))
            else:
                log_result(TestResult(
                    "번호 생성 (고급 빈도)",
                    False,
                    f"요청 2세트, 응답 {len(results)}세트",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "번호 생성 (고급 빈도)",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("번호 생성 (고급 빈도)", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 5: 제외/포함 번호 옵션
# ============================================================================

def test_generate_with_filters():
    """번호 생성 API 테스트 (제외/포함 번호)"""
    print("\n[TEST 5] 번호 생성 - 제외/포함 옵션")
    print("=" * 60)
    
    try:
        exclude = [1, 2, 3, 43, 44, 45]
        include = [7, 14, 21]
        
        payload = {
            "algorithm_id": 1,
            "n_sets": 2,
            "exclude_numbers": exclude,
            "include_numbers": include
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/generation",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            results = data.get('results', [])
            
            # 제외 번호가 포함되지 않았는지 확인
            all_excluded = True
            all_included = True
            
            for r in results:
                numbers = r.get('numbers', [])
                if any(n in exclude for n in numbers):
                    all_excluded = False
                if not all(n in numbers for n in include):
                    all_included = False
            
            if all_excluded and all_included:
                log_result(TestResult(
                    "제외/포함 옵션",
                    True,
                    f"필터 적용 성공: 제외 {exclude}, 포함 {include}",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "제외/포함 옵션",
                    False,
                    f"필터 미적용: excluded={all_excluded}, included={all_included}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "제외/포함 옵션",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("제외/포함 옵션", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 6: 가격 정책 조회
# ============================================================================

def test_get_pricing():
    """가격 정책 조회 API 테스트"""
    print("\n[TEST 6] 가격 정책 조회")
    print("=" * 60)
    
    try:
        start_time = datetime.now()
        response = requests.get(f"{BASE_URL}/api/pricing/policy", timeout=10)
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 백엔드 응답 형식: algorithm_costs (dict)
            if 'algorithm_costs' in data:
                costs = data['algorithm_costs']
                log_result(TestResult(
                    "가격 정책 조회",
                    True,
                    f"알고리즘 {len(costs)}개의 가격 정책 로드됨",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "가격 정책 조회",
                    False,
                    "'algorithm_costs' 필드 누락",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "가격 정책 조회",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("가격 정책 조회", False, f"예외 발생: {str(e)}"))

# ============================================================================
# 테스트 결과 요약
# ============================================================================

def print_summary():
    """테스트 결과 요약 출력"""
    print("\n" + "=" * 60)
    print("테스트 결과 요약")
    print("=" * 60)
    
    passed = sum(1 for r in TEST_RESULTS if r.passed)
    failed = len(TEST_RESULTS) - passed
    success_rate = (passed / len(TEST_RESULTS) * 100) if TEST_RESULTS else 0
    
    print(f"\n총 테스트: {len(TEST_RESULTS)}개")
    print(f"✅ 성공: {passed}개")
    print(f"❌ 실패: {failed}개")
    print(f"성공률: {success_rate:.1f}%")
    
    if failed > 0:
        print("\n실패한 테스트:")
        for r in TEST_RESULTS:
            if not r.passed:
                print(f"  - {r.name}: {r.message}")
    
    # 평균 응답 시간
    avg_time = sum(r.response_time for r in TEST_RESULTS) / len(TEST_RESULTS)
    print(f"\n평균 응답 시간: {avg_time:.3f}초")
    
    # 최종 판정
    print("\n" + "=" * 60)
    if failed == 0:
        print("🎉 모든 테스트 통과!")
        print("=" * 60)
        return 0
    else:
        print("⚠️  일부 테스트 실패")
        print("=" * 60)
        return 1

# ============================================================================
# 메인 실행
# ============================================================================

def main():
    """메인 함수"""
    print("=" * 60)
    print("Phase 3: Flutter API 통합 테스트")
    print("=" * 60)
    print(f"백엔드 URL: {BASE_URL}")
    print(f"테스트 시작: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 백엔드 연결 확인
    print("\n[사전 확인] 백엔드 서버 연결")
    print("=" * 60)
    try:
        response = requests.get(f"{BASE_URL}/", timeout=5)
        print(f"✅ 백엔드 서버 응답: HTTP {response.status_code}")
    except Exception as e:
        print(f"❌ 백엔드 서버 연결 실패: {str(e)}")
        print("\n백엔드 서버가 실행 중인지 확인하세요:")
        print("  cd pick_wizard/backend")
        print("  python -m uvicorn app.main:app --reload")
        return 1
    
    # 테스트 실행
    test_get_latest_draw()
    test_get_algorithms()
    test_generate_numbers_random()
    test_generate_numbers_frequency()
    test_generate_with_filters()
    test_get_pricing()
    
    # 결과 요약
    return print_summary()

if __name__ == "__main__":
    exit(main())
