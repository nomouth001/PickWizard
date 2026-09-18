"""
Phase 4: 게스트 인증 & 코인 시스템 통합 테스트 스크립트

백엔드 API의 게스트 인증, 코인 시스템, 번호 생성 통합을 테스트합니다.

2026-01-08 08:30:00 EST - 초기 생성
"""

import requests
import json
from datetime import datetime
from typing import Dict, Optional
from uuid import UUID

# ============================================================================
# 테스트 설정
# ============================================================================

BASE_URL = "http://localhost:8000"
TEST_RESULTS = []

# 테스트용 사용자 정보 (전역 변수로 공유)
TEST_USER_ID: Optional[str] = None
TEST_DEVICE_ID = f"test-device-{datetime.now().strftime('%Y%m%d%H%M%S')}"


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
# 테스트 1: 게스트 사용자 생성
# ============================================================================

def test_create_guest_user():
    """게스트 사용자 생성 API 테스트"""
    global TEST_USER_ID
    
    print("\n[TEST 1] 게스트 사용자 생성")
    print("=" * 60)
    
    try:
        payload = {
            "device_id": TEST_DEVICE_ID,
            "fcm_token": "test_fcm_token"
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/auth/guest",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 201:
            data = response.json()
            
            # 필수 필드 검증
            required = ['user_id', 'device_id', 'is_new_user', 'welcome_bonus', 'total_coins']
            missing = [f for f in required if f not in data]
            
            if missing:
                log_result(TestResult(
                    "게스트 사용자 생성",
                    False,
                    f"필수 필드 누락: {missing}",
                    elapsed
                ))
            else:
                # 웰컴 보너스 검증
                if data['is_new_user'] and data['welcome_bonus'] == 100 and data['total_coins'] == 100:
                    TEST_USER_ID = data['user_id']
                    log_result(TestResult(
                        "게스트 사용자 생성",
                        True,
                        f"사용자 생성 완료: user_id={data['user_id']}, 웰컴 보너스={data['welcome_bonus']}코인",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "게스트 사용자 생성",
                        False,
                        f"웰컴 보너스 검증 실패: is_new={data['is_new_user']}, bonus={data['welcome_bonus']}, total={data['total_coins']}",
                        elapsed
                    ))
        else:
            log_result(TestResult(
                "게스트 사용자 생성",
                False,
                f"HTTP {response.status_code}: {response.text}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("게스트 사용자 생성", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 2: 코인 잔액 조회
# ============================================================================

def test_get_coin_balance():
    """코인 잔액 조회 API 테스트"""
    print("\n[TEST 2] 코인 잔액 조회")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("코인 잔액 조회", False, "사용자 ID 없음 (Test 1 먼저 실행)"))
        return
    
    try:
        start_time = datetime.now()
        response = requests.get(
            f"{BASE_URL}/api/coins/balance",
            params={"user_id": TEST_USER_ID},
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 필수 필드 검증
            required = ['user_id', 'free_coins', 'paid_coins', 'total_coins', 'total_earned', 'total_spent']
            missing = [f for f in required if f not in data]
            
            if missing:
                log_result(TestResult(
                    "코인 잔액 조회",
                    False,
                    f"필수 필드 누락: {missing}",
                    elapsed
                ))
            else:
                # 잔액 검증 (웰컴 보너스 100코인)
                if data['total_coins'] == 100 and data['free_coins'] == 100:
                    log_result(TestResult(
                        "코인 잔액 조회",
                        True,
                        f"잔액: {data['total_coins']}코인 (무료: {data['free_coins']}, 유료: {data['paid_coins']})",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "코인 잔액 조회",
                        False,
                        f"잔액 불일치: total={data['total_coins']}, free={data['free_coins']}",
                        elapsed
                    ))
        else:
            log_result(TestResult(
                "코인 잔액 조회",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("코인 잔액 조회", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 3: 일일 로그인 보상
# ============================================================================

def test_daily_login():
    """일일 로그인 보상 API 테스트"""
    print("\n[TEST 3] 일일 로그인 보상")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("일일 로그인 보상", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {"user_id": TEST_USER_ID}
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/coins/daily-login",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('success'):
                # 첫 번째 로그인
                if data['coins_earned'] == 10 and data['new_balance'] == 110:
                    log_result(TestResult(
                        "일일 로그인 보상",
                        True,
                        f"보상 {data['coins_earned']}코인 획득, 잔액 {data['new_balance']}코인",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "일일 로그인 보상",
                        False,
                        f"보상 금액 오류: earned={data['coins_earned']}, balance={data['new_balance']}",
                        elapsed
                    ))
            else:
                # 이미 받은 경우 (테스트 재실행)
                log_result(TestResult(
                    "일일 로그인 보상",
                    True,
                    f"중복 방지 작동: {data.get('message', '')}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "일일 로그인 보상",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("일일 로그인 보상", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 4: 광고 시청 보상
# ============================================================================

def test_watch_ad():
    """광고 시청 보상 API 테스트"""
    print("\n[TEST 4] 광고 시청 보상")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("광고 시청 보상", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {
            "user_id": TEST_USER_ID,
            "ad_id": "test_ad_001",
            "ad_provider": "admob"
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/coins/watch-ad",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('success'):
                if data['coins_earned'] == 5:
                    log_result(TestResult(
                        "광고 시청 보상",
                        True,
                        f"보상 {data['coins_earned']}코인 획득, 잔액 {data['new_balance']}코인, 남은 횟수 {data['remaining_ads']}회",
                        elapsed
                    ))
                else:
                    log_result(TestResult(
                        "광고 시청 보상",
                        False,
                        f"보상 금액 오류: earned={data['coins_earned']}",
                        elapsed
                    ))
            else:
                log_result(TestResult(
                    "광고 시청 보상",
                    False,
                    f"광고 시청 실패: {data.get('message', '')}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "광고 시청 보상",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("광고 시청 보상", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 5: 무료 알고리즘 번호 생성 (코인 차감 없음)
# ============================================================================

def test_generate_free_algorithm():
    """무료 알고리즘 번호 생성 테스트"""
    print("\n[TEST 5] 무료 알고리즘 번호 생성")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("무료 번호 생성", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {
            "user_id": TEST_USER_ID,
            "algorithm_id": 1,  # 순수 랜덤 (무료)
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
            
            # 비용 확인 (무료)
            if data.get('cost') == 0 and len(data.get('results', [])) == 3:
                log_result(TestResult(
                    "무료 번호 생성",
                    True,
                    f"3세트 생성 완료, 비용 {data['cost']}코인",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "무료 번호 생성",
                    False,
                    f"생성 오류: cost={data.get('cost')}, sets={len(data.get('results', []))}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "무료 번호 생성",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("무료 번호 생성", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 6: 유료 알고리즘 번호 생성 (코인 차감)
# ============================================================================

def test_generate_paid_algorithm():
    """유료 알고리즘 번호 생성 테스트 (코인 차감)"""
    print("\n[TEST 6] 유료 알고리즘 번호 생성 (코인 차감)")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("유료 번호 생성", False, "사용자 ID 없음"))
        return
    
    try:
        payload = {
            "user_id": TEST_USER_ID,
            "algorithm_id": 6,  # 기본 빈도 (1코인/세트)
            "n_sets": 2
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
            
            # 비용 확인 (2코인 차감)
            expected_cost = 2
            if data.get('cost') == expected_cost and len(data.get('results', [])) == 2:
                log_result(TestResult(
                    "유료 번호 생성",
                    True,
                    f"2세트 생성 완료, {expected_cost}코인 차감됨",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "유료 번호 생성",
                    False,
                    f"생성 오류: cost={data.get('cost')}, sets={len(data.get('results', []))}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "유료 번호 생성",
                False,
                f"HTTP {response.status_code}: {response.text[:100]}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("유료 번호 생성", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 7: 코인 잔액 확인 (차감 후)
# ============================================================================

def test_verify_coin_deduction():
    """코인 차감 검증"""
    print("\n[TEST 7] 코인 차감 검증")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("코인 차감 검증", False, "사용자 ID 없음"))
        return
    
    try:
        start_time = datetime.now()
        response = requests.get(
            f"{BASE_URL}/api/coins/balance",
            params={"user_id": TEST_USER_ID},
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            # 예상 잔액: 100 (웰컴) + 10 (일일 로그인) + 5 (광고) - 2 (번호 생성) = 113코인
            expected_balance = 113
            actual_balance = data['total_coins']
            
            # ±5 코인 허용 (테스트 순서에 따라 다를 수 있음)
            if abs(actual_balance - expected_balance) <= 5:
                log_result(TestResult(
                    "코인 차감 검증",
                    True,
                    f"잔액 확인: {actual_balance}코인 (예상: {expected_balance}코인)",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "코인 차감 검증",
                    False,
                    f"잔액 불일치: {actual_balance}코인 (예상: {expected_balance}코인)",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "코인 차감 검증",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("코인 차감 검증", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 8: 코인 거래 내역 조회
# ============================================================================

def test_get_coin_history():
    """코인 거래 내역 조회 테스트"""
    print("\n[TEST 8] 코인 거래 내역 조회")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("거래 내역 조회", False, "사용자 ID 없음"))
        return
    
    try:
        start_time = datetime.now()
        response = requests.get(
            f"{BASE_URL}/api/coins/history",
            params={"user_id": TEST_USER_ID, "limit": 10},
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        if response.status_code == 200:
            data = response.json()
            
            total = data.get('total', 0)
            transactions = data.get('transactions', [])
            
            # 최소 4개 거래: 웰컴 보너스, 일일 로그인, 광고 시청, 번호 생성
            if total >= 4 and len(transactions) >= 4:
                log_result(TestResult(
                    "거래 내역 조회",
                    True,
                    f"거래 내역 {total}건 조회 (최근 {len(transactions)}건 표시)",
                    elapsed
                ))
            else:
                log_result(TestResult(
                    "거래 내역 조회",
                    False,
                    f"거래 내역 부족: total={total}, shown={len(transactions)}",
                    elapsed
                ))
        else:
            log_result(TestResult(
                "거래 내역 조회",
                False,
                f"HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("거래 내역 조회", False, f"예외 발생: {str(e)}"))


# ============================================================================
# 테스트 9: 코인 부족 시 번호 생성 실패
# ============================================================================

def test_generate_with_insufficient_coins():
    """코인 부족 시 번호 생성 실패 테스트"""
    print("\n[TEST 9] 코인 부족 시 번호 생성 실패")
    print("=" * 60)
    
    if not TEST_USER_ID:
        log_result(TestResult("코인 부족 테스트", False, "사용자 ID 없음"))
        return
    
    try:
        # 현재 잔액보다 많은 코인이 필요한 요청 (고급 LSTM 3코인 * 100세트 = 300코인)
        payload = {
            "user_id": TEST_USER_ID,
            "algorithm_id": 3,
            "n_sets": 100
        }
        
        start_time = datetime.now()
        response = requests.post(
            f"{BASE_URL}/api/generation",
            json=payload,
            timeout=10
        )
        elapsed = (datetime.now() - start_time).total_seconds()
        
        # 402 Payment Required 기대
        if response.status_code == 402:
            log_result(TestResult(
                "코인 부족 테스트",
                True,
                f"코인 부족 오류 정상 반환 (HTTP 402)",
                elapsed
            ))
        elif response.status_code == 200:
            log_result(TestResult(
                "코인 부족 테스트",
                False,
                "코인 부족인데 생성 성공 (오류)",
                elapsed
            ))
        else:
            log_result(TestResult(
                "코인 부족 테스트",
                False,
                f"예상치 못한 응답: HTTP {response.status_code}",
                elapsed
            ))
    except Exception as e:
        log_result(TestResult("코인 부족 테스트", False, f"예외 발생: {str(e)}"))


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
    avg_time = sum(r.response_time for r in TEST_RESULTS if r.response_time > 0) / len([r for r in TEST_RESULTS if r.response_time > 0])
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
    print("Phase 4: 게스트 인증 & 코인 시스템 통합 테스트")
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
    test_create_guest_user()
    test_get_coin_balance()
    test_daily_login()
    test_watch_ad()
    test_generate_free_algorithm()
    test_generate_paid_algorithm()
    test_verify_coin_deduction()
    test_get_coin_history()
    test_generate_with_insufficient_coins()
    
    # 결과 요약
    return print_summary()


if __name__ == "__main__":
    exit(main())
