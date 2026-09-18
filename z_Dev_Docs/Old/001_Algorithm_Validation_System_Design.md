# 로또 알고리즘 검증 시스템 설계서
## Backtesting & Performance Validation Framework

---

**문서 버전**: v1.0  
**작성일**: 2025-12-16  
**프로젝트**: LuckyAI 645  
**목적**: 9가지 알고리즘의 과학적 성능 검증 및 투명성 확보

---

## 📌 1. 검증의 중요성 (Why Validation Matters)

### 1.1 핵심 가치 제안의 근거

```
"우리 앱의 알고리즘이 정말 효과적인가?"
→ 이 질문에 대한 명확한 답변이 필요

투명성 = 경쟁 우위
- 경쟁사: "우리의 특별한 방법" (블랙박스)
- 우리: "1,160회 전체 데이터로 검증 완료" (투명한 증거)
```

### 1.2 검증이 필요한 이유

| 이해관계자 | 필요성 |
|-----------|--------|
| **사용자** | "이 알고리즘을 믿어도 되나?" → 과거 성적 공개로 신뢰 확보 |
| **개발팀** | "어떤 알고리즘이 가장 나은가?" → 데이터 기반 의사결정 |
| **투자자** | "시장 가치가 있나?" → 객관적 성능 증명 |
| **법적 방어** | "사기 아닌가?" → 확률론적 사실 입증 |

### 1.3 검증 목표

✅ **객관성**: 편향 없는 과거 데이터 백테스팅  
✅ **재현성**: 누구나 같은 결과를 얻을 수 있는 스크립트  
✅ **투명성**: 모든 파라미터와 결과 공개  
✅ **통계적 유의성**: 우연과 패턴의 구분  
✅ **지속적 개선**: 새 회차마다 자동 재검증  

---

## 🏗️ 2. 검증 시스템 아키텍처

### 2.1 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Historical Data (1~1169회)                │
│                      lotto_data.csv                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              Validation Engine (검증 엔진)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Walk-Forward Validation (시점 순차 검증)            │   │
│  │  • 회차 1 → 회차 N까지 순차 실행                      │   │
│  │  • 각 회차마다:                                       │   │
│  │    1) 과거 데이터만으로 알고리즘 실행                 │   │
│  │    2) 번호 생성 (5세트)                               │   │
│  │    3) 실제 당첨번호와 비교                            │   │
│  │    4) 등수/매칭 개수 기록                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌───────────┬───────────┬───────────┬──────────────────┐   │
│  │Algorithm 1│Algorithm 2│    ...    │  Algorithm 9     │   │
│  │ (Random)  │  (LSTM)   │           │ (Hybrid)         │   │
│  └───────────┴───────────┴───────────┴──────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│               Evaluator (평가자)                              │
│  • judge_rank(): 등수 판정 (1~5등, 꽝)                       │
│  • calculate_metrics(): 성능 지표 계산                       │
│  • statistical_test(): 통계적 유의성 검증                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              Results Storage (결과 저장)                      │
│  ┌──────────────┬──────────────┬────────────────────────┐   │
│  │  CSV Files   │  Database    │  Visualization         │   │
│  │  (상세 기록)  │  (집계 통계)  │  (그래프/리포트)       │   │
│  └──────────────┴──────────────┴────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 핵심 컴포넌트

#### **1) Data Loader (데이터 로더)**
```python
class LottoDataLoader:
    """
    과거 로또 당첨번호 로드 및 전처리
    """
    def load_historical_data(self, filepath: str) -> pd.DataFrame
    def get_draws_up_to(self, draw_no: int) -> pd.DataFrame
    def validate_data_integrity(self) -> bool
```

#### **2) Algorithm Runner (알고리즘 실행기)**
```python
class AlgorithmRunner:
    """
    각 알고리즘을 동일한 조건으로 실행
    """
    def run_algorithm(
        self,
        algorithm_id: int,
        historical_data: pd.DataFrame,
        params: dict
    ) -> List[List[int]]  # 5세트 반환
```

#### **3) Performance Evaluator (성능 평가기)**
```python
class PerformanceEvaluator:
    """
    생성된 번호와 실제 당첨번호 비교 평가
    """
    def judge_rank(
        self,
        predicted: List[int],
        winning: List[int],
        bonus: int
    ) -> Tuple[int, int, bool]  # (등수, 매칭수, 보너스여부)
    
    def calculate_aggregate_metrics(
        self,
        results: pd.DataFrame
    ) -> dict  # 전체 성능 지표
```

#### **4) Statistical Validator (통계 검증기)**
```python
class StatisticalValidator:
    """
    통계적 유의성 검증
    """
    def chi_square_test(self, results: dict) -> float
    def compare_vs_random(self, algo_results: dict, random_results: dict) -> dict
    def confidence_interval(self, results: list) -> Tuple[float, float]
```

#### **5) Report Generator (리포트 생성기)**
```python
class ReportGenerator:
    """
    시각화 및 리포트 생성
    """
    def generate_performance_chart(self, results: pd.DataFrame) -> str
    def create_comparison_table(self, all_results: dict) -> pd.DataFrame
    def export_html_report(self, output_path: str) -> None
```

---

## 🔬 3. Walk-Forward Validation 방법론

### 3.1 검증 원칙

#### **시간 누수 방지 (No Time Leakage)**
```
❌ 잘못된 방법:
   전체 데이터 (1~1169회) 학습 → 과거 회차 예측
   → 미래 정보 유출로 성능 과대평가

✅ 올바른 방법:
   100회 예측 시: 1~99회만 사용
   101회 예측 시: 1~100회만 사용
   ...
   → 실제 사용 환경과 동일한 조건
```

### 3.2 검증 프로세스

```python
# 의사 코드 (Pseudo Code)

for draw_no in range(START_DRAW, LATEST_DRAW + 1):
    
    # Step 1: 해당 회차 이전 데이터만 로드
    historical_data = load_draws_up_to(draw_no - 1)
    
    # Step 2: 실제 당첨번호 로드 (비교용)
    actual_winning = load_draw(draw_no)
    
    # Step 3: 각 알고리즘 실행
    for algorithm in ALGORITHMS:
        
        # 3-1: 번호 생성 (5세트)
        predictions = algorithm.generate(
            data=historical_data,
            n_sets=5
        )
        
        # 3-2: 각 세트 평가
        for idx, predicted_numbers in enumerate(predictions):
            rank, matched, has_bonus = judge_rank(
                predicted_numbers,
                actual_winning.numbers,
                actual_winning.bonus
            )
            
            # 3-3: 결과 기록
            save_result(
                draw_no=draw_no,
                algorithm_id=algorithm.id,
                set_no=idx + 1,
                predicted=predicted_numbers,
                rank=rank,
                matched_count=matched,
                has_bonus=has_bonus
            )
    
    # Step 4: 진행률 출력
    print(f"✓ {draw_no}회차 검증 완료")
```

### 3.3 검증 시나리오

#### **시나리오 A: 전체 회차 검증 (Full Backtest)**
```yaml
대상: 1회차 ~ 1169회차 전체
목적: 장기 성능 평가
소요시간: 약 30분 ~ 2시간 (알고리즘 복잡도에 따라)
용도:
  - 초기 알고리즘 성능 벤치마크
  - 리포트 생성용 데이터
  - 사용자 공개용 통계
```

#### **시나리오 B: 최근 N회차 검증 (Rolling Window)**
```yaml
대상: 최근 100회차 (1070 ~ 1169회)
목적: 최신 트렌드 반영 성능 확인
소요시간: 약 3~5분
용도:
  - 빠른 성능 비교
  - 알고리즘 파라미터 튜닝
  - A/B 테스트
```

#### **시나리오 C: 단일 회차 검증 (Single Draw)**
```yaml
대상: 특정 1개 회차 (예: 1169회)
목적: 디버깅 및 테스트
소요시간: 약 1~5초
용도:
  - 알고리즘 버그 수정
  - 새 알고리즘 프로토타입 테스트
```

---

## 📊 4. 평가 지표 (Performance Metrics)

### 4.1 기본 지표 (Primary Metrics)

#### **1) 등수별 당첨 횟수**
```python
metrics = {
    "rank_1": 0,    # 1등 (6개 일치)
    "rank_2": 0,    # 2등 (5개 + 보너스)
    "rank_3": 0,    # 3등 (5개)
    "rank_4": 0,    # 4등 (4개)
    "rank_5": 0,    # 5등 (3개)
    "matched_2": 0, # 2개 일치
    "matched_1": 0, # 1개 일치
    "matched_0": 0  # 0개 일치
}
```

#### **2) 평균 매칭 개수**
```python
avg_matched = total_matched_numbers / total_sets
# 예: 3000세트에서 총 6500개 매칭 → 평균 2.17개
```

#### **3) 당첨 확률 (실측값)**
```python
실측_5등_확률 = rank_5_count / total_sets
기준_5등_확률 = 0.02244  # 이론값 2.244%

성능_지수 = 실측_확률 / 기준_확률
# > 1.0 이면 기준보다 우수
# < 1.0 이면 기준보다 부족
```

### 4.2 고급 지표 (Advanced Metrics)

#### **1) Hit Rate (적중률)**
```python
# 적어도 1개 이상 맞춘 비율
hit_rate = (total_sets - matched_0) / total_sets

# 예: 1000세트 중 520세트가 1개 이상 맞춤 → 52%
```

#### **2) Expected Value (기대값)**
```python
# 가상 상금으로 계산한 기대 수익
EV = (rank_1_count × 2_000_000_000 +
      rank_2_count × 50_000_000 +
      rank_3_count × 1_500_000 +
      rank_4_count × 50_000 +
      rank_5_count × 5_000) / total_sets

# 실제 구매 비용 (1000원) 대비 수익률
ROI = (EV - 1000) / 1000 × 100  # %
```

**⚠️ 주의**: 
- 실제 상금은 회차마다 다름 (판매액에 따라)
- 이 지표는 **상대 비교용**이며 실제 수익 보장 아님

#### **3) Consistency Score (일관성 점수)**
```python
# 100회차 단위로 성능 표준편차 계산
# 낮을수록 안정적

windows = split_into_windows(results, window_size=100)
performance_scores = [calc_score(w) for w in windows]
consistency = 1 / np.std(performance_scores)
```

#### **4) Sharpe Ratio (샤프 비율)**
```python
# 금융에서 차용: 변동성 대비 수익률

avg_return = np.mean(returns_per_draw)
std_return = np.std(returns_per_draw)
risk_free_rate = 0  # 로또는 무위험 수익 없음

sharpe = (avg_return - risk_free_rate) / std_return
```

### 4.3 비교 지표 (Comparative Metrics)

#### **알고리즘 간 순위표**
```python
# 예시 결과
┌─────────────┬────────┬────────┬─────────┬──────────┐
│ Algorithm   │ Rank 5 │ Avg    │ Hit     │ Overall  │
│             │ Count  │ Match  │ Rate    │ Score    │
├─────────────┼────────┼────────┼─────────┼──────────┤
│ Algorithm 2 │   68   │  2.35  │  48.2%  │  ⭐⭐⭐⭐  │
│ Algorithm 6 │   65   │  2.31  │  47.8%  │  ⭐⭐⭐⭐  │
│ Algorithm 1 │   63   │  2.28  │  47.1%  │  ⭐⭐⭐   │
│ Algorithm 8 │   61   │  2.25  │  46.5%  │  ⭐⭐⭐   │
│ ...         │  ...   │  ...   │  ...    │  ...     │
└─────────────┴────────┴────────┴─────────┴──────────┘
```

---

## 🛠️ 5. 검증 스크립트 설계

### 5.1 디렉토리 구조

```
project_root/
├── validation/
│   ├── __init__.py
│   ├── validator.py          # 메인 검증 엔진
│   ├── evaluator.py          # 평가 로직
│   ├── metrics.py            # 지표 계산
│   ├── statistical_tests.py # 통계 검증
│   ├── report_generator.py  # 리포트 생성
│   └── config.yaml           # 검증 설정
│
├── algorithms/
│   ├── __init__.py
│   ├── base.py               # 추상 베이스 클래스
│   ├── algorithm_01.py       # 랜덤
│   ├── algorithm_02.py       # LSTM 단순
│   ├── ...
│   └── algorithm_09.py       # 하이브리드
│
├── data/
│   ├── lotto_data.csv        # 원본 데이터
│   └── preprocessed/         # 전처리 데이터
│
├── results/
│   ├── raw/                  # 상세 결과 CSV
│   │   ├── validation_20251216_150530.csv
│   │   └── ...
│   ├── aggregated/           # 집계 결과
│   │   ├── algorithm_performance_summary.csv
│   │   └── comparison_matrix.csv
│   └── reports/              # HTML/PDF 리포트
│       ├── full_report_20251216.html
│       └── charts/
│           ├── rank_distribution.png
│           ├── performance_trend.png
│           └── ...
│
└── scripts/
    ├── run_full_validation.py       # 전체 검증 실행
    ├── run_quick_test.py            # 빠른 테스트
    ├── compare_algorithms.py        # 알고리즘 비교
    └── generate_report.py           # 리포트만 재생성
```

### 5.2 핵심 스크립트

#### **5.2.1 메인 검증 스크립트**

**`scripts/run_full_validation.py`**
```python
#!/usr/bin/env python3
"""
전체 회차 알고리즘 검증 스크립트

Usage:
    python run_full_validation.py --algorithms 1,2,6 --start 1 --end 1169
    python run_full_validation.py --quick  # 최근 100회차만
"""

import argparse
from datetime import datetime
from pathlib import Path
import pandas as pd
from tqdm import tqdm

from validation.validator import LottoValidator
from validation.report_generator import ReportGenerator


def parse_args():
    parser = argparse.ArgumentParser(description="로또 알고리즘 검증")
    
    parser.add_argument(
        '--algorithms',
        type=str,
        default='1,2,3,4,5,6,7,8,9',
        help='검증할 알고리즘 ID (쉼표 구분, 예: 1,2,6)'
    )
    
    parser.add_argument(
        '--start',
        type=int,
        default=1,
        help='시작 회차 (기본: 1)'
    )
    
    parser.add_argument(
        '--end',
        type=int,
        default=None,
        help='종료 회차 (기본: 최신 회차)'
    )
    
    parser.add_argument(
        '--quick',
        action='store_true',
        help='빠른 검증 (최근 100회차만)'
    )
    
    parser.add_argument(
        '--n-sets',
        type=int,
        default=5,
        help='회차당 생성할 번호 세트 수 (기본: 5)'
    )
    
    parser.add_argument(
        '--output-dir',
        type=str,
        default='results',
        help='결과 저장 디렉토리'
    )
    
    return parser.parse_args()


def main():
    args = parse_args()
    
    # 알고리즘 ID 파싱
    algo_ids = [int(x.strip()) for x in args.algorithms.split(',')]
    
    # Validator 초기화
    validator = LottoValidator(
        data_path='data/lotto_data.csv',
        output_dir=args.output_dir
    )
    
    # 회차 범위 설정
    if args.quick:
        latest_draw = validator.get_latest_draw_no()
        start_draw = latest_draw - 99
        end_draw = latest_draw
        print(f"🚀 빠른 검증 모드: {start_draw}~{end_draw}회차")
    else:
        start_draw = args.start
        end_draw = args.end or validator.get_latest_draw_no()
        print(f"🔬 전체 검증 모드: {start_draw}~{end_draw}회차")
    
    # 검증 실행
    print(f"\n📊 검증할 알고리즘: {algo_ids}")
    print(f"📦 회차당 세트 수: {args.n_sets}")
    print(f"⏱️  예상 소요 시간: {estimate_time(algo_ids, start_draw, end_draw)}\n")
    
    results = validator.run_validation(
        algorithm_ids=algo_ids,
        start_draw=start_draw,
        end_draw=end_draw,
        n_sets_per_draw=args.n_sets,
        verbose=True
    )
    
    # 결과 저장
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = Path(args.output_dir) / 'raw' / f'validation_{timestamp}.csv'
    results.to_csv(output_file, index=False, encoding='utf-8-sig')
    print(f"\n✅ 상세 결과 저장: {output_file}")
    
    # 집계 및 리포트 생성
    print("\n📈 집계 통계 생성 중...")
    report_gen = ReportGenerator(results)
    
    summary = report_gen.generate_summary()
    summary_file = Path(args.output_dir) / 'aggregated' / 'algorithm_performance_summary.csv'
    summary.to_csv(summary_file, index=False, encoding='utf-8-sig')
    print(f"✅ 집계 결과 저장: {summary_file}")
    
    # HTML 리포트
    print("\n📄 HTML 리포트 생성 중...")
    report_html = Path(args.output_dir) / 'reports' / f'full_report_{timestamp}.html'
    report_gen.export_html_report(report_html)
    print(f"✅ 리포트 저장: {report_html}")
    
    # 터미널에 요약 출력
    print("\n" + "="*80)
    print("📊 검증 결과 요약")
    print("="*80)
    report_gen.print_summary()
    
    print("\n✨ 검증 완료!")


def estimate_time(algo_ids, start, end):
    """예상 소요 시간 계산"""
    n_draws = end - start + 1
    n_algos = len(algo_ids)
    
    # 알고리즘별 평균 소요 시간 (초)
    time_per_draw = {
        1: 0.01,  # Random
        2: 0.5,   # LSTM
        6: 0.02,  # Frequency
        # ... 나머지 추가
    }
    
    total_seconds = sum(time_per_draw.get(aid, 0.1) for aid in algo_ids) * n_draws
    
    if total_seconds < 60:
        return f"약 {total_seconds:.0f}초"
    elif total_seconds < 3600:
        return f"약 {total_seconds/60:.1f}분"
    else:
        return f"약 {total_seconds/3600:.1f}시간"


if __name__ == '__main__':
    main()
```

#### **5.2.2 Validator 클래스**

**`validation/validator.py`**
```python
"""
로또 알고리즘 검증 엔진
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import List, Dict, Tuple
from tqdm import tqdm
import importlib

from validation.evaluator import PerformanceEvaluator


class LottoValidator:
    """
    Walk-forward validation을 수행하는 메인 클래스
    """
    
    def __init__(self, data_path: str, output_dir: str = 'results'):
        self.data_path = Path(data_path)
        self.output_dir = Path(output_dir)
        self.evaluator = PerformanceEvaluator()
        
        # 데이터 로드
        self.full_data = pd.read_csv(self.data_path, encoding='utf-8-sig')
        print(f"✓ 데이터 로드: {len(self.full_data)}회차")
        
        # 알고리즘 동적 로드
        self.algorithms = {}
        self._load_algorithms()
    
    def _load_algorithms(self):
        """알고리즘 모듈을 동적으로 로드"""
        for i in range(1, 10):
            try:
                module = importlib.import_module(f'algorithms.algorithm_{i:02d}')
                self.algorithms[i] = module.Algorithm()
                print(f"✓ 알고리즘 {i} 로드")
            except ImportError:
                print(f"⚠ 알고리즘 {i} 미구현")
    
    def get_latest_draw_no(self) -> int:
        """최신 회차 번호 반환"""
        return self.full_data['회차'].max()
    
    def get_historical_data(self, up_to_draw: int) -> pd.DataFrame:
        """특정 회차까지의 데이터만 반환 (시간 누수 방지)"""
        return self.full_data[self.full_data['회차'] < up_to_draw].copy()
    
    def get_winning_numbers(self, draw_no: int) -> Tuple[List[int], int]:
        """특정 회차의 당첨번호와 보너스 반환"""
        row = self.full_data[self.full_data['회차'] == draw_no].iloc[0]
        winning = [row[f'번호{i}'] for i in range(1, 7)]
        bonus = row['보너스']
        return winning, bonus
    
    def run_validation(
        self,
        algorithm_ids: List[int],
        start_draw: int,
        end_draw: int,
        n_sets_per_draw: int = 5,
        verbose: bool = True
    ) -> pd.DataFrame:
        """
        Walk-forward validation 실행
        
        Args:
            algorithm_ids: 검증할 알고리즘 ID 리스트
            start_draw: 시작 회차
            end_draw: 종료 회차
            n_sets_per_draw: 회차당 생성할 번호 세트 수
            verbose: 진행 상황 출력 여부
        
        Returns:
            검증 결과 DataFrame
        """
        results = []
        
        # 진행바 설정
        total_iterations = (end_draw - start_draw + 1) * len(algorithm_ids)
        pbar = tqdm(total=total_iterations, desc="검증 진행") if verbose else None
        
        for draw_no in range(start_draw, end_draw + 1):
            
            # 실제 당첨번호
            winning_numbers, bonus = self.get_winning_numbers(draw_no)
            
            # 과거 데이터만 로드 (시간 누수 방지)
            historical_data = self.get_historical_data(draw_no)
            
            if len(historical_data) < 10:
                # 데이터가 너무 적으면 건너뛰기
                continue
            
            for algo_id in algorithm_ids:
                
                if algo_id not in self.algorithms:
                    print(f"⚠ 알고리즘 {algo_id} 없음. 건너뜀.")
                    if pbar:
                        pbar.update(1)
                    continue
                
                algorithm = self.algorithms[algo_id]
                
                # 번호 생성
                try:
                    predictions = algorithm.generate_numbers(
                        historical_data=historical_data,
                        n_sets=n_sets_per_draw
                    )
                except Exception as e:
                    print(f"\n❌ 알고리즘 {algo_id}, 회차 {draw_no} 오류: {e}")
                    if pbar:
                        pbar.update(1)
                    continue
                
                # 각 세트 평가
                for set_no, predicted in enumerate(predictions, start=1):
                    rank, matched_count, has_bonus = self.evaluator.judge_rank(
                        predicted, winning_numbers, bonus
                    )
                    
                    results.append({
                        'draw_no': draw_no,
                        'algorithm_id': algo_id,
                        'set_no': set_no,
                        'predicted': str(predicted),
                        'winning': str(winning_numbers),
                        'bonus': bonus,
                        'rank': rank,
                        'matched_count': matched_count,
                        'has_bonus': has_bonus
                    })
                
                if pbar:
                    pbar.update(1)
        
        if pbar:
            pbar.close()
        
        return pd.DataFrame(results)
```

#### **5.2.3 Evaluator 클래스**

**`validation/evaluator.py`**
```python
"""
성능 평가 로직
"""

from typing import List, Tuple


class PerformanceEvaluator:
    """
    로또 번호 세트 평가 클래스
    """
    
    @staticmethod
    def judge_rank(
        predicted: List[int],
        winning: List[int],
        bonus: int
    ) -> Tuple[int, int, bool]:
        """
        등수 판정
        
        Args:
            predicted: 예측 번호 (6개)
            winning: 당첨 번호 (6개)
            bonus: 보너스 번호
        
        Returns:
            (등수, 매칭 개수, 보너스 포함 여부)
            등수: 1~5 (당첨), 0 (꽝)
        """
        matched = set(predicted) & set(winning)
        matched_count = len(matched)
        has_bonus = bonus in predicted
        
        # 등수 판정
        if matched_count == 6:
            rank = 1
        elif matched_count == 5 and has_bonus:
            rank = 2
        elif matched_count == 5:
            rank = 3
        elif matched_count == 4:
            rank = 4
        elif matched_count == 3:
            rank = 5
        else:
            rank = 0  # 꽝
        
        return rank, matched_count, has_bonus
    
    @staticmethod
    def calculate_aggregate_metrics(results_df) -> dict:
        """
        집계 통계 계산
        
        Args:
            results_df: 검증 결과 DataFrame
        
        Returns:
            집계 지표 dict
        """
        total_sets = len(results_df)
        
        metrics = {
            'total_sets': total_sets,
            'rank_1': (results_df['rank'] == 1).sum(),
            'rank_2': (results_df['rank'] == 2).sum(),
            'rank_3': (results_df['rank'] == 3).sum(),
            'rank_4': (results_df['rank'] == 4).sum(),
            'rank_5': (results_df['rank'] == 5).sum(),
            'matched_0': (results_df['matched_count'] == 0).sum(),
            'matched_1': (results_df['matched_count'] == 1).sum(),
            'matched_2': (results_df['matched_count'] == 2).sum(),
            'avg_matched': results_df['matched_count'].mean(),
            'hit_rate': ((results_df['matched_count'] > 0).sum() / total_sets * 100)
        }
        
        # 확률 계산
        metrics['rank_5_prob'] = metrics['rank_5'] / total_sets * 100
        
        # 기준 대비 성능
        baseline_rank5_prob = 2.244  # 이론값
        metrics['performance_index'] = metrics['rank_5_prob'] / baseline_rank5_prob
        
        return metrics
```

### 5.3 설정 파일

**`validation/config.yaml`**
```yaml
# 검증 설정 파일

validation:
  # 기본 검증 범위
  default_start_draw: 1
  default_end_draw: null  # null이면 최신 회차까지
  
  # 회차당 생성 세트 수
  n_sets_per_draw: 5
  
  # 빠른 검증 모드
  quick_mode:
    enabled: true
    window_size: 100  # 최근 100회차
  
  # 알고리즘별 파라미터
  algorithm_params:
    2:  # LSTM
      window_size: 100
      hidden_size: 128
      num_layers: 2
      learning_rate: 0.001
    
    8:  # 최근 빈도 기반
      recent_window: 50
      exclude_consecutive: true

# 평가 지표
metrics:
  primary:
    - rank_distribution
    - avg_matched_count
    - hit_rate
  
  advanced:
    - expected_value
    - consistency_score
    - sharpe_ratio

# 리포트 생성
report:
  format: html
  include_charts: true
  chart_types:
    - rank_distribution_bar
    - performance_trend_line
    - algorithm_comparison_radar
    - matched_count_histogram
  
  export_csv: true
  export_json: true

# 통계 검증
statistical_tests:
  chi_square:
    enabled: true
    significance_level: 0.05
  
  compare_vs_random:
    enabled: true
    n_bootstrap: 1000
```

---

## 📈 6. 결과 저장 및 시각화

### 6.1 결과 CSV 포맷

#### **상세 결과 (raw)**
```csv
draw_no,algorithm_id,set_no,predicted,winning,bonus,rank,matched_count,has_bonus
1160,1,1,"[5, 12, 23, 31, 38, 42]","[7, 13, 22, 27, 32, 40]",35,0,1,False
1160,1,2,"[3, 15, 19, 28, 36, 44]","[7, 13, 22, 27, 32, 40]",35,0,0,False
1160,2,1,"[7, 14, 22, 30, 35, 41]","[7, 13, 22, 27, 32, 40]",35,0,2,True
...
```

#### **집계 결과 (aggregated)**
```csv
algorithm_id,algorithm_name,total_sets,rank_1,rank_2,rank_3,rank_4,rank_5,avg_matched,hit_rate,performance_index
1,Random,5845,0,0,0,8,130,2.15,47.3,1.02
2,LSTM Simple,5845,0,0,0,9,145,2.35,49.1,1.14
6,Frequency,5845,0,0,0,7,138,2.28,48.5,1.09
...
```

### 6.2 시각화 차트

#### **1) 등수별 분포 (막대 그래프)**
```python
import matplotlib.pyplot as plt
import seaborn as sns

def plot_rank_distribution(results_df, output_path):
    """알고리즘별 등수 분포"""
    
    rank_counts = results_df.groupby(['algorithm_id', 'rank']).size().unstack(fill_value=0)
    
    fig, ax = plt.subplots(figsize=(12, 6))
    rank_counts.plot(kind='bar', stacked=False, ax=ax)
    
    ax.set_title('알고리즘별 등수 분포', fontsize=16, fontweight='bold')
    ax.set_xlabel('알고리즘 ID', fontsize=12)
    ax.set_ylabel('횟수', fontsize=12)
    ax.legend(title='등수', labels=['꽝', '5등', '4등', '3등', '2등', '1등'])
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()
```

#### **2) 시간에 따른 성능 트렌드 (꺾은선 그래프)**
```python
def plot_performance_trend(results_df, output_path):
    """회차별 평균 매칭 개수 추이"""
    
    trend = results_df.groupby(['draw_no', 'algorithm_id'])['matched_count'].mean().unstack()
    
    fig, ax = plt.subplots(figsize=(14, 7))
    
    for algo_id in trend.columns:
        ax.plot(trend.index, trend[algo_id], 
                label=f'Algorithm {algo_id}', 
                marker='o', markersize=2, alpha=0.7)
    
    ax.set_title('시간에 따른 성능 변화 (평균 매칭 개수)', fontsize=16, fontweight='bold')
    ax.set_xlabel('회차', fontsize=12)
    ax.set_ylabel('평균 매칭 개수', fontsize=12)
    ax.legend(loc='best')
    ax.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300)
    plt.close()
```

#### **3) 알고리즘 비교 레이더 차트**
```python
def plot_algorithm_comparison_radar(metrics_dict, output_path):
    """
    다차원 성능 비교 (레이더 차트)
    
    metrics_dict 예시:
    {
        1: {'hit_rate': 47.3, 'avg_matched': 2.15, 'rank_5_rate': 2.22, ...},
        2: {'hit_rate': 49.1, 'avg_matched': 2.35, 'rank_5_rate': 2.56, ...},
        ...
    }
    """
    from math import pi
    
    categories = ['Hit Rate', 'Avg Matched', 'Rank 5 Rate', 'Consistency', 'Sharpe']
    N = len(categories)
    
    angles = [n / float(N) * 2 * pi for n in range(N)]
    angles += angles[:1]
    
    fig, ax = plt.subplots(figsize=(10, 10), subplot_kw=dict(polar=True))
    
    for algo_id, metrics in metrics_dict.items():
        values = [
            metrics['hit_rate'],
            metrics['avg_matched'] * 10,  # 스케일 조정
            metrics['rank_5_rate'],
            metrics['consistency'] * 20,
            metrics['sharpe'] * 10
        ]
        values += values[:1]
        
        ax.plot(angles, values, 'o-', linewidth=2, label=f'Algorithm {algo_id}')
        ax.fill(angles, values, alpha=0.15)
    
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(categories)
    ax.set_title('알고리즘 다차원 성능 비교', size=16, fontweight='bold', pad=20)
    ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))
    ax.grid(True)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
```

### 6.3 HTML 리포트 템플릿

**`validation/templates/report.html`**
```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로또 알고리즘 검증 리포트</title>
    <style>
        body {
            font-family: 'Malgun Gothic', sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .summary-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .metric-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .metric-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            text-align: center;
        }
        .metric-value {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        .metric-label {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background-color: #667eea;
            color: white;
            font-weight: bold;
        }
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎯 로또 알고리즘 검증 리포트</h1>
        <p>생성일시: {{ timestamp }}</p>
        <p>검증 범위: {{ start_draw }}회 ~ {{ end_draw }}회 (총 {{ total_draws }}회차)</p>
    </div>

    <div class="summary-card">
        <h2>📊 전체 요약</h2>
        <div class="metric-grid">
            <div class="metric-item">
                <div class="metric-value">{{ total_algorithms }}</div>
                <div class="metric-label">검증 알고리즘 수</div>
            </div>
            <div class="metric-item">
                <div class="metric-value">{{ total_sets }}</div>
                <div class="metric-label">생성된 총 세트 수</div>
            </div>
            <div class="metric-item">
                <div class="metric-value">{{ best_algorithm }}</div>
                <div class="metric-label">최고 성능 알고리즘</div>
            </div>
            <div class="metric-item">
                <div class="metric-value">{{ avg_hit_rate }}%</div>
                <div class="metric-label">평균 적중률</div>
            </div>
        </div>
    </div>

    <div class="summary-card">
        <h2>🏆 알고리즘별 성능 순위</h2>
        {{ performance_table }}
    </div>

    <div class="chart-container">
        <h2>📈 등수별 분포</h2>
        <img src="charts/rank_distribution.png" alt="등수 분포">
    </div>

    <div class="chart-container">
        <h2>📉 성능 트렌드</h2>
        <img src="charts/performance_trend.png" alt="성능 트렌드">
    </div>

    <div class="chart-container">
        <h2>🕸️ 다차원 비교</h2>
        <img src="charts/algorithm_comparison_radar.png" alt="레이더 차트">
    </div>

    <div class="summary-card">
        <h2>⚠️ 주의사항</h2>
        <ul>
            <li>이 리포트는 과거 데이터 기반 백테스팅 결과입니다.</li>
            <li>로또는 독립 시행이므로 과거 성능이 미래를 보장하지 않습니다.</li>
            <li>모든 알고리즘은 기준 확률(이론값)을 크게 벗어나지 못합니다.</li>
            <li>교육 및 연구 목적으로만 사용하세요.</li>
        </ul>
    </div>
</body>
</html>
```

---

## 🧪 7. 통계적 유의성 검증

### 7.1 카이제곱 검정 (Chi-Square Test)

```python
from scipy.stats import chisquare

def chi_square_test(observed_counts, expected_probs, total_sets):
    """
    관측된 등수 분포가 이론 확률과 유의미하게 다른지 검증
    
    H0 (귀무가설): 알고리즘은 랜덤과 동일하다
    H1 (대립가설): 알고리즘은 랜덤과 다르다
    """
    
    # 기대 빈도
    expected_counts = [prob * total_sets for prob in expected_probs]
    
    # 카이제곱 통계량 계산
    chi2_stat, p_value = chisquare(observed_counts, expected_counts)
    
    # 유의수준 0.05에서 판정
    is_significant = p_value < 0.05
    
    return {
        'chi2_statistic': chi2_stat,
        'p_value': p_value,
        'is_significant': is_significant,
        'interpretation': 'H0 기각 (랜덤과 다름)' if is_significant else 'H0 채택 (랜덤과 유사)'
    }
```

### 7.2 부트스트랩 신뢰구간 (Bootstrap Confidence Interval)

```python
import numpy as np

def bootstrap_confidence_interval(data, n_bootstrap=10000, confidence=0.95):
    """
    부트스트랩으로 평균 매칭 개수의 신뢰구간 추정
    """
    
    bootstrap_means = []
    
    for _ in range(n_bootstrap):
        sample = np.random.choice(data, size=len(data), replace=True)
        bootstrap_means.append(np.mean(sample))
    
    lower = np.percentile(bootstrap_means, (1 - confidence) / 2 * 100)
    upper = np.percentile(bootstrap_means, (1 + confidence) / 2 * 100)
    
    return {
        'mean': np.mean(data),
        'ci_lower': lower,
        'ci_upper': upper,
        'confidence': confidence
    }
```

### 7.3 알고리즘 간 유의성 검정 (t-test)

```python
from scipy.stats import ttest_ind

def compare_algorithms(algo1_results, algo2_results):
    """
    두 알고리즘의 평균 매칭 개수가 유의미하게 다른지 검증
    """
    
    t_stat, p_value = ttest_ind(
        algo1_results['matched_count'],
        algo2_results['matched_count']
    )
    
    is_different = p_value < 0.05
    
    return {
        't_statistic': t_stat,
        'p_value': p_value,
        'is_different': is_different,
        'conclusion': '유의미한 차이 있음' if is_different else '유의미한 차이 없음'
    }
```

---

## 🔄 8. 지속적 검증 파이프라인 (CI/CD)

### 8.1 자동화 전략

```yaml
# .github/workflows/validation.yml (GitHub Actions 예시)

name: Weekly Lotto Validation

on:
  schedule:
    - cron: '0 0 * * 6'  # 매주 토요일 자정
  workflow_dispatch:  # 수동 실행도 가능

jobs:
  validate:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Crawl latest draw
        run: |
          python scripts/update_lotto_data.py
      
      - name: Run validation (quick mode)
        run: |
          python scripts/run_full_validation.py --quick
      
      - name: Generate report
        run: |
          python scripts/generate_report.py
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: validation-report
          path: results/reports/
      
      - name: Notify Slack (optional)
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ 로또 알고리즘 검증 완료!"
            }
```

### 8.2 모니터링 대시보드

```python
# scripts/update_dashboard.py
"""
검증 결과를 실시간 대시보드에 업데이트
"""

import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd

def update_live_dashboard(results_df):
    """
    Plotly Dash로 실시간 대시보드 업데이트
    """
    
    # 최근 100회차 성능 트렌드
    recent = results_df[results_df['draw_no'] > results_df['draw_no'].max() - 100]
    
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('등수 분포', '평균 매칭 추이', '알고리즘 순위', 'Hit Rate')
    )
    
    # ... 차트 생성 로직 ...
    
    # HTML로 저장
    fig.write_html('dashboard/index.html')
    
    print("✅ 대시보드 업데이트 완료: dashboard/index.html")
```

---

## 📋 9. 구현 계획 (Implementation Plan)

### 9.1 Phase 1: 기본 검증 시스템 (1주)

**목표**: 단일 알고리즘 검증 가능

- [ ] Day 1-2: 프로젝트 구조 설정
  - 디렉토리 생성
  - 기본 클래스 스켈레톤
  - 데이터 로더 구현

- [ ] Day 3-4: Validator 핵심 로직
  - Walk-forward validation 구현
  - 시간 누수 방지 검증
  - 알고리즘 1 (Random) 통합 테스트

- [ ] Day 5-6: Evaluator 구현
  - 등수 판정 로직
  - 기본 지표 계산
  - CSV 저장 기능

- [ ] Day 7: 통합 테스트
  - 전체 파이프라인 검증
  - 버그 수정
  - 문서화

### 9.2 Phase 2: 다중 알고리즘 지원 (1주)

**목표**: 9개 알고리즘 전체 검증

- [ ] Day 1-3: 알고리즘 2~9 포팅
  - Trial02 코드 → 새 구조로 리팩토링
  - 각 알고리즘 단위 테스트
  - 파라미터 튜닝

- [ ] Day 4-5: 병렬 처리 최적화
  - 멀티프로세싱 구현
  - 진행률 표시 개선
  - 메모리 최적화

- [ ] Day 6-7: 전체 회차 검증 실행
  - 1~1169회 전체 백테스팅
  - 결과 검증 및 분석
  - 이슈 수정

### 9.3 Phase 3: 시각화 & 리포트 (1주)

**목표**: 프로페셔널 리포트 생성

- [ ] Day 1-2: 차트 생성 모듈
  - Matplotlib 기반 4가지 차트
  - 스타일 통일
  - 고해상도 저장

- [ ] Day 3-4: HTML 리포트
  - 템플릿 디자인
  - 동적 데이터 삽입
  - 반응형 레이아웃

- [ ] Day 5-6: 통계 검증 추가
  - 카이제곱 검정
  - 부트스트랩 CI
  - t-test 비교

- [ ] Day 7: 최종 통합
  - 전체 파이프라인 실행
  - 최종 리포트 생성
  - 공개용 샘플 제작

### 9.4 Phase 4: 자동화 & 고도화 (1주)

**목표**: CI/CD 파이프라인 구축

- [ ] Day 1-2: GitHub Actions 설정
  - 주간 자동 검증
  - 결과 아카이브
  - 슬랙 알림

- [ ] Day 3-4: 대시보드 구축
  - Plotly Dash 웹 대시보드
  - 실시간 업데이트
  - 공개 URL 배포

- [ ] Day 5-6: 모바일 앱 통합
  - API 엔드포인트 구현
  - 검증 결과 DB 저장
  - 앱에서 조회 기능

- [ ] Day 7: 문서화 & 배포
  - README 작성
  - API 문서화
  - 첫 공식 릴리스

---

## 🎯 10. 성공 기준 (Success Criteria)

### 10.1 기술적 기준

✅ **정확성**
- 등수 판정 100% 정확 (수동 검증 100건)
- 시간 누수 0건 (코드 리뷰 통과)

✅ **성능**
- 전체 회차 검증 < 2시간 (1169회 × 9알고리즘)
- 빠른 모드 검증 < 5분 (최근 100회)

✅ **안정성**
- 1000회 연속 실행 시 오류 0건
- 메모리 누수 없음

### 10.2 비즈니스 기준

✅ **투명성**
- 모든 알고리즘 성능 공개
- 재현 가능한 결과

✅ **신뢰성**
- 통계적 검증 포함
- 기준 확률 대비 비교

✅ **사용성**
- 1-command 실행 가능
- 리포트 자동 생성

---

## 📝 11. 결론

### 11.1 핵심 요약

이 검증 시스템은 다음을 보장합니다:

1. **과학적 엄밀성**: Walk-forward validation으로 시간 누수 방지
2. **투명성**: 모든 결과와 코드 공개
3. **재현성**: 누구나 같은 결과를 얻을 수 있음
4. **자동화**: 새 회차마다 자동 재검증
5. **시각화**: 직관적인 리포트와 차트

### 11.2 차별화 포인트

```
경쟁사: "우리 알고리즘이 최고입니다!" (증거 없음)

우리: "1,169회 전체 데이터로 검증했습니다.
      Algorithm 2가 평균 2.35개 맞췄고,
      5등 확률이 이론값 대비 14% 높았습니다.
      전체 결과는 여기서 확인하세요 (링크)"
```

→ **이것이 우리의 경쟁 우위입니다.**

### 11.3 Next Steps

1. ✅ 이 설계서 승인
2. ⬜ Phase 1 개발 시작 (1주일)
3. ⬜ 첫 검증 결과 확보 (2주 후)
4. ⬜ 모바일 앱에 통합 (3주 후)
5. ⬜ 공개용 샘플 리포트 제작 (4주 후)

---

**문서 끝 | 2025-12-16 작성**

> 💡 **"검증 가능한 것만이 신뢰받는다"** - 이것이 우리 플랫폼의 철학입니다.

