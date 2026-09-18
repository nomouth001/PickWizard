# 가격 정책 설정 가이드 (Pricing Configuration Guide)

## 📋 개요

`pricing_config.yaml` 파일을 수정하여 **서버 재시작 없이** 가격 정책을 변경할 수 있습니다.

## 🔧 주요 기능

### 1. 여러 정책 프로필 지원
- **standard**: 표준 가격 (운영용)
- **promotion_2026_01**: 프로모션 이벤트 (50% 할인)
- **subscription**: 구독형 (모든 알고리즘 무료)
- **development**: 개발 모드 (테스트용, 모두 무료)

### 2. 유연한 과금 모델
- **알고리즘별 가격**: 각 알고리즘마다 다른 가격
- **세트 수별 할인**: 많이 생성할수록 할인
- **일일 무료 할당량**: 무료 사용자 일일 제한
- **특별 이벤트**: 기간/요일 기반 자동 할인

### 3. Hot-Reload
```bash
# YAML 파일 수정 후
curl -X POST http://localhost:8000/api/pricing/reload
```

## 📝 사용 예시

### 예시 1: 가격 변경

```yaml
# pricing_config.yaml
standard:
  algorithm_costs:
    1: 0    # 무료 (변동 없음)
    3: 3    # 2코인 → 3코인 (인상)
    4: 1    # 2코인 → 1코인 (인하)
    5: 3    # 변동 없음
    6: 1    # 변동 없음
    7: 1    # 변동 없음
```

**적용 방법**:
```bash
# 1. YAML 파일 저장
# 2. Hot-reload
curl -X POST http://localhost:8000/api/pricing/reload

# 3. 확인
curl http://localhost:8000/api/algorithms
```

---

### 예시 2: 프로모션 이벤트 활성화

```yaml
# 2026년 1월 신년 이벤트 (50% 할인)
promotion_2026_01:
  enabled: true  # ← false에서 true로 변경
  algorithm_costs:
    1: 0
    3: 1    # 2코인의 50%
    4: 1    # 2코인의 50%
    5: 2    # 3코인의 50% (반올림)
    6: 1
    7: 1
```

**정책 전환**:
```bash
curl -X POST "http://localhost:8000/api/pricing/switch-policy?policy_name=promotion_2026_01"
```

---

### 예시 3: 볼륨 할인 적용

```yaml
standard:
  volume_discount:
    enabled: true  # ← false에서 true로 변경
    tiers:
      - min_sets: 1
        max_sets: 5
        discount: 0.0    # 1-5세트: 할인 없음
      
      - min_sets: 6
        max_sets: 10
        discount: 0.1    # 6-10세트: 10% 할인
      
      - min_sets: 11
        max_sets: null   # 11세트 이상
        discount: 0.2    # 20% 할인
```

**효과**:
- 5세트 생성: 할인 없음
- 10세트 생성: 10% 할인
- 20세트 생성: 20% 할인

---

### 예시 4: 주말 특가

```yaml
special_events:
  - event_id: "weekend_special"
    enabled: true  # ← false에서 true로 변경
    days_of_week: [5, 6]  # 토(5), 일(6)
    discount_percent: 30   # 30% 할인
    applies_to_algorithms: [3, 4, 5, 6, 7]  # 유료 알고리즘만
```

**효과**:
- **토요일, 일요일**: 자동 30% 할인
- **평일**: 정상 가격

---

### 예시 5: 신년 이벤트 (기간 한정)

```yaml
special_events:
  - event_id: "new_year_2026"
    enabled: true  # ← false에서 true로 변경
    start_date: "2026-01-01"
    end_date: "2026-01-31"
    discount_percent: 50
    applies_to_algorithms: [3, 4, 5]
```

**효과**:
- **2026년 1월 1일 ~ 31일**: 알고리즘 3, 4, 5번 50% 할인
- **2월 1일부터**: 자동으로 정상 가격

---

### 예시 6: 개발 모드 (무료)

```yaml
# 테스트용
default_policy: "development"  # ← "standard"에서 "development"로 변경

development:
  algorithm_costs:
    1: 0
    3: 0  # 모두 무료
    4: 0
    5: 0
    6: 0
    7: 0
```

**적용 방법**:
```bash
# 서버 재시작
# 또는
curl -X POST http://localhost:8000/api/pricing/reload
```

---

## 🛠️ API 사용법

### 1. 현재 정책 확인
```bash
curl http://localhost:8000/api/pricing/policy

# 응답 예시:
{
  "name": "표준 가격",
  "description": "알고리즘별 고정가 + 세트당 과금",
  "algorithm_costs": {
    "1": 0,
    "3": 2,
    "4": 2,
    "5": 3,
    "6": 1,
    "7": 1
  },
  "version": "1.0.0",
  "last_updated": "2026-01-08 03:30:00 EST"
}
```

### 2. 모든 정책 목록
```bash
curl http://localhost:8000/api/pricing/policies
```

### 3. 비용 미리 계산
```bash
curl -X POST http://localhost:8000/api/pricing/calculate \
  -H "Content-Type: application/json" \
  -d '{
    "algorithm_id": 3,
    "n_sets": 10,
    "user_subscription": null
  }'

# 응답 예시:
{
  "base_cost": 20,          # 2코인 × 10세트
  "discount_amount": 2,     # 10% 할인
  "final_cost": 18,         # 최종 비용
  "discount_reason": "볼륨 할인 10%",
  "breakdown": {
    "algorithm_id": 3,
    "n_sets": 10,
    "cost_per_set": 2
  }
}
```

### 4. 설정 재로드 (Hot-reload)
```bash
curl -X POST http://localhost:8000/api/pricing/reload

# 응답:
{
  "status": "success",
  "message": "가격 설정이 재로드되었습니다",
  "current_policy": "표준 가격"
}
```

### 5. 정책 전환
```bash
curl -X POST "http://localhost:8000/api/pricing/switch-policy?policy_name=promotion_2026_01"

# 응답:
{
  "status": "success",
  "message": "정책이 'promotion_2026_01'(으)로 전환되었습니다",
  "current_policy": {
    "name": "2026년 1월 신규 가입 이벤트",
    ...
  }
}
```

---

## ⚠️ 주의사항

### 1. 정책 변경 시
- **Hot-reload 후 확인**: 반드시 `/api/pricing/policy`로 확인
- **알고리즘 목록 확인**: `/api/algorithms`에서 새 가격 확인

### 2. 이벤트 설정 시
- **날짜 형식**: `YYYY-MM-DD` (예: `2026-01-31`)
- **요일 번호**: 0=월요일, 6=일요일
- **discount_percent**: 0~100 (정수)

### 3. 볼륨 할인 설정 시
- **max_sets: null**: 무제한 (마지막 티어에만 사용)
- **discount**: 0.0~1.0 (0.1 = 10% 할인)

### 4. 환경별 정책
```yaml
environment_mapping:
  development: "development"  # 개발: 무료
  staging: "standard"         # 스테이징: 표준
  production: "standard"      # 프로덕션: 표준
```

---

## 🔄 변경 워크플로우

### 개발 환경
```bash
# 1. pricing_config.yaml 수정
# 2. Hot-reload
curl -X POST http://localhost:8000/api/pricing/reload

# 3. 테스트
curl http://localhost:8000/api/pricing/calculate ...
```

### 프로덕션 환경
```bash
# 1. staging에서 먼저 테스트
# 2. pricing_config.yaml Git commit
# 3. 프로덕션 배포
# 4. Hot-reload (서버 재시작 불필요)
curl -X POST http://localhost:8000/api/pricing/reload
```

---

## 📊 향후 확장 계획

- [ ] **PostgreSQL 연동**: YAML → DB 마이그레이션
- [ ] **Admin Dashboard**: GUI로 가격 정책 관리
- [ ] **Redis 캐싱**: YAML 파일 I/O 최소화
- [ ] **사용자별 가격**: VIP, 신규 가입자 맞춤 가격
- [ ] **자동 정책 전환**: Celery 스케줄러로 자동화

---

**Version**: 1.0.0  
**Last Updated**: 2026-01-08 03:30:00 EST

