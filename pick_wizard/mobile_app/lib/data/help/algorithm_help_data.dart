/// 알고리즘 및 파라미터 도움말 데이터
/// 
/// 2026-01-17 EST - Phase 5-2: 도움말 시스템 구현

/// 파라미터 도움말
class ParameterHelp {
  final String name;
  final String description;
  final String effect;
  final String recommendation;

  const ParameterHelp({
    required this.name,
    required this.description,
    required this.effect,
    required this.recommendation,
  });
}

/// 알고리즘 도움말
class AlgorithmHelp {
  final int algorithmId;
  final String name;
  final String overview;
  final String howItWorks;
  final String whenToUse;
  final Map<String, ParameterHelp> parameters;

  const AlgorithmHelp({
    required this.algorithmId,
    required this.name,
    required this.overview,
    required this.howItWorks,
    required this.whenToUse,
    required this.parameters,
  });
}

/// 알고리즘 도움말 데이터
class AlgorithmHelpData {
  static Map<int, AlgorithmHelp> getAll() {
    return {
      1: _getQuickPickHelp(),
      2: _getAdvancedFrequencyHelp(),
      3: _getLstmHelp(),
      4: _getPatternHelp(),
      5: _getWeightedHelp(),
      6: _getFrequencyHelp(),
      7: _getHotColdHelp(),
      8: _getAISelectionHelp(),
      9: _getMonteCarloTop6Help(), // 038
    };
  }

  static AlgorithmHelp? get(int algorithmId) {
    return getAll()[algorithmId];
  }

  /// 시리얼(연금720+) 알고리즘 9 — 오프라인 홈 도움말 본문은 l10n(`serialAlgorithm9*`)으로 표시.
  /// 다이얼로그 표시 여부만 위해 빈 문자열 플레이스홀더를 둔다.
  static AlgorithmHelp getSerial9() {
    return const AlgorithmHelp(
      algorithmId: 9,
      name: '',
      overview: '',
      howItWorks: '',
      whenToUse: '',
      parameters: {},
    );
  }

  /// 알고리즘 1: 자동선택 (Quick Pick)
  static AlgorithmHelp _getQuickPickHelp() {
    return const AlgorithmHelp(
      algorithmId: 1,
      name: '자동선택 (Quick Pick)',
      overview: '완전한 무작위로 번호를 생성합니다. 모든 번호가 동일한 확률로 선택됩니다.',
      howItWorks: '1부터 45까지의 숫자 중 무작위로 6개를 선택합니다. '
          '통계나 패턴을 고려하지 않으며, 각 번호는 독립적으로 선택됩니다.',
      whenToUse: '특별한 전략 없이 순수하게 운에 맡기고 싶을 때 사용하세요. '
          '무료이며 가장 빠르게 번호를 생성할 수 있습니다.',
      parameters: {},
    );
  }

  /// 알고리즘 2: 출현 번호 빈도 기반 선택 (고급)
  static AlgorithmHelp _getAdvancedFrequencyHelp() {
    return const AlgorithmHelp(
      algorithmId: 2,
      name: '출현 번호 빈도 기반 선택 (고급)',
      overview: '과거 당첨 번호의 출현 빈도를 심층 분석하여 확률적으로 번호를 선택합니다.',
      howItWorks: '1. 설정한 범위의 과거 데이터를 분석합니다.\n'
          '2. 각 번호의 출현 빈도를 계산합니다.\n'
          '3. 설정한 필터를 적용하여 특정 번호를 제외합니다.\n'
          '4. 확률 모드와 온도에 따라 최종 번호를 선택합니다.',
      whenToUse: '과거 데이터의 패턴을 믿고, 세밀한 조정을 통해 나만의 전략을 만들고 싶을 때 사용하세요.',
      parameters: {
        'window_type': ParameterHelp(
          name: '데이터 범위',
          description: '분석에 사용할 데이터의 범위를 설정합니다.',
          effect: '전체 데이터: 모든 과거 회차 분석\n최근 N회차: 최근 트렌드 반영',
          recommendation: '최근 100~150회차를 추천합니다.',
        ),
        'window_type_all': ParameterHelp(
          name: '전체 데이터',
          description: '전체 과거 당첨 데이터를 모두 사용하여 분석합니다.',
          effect: '장기적인 패턴과 전체적인 경향성을 반영합니다.',
          recommendation: '안정적인 장기 패턴을 원할 때 선택하세요.',
        ),
        'window_type_recent': ParameterHelp(
          name: '최근 N회차',
          description: '최근 N회차의 데이터만 사용하여 분석합니다.',
          effect: '최신 트렌드와 최근 경향성을 중점적으로 반영합니다.',
          recommendation: '최근 패턴 변화를 반영하고 싶을 때 선택하세요.',
        ),
        'window_size': ParameterHelp(
          name: '회차 수',
          description: '최근 몇 회차의 데이터를 분석할지 설정합니다.',
          effect: '클수록: 장기 패턴 반영\n작을수록: 최신 트렌드 반영',
          recommendation: '일반적으로 100회차가 적당합니다.',
        ),
        'exclude_consecutive_2': ParameterHelp(
          name: '연속 출현 제외',
          description: '직전 2회차에 연속으로 나온 번호를 제외합니다.',
          effect: '체크: 최근 자주 나온 번호 회피\n해제: 모든 번호 후보 포함',
          recommendation: '보수적인 전략을 원한다면 체크하세요.',
        ),
        'exclude_frequent': ParameterHelp(
          name: '고빈도 번호 제외',
          description: '특정 기간 동안 너무 자주 나온 번호를 제외합니다.',
          effect: '체크: 과도하게 많이 나온 번호 회피\n해제: 빈도와 관계없이 선택',
          recommendation: '"회귀 평균" 전략을 원한다면 체크하세요.',
        ),
        'frequent_lookback': ParameterHelp(
          name: '조회 회차',
          description: '고빈도 판정을 위해 조회할 최근 회차 수입니다.',
          effect: '클수록: 장기간 고빈도 번호 제외\n작을수록: 단기 고빈도만 제외',
          recommendation: '10~20회차를 추천합니다.',
        ),
        'frequent_threshold': ParameterHelp(
          name: '출현 기준',
          description: '몇 회 이상 나오면 고빈도로 판정할지 설정합니다.',
          effect: '높을수록: 더 적은 번호 제외\n낮을수록: 더 많은 번호 제외',
          recommendation: '5회를 기준으로 하세요.',
        ),
        'apply_recent_penalty': ParameterHelp(
          name: '직전 회차 확률 할인',
          description: '직전 회차에 나온 번호의 선택 확률을 낮춥니다.',
          effect: '체크: 직전 번호 확률 감소\n해제: 동일한 확률 유지',
          recommendation: '직전 번호 중복을 피하고 싶다면 체크하세요.',
        ),
        'penalty_rate': ParameterHelp(
          name: '할인율',
          description: '직전 회차 번호의 확률을 얼마나 낮출지 설정합니다.',
          effect: '높을수록: 약한 할인 (70%: 30% 감소)\n낮을수록: 강한 할인 (30%: 70% 감소)',
          recommendation: '50%를 기본으로 조정하세요.',
        ),
        'probability_mode': ParameterHelp(
          name: '확률 모드',
          description: '빈도 높은 번호를 우선할지, 낮은 번호를 우선할지 설정합니다.',
          effect: '정확률: 자주 나온 번호 우선\n역확률: 적게 나온 번호 우선',
          recommendation: '일반적으로 정확률을 사용하세요.',
        ),
        'probability_mode_normal': ParameterHelp(
          name: '정확률',
          description: '빈도가 높은 번호일수록 높은 확률로 선택됩니다.',
          effect: '자주 나온 번호가 계속 나올 것이라는 전략입니다.',
          recommendation: '"핫 넘버" 전략을 선호한다면 선택하세요.',
        ),
        'probability_mode_inverse': ParameterHelp(
          name: '역확률',
          description: '빈도가 낮은 번호일수록 높은 확률로 선택됩니다.',
          effect: '적게 나온 번호가 이제 나올 차례라는 전략입니다.',
          recommendation: '"콜드 넘버" 전략을 선호한다면 선택하세요.',
        ),
        'temperature': ParameterHelp(
          name: '무작위성',
          description: '선택의 무작위성 정도를 조절합니다.',
          effect: '낮을수록: 고빈도 번호에 집중\n높을수록: 더 무작위적',
          recommendation: '1.0이 표준값이며, 0.8~1.2를 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 3: 딥러닝 선택
  static AlgorithmHelp _getLstmHelp() {
    return const AlgorithmHelp(
      algorithmId: 3,
      name: '딥러닝 선택',
      overview: '딥러닝이 과거 당첨 번호의 패턴을 학습하여 번호를 선택합니다.',
      howItWorks: '1. 과거 당첨 번호를 시계열 데이터로 변환합니다.\n'
          '2. 딥러닝 신경망으로 패턴을 학습합니다.\n'
          '3. 학습된 모델로 다음 번호의 출현 가능성을 분석합니다.\n'
          '4. 분석 결과에 따라 최종 번호를 선택합니다.\n\n'
          '💡 학습 방식: 항상 전체 데이터로 처음부터 학습합니다 (정확도 우선).',
      whenToUse: 'AI 기술을 활용한 고급 분석을 원하고, 시간적 패턴이 존재한다고 믿을 때 사용하세요. '
          '학습에 시간이 걸릴 수 있습니다.',
      parameters: {
        // 2026-01-17 19:15:00 EST - learning_mode 관련 도움말 제거
        // UI에서 학습 방식 선택이 숨겨졌으므로 도움말도 제거
        // (백엔드 파라미터는 유지됨)
        'probability_mode': ParameterHelp(
          name: '확률 방식',
          description: '분석 결과를 어떻게 해석할지 선택합니다.',
          effect: '정확률: 높은 확률 번호 우선\n역확률: 낮은 확률 번호 우선',
          recommendation: '일반적으로 정확률을 사용하세요.',
        ),
        'probability_mode_normal': ParameterHelp(
          name: '정확률',
          description: '모델이 예측한 높은 확률의 번호를 우선 선택합니다.',
          effect: 'AI가 "다음에 나올 가능성이 높다"고 판단한 번호를 선택합니다. '
              '일반적인 예측 방식입니다.',
          recommendation: '대부분의 경우 이 옵션을 사용하세요.',
        ),
        'probability_mode_inverse': ParameterHelp(
          name: '역확률',
          description: '모델이 예측한 낮은 확률의 번호를 우선 선택합니다.',
          effect: 'AI가 "다음에 나올 가능성이 낮다"고 판단한 번호를 역으로 선택합니다. '
              '반대 전략을 사용할 때 유용합니다.',
          recommendation: '실험적인 전략으로, 정확률이 잘 안 맞을 때 시도해보세요.',
        ),
        'window_size': ParameterHelp(
          name: '학습 범위',
          description: '학습에 사용할 과거 회차 수입니다.',
          effect: '클수록: 더 많은 데이터 학습 (느림)\n작을수록: 최근 데이터만 학습 (빠름)',
          recommendation: '100~150회차를 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 4: 출현 번호 패턴 기반 선택
  static AlgorithmHelp _getPatternHelp() {
    return const AlgorithmHelp(
      algorithmId: 4,
      name: '출현 번호 패턴 기반 선택',
      overview: '과거 당첨 번호의 패턴(구간 분포 또는 순위 조합)을 분석하여 유사한 패턴으로 번호를 생성합니다.',
      howItWorks: '1. 과거 당첨 번호를 패턴으로 변환합니다.\n'
          '   - 범위 패턴: 1-9(L), 10-18(M), 19-27(H) 등 구간 분포\n'
          '   - 순위 패턴: 빈도 1위, 3위, 5위 등 순위 조합\n'
          '2. 가장 자주 나타난 패턴을 찾습니다.\n'
          '3. 해당 패턴에 맞는 번호를 선택합니다.',
      whenToUse: '번호가 구간별로 균등하게 분포하거나, 빈도 순위에 규칙이 있다고 믿을 때 사용하세요.',
      parameters: {
        'pattern_type': ParameterHelp(
          name: '패턴 타입',
          description: '어떤 종류의 패턴을 분석할지 선택합니다.',
          effect: '범위 패턴: 구간 분포 분석 (1-9, 10-18 등)\n'
              '순위 패턴: 빈도 순위 조합 분석',
          recommendation: '일반적으로 범위 패턴이 이해하기 쉽습니다.',
        ),
        'pattern_type_range': ParameterHelp(
          name: '범위 패턴',
          description: '1~45를 여러 구간으로 나누어 구간별 분포 패턴을 분석합니다.',
          effect: '예: 저번호 2개 + 중번호 3개 + 고번호 1개 같은 패턴을 찾아 '
              '유사한 구간 분포로 번호를 생성합니다.',
          recommendation: '초보자도 이해하기 쉬운 직관적인 방식입니다.',
        ),
        'pattern_type_rank': ParameterHelp(
          name: '순위 패턴',
          description: '빈도 순위 조합(예: 1위, 5위, 10위)을 패턴으로 분석합니다.',
          effect: '예: 과거에 "1위+3위+7위" 조합이 자주 나왔다면, '
              '현재 빈도 순위 1위, 3위, 7위 번호를 선택합니다.',
          recommendation: '고급 사용자를 위한 방식으로, 빈도 순위에 규칙이 있다고 믿을 때 사용하세요.',
        ),
        'range_divisions': ParameterHelp(
          name: '구간 수',
          description: '1~45를 몇 개 구간으로 나눌지 설정합니다.',
          effect: '2구간: 저번호(L)/고번호(H)\n'
              '3구간: 저/중/고\n'
              '5구간: A~E로 세분화',
          recommendation: '5구간이 가장 균형잡혀 있습니다.',
        ),
        'rank_combo_size': ParameterHelp(
          name: '조합 크기',
          description: '순위 패턴에서 몇 개의 순위를 조합으로 볼지 설정합니다.',
          effect: '2개: (1위, 3위) 등 단순 조합\n'
              '5개: (1위, 2위, 5위, 10위, 20위) 등 복잡한 조합',
          recommendation: '3개를 추천합니다.',
        ),
        'rank_mode': ParameterHelp(
          name: '순위 계산 방식',
          description: '빈도 순위를 어떻게 계산할지 선택합니다.',
          effect: '누적 빈도: 전체 데이터 기준 순위\n최근 빈도: 최근 N회차 기준 순위',
          recommendation: '최근 50회차 기준을 추천합니다.',
        ),
        'rank_mode_cumulative': ParameterHelp(
          name: '누적 빈도',
          description: '전체 과거 데이터를 기준으로 빈도 순위를 계산합니다.',
          effect: '로또 시작부터 현재까지 모든 회차의 출현 횟수를 집계하여 순위를 매깁니다. '
              '장기적인 통계적 패턴을 반영합니다.',
          recommendation: '안정적인 장기 트렌드를 원할 때 사용하세요.',
        ),
        'rank_mode_recent': ParameterHelp(
          name: '최근 빈도',
          description: '최근 N회차만을 기준으로 빈도 순위를 계산합니다.',
          effect: '최근 데이터만 사용하므로 단기 트렌드를 잘 반영합니다. '
              '최근에 자주 나온 번호가 높은 순위를 받습니다.',
          recommendation: '최근 트렌드를 중요시할 때 사용하세요. 일반적으로 50회차를 권장합니다.',
        ),
        'rank_window': ParameterHelp(
          name: '최근 회차',
          description: '최근 빈도 모드에서 사용할 회차 수입니다.',
          effect: '클수록: 장기 트렌드 반영\n작을수록: 단기 트렌드 반영',
          recommendation: '50회차를 추천합니다.',
        ),
        'top_n_patterns': ParameterHelp(
          name: '패턴 수',
          description: '상위 몇 개의 패턴을 고려할지 설정합니다.',
          effect: '작을수록: 가장 빈번한 패턴만 사용\n클수록: 다양한 패턴 고려',
          recommendation: '10개를 추천합니다.',
        ),
        'in_pattern_probability': ParameterHelp(
          name: '패턴 내 선택 방식',
          description: '패턴이 정해진 후 구체적인 번호를 선택하는 방법입니다.',
          effect: '균등: 패턴 내 모든 번호 동일 확률\n'
              '빈도 기반: 자주 나온 번호 우선\n'
              '역확률: 적게 나온 번호 우선',
          recommendation: '빈도 기반을 추천합니다.',
        ),
        'in_pattern_probability_uniform': ParameterHelp(
          name: '균등 (패턴 내)',
          description: '패턴 내에서 모든 후보 번호를 동일한 확률로 선택합니다.',
          effect: '예: 저번호 구간(1-9)에서 선택할 때, 1~9번이 모두 동일한 확률을 가집니다. '
              '가장 공정한 방식입니다.',
          recommendation: '특별한 편향 없이 공정하게 선택하고 싶을 때 사용하세요.',
        ),
        'in_pattern_probability_frequency': ParameterHelp(
          name: '빈도 기반 (패턴 내)',
          description: '패턴 내에서 과거에 자주 나온 번호를 우선적으로 선택합니다.',
          effect: '예: 저번호 구간에서 선택할 때, 1~9 중 과거에 많이 나온 번호가 더 높은 확률을 가집니다.',
          recommendation: '패턴 + 빈도를 동시에 고려하는 추천 방식입니다.',
        ),
        'in_pattern_probability_inverse': ParameterHelp(
          name: '역확률 (패턴 내)',
          description: '패턴 내에서 과거에 적게 나온 번호를 우선적으로 선택합니다.',
          effect: '예: 저번호 구간에서 선택할 때, 1~9 중 적게 나온 번호가 더 높은 확률을 가집니다. '
              '"이제 나올 때가 됐다"는 전략입니다.',
          recommendation: '실험적인 역발상 전략으로, 고급 사용자에게 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 5: 가중치 조합 선택
  static AlgorithmHelp _getWeightedHelp() {
    return const AlgorithmHelp(
      algorithmId: 5,
      name: '가중치 조합 선택',
      overview: '빈도, 최근성, 구간 균형, 다양성 등 여러 요소를 가중치로 조합하여 종합적으로 번호를 선택합니다.\n\n'
          '💡 자동 정규화: 가중치 합계가 100%를 넘거나 미달해도 괜찮습니다! '
          '시스템이 자동으로 비율을 유지하며 100%로 맞춰줍니다.',
      howItWorks: '1. 각 번호에 대해 4가지 점수를 계산합니다:\n'
          '   - 빈도 점수: 자주 나온 번호일수록 높음\n'
          '   - 최근성 점수: 최근에 나온 번호일수록 높음\n'
          '   - 구간 균형 점수: 구간 분포가 균등할 때 높음\n'
          '   - 다양성 점수: 홀짝/끝자리가 다양할 때 높음\n'
          '2. 설정한 가중치로 점수를 합산합니다.\n'
          '3. 최종 점수가 높은 번호를 선택합니다.\n\n'
          '📊 자동 정규화 예시:\n'
          '   입력: 빈도 50%, 최근성 40%, 구간 30%, 다양성 30% (합계 150%)\n'
          '   → 자동 조정: 33.3%, 26.7%, 20%, 20% (합계 100%)\n'
          '   → 비율 유지: 5 : 4 : 3 : 3',
      whenToUse: '여러 전략을 동시에 적용하고, 가중치를 조절하며 나만의 밸런스를 찾고 싶을 때 사용하세요. '
          '합계 100%를 맞추려 애쓰지 마세요! 중요도 비율만 조정하면 됩니다.',
      parameters: {
        'frequency_weight': ParameterHelp(
          name: '빈도 가중치',
          description: '과거 출현 빈도를 얼마나 중요하게 볼지 설정합니다. '
              '합계를 신경쓰지 말고, 다른 가중치 대비 상대적 중요도만 설정하세요.',
          effect: '높을수록: 자주 나온 번호 우선\n낮을수록: 빈도 무시\n\n'
              '예: 빈도를 최근성의 2배 중요하게 생각한다면, '
              '빈도 0.4, 최근성 0.2로 설정 (합계는 자동 조정)',
          recommendation: '30%를 기본으로 하거나, 다른 가중치와의 비율로 생각하세요.',
        ),
        'recency_weight': ParameterHelp(
          name: '최근성 가중치',
          description: '최근 출현 여부를 얼마나 중요하게 볼지 설정합니다.',
          effect: '높을수록: 최근 나온 번호 우선\n낮을수록: 최근성 무시',
          recommendation: '30%를 기본으로 하세요.',
        ),
        'zone_weight': ParameterHelp(
          name: '구간 균형 가중치',
          description: '구간 분포의 균형을 얼마나 중요하게 볼지 설정합니다.',
          effect: '높을수록: 1-15, 16-30, 31-45 구간에서 골고루 선택\n낮을수록: 구간 무시',
          recommendation: '20%를 기본으로 하세요.',
        ),
        'diversity_weight': ParameterHelp(
          name: '다양성 가중치',
          description: '홀짝, 끝자리 다양성을 얼마나 중요하게 볼지 설정합니다.',
          effect: '높을수록: 홀짝 균형, 끝자리 다양 우선\n낮을수록: 다양성 무시',
          recommendation: '20%를 기본으로 하세요.',
        ),
        'recent_draws': ParameterHelp(
          name: '분석 범위',
          description: '최근 몇 회차의 데이터를 분석할지 설정합니다.',
          effect: '클수록: 장기 패턴 반영\n작을수록: 최신 트렌드 반영',
          recommendation: '100회차를 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 6: 출현 번호 빈도 기반 선택
  static AlgorithmHelp _getFrequencyHelp() {
    return const AlgorithmHelp(
      algorithmId: 6,
      name: '출현 번호 빈도 기반 선택',
      overview: '과거에 자주 나온 번호를 우선적으로 선택하는 간단한 전략입니다.',
      howItWorks: '1. 최근 N회차의 데이터를 수집합니다.\n'
          '2. 각 번호의 출현 횟수를 계산합니다.\n'
          '3. 빈도가 높은 번호일수록 높은 확률로 선택됩니다.\n'
          '4. 무작위성 설정에 따라 선택 확률을 조절합니다.',
      whenToUse: '간단한 전략으로 자주 나온 번호를 선호할 때 사용하세요. 초보자에게 추천합니다.',
      parameters: {
        'recent_draws': ParameterHelp(
          name: '분석 회차',
          description: '몇 회차의 과거 데이터를 분석할지 설정합니다.',
          effect: '클수록: 장기적인 패턴 반영\n작을수록: 최근 트렌드 반영',
          recommendation: '일반적으로 100회차가 적당합니다.',
        ),
        'temperature': ParameterHelp(
          name: '무작위성',
          description: '선택의 무작위성 정도를 조절합니다.',
          effect: '낮을수록: 고빈도 번호에 집중\n높을수록: 더 무작위적',
          recommendation: '1.0이 표준값이며, 0.8~1.2 범위를 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 7: 핫/콜드 넘버 선택
  static AlgorithmHelp _getHotColdHelp() {
    return const AlgorithmHelp(
      algorithmId: 7,
      name: '핫/콜드 넘버 선택',
      overview: '최근 자주 나온 "Hot" 번호와 오랫동안 나오지 않은 "Cold" 번호를 조합하여 선택합니다.',
      howItWorks: '1. Hot 번호: 최근 N회차에서 가장 자주 나온 번호\n'
          '2. Cold 번호: 최근 M회차 동안 나오지 않은 번호\n'
          '3. Hot에서 X개, Cold에서 Y개 선택\n'
          '4. 나머지는 랜덤으로 선택하여 6개를 완성합니다.',
      whenToUse: '"뜨거운 번호"와 "차가운 번호"를 균형있게 조합하고 싶을 때 사용하세요. '
          '양쪽 전략을 동시에 취할 수 있습니다.',
      parameters: {
        'hot_window': ParameterHelp(
          name: 'Hot 분석 회차',
          description: 'Hot 번호를 찾기 위해 분석할 최근 회차 수입니다.',
          effect: '작을수록: 단기 핫 번호\n클수록: 장기 핫 번호',
          recommendation: '20회차를 추천합니다.',
        ),
        'hot_count': ParameterHelp(
          name: 'Hot 선택 개수',
          description: 'Hot 번호를 몇 개 선택할지 설정합니다.',
          effect: '많을수록: 핫 번호 비중 증가\n적을수록: 다양성 증가',
          recommendation: '2~3개를 추천합니다.',
        ),
        'cold_window': ParameterHelp(
          name: 'Cold 분석 회차',
          description: 'Cold 번호를 찾기 위해 분석할 회차 수입니다.',
          effect: '클수록: 더 오래 나오지 않은 번호\n작을수록: 최근에만 안 나온 번호',
          recommendation: '50회차를 추천합니다.',
        ),
        'cold_count': ParameterHelp(
          name: 'Cold 선택 개수',
          description: 'Cold 번호를 몇 개 선택할지 설정합니다.',
          effect: '많을수록: 콜드 번호 비중 증가\n적을수록: 다양성 증가',
          recommendation: '2개를 추천합니다.',
        ),
      },
    );
  }

  /// 알고리즘 8: 인공지능 선택
  static AlgorithmHelp _getAISelectionHelp() {
    return const AlgorithmHelp(
      algorithmId: 8,
      name: '인공지능 선택',
      overview: '대규모 언어 모델(AI)이 과거 당첨 번호 데이터를 학습하고 패턴을 분석하여 '
          '번호를 추천하는 알고리즘입니다. 복잡한 통계적 관계와 패턴을 AI가 자동으로 발견하고 '
          '이를 바탕으로 번호를 생성합니다.',
      // 2026-01-18 21:30:00 EST - "200회차" 하드코딩 제거
      // Backend config.py의 AI_SELECTION_WINDOW_SIZE (현재 100)
      howItWorks: '1. 최근 100회차의 당첨 번호 데이터를 AI에 전송합니다.\n'
          '2. AI가 통계적 패턴, 빈도, 분포 등을 종합적으로 분석합니다.\n'
          '3. 분석 결과를 바탕으로 추천 번호를 생성합니다.\n\n'
          '주의: AI 응답 생성에 3~10초가 소요될 수 있습니다.',
      whenToUse: '• AI의 창의적인 분석을 원할 때\n'
          '• 다른 알고리즘과 다른 접근을 시도하고 싶을 때\n'
          '• 복합적인 패턴 분석을 기대할 때\n\n'
          '비용: 1코인/세트 (다른 알고리즘보다 저렴)',
      parameters: {},
    );
  }

  /// 알고리즘 9: 몬테카를로 상위 6개 (038)
  static AlgorithmHelp _getMonteCarloTop6Help() {
    return const AlgorithmHelp(
      algorithmId: 9,
      name: '몬테카를로 상위 6개 (Monte Carlo Top 6)',
      overview: '1~45를 10,000번 무작위로 뽑아 가장 많이 나온 6개를 한 세트로 합니다. '
          '과거 데이터를 사용하지 않는 순수 시뮬레이션 방식입니다.',
      howItWorks: '1. 1부터 45까지의 숫자 중 하나를 무작위로 뽑는 시행을 10,000회 반복합니다.\n'
          '2. 각 번호가 나온 횟수를 세어 빈도를 계산합니다.\n'
          '3. 가장 많이 나온 6개 번호를 한 세트로 선택합니다.\n'
          '4. 동점일 경우 번호가 작은 쪽을 우선합니다.',
      whenToUse: '통계나 과거 데이터 없이, 반복 랜덤 시뮬레이션 결과를 믿고 싶을 때 사용하세요. '
          '무료이며 별도 설정이 없습니다.',
      parameters: {},
    );
  }
}
