/// 파라미터 프리셋 값
/// 
/// 2026-01-17 EST - Phase 5-1: 슬라이더를 프리셋 버튼으로 대체
class ParameterPresets {
  /// 정수형 파라미터 프리셋
  static List<int> getIntPresets(String paramKey) {
    switch (paramKey) {
      // 분석 회차 (50~200)
      case 'recent_draws':
        return [50, 100, 150, 200];
      
      // LSTM 학습 범위 (50~전체)
      // 2026-01-17 19:30:00 EST - 500회차, 전회차 프리셋 추가
      case 'window_size':
        return [50, 100, 150, 200, 500, 9999]; // 9999 = 전회차
      
      // Hot 분석 회차 (10~50)
      case 'hot_window':
        return [10, 20, 30, 40];
      
      // Cold 분석 회차 (20~100)
      case 'cold_window':
        return [30, 50, 70, 100];
      
      // 선택 개수 (1~5)
      case 'hot_count':
      case 'cold_count':
      case 'rank_combo_size':
        return [1, 2, 3, 4, 5];
      
      // 고빈도 조회 회차 (5~50)
      case 'frequent_lookback':
        return [5, 10, 20, 30];
      
      // 고빈도 기준 (3~10)
      case 'frequent_threshold':
        return [3, 5, 7, 10];
      
      // 순위 회차 (10~100)
      case 'rank_window':
        return [20, 50, 80, 100];
      
      // 패턴 개수 (5~20)
      case 'top_n_patterns':
        return [5, 10, 15, 20];
      
      default:
        return [1, 2, 3, 4, 5];
    }
  }
  
  /// 실수형 파라미터 프리셋
  static List<double> getDoublePresets(String paramKey) {
    switch (paramKey) {
      // 온도 (0.8~1.2 추천 범위)
      case 'temperature':
        return [0.8, 1.0, 1.2];
      
      // 할인율 (0.3~1.0)
      case 'penalty_rate':
        return [0.3, 0.5, 0.7, 1.0];
      
      // 가중치 (0.0~0.5)
      case 'frequency_weight':
      case 'recency_weight':
      case 'zone_weight':
      case 'diversity_weight':
        return [0.0, 0.2, 0.3, 0.5];
      
      default:
        return [0.5, 1.0, 1.5, 2.0];
    }
  }
}

/// 파라미터 범위
class ParameterRanges {
  /// 정수형 파라미터 범위
  static (int min, int max) getIntRange(String paramKey) {
    switch (paramKey) {
      // 분석 회차
      case 'recent_draws':
        return (50, 200);
      
      // LSTM 학습 범위
      // 2026-01-17 19:30:00 EST - 최대값 9999로 확장 (전회차 지원)
      case 'window_size':
        return (50, 9999);
      
      // Hot 분석 회차
      case 'hot_window':
        return (10, 50);
      
      // Cold 분석 회차
      case 'cold_window':
        return (20, 100);
      
      // 선택 개수
      case 'hot_count':
      case 'cold_count':
      case 'rank_combo_size':
        return (1, 5);
      
      // 고빈도 조회 회차
      case 'frequent_lookback':
        return (5, 50);
      
      // 고빈도 기준
      case 'frequent_threshold':
        return (3, 10);
      
      // 순위 회차
      case 'rank_window':
        return (10, 100);
      
      // 패턴 개수
      case 'top_n_patterns':
        return (5, 20);
      
      default:
        return (1, 100);
    }
  }
  
  /// 실수형 파라미터 범위
  static (double min, double max) getDoubleRange(String paramKey) {
    switch (paramKey) {
      // 온도
      case 'temperature':
        return (0.5, 2.0);
      
      // 할인율, 가중치
      case 'penalty_rate':
      case 'frequency_weight':
      case 'recency_weight':
      case 'zone_weight':
      case 'diversity_weight':
        return (0.0, 1.0);
      
      default:
        return (0.0, 1.0);
    }
  }
  
  /// 단위 가져오기
  static String getUnit(String paramKey) {
    if (paramKey.contains('window') || 
        paramKey.contains('draws') || 
        paramKey.contains('lookback')) {
      return '회차';
    }
    if (paramKey.contains('count') || 
        paramKey.contains('size') || 
        paramKey.contains('patterns')) {
      return '개';
    }
    if (paramKey.contains('threshold')) {
      return '회';
    }
    return '';
  }
}
