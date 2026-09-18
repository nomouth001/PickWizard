"""
백테스트 서비스

2026-02-14 EST - 036 설계안 구현
- Walk-Forward Validation
- 채점 시스템 (006 SSOT)
"""

import time
import uuid
from typing import Callable, Dict, List, Optional, Any

import pandas as pd
from loguru import logger

from app.algorithms import get_algorithm, get_algorithm_list
from app.algorithms.constants import LOTTO_ROUND_COLUMN
from app.core.data_manager import data_manager
from app.services.winning_check_service import WinningCheckService
from app.db.models.user_numbers import WinningRank

# 006 SSOT: 등수별 점수
RANK_SCORES = {1: 10000, 2: 5000, 3: 1000, 4: 100, 5: 10, 0: 0}

# 006 SSOT: 평균 당첨금 (ROI 계산용)
AVERAGE_PRIZE = {
    1: 2_000_000_000,
    2: 50_000_000,
    3: 1_500_000,
    4: 50_000,
    5: 5_000,
    0: 0,
}

# 036: 등급 구간
GRADE_THRESHOLDS = [
    (95, "A+"), (90, "A"), (85, "B+"), (80, "B"),
    (70, "C+"), (60, "C"), (50, "D"), (0, "F"),
]


def _rank_to_key(rank: str) -> str:
    """WinningRank.value → rank_distribution 키"""
    m = {"1등": "1", "2등": "2", "3등": "3", "4등": "4", "5등": "5", "미당첨": "miss"}
    return m.get(rank, "miss")


def _rank_to_num(rank: str) -> int:
    """WinningRank.value → 숫자 (ROI 등용)"""
    m = {"1등": 1, "2등": 2, "3등": 3, "4등": 4, "5등": 5, "미당첨": 0}
    return m.get(rank, 0)


def _calculate_rank_distribution(rank_counts: Dict[str, int]) -> Dict[str, int]:
    """표준 rank_distribution 형식으로 정규화"""
    return {
        "1": rank_counts.get("1", 0),
        "2": rank_counts.get("2", 0),
        "3": rank_counts.get("3", 0),
        "4": rank_counts.get("4", 0),
        "5": rank_counts.get("5", 0),
        "miss": rank_counts.get("miss", 0),
    }


def _calculate_win_rate(rank_dist: Dict[str, int], total_sets: int) -> float:
    if total_sets == 0:
        return 0.0
    win_count = sum(
        rank_dist.get(k, 0) for k in ("1", "2", "3", "4", "5")
    )
    return round(win_count / total_sets, 4)


def _calculate_roi(rank_dist: Dict[str, int], total_sets: int) -> float:
    if total_sets == 0:
        return 0.0
    total_cost = 1000 * total_sets
    total_prize = 0
    for r, count in rank_dist.items():
        if r == "miss":
            continue
        total_prize += AVERAGE_PRIZE[int(r)] * count
    roi = (total_prize / total_cost) * 100
    return round(roi, 2)


def _calculate_composite_score(
    win_rate: float, roi: float, high_rank_ratio: float, consistency: float = 0.5
) -> float:
    """006 SSOT: 종합 점수 0~100"""
    win_score = min(win_rate / 0.018, 1.0) * 40
    roi_score = min(roi / 100, 1.0) * 30
    consistency_score = consistency * 20
    high_score = min(high_rank_ratio * 10, 1.0) * 10
    total = win_score + roi_score + consistency_score + high_score
    return round(min(total, 100.0), 2)


def _get_grade(composite_score: float) -> str:
    for threshold, grade in GRADE_THRESHOLDS:
        if composite_score >= threshold:
            return grade
    return "F"


def _get_min_required_draws(algorithm_params: Optional[Dict[str, Any]]) -> int:
    """
    037: 알고리즘 파라미터에서 최소 필요 회차 수 산출.
    window_size, recent_draws 등 lookback 파라미터의 최댓값 반환.
    """
    if not algorithm_params:
        return 0
    vals: List[int] = []
    for k in ("window_size", "recent_draws", "analysis_window_size"):
        v = algorithm_params.get(k)
        if v is not None:
            if isinstance(v, (int, float)):
                vals.append(int(v))
            elif isinstance(v, (list, tuple)) and v:
                vals.append(max(int(x) for x in v if isinstance(x, (int, float))))
    for k in ("hot_window", "cold_window"):
        v = algorithm_params.get(k)
        if v is not None:
            if isinstance(v, (int, float)):
                vals.append(int(v))
            elif isinstance(v, (list, tuple)) and v:
                vals.append(max(int(x) for x in v if isinstance(x, (int, float))))
    return max(vals) if vals else 0


def execute_walk_forward(
    algorithm_id: int,
    start_draw: int,
    end_draw: int,
    n_sets: int = 5,
    enable_detailed_log: bool = False,
    enable_cumulative_series: bool = True,
    algorithm_params: Optional[Dict[str, Any]] = None,
    exclude_numbers: Optional[List[int]] = None,
    include_numbers: Optional[List[int]] = None,
    progress_callback: Optional[Callable[[int, int, int], None]] = None,
) -> Dict[str, Any]:
    """
    Walk-Forward Validation 실행 (036 §8.0)

    각 회차 N에 대해 1~(N-1)회 데이터로 번호 생성 후 N회 당첨번호와 비교.
    """
    algorithm = get_algorithm(algorithm_id)
    if not algorithm:
        raise ValueError(f"알고리즘 {algorithm_id}를 찾을 수 없습니다")

    df = data_manager.get_dataframe()
    if df is None or len(df) == 0:
        raise ValueError("로또 데이터가 없습니다")

    draws_in_range = df[(df["draw_no"] >= start_draw) & (df["draw_no"] <= end_draw)]
    if len(draws_in_range) == 0:
        raise ValueError(
            f"회차 범위 {start_draw}~{end_draw}에 해당하는 데이터가 없습니다"
        )

    rank_counts: Dict[str, int] = {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0, "miss": 0}
    detailed: List[Dict] = [] if enable_detailed_log else []
    cumulative_series: List[Dict[str, Any]] = [] if enable_cumulative_series else []
    params = algorithm_params or {}
    min_required = _get_min_required_draws(algorithm_params)

    t0 = time.time()
    total_sets = 0
    total_draws = len(draws_in_range)
    current_draw = 0

    for _, row in draws_in_range.iterrows():
        draw_no = int(row["draw_no"])
        winning = [int(row[f"num{i}"]) for i in range(1, 7)]
        bonus = int(row["bonus"])

        hist = df[df["draw_no"] < draw_no].copy()
        if len(hist) == 0:
            continue
        # 알고리즘 3(LSTM) 등이 기대하는 회차 컬럼명 'round' 보장 (data_manager는 draw_no 사용)
        if LOTTO_ROUND_COLUMN not in hist.columns:
            hist[LOTTO_ROUND_COLUMN] = hist["draw_no"]
        if min_required > 0 and len(hist) < min_required:
            current_draw += 1
            if progress_callback:
                progress_callback(current_draw, total_draws, draw_no)
            continue

        try:
            sets = algorithm.generate_numbers(
                historical_data=hist,
                n_sets=n_sets,
                exclude_numbers=exclude_numbers,
                include_numbers=include_numbers,
                **params,
            )
        except Exception as e:
            logger.warning(f"회차 {draw_no} 생성 실패: {e}")
            current_draw += 1
            if progress_callback:
                progress_callback(current_draw, total_draws, draw_no)
            continue

        for nums in sets:
            total_sets += 1
            rank, _, _ = WinningCheckService.judge_rank(nums, winning, bonus)
            key = _rank_to_key(rank)
            rank_counts[key] = rank_counts.get(key, 0) + 1

            if enable_detailed_log:
                detailed.append({
                    "draw_no": draw_no,
                    "numbers": nums,
                    "rank": rank,
                })

        if enable_cumulative_series:
            wins_so_far = sum(rank_counts.get(k, 0) for k in ("1", "2", "3", "4", "5"))
            cumulative_series.append({
                "draw_no": draw_no,
                "valid_draw_index": len(cumulative_series) + 1,
                "total_sets": total_sets,
                "wins": wins_so_far,
                "win_rate": round(wins_so_far / total_sets, 4) if total_sets else 0.0,
            })

        current_draw += 1
        if progress_callback:
            progress_callback(current_draw, total_draws, draw_no)

    elapsed = round(time.time() - t0, 2)
    rank_dist = _calculate_rank_distribution(rank_counts)
    win_rate = _calculate_win_rate(rank_dist, total_sets)
    roi = _calculate_roi(rank_dist, total_sets)

    high_rank_count = sum(rank_dist.get(k, 0) for k in ("1", "2", "3"))
    high_rank_ratio = high_rank_count / total_sets if total_sets else 0
    composite = _calculate_composite_score(win_rate, roi, high_rank_ratio)
    grade = _get_grade(composite)

    result = {
        "backtest_id": str(uuid.uuid4()),
        "algorithm_id": algorithm_id,
        "algorithm_name": algorithm.name,
        "period": {
            "start": start_draw,
            "end": end_draw,
            "total_draws": len(draws_in_range),
        },
        "execution_time": elapsed,
        "rank_distribution": rank_dist,
        "win_rate": win_rate,
        "roi": roi,
        "composite_score": composite,
        "grade": grade,
        "total_sets_generated": total_sets,
        "n_sets": n_sets,
        "effective_draw_count": len(cumulative_series) if enable_cumulative_series else None,
    }
    if enable_detailed_log and detailed:
        result["detailed_results"] = detailed
    if enable_cumulative_series and cumulative_series:
        result["cumulative_win_rate_series"] = cumulative_series
        best_point = max(cumulative_series, key=lambda x: x["win_rate"])
        result["max_cumulative_win_rate"] = round(best_point["win_rate"] * 100, 2)
        result["max_cumulative_win_rate_draw_no"] = best_point["draw_no"]
        result["max_cumulative_win_rate_valid_index"] = best_point["valid_draw_index"]

    return result


def _expand_grid_combinations(grid: Dict[str, List[Any]]) -> List[Dict[str, Any]]:
    """그리드 파라미터 조합 확장 (카테시안 곱)"""
    if not grid:
        return [{}]
    keys = list(grid.keys())
    vals = [grid[k] for k in keys]
    result = []
    from itertools import product
    for combo in product(*vals):
        result.append(dict(zip(keys, combo)))
    return result


def execute_grid_backtest(
    algorithm_id: int,
    start_draw: int,
    end_draw: int,
    grid: Dict[str, List[Any]],
    n_sets: int = 5,
    max_combinations: int = 300,
    enable_detailed_log: bool = False,
    enable_cumulative_series: bool = True,
    exclude_numbers: Optional[List[int]] = None,
    include_numbers: Optional[List[int]] = None,
    progress_callback: Optional[Callable[[int, int, int, int], None]] = None,
) -> Dict[str, Any]:
    """
    그리드 루프 백테스트 (036 §5.6)

    grid: { "window_size": [100, 200], "probability_mode": ["normal", "inverse"] } 등
    """
    algorithm = get_algorithm(algorithm_id)
    if not algorithm:
        raise ValueError(f"알고리즘 {algorithm_id}를 찾을 수 없습니다")

    combinations = _expand_grid_combinations(grid)
    if len(combinations) > max_combinations:
        raise ValueError(
            f"조합 수({len(combinations)})가 상한({max_combinations})을 초과합니다"
        )

    t0 = time.time()
    items = []
    best = None
    best_score = -1
    total_combos = len(combinations)
    total_draws = end_draw - start_draw + 1
    total_work = total_combos * total_draws

    def _grid_progress(cur_draw: int, tot_draws: int, draw_no: int):
        if progress_callback and tot_draws > 0:
            work_done = combo_idx * total_draws + cur_draw
            progress_callback(work_done, total_work, combo_idx + 1, total_combos)

    for combo_idx, params in enumerate(combinations):
        try:
            r = execute_walk_forward(
                algorithm_id=algorithm_id,
                start_draw=start_draw,
                end_draw=end_draw,
                n_sets=n_sets,
                enable_detailed_log=False,
                enable_cumulative_series=enable_cumulative_series,
                algorithm_params=params,
                exclude_numbers=exclude_numbers,
                include_numbers=include_numbers,
                progress_callback=_grid_progress if progress_callback else None,
            )
            item = {
                "params": params,
                "win_rate": r["win_rate"],
                "roi": r["roi"],
                "composite_score": r["composite_score"],
                "grade": r["grade"],
                "rank_distribution": r["rank_distribution"],
                "effective_draw_count": r.get("effective_draw_count"),
                "cumulative_win_rate_series": r.get("cumulative_win_rate_series"),
                "max_cumulative_win_rate": r.get("max_cumulative_win_rate"),
                "max_cumulative_win_rate_draw_no": r.get("max_cumulative_win_rate_draw_no"),
                "max_cumulative_win_rate_valid_index": r.get("max_cumulative_win_rate_valid_index"),
            }
            items.append(item)
            if r["composite_score"] > best_score:
                best_score = r["composite_score"]
                best = item
        except Exception as e:
            logger.warning(f"그리드 조합 {params} 실패: {e}")

    elapsed = round(time.time() - t0, 2)
    items.sort(key=lambda x: x["composite_score"], reverse=True)

    return {
        "backtest_id": str(uuid.uuid4()),
        "algorithm_id": algorithm_id,
        "algorithm_name": algorithm.name,
        "period": {"start": start_draw, "end": end_draw, "total_draws": end_draw - start_draw + 1},
        "execution_time": elapsed,
        "combinations": len(items),
        "best": best,
        "items": items,
    }


# 036 Phase 2: 이력 저장 (인메모리, 재시작 시 초기화)
_history_store: List[Dict] = []


def add_to_history(result: Dict) -> None:
    """백테스트 결과를 이력에 추가"""
    global _history_store
    _history_store.insert(0, {
        "backtest_id": result.get("backtest_id"),
        "algorithm_id": result.get("algorithm_id"),
        "algorithm_name": result.get("algorithm_name"),
        "period": result.get("period"),
        "execution_time": result.get("execution_time"),
        "win_rate": result.get("win_rate"),
        "roi": result.get("roi"),
        "composite_score": result.get("composite_score"),
        "grade": result.get("grade"),
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime()),
    })
    _history_store = _history_store[:100]  # 최대 100건


def get_history(limit: int = 20) -> List[Dict]:
    """최근 백테스트 이력 조회"""
    return _history_store[:limit]
