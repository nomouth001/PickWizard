"""
Phase 5: 내 번호 관리 & 당첨 확인 통합 테스트 스크립트

2026-01-16 04:35:00 EST - 초기 생성
"""

import requests
import json
from datetime import datetime
from typing import Optional

# ============================================================================
# 테스트 설정
# ============================================================================

BASE_URL = "http://localhost:8000"
TEST_RESULTS = []

# 테스트용 사용자 정보
TEST_USER_ID: Optional[str] = None
TEST_SAVED_NUMBER_IDS = []


class TestResult:
    """테스트 결과 클래스"""
    def __init__(self, name: str, passed: bool, message: str = "", response_time: float = 0.0):
        self.name = name
        self.passed = passed
        self.message = message
        self.response_time = response_time


def log_result(result: TestResult):
    """테스트 결과 로깅"""
    TEST_RESULTS.append(result)
    status = "✅ PASS" if result.passed else "❌ FAIL"
    time_str = f"({result.response_time:.3f}s)" if result.response_time > 0 else ""
    print(f"{status} {result.name} {time_str}")
    if result.message:
        print(f"     {result.message}")


# ============================================================================
# 사전 준비: 게스트 사용자 생성
# ============================================================================

def setup_test_user():
    """테스트용 게스트 사용자 생성"""
    global TEST_USER_ID
    
    print("\n[사전 준비] 테스트 사용자 생성")
    print("=" * 60)
    
    try:
        device_id = f"test-phase5-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        response = requests.post(
            f"{BASE_URL}/api/auth/guest",
            json={"device_id": device_id, "fcm_token": "test"},
            timeout=10
        )
        
        if response.status_code == 201:
            data = response.json()
            TEST_USER_ID = data['user_id']
            print(f"✅ 테스트 사용자 생성 완료: {TEST_USER_ID}")
            return True
        else:
            print(f"❌ 사용자 생성 실패: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 예외 발생: {e}")
        return False


# ============================================================================
# TEST 1: 번호 저장
# ============================================================================

def test_save_number():
    """번호 저장 API 테스트"""
    print("\n[TEST 1] 번호 저장")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("번호 저장", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {
            "user_id": TEST_USER_ID,
            "numbers": [1, 7, 14, 21, 28, 35],
            "algorithm_id": 2,
            "algorithm_name": "고급 빈도 분석",
            "memo": "첫 번째 번호"
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/my-numbers/save",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 201:
            data = response.json()
            
            if data['numbers'] == payload['numbers']:
                TEST_SAVED_NUMBER_IDS.append(data['id'])
                log_result(TestResult(
                    "번호 저장",
                    True,
                    f"번호 저장 완료: ID={data['id']}, 번호={data['numbers']}",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "번호 저장",
                    False,
                    f"번호 불일치: expected={payload['numbers']}, got={data['numbers']}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "번호 저장",
                False,
                f"HTTP {response.status_code}: {response.text[:100]}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("번호 저장", False, f"예외 발생: {str(e)}"))


# ============================================================================
# TEST 2: 여러 번호 저장
# ============================================================================

def test_save_multiple_numbers():
    """여러 번호 저장 테스트"""
    print("\n[TEST 2] 여러 번호 저장")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("여러 번호 저장", False, "사용자 ID 없음"))
        return
    
    try:
        test_numbers = [
            [3, 17, 26, 27, 42, 45],  # 1206회차와 유사
            [5, 12, 23, 31, 38, 42],
        ]
        
        success_count = 0
        start_time = datetime.now()
        
        for idx, numbers in enumerate(test_numbers):
            payload = {
                "user_id": TEST_USER_ID,
                "numbers": numbers,
                "memo": f"테스트 번호 {idx+2}"
            }
            
            response = requests.post(
                f"{BASE_URL}/api/my-numbers/save",
                json=payload,
                timeout=10
            )
            
            if response.status_code == 201:
                data = response.json()
                TEST_SAVED_NUMBER_IDS.append(data['id'])
                success_count += 1
        
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if success_count == len(test_numbers):
            log_result(TestResult(
                "여러 번호 저장",
                True,
                f"{len(test_numbers)}개 번호 모두 저장 완료",
                elapsed
            ))
        else:
            log_result(TestResult(
                "여러 번호 저장",
                False,
                f"일부 실패: {success_count}/{len(test_numbers)}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("여러 번호 저장", False, f"예외 발생: {str(e)}"))


# ============================================================================
# TEST 3: 내 번호 목록 조회
# ============================================================================

def test_get_my_numbers():
    """내 번호 목록 조회 테스트"""
    print("\n[TEST 3] 내 번호 목록 조회")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("내 번호 목록 조회", False, "사용자 ID 없음"))
        return
    
    try:
        start_time = datetime.now()
        response = requests.get(
            f"{BASE_URL}/api/my-numbers/list",
            params={"user_id": TEST_USER_ID, "limit": 10},
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            expected_count = len(TEST_SAVED_NUMBER_IDS)
            actual_count = data['total']
            
            if actual_count == expected_count:
                log_result(TestResult(
                    "내 번호 목록 조회",
                    True,
                    f"{actual_count}개 번호 조회 완료",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "내 번호 목록 조회",
                    False,
                    f"개수 불일치: expected={expected_count}, got={actual_count}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "내 번호 목록 조회",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("내 번호 목록 조회", False, f"예외 발생: {str(e)}"))


# ============================================================================
# TEST 4: 당첨 확인
# ============================================================================

def test_check_winning():
    """당첨 확인 테스트"""
    print("\n[TEST 4] 당첨 확인 (1205회차)")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("당첨 확인", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {
            "user_id": TEST_USER_ID,
            "draw_no": 1205  # 1206 → 1205로 변경
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/my-numbers/check-winning",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 검증
            if 'winning_numbers' in data and 'total_checked' in data:
                total_checked = data['total_checked']
                winning_numbers = data['winning_numbers']
                
                # 당첨 결과 상세
                results_msg = []
                for result in data.get('results', []):
                    rank = result.get('winning_rank', '미당첨')
                    matched = result.get('matched_count', 0)
                    results_msg.append(f"{rank} ({matched}개 일치)")
                
                log_result(TestResult(
                    "당첨 확인",
                    True,
                    f"{total_checked}개 확인, 당첨번호={winning_numbers}, 결과={', '.join(results_msg) if results_msg else '없음'}",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "당첨 확인",
                    False,
                    f"필수 필드 누락",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "당첨 확인",
                False,
                f"HTTP {response.status_code}: {response.text[:100]}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("당첨 확인", False, f"예외 발생: {str(e)}"))


# ============================================================================
# TEST 5: 번호 삭제
# ============================================================================

def test_delete_number():
    """번호 삭제 테스트"""
    print("\n[TEST 5] 번호 삭제")
    print("=" * 60)
    
    if not TEST_USER_ID or not TEST_SAVED_NUMBER_IDS:
        log_result(TestResult("번호 삭제", False, "테스트 데이터 없음"))
        return
    
    try:
        number_id = TEST_SAVED_NUMBER_IDS[0]
        
        start_time = datetime.now()
        response = requests.delete(
            f"{BASE_URL}/api/my-numbers/{number_id}",
            params={"user_id": TEST_USER_ID},
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 204:
            log_result(TestResult(
                "번호 삭제",
                True,
                f"번호 ID={number_id} 삭제 완료",
                elapsed
            ))
        else:
            log_result(TestResult(
                "번호 삭제",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("번호 삭제", False, f"예외 발생: {str(e)}"))


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
    valid_times = [r.response_time for r in TEST_RESULTS if r.response_time > 0]
    if valid_times:
        avg_time = sum(valid_times) / len(valid_times)
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
    print("Phase 5: 내 번호 관리 & 당첨 확인 통합 테스트")
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
    
    # 사전 준비
    if not setup_test_user():
        print("❌ 테스트 사용자 생성 실패, 테스트 중단")
        return 1
    
    # 테스트 실행
    test_save_number()
    test_save_multiple_numbers()
    test_get_my_numbers()
    test_check_winning()
    test_delete_number()
    
    # 결과 요약
    return print_summary()


if __name__ == "__main__":
    exit(main())
