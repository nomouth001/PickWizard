# 038. 몬테카를로 상위 6개 알고리즘 추가 계획

**문서 번호**: 038  
**작성일**: 2026-02-15  
**대상**: LuckyAI 645 백엔드·모바일 앱  
**목적**: 1~45 랜덤 10,000회 추출 후 출현 빈도 상위 6개를 1세트로 하는 알고리즘 추가, 알고리즘 선택 메뉴에서 **자동선택 아래·출현번호 빈도 기반 선택 위**에 배치

**요약**: 1~45를 한 번에 하나씩 10,000회 랜덤 추출 → 가장 많이 나온 6개 = 1세트. 신규 알고리즘 ID 9, API 목록 표시 순서를 `[1, 9, 2, 3, 4, 5, 6, 7, 8]`로 두어 메뉴에서 자동선택 바로 아래에 노출.

---

## 1. 요구사항 요약

### 1.1 알고리즘 동작

| 항목 | 내용 |
|------|------|
| **로직** | 1~45 범위에서 **한 번에 하나**의 수를 무작위로 뽑는 시행을 **10,000회** 반복 후, 가장 많이 나온 **6개** 번호를 한 세트로 사용 |
| **1세트** | 위 규칙으로 얻은 상위 6개 = 번호 1세트 |
| **n세트** | 동일 로직을 n번 수행하여 n세트 생성 (세트마다 10,000회 시행 독립) |
| **과거 데이터** | 사용하지 않음 (역사 데이터 무관) |
| **파라미터** | 사용자 조정 파라미터 없음 (n_sets, exclude_numbers, include_numbers 등 공통만) |

### 1.2 메뉴 위치

- **위치**: 자동선택(Quick Pick) **아래**, 출현번호 빈도 기반 선택 **위**
- 즉, 알고리즘 목록에서 **2번째**에 노출

---

## 2. 코드베이스 현황

### 2.1 백엔드 알고리즘 구조

| 경로 | 역할 |
|------|------|
| `pick_wizard/backend/app/algorithms/base.py` | `LottoAlgorithm` 추상 클래스, `algorithm_id`, `name`, `description`, `generate_numbers()`, `get_default_parameters()`, `validate_parameters()`, `get_available_numbers()`, `calculate_frequency()` 등 |
| `pick_wizard/backend/app/algorithms/__init__.py` | `load_all_algorithms()`에서 클래스 리스트로 인스턴스 생성 후 `_algorithms[algorithm_id]`에 저장, `get_algorithm_list()`는 `_algorithms.values()` 순서대로 반환 (현재는 등록 순 = ID 순) |
| `pick_wizard/backend/app/algorithms/constants.py` | `LOTTO_MIN_NUMBER`, `LOTTO_MAX_NUMBER`, `LOTTO_NUMBERS_PER_DRAW` 등 |

**현재 알고리즘 목록 (등록 순 = ID 순)**

| ID | 클래스 | 파일 | 표시명 (한글) |
|----|--------|------|----------------|
| 1 | RandomAlgorithm | algorithm_01_random.py | 자동선택 (Quick Pick) |
| 2 | AdvancedFrequencyAlgorithm | algorithm_02_advanced_frequency.py | 출현 번호 빈도 기반 선택 (고급) |
| 3 | AdvancedLSTMAlgorithm | algorithm_03_advanced_lstm.py | 딥러닝 선택 |
| 4 | AdvancedPatternAlgorithm | algorithm_04_advanced_pattern.py | 출현 번호 패턴 기반 선택 |
| 5 | WeightedAlgorithm | algorithm_05_weighted.py | 가중치 조합 선택 |
| 6 | FrequencyAlgorithm | algorithm_06_frequency.py | **출현 번호 빈도 기반 선택** |
| 7 | HotColdAlgorithm | algorithm_07_hot_cold.py | 핫/콜드 넘버 선택 |
| 8 | AISelectionAlgorithm | algorithm_08_ai_selection.py | 인공지능 선택 |

- **출현번호 빈도 기반 선택** = ID **6** (FrequencyAlgorithm).  
- 신규 알고리즘은 **자동선택(1) 아래, 6 위**에 두려면 목록에서 **2번째**여야 함.

### 2.2 API·스키마

| 항목 | 위치 | 내용 |
|------|------|------|
| 목록 API | `GET /api/algorithms/` | `get_algorithm_list()` 결과를 그대로 반환. 현재는 `_algorithms.values()` 순서 = ID 1~8 순. |
| 생성 요청 | `app/schemas/generation.py` | `algorithm_id: int`, `ge=1`, **`le=9`** → ID 9까지 허용 가능. |
| 단일 조회 | `GET /api/algorithms/{algorithm_id}` | `get_algorithm(algorithm_id)` 사용. |

### 2.3 가격 설정

- `pick_wizard/backend/app/config/pricing_config.yaml`  
  - `policies.standard.algorithm_costs`: 1~8만 정의됨.  
  - 새 알고리즘용 ID(9) 항목 추가 필요.  
- `app/services/pricing_service.py`: `algorithm_costs.get(algorithm_id, 0)` → ID 9 미정의 시 0으로 처리 가능.

### 2.4 모바일 앱

| 항목 | 위치 | 내용 |
|------|------|------|
| 알고리즘 목록 | API 응답 사용 | `algo.name` 등은 백엔드에서 오는 값 사용. 목록 **순서**도 API 순서에 따름. |
| 파라미터 UI | `generate_screen.dart` | `algo.id == 2` ~ `algo.id == 8`만 별도 파라미터 블록 있음. `id == 1`은 파라미터 없음. 신규도 파라미터 없으면 **추가 분기만 없어도 됨** (1과 동일하게 처리 가능). |
| 도움말 | `algorithm_help_data.dart` | `AlgorithmHelpData.get(algorithmId)`로 ID별 도움말. 9번 추가 시 9에 대한 항목 필요. |
| 로컬라이제이션 | `app_ko.arb` 등 / generated | `algorithm1Name` ~ `algorithm8Name` 존재. 목록 이름은 API 기준이므로 **선택**적으로 `algorithm9Name` 등 추가 가능. |

### 2.5 Admin 백테스트

- `z_Dev_Docs/036_Admin_Backtest_Page_Plan.md`: 알고리즘 목록은 `GET /api/algorithms/` 기반 동적 로딩.  
- 백테스트 서비스는 `get_algorithm(algorithm_id)` 사용 → ID 9 알고리즘만 추가하면 자동으로 옵션에 포함 가능.

---

## 3. 설계 방안

### 3.1 알고리즘 ID 및 표시 순서

- **신규 알고리즘 ID**: **9**  
  - 기존 2~8 번호 변경 없음.  
  - `generation.py`의 `le=9`로 이미 9 허용.  
- **메뉴 순서**: 자동선택(1) 아래, 출현번호 빈도 기반(6) 위 → 전체 순서  
  **1 → 9 → 2 → 3 → 4 → 5 → 6 → 7 → 8**  
- **구현 방식**:  
  - 백엔드에서 `get_algorithm_list()`가 **고정 표시 순서**를 사용하도록 변경.  
  - 순서: `[1, 9, 2, 3, 4, 5, 6, 7, 8]`.

### 3.2 알고리즘 로직 (백엔드)

- **파일**: `pick_wizard/backend/app/algorithms/algorithm_09_monte_carlo_top6.py` (신규)
- **클래스명**: 예: `MonteCarloTop6Algorithm`
- **상수**  
  - 시행 횟수: `TRIALS_PER_SET = 10_000`  
  - 번호 범위: `constants.LOTTO_MIN_NUMBER`, `LOTTO_MAX_NUMBER`  
  - 세트당 번호 수: `LOTTO_NUMBERS_PER_DRAW` (6)
- **동작**  
  1. `generate_numbers(historical_data, n_sets, exclude_numbers, include_numbers, **kwargs)`  
  2. `validate_parameters()` 호출 (공통).  
  3. `exclude_numbers` / `include_numbers` 반영:  
     - 사용 가능 풀 = 1~45에서 exclude 제거, include는 “이미 선택된 것”으로 간주하고 풀에서 제거한 뒤, 나머지 중에서만 빈도 집계.  
     - 포함 번호가 있으면 “고정 포함 + 나머지 6-k개를 빈도 상위에서 채우기” 방식으로 구현 가능 (요구사항에 따라 “완전 무시”할지 결정).  
  4. 세트별로:  
     - 1~45(또는 사용 가능 풀)에서 **한 번에 하나** 랜덤 추출을 10,000회 수행.  
     - `Counter` 등으로 빈도 계산 후, **가장 많이 나온 6개**를 선택 (동점 시 정렬 기준 명시: 예, 번호 오름차순).  
     - 한 세트 생성.  
  5. `include_numbers`가 있으면 해당 번호를 포함하고, 나머지 자리를 빈도 상위로 채우는 방식으로 통일할 수 있음 (기존 알고리즘들과 동일한 시맨틱).
- **과거 데이터**: 사용하지 않음. `historical_data`는 무시.
- **기본 파라미터**: `get_default_parameters()`는 `n_sets`, `exclude_numbers`, `include_numbers` 등 공통만 반환.

### 3.3 표시 이름·설명 제안

- **이름 (한글)**: `몬테카를로 상위 6개 (Monte Carlo Top 6)` 또는 `반복 랜덤 상위 6개`  
- **설명**: `1~45를 10,000번 무작위로 뽑아 가장 많이 나온 6개를 한 세트로 합니다.`

### 3.4 백엔드 수정 목록

| 순서 | 작업 | 파일/위치 |
|------|------|-----------|
| 1 | 신규 알고리즘 클래스 구현 | `app/algorithms/algorithm_09_monte_carlo_top6.py` |
| 2 | 알고리즘 로더에 클래스 추가 및 목록 표시 순서 적용 | `app/algorithms/__init__.py`: 클래스 등록 + `get_algorithm_list()`에서 `[1,9,2,3,4,5,6,7,8]` 순으로 반환 |
| 3 | 가격 설정 (필요 시) | `app/config/pricing_config.yaml`: `algorithm_costs`에 `9: 0` 또는 `9: 1` 등 |

### 3.5 모바일 앱 수정 목록

| 순서 | 작업 | 파일/위치 |
|------|------|-----------|
| 1 | 알고리즘 9 파라미터 UI | `generate_screen.dart`: algo.id == 9인 경우 파라미터 없음(생략 가능, 1과 동일). 또는 명시적 `else if (algo.id == 9) ...[ ]` 추가. |
| 2 | 도움말 | `algorithm_help_data.dart`: 9번용 `AlgorithmHelp` 추가 및 `getAll()`에 `9: _getMonteCarloTop6Help()` 등 반영. |
| 3 | (선택) 로컬라이제이션 | `app_ko.arb`, `app_en.arb` 등에 `algorithm9Name`, `algorithm9Desc` 추가 후 codegen. 목록은 API 이름 사용하므로 필수는 아님. |

### 3.6 기타

- **Admin 백테스트**: 알고리즘 목록이 API 순서를 쓰므로, 백엔드에서 9번 추가·목록 순서만 적용하면 별도 수정 없이 노출 가능.  
- **DB/저장**: 기존 `algorithm_id` 컬럼 등은 정수형이면 9 저장 가능.  
- **테스트**: 단위 테스트에서 `n_sets=1`, `exclude/include=None`으로 1세트 생성 시 6개 번호, 1~45 범위, 중복 없음 검증.

---

## 4. 구현 시 유의사항

1. **동점 처리**: 10,000회 시행 후 7번째 이후 번호와 6번째 번호가 동점일 수 있음. 정렬 기준을 명확히 할 것 (예: 빈도 내림차순 → 동점이면 번호 오름차순).  
2. **재현성**: 테스트 시 `random.seed` 고정으로 재현 가능하게 할지 결정.  
3. **성능**: 세트당 10,000회 랜덤이므로 n_sets가 크면 부하 증가. 필요 시 배치 크기 제한 또는 비동기 처리 검토.  
4. **표시 순서 SSOT**: 메뉴 순서는 백엔드 `get_algorithm_list()` 반환 순서를 단일 소스로 두고, Admin/모바일은 그대로 사용.

---

## 5. 작업 체크리스트

- [x] 백엔드: `algorithm_09_monte_carlo_top6.py` 구현 (로직, 상수, exclude/include 처리, 동점 처리)
- [x] 백엔드: `__init__.py`에 클래스 등록 및 `get_algorithm_list()` 표시 순서 `[1,9,2,3,4,5,6,7,8]` 적용
- [x] 백엔드: `pricing_config.yaml`에 `9` 항목 추가
- [x] 모바일: `generate_screen.dart`에서 알고리즘 9 파라미터 처리 (없음으로 두거나 빈 블록)
- [x] 모바일: `algorithm_help_data.dart`에 9번 도움말 추가
- [ ] (선택) 모바일: arb/generated에 `algorithm9Name`/`algorithm9Desc` 추가
- [x] 단위/통합 테스트 추가 및 Admin 백테스트에서 9번 선택 동작 확인 (로컬 실행 검증 완료)

---

**참조 문서**: 036 (Admin 백테스트), 037 (백테스트 window_size), code_change_log.md (알고리즘 명칭·ID 이력)
