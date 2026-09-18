"""
API 엔드포인트 테스트

2026-01-04 EST
"""

import requests
import json

BASE_URL = "http://localhost:8000"

print("="*60)
print("API 엔드포인트 테스트")
print("="*60)

# 1. Root API
print("\n[1/6] GET / (Root)")
response = requests.get(f"{BASE_URL}/")
print(f"  Status: {response.status_code}")
print(f"  Response: {response.json()}\n")

# 2. Health Check
print("[2/6] GET /health")
response = requests.get(f"{BASE_URL}/health")
print(f"  Status: {response.status_code}")
print(f"  Response: {response.json()}\n")

# 3. 알고리즘 목록
print("[3/6] GET /api/v1/algorithms/")
response = requests.get(f"{BASE_URL}/api/v1/algorithms/")
print(f"  Status: {response.status_code}")
data = response.json()
print(f"  총 {data['total']}개 알고리즘:")
for algo in data['algorithms']:
    print(f"    - ID {algo['id']}: {algo['name']} ({algo['cost_per_set']}코인)")
print()

# 4. 특정 알고리즘 조회
print("[4/6] GET /api/v1/algorithms/1")
response = requests.get(f"{BASE_URL}/api/v1/algorithms/1")
print(f"  Status: {response.status_code}")
algo = response.json()
print(f"  이름: {algo['name']}")
print(f"  설명: {algo['description']}")
print(f"  비용: {algo['cost_per_set']}코인\n")

# 5. 번호 생성 (랜덤)
print("[5/6] POST /api/v1/generation/ (랜덤 알고리즘)")
payload = {
    "algorithm_id": 1,
    "n_sets": 3
}
response = requests.post(
    f"{BASE_URL}/api/v1/generation/",
    json=payload,
    headers={"Content-Type": "application/json"}
)
print(f"  Status: {response.status_code}")
data = response.json()
print(f"  알고리즘: {data['algorithm_name']}")
print(f"  소모 코인: {data['cost']}")
print(f"  생성된 번호:")
for result in data['results']:
    nums = result['numbers']
    print(f"    세트 {result['set_no']}: {nums[0]}, {nums[1]}, {nums[2]}, {nums[3]}, {nums[4]}, {nums[5]}")
print()

# 6. 번호 생성 (제외/포함 옵션)
print("[6/6] POST /api/v1/generation/ (제외/포함 옵션)")
payload = {
    "algorithm_id": 1,
    "n_sets": 2,
    "exclude_numbers": [1, 2, 3],
    "include_numbers": [7, 14]
}
response = requests.post(
    f"{BASE_URL}/api/v1/generation/",
    json=payload,
    headers={"Content-Type": "application/json"}
)
print(f"  Status: {response.status_code}")
data = response.json()
print(f"  제외: [1, 2, 3]")
print(f"  포함: [7, 14]")
print(f"  생성된 번호:")
for result in data['results']:
    nums = result['numbers']
    print(f"    세트 {result['set_no']}: {nums[0]}, {nums[1]}, {nums[2]}, {nums[3]}, {nums[4]}, {nums[5]}")
    # 7, 14가 포함되어 있는지 확인
    has_7 = 7 in nums
    has_14 = 14 in nums
    print(f"      -> 7 포함: {has_7}, 14 포함: {has_14}")

print("\n" + "="*60)
print("API 테스트 완료!")
print("="*60)

