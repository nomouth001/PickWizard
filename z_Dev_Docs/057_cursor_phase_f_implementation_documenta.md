# Phase F implementation documentation
_Exported on 5/9/2026 at 18:06:30 EDT from Cursor (3.3.27)_

---

**User**

이제 @z_Dev_Docs/055_cursor_codebase_implementation_review.md:471-473 phase F를 진행하자. 기획서, 상세설계, 상세구현계획, 상세 시험항목 정의, 통과/실패 기준 설정, 자동시험설정 및 계획 설계, 각 구현단계별 커서 ide의 모토모델에 시킬지, thknk모델에 시킬지와 각 단계별 시행지시 프롬프트작성까지 전부 056 문서로 작성하라.

---

**Cursor**

먼저 관련 문서들을 읽어서 현재 상태를 파악하겠습니다.

이제 기존 구현 코드들을 확인하겠습니다.

현재 구현 코드도 확인하겠습니다.

이제 전체 설계를 파악했습니다. 056 문서를 작성하겠습니다.

작성 완료했습니다. 문서를 확인하겠습니다.

**1,167줄** 분량의 `056_PhaseF_Annuity720_기획설계구현시험.md` 문서 작성이 완료됐습니다.

---

## 문서 구성 요약

### 기획서 (§1~§2)
- 볼 픽 방식과 시리얼 방식의 구조적 차이 명시
- 기존 `GeneratedNumbers` 필드를 **변경 없이** 재활용하는 설계 결정
  - `results[i].numbers` = 6자리 숫자 [d0~d5]
  - `bonusBalls[i]` = 조(1~5) 저장

### 상세설계 (§3)
- `GameCategory` enum (`ballPick` / `serial`) 신규 레이어
- `GameTypeId.annuity720` — **반드시 enum 끝에 추가** (Hive index 4 보장, 기존 데이터 호환)
- `GameType.isSerial` / `isBallPick` getter
- `dbSchemaVersion` 변경 없음 (스키마 호환 유지)
- `DigitBox` / `SerialNumberRow` 신규 위젯 설계

### 구현 단계 (§4) — STEP F-0 ~ F-9 (10단계)
| Think 모델 | Auto 모델 |
|-----------|-----------|
| F-1 (GameCategory 아키텍처) | F-0, F-2, F-4~F-9 |
| F-3 (시리얼 생성 로직) | |

### 시험항목 (§5) — 총 56개 신규 테스트
기존 90개 포함 **총 약 142개** 예측

### 통과/실패 기준 (§6), 자동시험 계획 (§7)
- `flutter test` 전체 PASS + 기존 회귀 유지
- CI 실행 7단계 명령 순서 정의

### 실행 프롬프트 (§9) — STEP F-0 ~ F-9 전체
각 STEP별로 `[구현]`, `[시험]`, `[실행]`, `완료 기준`을 포함한 붙여넣기 즉시 사용 가능한 프롬프트.

---

진행할 때는 **STEP F-0 (사전 확인)** 부터 순서대로 진행하면 됩니다. F-1, F-3은 Think 모델로, 나머지는 Auto 모델로 실행하면 됩니다.

