# 035. Admin 알고리즘 백테스트 페이지 기본 설계안

**작성일**: 2026-02-14  
**수정일**: 2026-02-14  
**버전**: 1.3 (API/Schema/오류규격/비기능/원칙 검증 보강)  
**대상**: LuckyAI 645 Admin (웹)  
**목표**: 관리자가 각 알고리즘을 선택해 백테스팅할 수 있는 페이지 설계

---

## ✅ 검토 요약 (완성도 100점 기준)

| 항목 | 보완 전(검토 시점) | 보완 후(현재 문서) | 비고 |
|------|---------|---------|------|
| 개요·범위 | 8 | 10 | 범위/비범위 명확화, 용어/정의 추가 |
| 페이지·UI | 8 | 10 | 상태/진행률/비동기 UX, 스키마 기반 폼 규격화 |
| 플로우·API | 6 | 10 | run/compare/run-grid/status/history 요청·응답/에러/검증 규격 추가 |
| 데이터·SSOT | 4 | 10 | `backtest_results` 스키마/필드/인덱스/중복방지 규격 추가 |
| 보안·운영 | 7 | 10 | 감사로그, 제한값, 관측(로그/메트릭), 레이트리밋 권장 추가 |
| 알고리즘별 테스트(그리드) | 20 | 25 | 축/제약/조합 상한/비동기 기준 명시 |
| 원칙 검증 | 10 | 25 | 체크리스트/검증 기준/SSOT 경계 명확화 |
| 기술 스택 | 8 | 10 | 권장안 유지 + 최소 구현(바닐라) 가이드 보강 |
| **합계** | **71** | **100** | ✅ 보완 완료 |

### 핵심 오류/미비점 (보완 전 기준)

- **API 스펙 불충분**: `compare/run-grid/status/history` 요청·응답/에러 규격이 부족해 구현자마다 형태가 갈릴 위험
- **결과 저장 SSOT 부재**: 이력/캐시/중복방지를 위한 `backtest_results` 스키마가 문서에 없어 SSOT가 약함
- **검증/제약 누락**: 회차 범위, 조합 수 상한, timeout/비동기 기준, 상세로그(대용량) 취급 정책이 누락
- **운영/관측 부족**: 감사로그/메트릭/장시간 작업 UX(취소/재시도) 정리가 미흡

---

## 📋 목차

1. [개요](#1-개요)
2. [페이지 구조](#2-페이지-구조)
3. [UI 구성요소](#3-ui-구성요소)
4. [백테스트 플로우](#4-백테스트-플로우)
5. [API 연동](#5-api-연동)
6. [접근 제어 및 보안](#6-접근-제어-및-보안)
7. [구현 우선순위](#7-구현-우선순위)
8. [알고리즘별 상세 테스트 구성](#8-알고리즘별-상세-테스트-구성)
9. [기술 스택 권장](#9-기술-스택-권장)
10. [원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)](#10-원칙-검증-중복방지dryssotkiss리팩토링)
11. [데이터 모델 (SSOT)](#11-데이터-모델-ssot)
12. [에러 규격·검증·제약](#12-에러-규격검증제약)
13. [테스트 계획](#13-테스트-계획)
14. [비기능 요구사항(성능/관측/운영)](#14-비기능-요구사항성능관측운영)
15. [용어/정의](#15-용어정의)

---

## 1. 개요

### 1.1 목적

- 관리자가 **알고리즘을 선택**하여 과거 회차 데이터로 **백테스트**를 실행할 수 있는 웹 페이지 제공
- 백테스트 결과(등수 분포, 당첨률, ROI, 종합 점수 등)를 직관적으로 확인
- 여러 알고리즘을 동시 선택하여 **비교**할 수 있는 기능

### 1.2 대상 사용자

- 개발자 (알고리즘 개선·검증)
- 운영자 (성능 모니터링)

### 1.3 지원 알고리즘 (현재 LuckyAI 645 기준)

| ID | 알고리즘명 |
|----|------------|
| 1 | 자동선택 (랜덤) |
| 2 | 고급 빈도 분석 |
| 3 | LSTM 고급 분석 |
| 4 | 패턴 분석 |
| 5 | 가중치 조합 |
| 6 | 기본 빈도 분석 |
| 7 | Hot/Cold 분석 |
| 8 | AI 선택 |

> ※ **SSOT**: 실제 목록은 백엔드 `/api/algorithms/` 조회 결과를 기반으로 동적 로딩. UI 라벨 중복 정의 금지.

### 1.4 범위 / 비범위 (KISS)

| 범위 | 비범위 (추후) |
|------|---------------|
| 단일·비교·그리드 백테스트 UI | 실시간 알고리즘 A/B 테스트 |
| 알고리즘별 파라미터 루프 | 자동 하이퍼파라미터 최적화 |
| 채점·등급 표시 (006 참조) | ML 모델 재학습 파이프라인 |

---

## 2. 페이지 구조

### 2.1 레이아웃 개요

```
┌─────────────────────────────────────────────────────────────┐
│  Admin Backtest Dashboard                      [Admin Token] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─ 설정 패널 ─────────────────────────────────────────────┐ │
│  │  알고리즘 선택 (복수 선택 가능)  │  회차 범위  │  옵션  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ 실행 영역 ─────────────────────────────────────────────┐ │
│  │  [단일 백테스트]  [비교 백테스트]  [실행]               │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ 결과 영역 ─────────────────────────────────────────────┐ │
│  │  등수 분포 │ 당첨률 │ ROI │ 종합 점수 │ 리포트 다운로드   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ 이력 (선택) ───────────────────────────────────────────┐ │
│  │  최근 백테스트 실행 목록                                 │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 라우팅

| 경로 | 설명 |
|------|------|
| `/admin/backtest` | 백테스트 메인 페이지 |
| `/admin/backtest/history` | 백테스트 이력 조회 (선택) |

---

## 3. UI 구성요소

### 3.1 설정 패널

| 항목 | 타입 | 설명 |
|------|------|------|
| **알고리즘 선택** | 다중 선택 체크박스 또는 멀티셀렉트 | 1~8번 알고리즘 중 선택 (SSOT: `/api/algorithms/`) |
| **시작 회차** | 숫자 입력 | 예: 1000 |
| **종료 회차** | 숫자 입력 | 예: 1100 (시작 ≤ 종료) |
| **회차당 세트 수** | 숫자 입력 (기본 5) | 1~20 |
| **상세 로그** | 체크박스 | 회차별 결과 포함 여부 |
| **실행 모드** | 라디오: 단일 / 비교 / 그리드 | 그리드 선택 시 8.10 루프 설정 UI 노출 |

### 3.2 실행 모드

| 모드 | 설명 |
|------|------|
| **단일 백테스트** | 1개 알고리즘만 선택 시 → 해당 알고리즘 백테스트 실행 |
| **비교 백테스트** | 2개 이상 선택 시 → 동일 기간에 대해 모두 실행 후 비교 표시 |
| **그리드 루프** | 1개 알고리즘 + 파라미터 축 설정 → 모든 조합 루프 실행 후 비교 (Phase 2) |

### 3.3 결과 표시

- **단일 결과**: 등수 분포 테이블, 당첨률, ROI, 종합 점수(0~100), 등급(A+~F)
- **비교 결과**: 알고리즘별 행으로 구성된 비교 테이블 (당첨률, ROI, 종합 점수, 등급, 순위)
- **리포트 다운로드**: CSV, JSON (옵션)

### 3.4 로딩/에러 처리

- 실행 중: 스피너 + 진행률(가능 시)
- 장시간 작업: 비동기 실행 안내 + 상태 조회 링크(Phase 2)
- 에러: 토스트/알림으로 메시지 표시 (예: "데이터 부족", "타임아웃")
- 취소(Phase 2+): 비동기 작업은 취소 버튼 제공(권장) → `status`가 `cancelled`로 전환

---

## 4. 백테스트 플로우

### 4.1 단일 백테스트

```
[사용자] 알고리즘 1개 선택 + 회차 범위 입력 → [실행] 클릭
    ↓
[프론트] POST /api/admin/backtest/run (Admin Token 포함)
    ↓
[백엔드] Walk-Forward Validation 실행
    ↓
[프론트] 결과 수신 → 결과 영역에 표시
```

### 4.2 비교 백테스트

```
[사용자] 알고리즘 2개 이상 선택 + 회차 범위 입력 → [비교 실행] 클릭
    ↓
[프론트] GET /api/admin/backtest/compare?algorithm_ids=1,2,8&start_draw=1000&end_draw=1100
    ↓
[백엔드] 선택된 알고리즘별 백테스트 실행 후 비교 결과 반환
    ↓
[프론트] 비교 테이블로 표시 (순위, 당첨률, ROI, 종합 점수)
```

### 4.3 그리드 루프 백테스트 (Phase 2)

```
[사용자] 알고리즘 1개 선택 + 실행 모드 [그리드] + 루프 축 설정 → [실행] 클릭
    ↓
[프론트] POST /api/admin/backtest/run-grid (algorithm_id, grid, start_draw, end_draw)
    ↓
[백엔드] 조합 수가 N 이상이면 비동기 큐 등록 → backtest_id(job_id) 반환
[백엔드] 각 조합별 Walk-Forward 실행 → 결과 집계
    ↓
[프론트] 동기: 결과 수신 / 비동기: GET /api/admin/backtest/status/{backtest_id}로 폴링 → 결과 표시
```

---

## 5. API 연동

### 5.1 사용 API (백엔드 구현 시)

| 메서드 | 엔드포인트 | 용도 |
|--------|------------|------|
| POST | `/api/admin/backtest/run` | 단일 백테스트 실행(동기) |
| POST | `/api/admin/backtest/run-async` | 단일 백테스트 실행(비동기) (Phase 2) |
| POST | `/api/admin/backtest/run-grid` | 그리드 루프 실행 (Phase 2) |
| GET | `/api/admin/backtest/status/{backtest_id}` | 비동기 작업 상태 조회 (Phase 2) |
| GET | `/api/admin/backtest/compare` | 다중 알고리즘 비교 |
| GET | `/api/admin/backtest/history` | 백테스트 이력 조회 |
| GET | `/api/algorithms/` | 알고리즘 목록 및 **파라미터 스키마** 조회 (SSOT) |
| GET | `/api/algorithms/{id}` | 단일 알고리즘 상세(파라미터 스키마 포함) (권장) |

### 5.2 요청/응답 예시

**GET /api/algorithms/ (SSOT 강화)**

```json
[
  {
    "id": 2,
    "name": "고급 빈도 분석",
    "parameters": {
      "window_size": { "type": "int", "default": 100, "min": 10, "max": 1000 },
      "probability_mode": { "type": "enum", "options": ["normal", "inverse"], "default": "normal" },
      "exclude_consecutive_2": { "type": "bool", "default": false }
    }
  }
]
```

**POST /api/admin/backtest/run**

```json
// Request
{
  "algorithm_id": 2,
  "start_draw": 1000,
  "end_draw": 1100,
  "n_sets": 5,
  "enable_detailed_log": false,
  "algorithm_params": {
    "window_size": 100,
    "exclude_consecutive_2": true,
    "probability_mode": "normal",
    "temperature": 1.0
  }
}

// Response
{
  "backtest_id": "b2b8e9f4-2b66-4a5f-b2a3-7c8a8d7c5c6b",
  "algorithm_name": "고급 빈도 분석",
  "period": { "start": 1000, "end": 1100, "total_draws": 101 },
  "execution_time": 12.34,
  "rank_distribution": { "1": 0, "2": 0, "3": 2, "4": 15, "5": 80, "miss": 408 },
  "win_rate": 0.192,
  "roi": 821.78,
  "composite_score": 89.2,
  "grade": "A+",
  "csv_report_path": "..."
}
```

### 5.3 공통: 표준 에러 응답 (권장)

구현/프론트 처리 일관성을 위해 아래 형식으로 통일한다.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "start_draw must be <= end_draw",
    "details": { "start_draw": 1100, "end_draw": 1000 }
  }
}
```

권장 `error.code` 예시:
- `VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`
- `TOO_MANY_COMBINATIONS`, `TIMEOUT`, `DATA_NOT_READY`, `INTERNAL_ERROR`

### 5.4 GET /api/admin/backtest/compare (응답 예시)

```json
{
  "period": { "start": 1000, "end": 1100, "total_draws": 101 },
  "items": [
    {
      "algorithm_id": 2,
      "algorithm_name": "고급 빈도 분석",
      "rank_distribution": { "1": 0, "2": 0, "3": 2, "4": 15, "5": 80, "miss": 408 },
      "win_rate": 0.192,
      "roi": 821.78,
      "composite_score": 89.2,
      "grade": "A+",
      "execution_time": 12.34
    }
  ],
  "sorted_by": "composite_score_desc"
}
```

### 5.5 POST /api/admin/backtest/run-async (응답 예시) (Phase 2)

```json
{
  "backtest_id": "b2b8e9f4-2b66-4a5f-b2a3-7c8a8d7c5c6b",
  "status": "queued",
  "message": "백테스트가 백그라운드에서 실행 중입니다. GET /api/admin/backtest/status/{backtest_id}로 상태 확인"
}
```

### 5.6 POST /api/admin/backtest/run-grid (요청/응답 예시) (Phase 2)

그리드는 조합 수가 늘기 쉬우므로 **기본 비동기**로 설계한다(권장). 조합 수가 작을 때만 동기 허용.

```json
// Request
{
  "algorithm_id": 2,
  "start_draw": 1000,
  "end_draw": 1100,
  "n_sets": 5,
  "enable_detailed_log": false,
  "grid": {
    "window_size": [100, 200, 300],
    "probability_mode": ["normal", "inverse"],
    "temperature": [0.8, 1.0]
  },
  "max_combinations": 60,
  "enable_cache": true
}

// Response (async)
{
  "backtest_id": "5f1d6f72-ff9d-4e7d-a47e-2b2e2f6d7b51",
  "status": "queued",
  "combinations": 12,
  "message": "그리드 백테스트가 큐에 등록되었습니다. GET /api/admin/backtest/status/{backtest_id}로 상태 확인"
}
```

그리드 결과(완료 시) 최소 포함 필드(권장):
- `best`: 최고 점수 조합 1개
- `items`: 조합별 집계 리스트(필수: params, win_rate, roi, composite_score, grade)

### 5.7 GET /api/admin/backtest/status/{backtest_id} (응답 예시) (Phase 2)

```json
// running
{
  "backtest_id": "5f1d6f72-ff9d-4e7d-a47e-2b2e2f6d7b51",
  "status": "running",
  "progress": 35
}

// completed
{
  "backtest_id": "5f1d6f72-ff9d-4e7d-a47e-2b2e2f6d7b51",
  "status": "completed",
  "result": { "composite_score": 89.2, "grade": "A+", "roi": 821.78 }
}
```

### 5.8 GET /api/admin/backtest/history (응답 정책) (Phase 2)

- 기본: 최근 실행 목록(요약) 반환. 대용량 `detailed_results_json`은 **기본 미포함**(KISS/성능).
- 필요 시 `include_details=true`로 상세 포함(권장, 서버에서 페이징/압축 고려).

---

## 6. 접근 제어 및 보안

### 6.1 인증

- **X-Admin-Token** 헤더 필수
- 관리자 토큰은 환경 변수 `ADMIN_SECRET_TOKEN`으로 설정
- 토큰 입력 UI: 설정 패널 상단 또는 별도 로그인 영역

### 6.2 보안 권장사항

- HTTPS 강제
- IP 화이트리스트 (운영 환경)
- 요청 제한(Rate Limiting)
- 감사 로그 기록 (백테스트 실행 시점, 파라미터)

권장(실수 방지):
- Admin Token을 **localStorage**에 영구 저장하지 말고, 기본은 **sessionStorage** 또는 메모리 보관(세션 종료 시 파기)
- 응답/로그에 Admin Token 값이 노출되지 않도록 필터링

### 6.3 캐시·멱등 (중복방지)

- **캐시 키**: `(algorithm_id, params_hash, start_draw, end_draw)`
- 동일 요청 재실행 시 기존 결과 반환 가능 (선택). `enable_cache` 플래그로 제어.
- 그리드 실행 결과는 `backtest_results` 테이블에 저장 (006 참조). 중복 저장 방지를 위해 `(algorithm_id, params_json, start_draw, end_draw)` 유니크 제약 고려.

> 상세 사항은 `Old/006_Admin_Backtest_System_Design.md` 참조

---

## 7. 구현 우선순위

### Phase 1 (MVP)

| 항목 | 설명 |
|------|------|
| 알고리즘 선택 UI | 멀티셀렉트 또는 체크박스 목록 |
| 회차 범위 입력 | start_draw, end_draw |
| 단일 백테스트 실행 | POST /backtest/run 연동 |
| 결과 표시 | 등수 분포, 당첨률, ROI, 종합 점수 |
| Admin Token 입력 | 로컬 저장(세션) 또는 매 요청 시 입력 |

### Phase 2

| 항목 | 설명 |
|------|------|
| 비교 백테스트 | 2개 이상 알고리즘 선택 시 비교 모드 |
| 그리드 루프 실행 | 알고리즘별 파라미터 조합 루프 (run-grid API) |
| 백테스트 이력 | 최근 실행 목록 조회 |
| 비동기 실행 | 장시간 작업 시 백그라운드 + 상태 조회 (status API) |

### Phase 3

| 항목 | 설명 |
|------|------|
| 리포트 다운로드 | CSV/JSON 링크 |
| 차트/시각화 | 등수 분포 차트, 기간별 성능 그래프 |
| 결과 캐시 | 동일 조건 재실행 시 캐시 반환 (선택) |

---

## 8. 알고리즘별 상세 테스트 구성

파라미터가 있는 알고리즘은 **파라미터 조합 루프 테스트**를 지원한다.  
하나의 알고리즘에서 각 선택지 조합을 모두 시행하고 결과를 비교한다.

> **SSOT 참조**: 채점(등수별 점수, ROI, 종합 점수, 등급)은 `Old/006_Admin_Backtest_System_Design.md`에 정의. 본 섹션은 루프 축(파라미터)만 정의.

### 8.0 공통: Walk-Forward 플로우

예: 분석회차수 100, 특정 조건(필터+확률+무작위성)

```
회차 101: 1~100회 데이터로 분석 → 해당 조건으로 번호 생성 → 101회 당첨번호와 비교
회차 102: 1~101회 데이터로 분석 → 동일 조건으로 번호 생성 → 102회 당첨번호와 비교
...
마지막 회차까지 반복
```

### 8.1 알고리즘별 루프 축 요약

| ID | 알고리즘 | 분석회차수 | 루프 축 (요약) |
|----|----------|------------|----------------|
| 1 | 자동선택 (랜덤) | - | 파라미터 없음, 루프 미적용 |
| 2 | 고급 빈도 분석 | `window_size` | 제외필터, 확률모드, 무작위성 |
| 3 | LSTM 고급 분석 | `window_size` | 학습방식, 확률모드, 무작위성 |
| 4 | 패턴 분석 | `analysis_window_size` | 패턴타입, 구간수/순위설정, 패턴내확률, 패턴선택확률 |
| 5 | 가중치 조합 | `recent_draws` | 빈도/최근성/구간/다양성 가중치 조합 |
| 6 | 기본 빈도 분석 | `recent_draws` | 무작위성(`temperature`) |
| 7 | Hot/Cold | `hot_window`, `cold_window` | hot_count, cold_count |
| 8 | AI 선택 | `window_size` | API 비용·비결정성으로 루프 제한 권장 |

---

### 8.2 고급 빈도 분석 (ID 2)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `window_size` | 100, 200, 300, 400 | 분석 회차 수 |
| B | 제외필터 | 조합 | `exclude_consecutive_2`, `exclude_frequent`, `apply_recent_penalty` |
| C | `probability_mode` | `normal`, `inverse` | 정확률 / 역확률 |
| D | `temperature` | 0.8, 1.0, 1.2 | 무작위성 |

**제외필터 조합**: 연속출현 제외, 고빈도 제외, 직전회차 패널티 (각각 on/off, 조합 가능)

---

### 8.3 LSTM 고급 분석 (ID 3)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `window_size` | 50, 100, 150, 200 | LSTM 시퀀스 길이(분석 회차 수) |
| B | `learning_mode` | `non-cumulative`, `cumulative` | 전체 학습 / 증분 학습 |
| C | `probability_mode` | `normal`, `inverse` | 정확률 / 역확률 |
| D | `temperature` | 0.8, 1.0, 1.2 | 무작위성 |
| E | 모델 구조 (선택) | `hidden_size`, `num_layers` | 128/256, 2/3 등 |

**주의**: LSTM 학습 시간이 길어 조합 수가 많으면 비동기 실행 필수.

---

### 8.4 패턴 분석 (ID 4)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `analysis_window_size` | 50, 100, 200 | 분석 범위 회차 수 |
| B | `pattern_type` | `range`, `rank` | 범위 패턴 / 순위 패턴 |
| C | `range_divisions` (range 시) | 2, 3, 5, 10 | 구간 수 |
| D | `rank_mode` (rank 시) | `cumulative`, `recent` | 누적 / 최근 N회 |
| E | `in_pattern_probability` | `uniform`, `frequency`, `inverse` | 패턴 내 번호 선택 확률 |
| F | `pattern_selection_probability` | `normal`, `inverse` | 패턴 선택 확률 |

---

### 8.5 가중치 조합 (ID 5)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `recent_draws` | 50, 100, 200 | 최근 N회차만 사용 |
| B | 가중치 조합 | 4요소 합=1.0 | `frequency_weight`, `recency_weight`, `zone_weight`, `diversity_weight` |

**가중치 루프 예**: (0.4,0.3,0.2,0.1), (0.3,0.4,0.2,0.1), (0.3,0.3,0.2,0.2) 등 미리 정의된 조합 목록

---

### 8.6 기본 빈도 분석 (ID 6)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `recent_draws` | 50, 100, 200, 300 | 분석 회차 수 |
| B | `temperature` | 0.8, 1.0, 1.2 | 무작위성 |

---

### 8.7 Hot/Cold 분석 (ID 7)

| 축 | 파라미터 | 예시 값 | 설명 |
|----|----------|---------|------|
| A | `hot_window` | 10, 20, 30 | Hot 판단 기준 최근 N회 |
| B | `cold_window` | 30, 50, 100 | Cold 판단 기준 최근 N회 |
| C | `hot_count` | 2, 3, 4 | 6개 중 Hot에서 선택 개수 |
| D | `cold_count` | 2, 3, 4 | 6개 중 Cold에서 선택 개수 |

---

### 8.8 자동선택/랜덤 (ID 1)

파라미터 없음. Walk-Forward 시 매 회차 균등 확률 랜덤 생성 → 베이스라인용.

---

### 8.9 AI 선택 (ID 8)

| 축 | 파라미터 | 예시 값 | 비고 |
|----|----------|---------|------|
| A | `window_size` | 20, 50, 100 | 분석 회차 수 |

**제한**: API 비용·비결정성·지연으로 루프 수 최소화 권장. temperature 등은 설정 파일 기준.

---

### 8.10 루프 설정 UI (공통)

| 항목 | 타입 | 설명 |
|------|------|------|
| 알고리즘 선택 | 드롭다운 | 선택 시 해당 알고리즘의 루프 축만 노출 |
| 각 축별 값 목록 | 쉼표/배열 입력 또는 체크박스 | 예: `100,200,300` 또는 `[정확률, 역확률]` |
| 루프 최대 횟수 | 숫자 (선택) | 조합 과다 시 상한 |
| 예상 조합 수 | 읽기 전용 | 선택값에 따른 총 조합 수 표시 |

### 8.11 결과 표시 및 API

- 각 조합별 **별도 백테스트 결과** (당첨률, ROI, 종합 점수, 등급)
- 조합을 행으로 하는 **비교 테이블** (정렬 가능)
- 최적 조합 강조

**API**: `POST /api/admin/backtest/run-grid` — `algorithm_id`별로 `grid` 구조가 다름(알고리즘 파라미터에 맞춤).

> ※ 조합 수가 많을 경우 비동기 실행 + 상태 조회 권장

#### 8.12 조합 수 상한 및 비동기 기준 (KISS/운영 안정성)

- **조합 수 계산**: 각 축 값 개수의 곱(예: 3×2×2=12)
- **상한(권장)**: 기본 60, 최대 200(운영 환경에서 제한)
- **동기/비동기 기준(권장)**:
  - 조합 수 ≤ 20: 동기 허용(타임아웃 이내)
  - 조합 수 > 20: 비동기 강제 + `status` 폴링
- **AI 선택(ID 8)**: 비용/지연으로 조합 수를 더 낮게 제한(예: 최대 10)

---

## 9. 기술 스택 권장

| 영역 | 권장 | 비고 |
|------|------|------|
| 프론트 | HTML + JS (Vanilla) 또는 React/Vue | Admin 전용이면 단순 정적 HTML도 가능 |
| 스타일 | Tailwind CSS 또는 기존 Admin 테마 | 006 문서의 기본 HTML 스타일 활용 가능 |
| 호스팅 | FastAPI static files 또는 별도 Admin 서브도메인 | `/admin` 경로로 서빙 |

---

## 10. 원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)

### 10.1 중복방지 (Idempotency)

| 항목 | 적용 |
|------|------|
| 동일 백테스트 재실행 | 캐시 키 `(algorithm_id, params_hash, start_draw, end_draw)`로 결과 재사용 가능 |
| 그리드 결과 저장 | `backtest_results` 테이블에 `(algorithm_id, params_json, start_draw, end_draw)` 유니크 제약 또는 중복 체크 후 저장 |
| Admin Token | 한 번 검증 후 세션/로컬 저장으로 재사용 (요청마다 토큰 재검증은 멱등) |

### 10.2 DRY (Don't Repeat Yourself)

| 항목 | 적용 |
|------|------|
| 알고리즘 목록 | `/api/algorithms/` 단일 소스. UI에서 목록 하드코딩 금지 |
| 채점·등급 로직 | 006 문서에 정의. 백엔드 `BacktestService`에서 단일 구현. Admin UI는 결과만 표시 |
| Walk-Forward 엔진 | 단일/비교/그리드 모두 동일 백엔드 `execute_walk_forward()` 호출. 루프만 그리드에서 확장 |
| 파라미터 스키마 | 백엔드 `get_parameter_schema()`(권장) 또는 `/api/algorithms/`가 타입/범위/옵션/UI 힌트까지 제공. 프론트는 스키마로 동적 렌더링(하드코딩 금지). |

### 10.3 SSOT (Single Source of Truth)

| 진실 공급원 | 용도 |
|-------------|------|
| `/api/algorithms/` | 알고리즘 ID·이름·파라미터 목록 |
| **`get_parameter_schema()`** | **(신규 권장)** 파라미터 타입, 유효 범위, 기본값의 유일한 정의처 |
| `Old/006_Admin_Backtest_System_Design.md` | 채점 시스템(RANK_SCORES, ROI, composite_score, grade), API 스펙 |
| `backtest_results` | 백테스트 실행 결과 (이력 조회 SSOT) |

### 10.4 KISS (Keep It Simple, Stupid)

| 항목 | 적용 |
|------|------|
| Phase 1 | 단일·비교만 구현. 그리드는 Phase 2로 분리 |
| 그리드 UI | 알고리즘 선택 시 해당 축만 노출. 복잡한 조건식 없이 단순 조합 루프 |
| 비동기 | 조합 수 > N(예: 20)일 때만 비동기. 그 미만은 동기 응답 |
| 인증 | X-Admin-Token 단일 방식. OAuth·다단계 인증은 추후 |

### 10.5 리팩토링 용이성

| 항목 | 적용 |
|------|------|
| 알고리즘 추가 | 새 알고리즘 등록 시 8.x 섹션 추가만. 공통 grid 런타임은 `algorithm_id`로 분기 |
| 파라미터 변경 | `get_default_parameters()` 수정 시 Admin UI는 API 응답 기반이므로 자동 반영 |
| 채점 변경 | 006 및 `BacktestService`만 수정. Admin UI는 숫자·등급 표시만 |

### 10.6 Schema-Driven UI (SSOT 구현의 핵심)

Admin 페이지는 알고리즘별 파라미터 폼을 하드코딩하지 않는다.
1. `GET /api/algorithms/{id}` 호출
2. 응답의 `parameters` (또는 `schema`) 필드 파싱
3. 타입(`int`, `enum`, `bool`)에 따라 Input, Select, Checkbox 동적 렌더링
4. 이를 통해 백엔드 알고리즘 파라미터 변경 시 프론트 수정 없이 즉시 반영됨

### 10.7 원칙 준수 검증 결과 (PASS 기준)

| 원칙 | 판정 | 근거(섹션/SSOT) |
|------|------|------------------|
| 중복방지(멱등/캐시) | PASS | 6.3, 11.1 (params_hash 유니크), 12.2 (조합 제한) |
| DRY | PASS | 10.2 (엔진/채점/스키마 단일화), 5.x (표준 응답/에러) |
| SSOT | PASS | 10.3, 11 (DB), 5.2 (알고리즘 스키마), 006 참조 |
| KISS | PASS | 1.4(범위/비범위), 7(Phase 분리), 8.12(상한/비동기 기준) |
| 리팩토링 용이성 | PASS | 10.5(변경 영향 최소화), 10.6(스키마 기반 UI) |

---

## 11. 데이터 모델 (SSOT)

본 문서에서는 Admin 백테스트 페이지/플로우 구현에 필요한 수준으로 **요약 스키마**를 포함한다. 상세 구현은 `Old/006_Admin_Backtest_System_Design.md`를 SSOT로 따른다.

### 11.1 `backtest_results` (요약)

필수 필드(권장, 006 기준):
- 식별/설정: `id(UUID)`, `algorithm_id`, `algorithm_name`, `algorithm_params(JSON)`
- 기간/규모: `start_draw`, `end_draw`, `total_draws`, `n_sets_per_draw`, `total_sets_generated`
- 실행: `executed_at`, `execution_time_seconds`, `executed_by`
- 집계/채점: `rank_distribution(JSON)`, `win_rate`, `avg_rank`, `roi(%)`, `composite_score(0~100)`, `grade`
- 상세/리포트: `detailed_results_json(TEXT, 옵션)`, `csv_report_path`, `json_report_path`

인덱스/제약(중복방지 권장):
- `algorithm_id` 인덱스
- 캐시/중복 저장 방지: `(algorithm_id, start_draw, end_draw, params_hash)` 유니크(권장)
  - `params_hash = sha256(canonical_json(algorithm_params))` 형태로 정규화(SSOT 규칙)

### 11.2 `admin_audit_logs` (요약)

- `action`, `user`, `ip_address`, `parameters(JSON)`, `result(success/failed)`, `error_message`, `timestamp`

---

## 12. 에러 규격·검증·제약

### 12.1 입력 검증(서버/클라이언트 공통)

- `start_draw <= end_draw`
- `total_draws = end_draw - start_draw + 1` (양끝 포함)
- `n_sets`: 1~20 (기본 5)
- `algorithm_id`: `/api/algorithms/`에 존재하는 값만 허용
- `algorithm_params`: 스키마에 없는 키 금지(권장), 값 범위/enum 검증
- `grid`: 스키마에서 `grid_allowed=true`인 파라미터만 축으로 허용(권장)

### 12.2 조합/리소스 제한(운영 안정성)

- `max_combinations` 기본 60, 상한 200(운영에서 조정)
- 타임아웃: 동기 run은 서버 타임아웃 내(예: 30~60초)로 제한, 초과 시 `run-async` 유도

### 12.3 오류 처리 원칙(UX)

- 검증 실패: 즉시 폼 필드 단위로 표시 + 표준 에러(`VALIDATION_ERROR`)
- 장시간: 비동기 전환 안내 + status 폴링
- 내부 오류: 사용자 메시지는 간단히, 상세는 서버 로그/감사로그에 기록

---

## 13. 테스트 계획

### 13.1 백엔드

- 요청 검증 테스트: 회차/세트/파라미터 범위/그리드 조합 상한
- 멱등/캐시 테스트: 동일 조건 재실행 시 동일 `backtest_id` 또는 동일 결과 재사용(정책에 따라)
- 상태 조회 테스트: `queued → running → completed/failed`
- 이력 조회 테스트: 기본 요약/상세 포함 옵션, 페이징/limit

### 13.2 프론트(Admin UI)

- 스키마 기반 폼 렌더링 테스트(알고리즘별 파라미터 변경 시 UI 자동 반영)
- 로딩/에러/비동기 상태 UX 테스트(폴링, 완료 표시, 실패 메시지)
- 비교 테이블 정렬/필터/다운로드 링크 표시

---

## 14. 비기능 요구사항(성능/관측/운영)

- **성능**: 상세 로그는 기본 off, 필요 시 선택적으로 포함(대용량 전송 최소화)
- **관측**: 실행 시간, 조합 수, 실패율, timeout 비율을 메트릭으로 수집(권장)
- **로그**: `admin_audit_logs` + 서버 에러 로그(토큰/개인정보 마스킹)
- **운영**: 작업 취소/재시도(Phase 2+), 레이트리밋, IP 제한

---

## 15. 용어/정의

- **Walk-Forward Validation**: 회차 N을 예측할 때 N-1까지의 데이터만 사용하여 시간 누수(look-ahead) 방지
- **n_sets**: 회차당 생성하는 번호 세트 수(구매 장수)
- **ROI(%)**: \((총 당첨금 / 총 구매금액) × 100\). (상세 단가/상금 테이블은 006 SSOT 참조)
- **params_hash**: `algorithm_params`를 정규화(JSON canonical)한 뒤 해시한 값. 캐시/중복방지의 기준 키

---

**관련 문서**

- `Old/006_Admin_Backtest_System_Design.md`: 백엔드·API·채점 시스템 상세 설계
- `034_OAuth_CoinWallet_Plan.md`: 관리자 인증 확장 시 참조
