# 037. 백테스트 window_size 한계 보완 계획

**작성일**: 2026-02-14  
**대상**: LuckyAI 645 Admin 백테스트 서비스  
**목적**: window_size 미충족 회차(2~50)에서 부족한 데이터로 예측하는 한계 보완

---

## 1. 현재 동작

### 알고리즘 내부 (예: algorithm_02)

```python
# window_type != 'all' 일 때
analysis_data = historical_data.tail(window_size or 50)
```

- `historical_data`: 해당 회차 **이전** 모든 회차 (1 ~ draw_no-1)
- `tail(50)`: **최근 50개**만 사용
- 데이터가 50개 미만이면 → 있는 만큼만 사용

### 회차별 실제 동작

| 예측 회차 | hist 행 수 | tail(50) 결과 | 비고 |
|----------|------------|---------------|------|
| 2 | 1 | 1개 사용 | window_size 50 미충족 |
| 51 | 50 | 50개 사용 | 정상 |
| 1100 | 1099 | 1050~1099 (50개) | 정상 |

---

## 2. 한계

- **회차 2~50**: hist가 50개 미만 → `tail(50)`이 실제로는 1~49개만 사용
- 윈도우 50을 의도한 설정이어도, 초기 구간에서는 부족한 데이터로 예측 수행
- 결과 해석 시 “window_size=50인데 1개만 사용한 결과”가 섞여 혼란 가능

---

## 3. 보완 방향

### 원칙

- **최소 필요 회차 수 (min_required)** 만족 시에만 해당 회차를 평가
- `len(hist) >= min_required` 일 때만 당첨 비교 수행
- min_required = `algorithm_params`에서 **lookback 파라미터**의 최댓값

### 알고리즘별 lookback 파라미터

| 알고리즘 ID | 파라미터 |
|-------------|----------|
| 2 | window_size |
| 3 | window_size |
| 4 | analysis_window_size |
| 5 | recent_draws |
| 6 | recent_draws |
| 7 | hot_window, cold_window → max(hot_window, cold_window) |
| 8 | window_size |

---

## 4. 구현 계획

### 4.1 backtest_service.py 수정

```python
def _get_min_required_draws(algorithm_params: Optional[Dict]) -> int:
    """알고리즘 파라미터에서 최소 필요 회차 수 산출"""
    if not algorithm_params:
        return 0
    vals = []
    for k in ('window_size', 'recent_draws', 'analysis_window_size'):
        v = algorithm_params.get(k)
        if v is not None:
            vals.append(int(v) if isinstance(v, (int, float)) else max(v) if isinstance(v, (list, tuple)) else 0)
    for k in ('hot_window', 'cold_window'):
        v = algorithm_params.get(k)
        if v is not None:
            vals.append(int(v) if isinstance(v, (int, float)) else max(v) if isinstance(v, (list, tuple)) else 0)
    return max(vals) if vals else 0
```

- `execute_walk_forward` 내부에서 `min_required = _get_min_required_draws(algorithm_params)` 계산
- 각 draw_no에 대해:
  - `hist = df[df["draw_no"] < draw_no]`
  - `if len(hist) < min_required: continue` → 해당 회차는 건너뜀

### 4.2 그리드 백테스트

- `execute_grid_backtest`는 이미 각 조합별로 `algorithm_params`를 넘김
- `execute_walk_forward`에서 위와 같이 `min_required` 적용 시, 그리드도 동일 규칙 적용됨

### 4.3 적용 시 주의점

1. **window_type='all'**: lookback이 없음 → `min_required = 0` (모든 회차 평가)
2. **복합 파라미터**: window_size + recent_draws 등 여러 값이 있으면 **가장 큰 값**을 min_required로 사용
3. **결과 메트릭**: 건너뛴 회차가 생기므로, `total_draws`·`rank_distribution`은 **실제 평가한 회차**만 반영

### 4.4 결과 표시

- `period` 또는 결과 메타에 `skipped_draws` (건너뛴 회차 수) 또는 `effective_draws` (평가한 회차 수)를 추가해, 사용자가 “몇 회차만 평가됐는지”를 명확히 알 수 있게 함 (선택)

---

## 5. 검증

- window_size=50, start_draw=1, end_draw=1100일 때:
  - 회차 2~50: skip
  - 회차 51~1100: 평가 (1050개 회차)
- 각 알고리즘별로 lookback 파라미터만 사용하는 경우, 위와 동일하게 min_required 미충족 회차는 skip되는지 확인
