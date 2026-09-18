"""
Admin API 라우터

2026-02-14 EST - 035 설계안(Admin 웹 진입점·레이아웃·인증) 구현
2026-02-14 EST - 036 백테스트 API 추가
"""

import asyncio
import json
import secrets
from fastapi import APIRouter, Header, HTTPException, Depends, Query
from fastapi.responses import StreamingResponse
from loguru import logger

from app.config import settings
from app.schemas.backtest import BacktestRunRequest, BacktestRunGridRequest
from app.services.backtest_service import (
    execute_walk_forward,
    execute_grid_backtest,
    add_to_history,
    get_history,
)

router = APIRouter(prefix="/admin", tags=["Admin"])


def _verify_admin_token(x_admin_token: str | None = Header(None, alias="X-Admin-Token")) -> str:
    """
    X-Admin-Token 헤더 검증.
    상수시간 비교(secrets.compare_digest) 적용.
    앞뒤 공백·줄바꿈 제거 (.env 인코딩, 입력 오타 대응)
    """
    expected_raw = settings.ADMIN_SECRET_TOKEN
    if not expected_raw:
        logger.warning("ADMIN_SECRET_TOKEN not configured - admin verify will fail")
        raise HTTPException(status_code=503, detail="Admin auth not configured")
    expected = expected_raw.strip()
    token = (x_admin_token or "").strip()
    if not token:
        raise HTTPException(status_code=401, detail="Invalid token")
    if not secrets.compare_digest(token, expected):
        raise HTTPException(status_code=401, detail="Invalid token")
    return token


@router.get("/verify")
async def admin_verify(
    _: str = Depends(_verify_admin_token),
):
    """
    Admin 토큰 유효성 검증 (035 §8 SSOT).
    - 요청 헤더: X-Admin-Token (필수)
    - 200: 토큰 유효
    - 401: 토큰 무효
    - 403: 접근 거부 (IP 제한 등, 추후 확장)
    """
    # Cache-Control: no-store (035 §8.1)
    from fastapi.responses import JSONResponse
    return JSONResponse(
        content={"ok": True},
        headers={"Cache-Control": "no-store"},
    )


# === 036 백테스트 API ===


@router.post("/backtest/run")
async def backtest_run(
    req: BacktestRunRequest,
    _: str = Depends(_verify_admin_token),
):
    """
    단일 백테스트 실행 (036 §5.2).
    Walk-Forward Validation.
    """
    try:
        result = execute_walk_forward(
            algorithm_id=req.algorithm_id,
            start_draw=req.start_draw,
            end_draw=req.end_draw,
            n_sets=req.n_sets,
            enable_detailed_log=req.enable_detailed_log,
            enable_cumulative_series=req.enable_cumulative_series,
            algorithm_params=req.algorithm_params,
            exclude_numbers=req.exclude_numbers,
            include_numbers=req.include_numbers,
        )
        add_to_history(result)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"백테스트 실행 오류: {e}")
        raise HTTPException(status_code=500, detail="백테스트 실행 중 오류가 발생했습니다")


@router.get("/backtest/compare")
async def backtest_compare(
    algorithm_ids: str = Query(..., description="알고리즘 ID 목록 (쉼표 구분)"),
    start_draw: int = Query(..., ge=1),
    end_draw: int = Query(..., ge=1),
    n_sets: int = Query(5, ge=1, le=20),
    _: str = Depends(_verify_admin_token),
):
    """
    다중 알고리즘 비교 백테스트 (036 §5.4).
    """
    if start_draw > end_draw:
        raise HTTPException(status_code=400, detail="start_draw must be <= end_draw")

    try:
        ids = [int(x.strip()) for x in algorithm_ids.split(",") if x.strip()]
    except ValueError:
        raise HTTPException(status_code=400, detail="algorithm_ids must be comma-separated integers")

    if len(ids) < 2:
        raise HTTPException(status_code=400, detail="2개 이상의 알고리즘을 선택하세요")

    items = []
    for aid in ids:
        try:
            r = execute_walk_forward(
                algorithm_id=aid,
                start_draw=start_draw,
                end_draw=end_draw,
                n_sets=n_sets,
                enable_detailed_log=False,
            )
            items.append({
                "algorithm_id": r["algorithm_id"],
                "algorithm_name": r["algorithm_name"],
                "rank_distribution": r["rank_distribution"],
                "win_rate": r["win_rate"],
                "roi": r["roi"],
                "composite_score": r["composite_score"],
                "grade": r["grade"],
                "execution_time": r["execution_time"],
            })
        except ValueError as e:
            raise HTTPException(status_code=400, detail=str(e))

    items.sort(key=lambda x: x["composite_score"], reverse=True)

    return {
        "period": {"start": start_draw, "end": end_draw, "total_draws": end_draw - start_draw + 1},
        "items": items,
        "sorted_by": "composite_score_desc",
    }


@router.post("/backtest/run-grid")
async def backtest_run_grid(
    req: BacktestRunGridRequest,
    _: str = Depends(_verify_admin_token),
):
    """
    그리드 루프 백테스트 (036 §5.6 Phase 2).
    """
    try:
        result = execute_grid_backtest(
            algorithm_id=req.algorithm_id,
            start_draw=req.start_draw,
            end_draw=req.end_draw,
            grid=req.grid,
            n_sets=req.n_sets,
            max_combinations=req.max_combinations,
            enable_detailed_log=req.enable_detailed_log,
            enable_cumulative_series=req.enable_cumulative_series,
            exclude_numbers=req.exclude_numbers,
            include_numbers=req.include_numbers,
        )
        best = result.get("best")
        if best:
            hist = {**result, "win_rate": best["win_rate"], "roi": best["roi"], "composite_score": best["composite_score"], "grade": best["grade"]}
            add_to_history(hist)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"그리드 백테스트 오류: {e}")
        raise HTTPException(status_code=500, detail="그리드 백테스트 실행 중 오류가 발생했습니다")


@router.get("/backtest/history")
async def backtest_history(
    limit: int = Query(20, ge=1, le=100),
    _: str = Depends(_verify_admin_token),
):
    """
    백테스트 이력 조회 (036 §5.8 Phase 2).
    """
    return {"items": get_history(limit=limit)}


def _ndjson_line(obj: dict) -> str:
    return json.dumps(obj, ensure_ascii=False) + "\n"


@router.post("/backtest/run-stream")
async def backtest_run_stream(
    req: BacktestRunRequest,
    _: str = Depends(_verify_admin_token),
):
    """
    단일 백테스트 실행 (NDJSON 스트리밍).
    progress 이벤트 후 result 이벤트.
    """
    queue: asyncio.Queue = asyncio.Queue()
    loop = asyncio.get_event_loop()

    def on_progress(current: int, total: int, draw_no: int):
        loop.call_soon_threadsafe(
            queue.put_nowait,
            {"type": "progress", "current": current, "total": total, "draw_no": draw_no, "percent": round(100 * current / total, 1) if total > 0 else 0},
        )

    def run_sync():
        try:
            r = execute_walk_forward(
                algorithm_id=req.algorithm_id,
                start_draw=req.start_draw,
                end_draw=req.end_draw,
                n_sets=req.n_sets,
                enable_detailed_log=req.enable_detailed_log,
                enable_cumulative_series=req.enable_cumulative_series,
                algorithm_params=req.algorithm_params,
                exclude_numbers=req.exclude_numbers,
                include_numbers=req.include_numbers,
                progress_callback=on_progress,
            )
            add_to_history(r)
            loop.call_soon_threadsafe(queue.put_nowait, {"type": "result", "data": r})
        except Exception as e:
            loop.call_soon_threadsafe(queue.put_nowait, {"type": "error", "detail": str(e)})
        finally:
            loop.call_soon_threadsafe(queue.put_nowait, None)

    async def generate():
        task = asyncio.get_event_loop().run_in_executor(None, run_sync)
        while True:
            item = await queue.get()
            if item is None:
                break
            yield _ndjson_line(item)

        await task

    return StreamingResponse(
        generate(),
        media_type="application/x-ndjson",
        headers={"Cache-Control": "no-store"},
    )


@router.post("/backtest/run-grid-stream")
async def backtest_run_grid_stream(
    req: BacktestRunGridRequest,
    _: str = Depends(_verify_admin_token),
):
    """
    그리드 백테스트 실행 (NDJSON 스트리밍).
    progress 이벤트 후 result 이벤트.
    """
    queue: asyncio.Queue = asyncio.Queue()
    loop = asyncio.get_event_loop()

    def on_progress(work_done: int, total_work: int, combo_done: int, total_combos: int):
        loop.call_soon_threadsafe(
            queue.put_nowait,
            {"type": "progress", "current": work_done, "total": total_work, "combo_current": combo_done, "combo_total": total_combos, "percent": round(100 * work_done / total_work, 1) if total_work > 0 else 0},
        )

    def run_sync():
        try:
            r = execute_grid_backtest(
                algorithm_id=req.algorithm_id,
                start_draw=req.start_draw,
                end_draw=req.end_draw,
                grid=req.grid,
                n_sets=req.n_sets,
                max_combinations=req.max_combinations,
                enable_detailed_log=req.enable_detailed_log,
                enable_cumulative_series=req.enable_cumulative_series,
                exclude_numbers=req.exclude_numbers,
                include_numbers=req.include_numbers,
                progress_callback=on_progress,
            )
            best = r.get("best")
            if best:
                hist = {**r, "win_rate": best["win_rate"], "roi": best["roi"], "composite_score": best["composite_score"], "grade": best["grade"]}
                add_to_history(hist)
            loop.call_soon_threadsafe(queue.put_nowait, {"type": "result", "data": r})
        except Exception as e:
            loop.call_soon_threadsafe(queue.put_nowait, {"type": "error", "detail": str(e)})
        finally:
            loop.call_soon_threadsafe(queue.put_nowait, None)

    async def generate():
        task = asyncio.get_event_loop().run_in_executor(None, run_sync)
        while True:
            item = await queue.get()
            if item is None:
                break
            yield _ndjson_line(item)

        await task

    return StreamingResponse(
        generate(),
        media_type="application/x-ndjson",
        headers={"Cache-Control": "no-store"},
    )
