/**
 * Admin 백테스트 페이지
 * 2026-02-14 EST - 036 설계안 구현
 * Phase 2: 그리드 루프, 이력
 */
(function (global) {
  'use strict';
  const api = global.AdminApi;
  const cfg = global.AdminConfig || {};

  // 등수 분포 가독화: { "1": 0, "2": 0, ... } -> "1등 0번, 2등 0번, ..."
  function formatRankDistribution(rd) {
    if (!rd || typeof rd !== 'object') return '';
    var labels = { '1': '1등', '2': '2등', '3': '3등', '4': '4등', '5': '5등', 'miss': '미당첨' };
    var parts = [];
    for (var k of ['1', '2', '3', '4', '5', 'miss']) {
      if (rd[k] !== undefined) parts.push((labels[k] || k) + ' ' + rd[k] + '번');
    }
    return parts.length ? parts.join(', ') : JSON.stringify(rd);
  }
  // 테이블용 한 줄 요약 (구분자 |)
  function formatRankDistributionCompact(rd) {
    if (!rd || typeof rd !== 'object') return '';
    var labels = { '1': '1등', '2': '2등', '3': '3등', '4': '4등', '5': '5등', 'miss': '미당첨' };
    var parts = [];
    for (var k of ['1', '2', '3', '4', '5', 'miss']) {
      if (rd[k] !== undefined) parts.push((labels[k] || k) + ' ' + rd[k]);
    }
    return parts.length ? parts.join(' | ') : '';
  }
  // 파라미터 객체 → 줄 단위 키:값 (가독용 라벨)
  var PARAM_LABELS = {
    window_type: '윈도우타입', window_size: '윈도우', recent_draws: '최근회차', analysis_window_size: '분석윈도우', analysis_window_type: '분석범위',
    pattern_type: '패턴타입', range_divisions: '구간수', rank_combo_size: '순위조합크기', rank_mode: '순위방식', rank_window: '순위회차',
    top_n_patterns: '상위패턴수', in_pattern_probability: '패턴내확률', pattern_selection_probability: '패턴선택확률',
    probability_mode: '확률모드', temperature: '온도', learning_mode: '학습방식',
    exclude_consecutive_2: '연속제외', exclude_frequent: '고빈도제외', apply_recent_penalty: '직전회차 확률할인', penalty_rate: '할인율',
    hot_window: 'Hot윈도우', cold_window: 'Cold윈도우', hot_count: 'Hot개수', cold_count: 'Cold개수',
    frequency_weight: '빈도가중치', recency_weight: '최근성가중치', zone_weight: '구간가중치', diversity_weight: '다양성가중치'
  };
  function formatParamsForDisplay(params) {
    if (!params || typeof params !== 'object') return '';
    var lines = [];
    for (var k in params) {
      if (!Object.prototype.hasOwnProperty.call(params, k)) continue;
      var label = PARAM_LABELS[k] || k;
      var v = params[k];
      var s = v === true ? '예' : v === false ? '아니오' : String(v);
      lines.push(label + ': ' + s);
    }
    return lines.join('\n');
  }

  // 036 §8 + 모바일 앱과 동일/유사: 알고리즘별 루프 축 (param: [values])
  var GRID_AXES = {
    1: {},
    2: { window_type: ['all', 'recent'], window_size: [50, 100, 200, 300], probability_mode: ['normal', 'inverse'], temperature: [0.8, 1.0, 1.2], exclude_consecutive_2: [true, false], exclude_frequent: [true, false], apply_recent_penalty: [true, false], penalty_rate: [0.3, 0.5, 0.7] },
    3: { learning_mode: ['non-cumulative', 'cumulative'], window_size: [50, 100, 150], probability_mode: ['normal', 'inverse'], temperature: [0.8, 1.0] },
    4: { pattern_type: ['range', 'rank'], range_divisions: [2, 3, 5, 10], rank_combo_size: [2, 3], rank_mode: ['cumulative', 'recent'], analysis_window_size: [50, 100], top_n_patterns: [5, 10, 15], in_pattern_probability: ['uniform', 'frequency', 'inverse'] },
    5: { recent_draws: [50, 100, 200], frequency_weight: [0.2, 0.3, 0.4], recency_weight: [0.2, 0.3, 0.4], zone_weight: [0.1, 0.2, 0.3], diversity_weight: [0.1, 0.2, 0.3] },
    6: { recent_draws: [50, 100, 200], temperature: [0.8, 1.0, 1.2] },
    7: { hot_window: [10, 20], cold_window: [30, 50], hot_count: [2, 3], cold_count: [2, 3] },
    8: { window_size: [50, 100] },
    9: {},
  };
  var GRID_INPUT_PARAMS = ['window_size', 'recent_draws', 'analysis_window_size', 'rank_window', 'hot_window', 'cold_window', 'hot_count', 'cold_count', 'frequency_weight', 'recency_weight', 'zone_weight', 'diversity_weight'];

  function parseGridValue(val) {
    if (Array.isArray(val)) return val;
    if (typeof val === 'string') {
      var parts = val.split(',').map(function (x) { return x.trim(); });
      return parts.map(function (x) {
        var n = parseFloat(x);
        if (!isNaN(n)) return n;
        if (x === 'true') return true;
        if (x === 'false') return false;
        return x;
      });
    }
    return [];
  }

  function BacktestPage() {
    return {
      template: `
        <div class="space-y-6">
          <h2 class="text-xl font-bold text-gray-800">백테스트</h2>

          <!-- 설정 패널 -->
          <div class="bg-white rounded-lg shadow p-4 space-y-4">
            <h3 class="font-semibold text-gray-700">설정</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">알고리즘 (SSOT: API)</label>
                <div class="flex flex-wrap gap-2 border rounded p-2 bg-gray-50">
                  <label v-for="a in algorithms" :key="a.id" class="inline-flex items-center gap-1 cursor-pointer">
                    <input type="checkbox" :value="a.id" v-model="selectedAlgos" class="rounded" />
                    <span class="text-sm">{{ a.id }}. {{ a.name }}</span>
                  </label>
                </div>
                <p v-if="algoError" class="text-xs text-red-600 mt-1">{{ algoError }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">시작 회차</label>
                <input v-model.number="startDraw" type="number" min="1" class="w-full border rounded px-3 py-2" placeholder="1000" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">종료 회차</label>
                <input v-model.number="endDraw" type="number" min="1" class="w-full border rounded px-3 py-2" :placeholder="'최신 ' + (latestDrawNo || '-') + '회'" />
                <p class="text-xs text-gray-500 mt-0.5">종료회차 빈값 시 최신회차 자동 적용</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">회차당 세트 수 (1~20)</label>
                <input v-model.number="nSets" type="number" min="1" max="20" class="w-full border rounded px-3 py-2" />
              </div>
            </div>
            <!-- 실행 모드 (알고리즘 1개 선택 시) -->
            <div v-if="selectedAlgos.length === 1" class="border-t pt-4 mt-2">
              <label class="block text-sm font-medium text-gray-600 mb-2">실행 모드</label>
              <div class="flex gap-4">
                <label class="inline-flex items-center gap-2 cursor-pointer">
                  <input type="radio" value="single" v-model="executionMode" class="rounded" />
                  <span class="text-sm">단일</span>
                </label>
                <label class="inline-flex items-center gap-2 cursor-pointer">
                  <input type="radio" value="grid" v-model="executionMode" class="rounded" />
                  <span class="text-sm">그리드 루프</span>
                </label>
              </div>
              <!-- 루프 설정 (그리드 선택 시) -->
              <div v-if="executionMode === 'grid' && gridAxesKeys.length > 0" class="mt-4 p-3 bg-gray-50 rounded space-y-3">
                <h4 class="text-sm font-medium text-gray-700">루프에 포함할 요소</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div v-for="key in gridAxesKeys" :key="key">
                    <label class="block text-xs text-gray-600 mb-1">{{ paramLabel(key) }}</label>
                    <template v-if="isGridInputParam(key)">
                      <input v-model="gridInputs[key]" type="text" class="w-full border rounded px-2 py-1 text-sm" :placeholder="gridPlaceholder(key)" />
                    </template>
                    <div v-else class="flex flex-wrap gap-2">
                      <label v-for="opt in gridAxisOptions(key)" :key="String(opt)" class="inline-flex items-center gap-1 cursor-pointer">
                        <input type="checkbox" :value="opt" v-model="gridCheckboxes[key]" class="rounded" />
                        <span class="text-sm">{{ gridAxisLabel(key, opt) }}</span>
                      </label>
                    </div>
                  </div>
                </div>
                <p class="text-xs text-gray-500">숫자 입력: 쉼표로 구분 (예: 100,200,300 또는 가중치 0, 0.2, 0.5)</p>
              </div>
              <div v-else-if="executionMode === 'grid' && gridAxesKeys.length === 0" class="mt-4 p-3 bg-gray-50 rounded text-sm text-gray-500">
                선택한 알고리즘은 파라미터 루프를 지원하지 않습니다.
              </div>
            </div>
            <!-- 제외/포함 번호 (공통) -->
            <div class="border-t pt-4 mt-2 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">제외 번호</label>
                <input v-model="excludeNumbers" type="text" class="w-full border rounded px-3 py-2 text-sm" placeholder="쉼표 구분 (예: 7,14,21)" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-600 mb-1">포함 번호</label>
                <input v-model="includeNumbers" type="text" class="w-full border rounded px-3 py-2 text-sm" placeholder="쉼표 구분 (예: 1,2,3)" />
              </div>
            </div>
            <!-- 알고리즘 파라미터 (단일 실행, 모바일 앱과 동일/유사) -->
            <div v-if="selectedAlgos.length === 1 && executionMode === 'single'" class="border-t pt-4 mt-2 space-y-4">
              <!-- 2: 고급 빈도 -->
              <div v-if="selectedAlgos[0] === 2" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">윈도우 타입</label><select v-model="windowType" class="w-full border rounded px-2 py-1 text-sm"><option value="all">전체</option><option value="recent">최근 N회</option></select></div>
                <div><label class="block text-xs text-gray-600 mb-1">윈도우/회차</label><input v-model.number="windowSize" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">확률 모드</label><select v-model="probabilityMode" class="w-full border rounded px-2 py-1 text-sm"><option value="normal">정확률</option><option value="inverse">역확률</option></select></div>
                <div><label class="block text-xs text-gray-600 mb-1">온도</label><input v-model.number="temperature" type="number" step="0.1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div class="flex flex-wrap gap-3 items-center">
                  <label class="inline-flex items-center gap-1 cursor-pointer"><input type="checkbox" v-model="excludeConsecutive2" class="rounded" /><span class="text-sm">연속 출현 제외</span></label>
                  <label class="inline-flex items-center gap-1 cursor-pointer"><input type="checkbox" v-model="excludeFrequent" class="rounded" /><span class="text-sm">고빈도 제외</span></label>
                  <label class="inline-flex items-center gap-1 cursor-pointer"><input type="checkbox" v-model="applyRecentPenalty" class="rounded" /><span class="text-sm">직전회차 할인</span></label>
                  <select v-if="applyRecentPenalty" v-model.number="penaltyRate" class="border rounded px-2 py-1 text-sm w-20"><option :value="0.3">30%</option><option :value="0.5">50%</option><option :value="0.7">70%</option></select>
                </div>
              </div>
              <!-- 3: LSTM -->
              <div v-if="selectedAlgos[0] === 3" class="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">학습 방식</label><select v-model="learningMode" class="w-full border rounded px-2 py-1 text-sm"><option value="non-cumulative">비누적</option><option value="cumulative">누적</option></select></div>
                <div><label class="block text-xs text-gray-600 mb-1">윈도우/회차</label><input v-model.number="windowSize" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">확률 모드</label><select v-model="probabilityMode" class="w-full border rounded px-2 py-1 text-sm"><option value="normal">정확률</option><option value="inverse">역확률</option></select></div>
                <div><label class="block text-xs text-gray-600 mb-1">온도</label><input v-model.number="temperature" type="number" step="0.1" class="w-full border rounded px-2 py-1 text-sm" /></div>
              </div>
              <!-- 4: 패턴 -->
              <div v-if="selectedAlgos[0] === 4" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">패턴 타입</label><select v-model="patternType" class="w-full border rounded px-2 py-1 text-sm"><option value="range">범위 패턴</option><option value="rank">순위 패턴</option></select></div>
                <div v-if="patternType === 'range'"><label class="block text-xs text-gray-600 mb-1">구간 수</label><select v-model.number="rangeDivisions" class="w-full border rounded px-2 py-1 text-sm"><option :value="2">2 (L/H)</option><option :value="3">3 (L/M/H)</option><option :value="5">5 (A~E)</option><option :value="10">10 (A~J)</option></select></div>
                <div v-if="patternType === 'rank'"><label class="block text-xs text-gray-600 mb-1">조합 크기</label><input v-model.number="rankComboSize" type="number" min="2" max="5" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div v-if="patternType === 'rank'"><label class="block text-xs text-gray-600 mb-1">순위 방식</label><select v-model="rankMode" class="w-full border rounded px-2 py-1 text-sm"><option value="cumulative">누적</option><option value="recent">최근</option></select></div>
                <div v-if="patternType === 'rank' && rankMode === 'recent'"><label class="block text-xs text-gray-600 mb-1">순위 회차</label><input v-model.number="rankWindow" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">분석 범위</label><select v-model="analysisWindowType" class="w-full border rounded px-2 py-1 text-sm"><option value="all">전체</option><option value="recent">최근 N회</option></select></div>
                <div v-if="analysisWindowType === 'recent'"><label class="block text-xs text-gray-600 mb-1">분석 회차</label><input v-model.number="analysisWindowSize" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">상위 패턴 수</label><input v-model.number="topNPatterns" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">패턴 내 확률</label><select v-model="inPatternProbability" class="w-full border rounded px-2 py-1 text-sm"><option value="uniform">균등</option><option value="frequency">빈도</option><option value="inverse">역확률</option></select></div>
                <div><label class="block text-xs text-gray-600 mb-1">패턴 선택 확률</label><select v-model="patternSelectionProbability" class="w-full border rounded px-2 py-1 text-sm"><option value="normal">정상</option><option value="inverse">역</option></select></div>
              </div>
              <!-- 5: 가중치 -->
              <div v-if="selectedAlgos[0] === 5" class="space-y-3">
                <p class="text-xs text-gray-600">가중치 합은 1이 아니어도 됩니다. 0 초과이면 자동 정규화됩니다. 음의 가중치는 정규화 후 비율이 같아져 의미가 없으므로 사용하지 마세요.</p>
                <div><label class="block text-xs text-gray-600 mb-1">가중치 (빈도, 최근성, 구간, 다양성 순으로 쉼표 구분)</label><input v-model="weightedWeightsInput" type="text" class="w-full border rounded px-2 py-1 text-sm" placeholder="0.3, 0.3, 0.2, 0.2" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">최근 회차</label><input v-model.number="recentDraws" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
              </div>
              <!-- 6: 빈도 -->
              <div v-if="selectedAlgos[0] === 6" class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">최근 회차</label><input v-model.number="recentDraws" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">온도</label><input v-model.number="temperature" type="number" step="0.1" class="w-full border rounded px-2 py-1 text-sm" /></div>
              </div>
              <!-- 7: 핫/콜드 -->
              <div v-if="selectedAlgos[0] === 7" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">Hot 회차</label><input v-model.number="hotWindow" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">Hot 개수</label><input v-model.number="hotCount" type="number" min="0" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">Cold 회차</label><input v-model.number="coldWindow" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
                <div><label class="block text-xs text-gray-600 mb-1">Cold 개수</label><input v-model.number="coldCount" type="number" min="0" class="w-full border rounded px-2 py-1 text-sm" /></div>
              </div>
              <!-- 8: AI 선택 -->
              <div v-if="selectedAlgos[0] === 8" class="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div><label class="block text-xs text-gray-600 mb-1">분석 회차</label><input v-model.number="windowSize" type="number" min="1" class="w-full border rounded px-2 py-1 text-sm" /></div>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <label class="inline-flex items-center gap-2 cursor-pointer">
                <input type="checkbox" v-model="enableDetailedLog" class="rounded" />
                <span class="text-sm">상세 로그 (회차별 결과)</span>
              </label>
            </div>
          </div>

          <!-- 실행 -->
          <div class="flex flex-wrap gap-2">
            <button @click="runSingle" :disabled="loading || !canRunSingle"
              class="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed">
              단일 백테스트
            </button>
            <button @click="runGrid" :disabled="loading || !canRunGrid"
              class="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed">
              그리드 루프
            </button>
            <button @click="runCompare" :disabled="loading || selectedAlgos.length < 2"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed">
              비교 백테스트
            </button>
          </div>

          <p v-if="error" class="text-red-600">{{ error }}</p>
          <!-- 진행률 -->
          <div v-if="loading && progress" class="bg-white rounded-lg shadow p-4 space-y-2">
            <div class="flex justify-between text-sm text-gray-600">
              <span>{{ progressMessage }}</span>
              <span>{{ progress.percent }}% <span v-if="elapsedSeconds >= 0" class="text-gray-500">(경과 {{ formatElapsed(elapsedSeconds) }})</span></span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div class="bg-blue-600 h-2 rounded-full transition-all duration-200" :style="{ width: progress.percent + '%' }"></div>
            </div>
          </div>
          <p v-else-if="loading && !progress" class="text-gray-500">실행 중...</p>

          <!-- 단일 결과 -->
          <div v-if="singleResult" class="bg-white rounded-lg shadow p-4 space-y-3">
            <h3 class="font-semibold">결과: {{ singleResult.algorithm_name }}</h3>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-2 text-sm">
              <div class="p-2 bg-gray-50 rounded">당첨률: {{ (singleResult.win_rate * 100).toFixed(2) }}%</div>
              <div class="p-2 bg-gray-50 rounded">ROI: {{ singleResult.roi.toFixed(1) }}%</div>
              <div class="p-2 bg-gray-50 rounded">종합 점수: {{ singleResult.composite_score }}</div>
              <div class="p-2 bg-gray-50 rounded">등급: {{ singleResult.grade }}</div>
            </div>
            <div class="text-sm">
              <span class="font-medium">등수 분포:</span>
              {{ formatRankDistribution(singleResult.rank_distribution) }}
            </div>
            <div class="text-xs text-gray-500">실행 시간: {{ singleResult.execution_time }}초, 회차 {{ singleResult.period.start }}~{{ singleResult.period.end }}</div>
            <div v-if="singleResult.effective_draw_count != null" class="text-xs text-gray-600">유효 회차: {{ singleResult.effective_draw_count }}회 (예측 세트 {{ singleResult.total_sets_generated }}개, 회차당 {{ singleResult.n_sets || 5 }}세트)</div>
            <div v-if="singleResult.max_cumulative_win_rate != null" class="text-xs text-gray-700">시계열 최고 확률: {{ singleResult.max_cumulative_win_rate }}% (회차 {{ singleResult.max_cumulative_win_rate_draw_no }}{{ singleResult.max_cumulative_win_rate_valid_index != null ? ', 유효 ' + singleResult.max_cumulative_win_rate_valid_index + '회' : '' }})</div>
            <div v-if="singleResult.cumulative_win_rate_series && singleResult.cumulative_win_rate_series.length" class="border-t pt-3 mt-3 space-y-2">
              <h4 class="font-medium text-gray-800">회차별 누적 당첨률 <span class="text-xs font-normal text-gray-500">(가로 스크롤 가능)</span></h4>
              <div class="text-xs text-gray-600 mb-0.5">유효 회차 순번 →</div>
              <div class="flex gap-1">
                <div class="text-xs text-gray-600 shrink-0 self-center pr-1" style="writing-mode: vertical-rl; transform: rotate(180deg);">누적 당첨률 (%)</div>
                <div class="max-w-full overflow-x-auto overflow-y-hidden flex-1 min-w-0">
                  <svg :width="cumulativeChartWidth(singleResult.cumulative_win_rate_series)" height="280" :viewBox="'0 0 ' + cumulativeChartWidth(singleResult.cumulative_win_rate_series) + ' 280'" preserveAspectRatio="none" @mousemove="onCumulativeChartMouseMove($event, singleResult.cumulative_win_rate_series)" @mouseleave="chartTooltip = null">
                    <rect x="45" y="25" :width="cumulativeChartWidth(singleResult.cumulative_win_rate_series) - 90" height="220" fill="none" stroke="#e5e7eb" stroke-width="1"/>
                    <template v-for="t in cumulativeChartXTicks(singleResult.cumulative_win_rate_series, 45, cumulativeChartWidth(singleResult.cumulative_win_rate_series) - 90)">
                      <line :key="'x'+t.label" :x1="t.x" :y1="245" :x2="t.x" :y2="25" stroke="#e5e7eb" stroke-width="0.5"/>
                      <text :key="'xl'+t.label" :x="t.x" y="262" text-anchor="middle" class="text-xs fill-gray-500">{{ t.label }}</text>
                    </template>
                    <template v-for="t in cumulativeChartYTicks(singleResult.cumulative_win_rate_series, 245, 220)">
                      <line :key="'y'+t.label" x1="45" :y1="t.y" :x2="cumulativeChartWidth(singleResult.cumulative_win_rate_series) - 45" :y2="t.y" stroke="#e5e7eb" stroke-width="0.5"/>
                      <text :key="'yl'+t.label" x="38" :y="t.y" text-anchor="end" dominant-baseline="middle" class="text-xs fill-gray-500">{{ t.label }}</text>
                    </template>
                    <polyline :points="cumulativeSeriesPolyline(singleResult.cumulative_win_rate_series, 45, 245, cumulativeChartWidth(singleResult.cumulative_win_rate_series) - 90, 220)" fill="none" stroke="#3b82f6" stroke-width="1.5" stroke-linejoin="round"/>
                  </svg>
                  <div v-if="chartTooltip" class="absolute z-10 px-2 py-1 text-xs bg-gray-800 text-white rounded shadow-lg pointer-events-none" :style="chartTooltip.style">유효 {{ chartTooltip.valid_draw_index }}회차, 회차 {{ chartTooltip.draw_no }}, 누적 당첨률 {{ chartTooltip.win_rate_pct }}%</div>
                </div>
              </div>
              <div class="overflow-x-auto max-h-48 overflow-y-auto">
                <table class="min-w-full text-xs border border-gray-200">
                  <thead class="bg-gray-50 sticky top-0"><tr><th class="px-2 py-1 text-left border-b">회차</th><th class="px-2 py-1 text-right border-b">유효회차순번</th><th class="px-2 py-1 text-right border-b">누적 시행</th><th class="px-2 py-1 text-right border-b">누적 당첨</th><th class="px-2 py-1 text-right border-b">누적 당첨률(%)</th></tr></thead>
                  <tbody>
                    <tr v-for="pt in singleResult.cumulative_win_rate_series" :key="pt.draw_no"><td class="px-2 py-1 border-b">{{ pt.draw_no }}</td><td class="px-2 py-1 text-right border-b">{{ pt.valid_draw_index }}</td><td class="px-2 py-1 text-right border-b">{{ pt.total_sets }}</td><td class="px-2 py-1 text-right border-b">{{ pt.wins }}</td><td class="px-2 py-1 text-right border-b">{{ (pt.win_rate * 100).toFixed(2) }}</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- 그리드 결과 -->
          <div v-if="gridResult" class="bg-white rounded-lg shadow overflow-hidden">
            <h3 class="p-4 font-semibold">그리드 결과: {{ gridResult.algorithm_name }} ({{ gridResult.combinations }}조합)</h3>
            <div v-if="gridResult.best" class="px-4 pb-4 border-b border-gray-100">
              <div class="text-sm font-medium text-gray-800 mb-1">최고 조합</div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                <div class="bg-gray-50 rounded p-2 whitespace-pre-line text-xs font-mono">{{ formatParamsForDisplay(gridResult.best.params) }}</div>
                <div>
                  <div class="text-gray-600">당첨률 {{ (gridResult.best.win_rate * 100).toFixed(2) }}% · ROI {{ gridResult.best.roi.toFixed(1) }}% · 점수 {{ gridResult.best.composite_score }} · 등급 {{ gridResult.best.grade }}</div>
                  <div v-if="gridResult.best.rank_distribution" class="text-xs text-gray-500 mt-1">{{ formatRankDistributionCompact(gridResult.best.rank_distribution) }}</div>
                </div>
              </div>
            </div>
            <div v-if="gridFilterParamKeys.length" class="px-4 py-3 border-b border-gray-100 bg-gray-50">
              <div class="text-xs font-medium text-gray-700 mb-2">파라미터 필터 (선택한 값만 표시, 비면 전체) · 표시 {{ gridSortedItems.length }}건</div>
              <div class="flex flex-wrap gap-3">
                <div v-for="key in gridFilterParamKeys" :key="key" class="flex flex-wrap items-center gap-1">
                  <span class="text-xs text-gray-600 mr-1">{{ paramLabel(key) }}:</span>
                  <button v-for="opt in (gridFilterOptions[key] || [])" :key="String(opt)" type="button" class="px-2 py-0.5 rounded text-xs border" :class="(gridParamFilters[key] || []).indexOf(opt) >= 0 ? 'bg-blue-500 text-white border-blue-500' : 'bg-white border-gray-300 hover:bg-gray-100'" @click="toggleGridParamFilter(key, opt)">{{ opt }}</button>
                </div>
              </div>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full text-sm">
                <thead class="bg-gray-100">
                  <tr>
                    <th class="px-3 py-2 text-left w-12">순위</th>
                    <th class="px-3 py-2 text-left min-w-[180px]">파라미터</th>
                    <th class="px-3 py-2 text-left">등수 분포</th>
                    <th class="px-3 py-2 text-right w-16">유효회차</th>
                    <th class="px-3 py-2 text-left min-w-[140px]" title="당첨이 발생한 유효 회차 순번">당첨 유효회차</th>
                    <th class="px-3 py-2 text-right w-20 cursor-pointer select-none hover:bg-gray-200" @click="setGridSort('max_cumulative_win_rate')" title="클릭 시 오름/내림차순">시계열 최고 <span v-if="gridSortBy==='max_cumulative_win_rate'" class="text-gray-500">{{ gridSortDesc ? '▼' : '▲' }}</span></th>
                    <th class="px-3 py-2 text-right w-16 cursor-pointer select-none hover:bg-gray-200" @click="setGridSort('max_cumulative_win_rate_draw_no')" title="클릭 시 오름/내림차순">최고 시 회차 <span v-if="gridSortBy==='max_cumulative_win_rate_draw_no'" class="text-gray-500">{{ gridSortDesc ? '▼' : '▲' }}</span></th>
                    <th class="px-3 py-2 text-right w-16 cursor-pointer select-none hover:bg-gray-200" @click="setGridSort('max_cumulative_win_rate_valid_index')" title="클릭 시 오름/내림차순">최고 시 유효회차 <span v-if="gridSortBy==='max_cumulative_win_rate_valid_index'" class="text-gray-500">{{ gridSortDesc ? '▼' : '▲' }}</span></th>
                    <th class="px-3 py-2 text-right w-20 cursor-pointer select-none hover:bg-gray-200" @click="setGridSort('win_rate')" title="클릭 시 오름/내림차순">당첨률 <span v-if="gridSortBy==='win_rate'" class="text-gray-500">{{ gridSortDesc ? '▼' : '▲' }}</span></th>
                    <th class="px-3 py-2 text-right w-16 cursor-pointer select-none hover:bg-gray-200" @click="setGridSort('roi')" title="클릭 시 오름/내림차순">ROI <span v-if="gridSortBy==='roi'" class="text-gray-500">{{ gridSortDesc ? '▼' : '▲' }}</span></th>
                    <th class="px-3 py-2 text-right w-20">점수</th>
                    <th class="px-3 py-2 w-14">등급</th>
                    <th class="px-3 py-2 w-16">시계열</th>
                    <th class="px-3 py-2 w-14" title="선택한 조합을 한 차트에 겹쳐 보기">비교</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(item, i) in gridSortedItems" :key="i" :class="[i % 2 ? 'bg-gray-50' : '', selectedGridSeriesItem === item ? 'ring-1 ring-blue-400' : '']">
                    <td class="px-3 py-2">{{ i + 1 }}</td>
                    <td class="px-3 py-2 text-xs align-top whitespace-pre-line font-mono bg-white border border-gray-100 rounded">{{ formatParamsForDisplay(item.params) }}</td>
                    <td class="px-3 py-2 text-xs text-gray-600 whitespace-nowrap">{{ formatRankDistributionCompact(item.rank_distribution) }}</td>
                    <td class="px-3 py-2 text-right">{{ item.effective_draw_count != null ? item.effective_draw_count : '-' }}</td>
                    <td class="px-3 py-2 text-xs text-gray-700">
                      <span>{{ formatWinningValidDrawIndices(item) }}</span>
                      <button v-if="getWinningValidDrawIndices(item).length" type="button" class="ml-1 px-1.5 py-0.5 text-xs border border-gray-300 rounded hover:bg-gray-100 text-gray-600" :title="'당첨 유효회차 목록 복사: ' + getWinningValidDrawIndices(item).join(', ')" @click="copyWinningValidDrawIndices(item)">{{ copyWinningFeedback === item ? '복사됨' : '복사' }}</button>
                    </td>
                    <td class="px-3 py-2 text-right">{{ item.max_cumulative_win_rate != null ? item.max_cumulative_win_rate + '%' : '-' }}</td>
                    <td class="px-3 py-2 text-right">{{ item.max_cumulative_win_rate_draw_no != null ? item.max_cumulative_win_rate_draw_no : '-' }}</td>
                    <td class="px-3 py-2 text-right">{{ item.max_cumulative_win_rate_valid_index != null ? item.max_cumulative_win_rate_valid_index : '-' }}</td>
                    <td class="px-3 py-2 text-right">{{ (item.win_rate * 100).toFixed(2) }}%</td>
                    <td class="px-3 py-2 text-right">{{ item.roi.toFixed(1) }}%</td>
                    <td class="px-3 py-2 text-right">{{ item.composite_score }}</td>
                    <td class="px-3 py-2">{{ item.grade }}</td>
                    <td class="px-3 py-2"><button type="button" class="text-xs text-blue-600 hover:underline" @click="selectedGridSeriesItem = (selectedGridSeriesItem === item ? null : item)">{{ (selectedGridSeriesItem === item) ? '접기' : '보기' }}</button></td>
                    <td class="px-3 py-2"><label class="inline-flex items-center gap-1 cursor-pointer"><input type="checkbox" :checked="gridSeriesOverlayItems.indexOf(item) >= 0" :disabled="gridSeriesOverlayItems.length >= 10 && gridSeriesOverlayItems.indexOf(item) < 0" @change="toggleGridOverlayItem(item)" class="rounded" /><span class="text-xs">비교</span></label></td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="gridSeriesOverlayItems.length > 0" class="px-4 py-4 border-t bg-gray-50 space-y-2">
              <h4 class="font-medium text-gray-800">선택 조합 시계열 비교 (유효 회차 순번 기준, 가로 스크롤 가능)</h4>
              <div class="flex flex-wrap gap-2 mb-2">
                <span v-for="(it, idx) in gridSeriesOverlayItems" :key="idx" class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs" :style="{ backgroundColor: overlaySeriesColor(idx) + '22', border: '1px solid ' + overlaySeriesColor(idx) }">
                  <span class="w-2 h-2 rounded-full" :style="{ backgroundColor: overlaySeriesColor(idx) }"></span>
                  {{ formatParamsFirstLine(it.params) }}
                </span>
              </div>
              <label class="inline-flex items-center gap-2 mb-2 cursor-pointer">
                <input type="checkbox" v-model="overlayExtendShortSeries" class="rounded" />
                <span class="text-sm text-gray-700">짧은 시계열을 최대 회차까지 연장하여 표시</span>
              </label>
              <div class="overflow-x-auto overflow-y-hidden min-w-0 w-full border border-gray-200 rounded bg-white">
                <div :style="{ minWidth: overlayChartWidth + 'px' }">
                  <svg :width="overlayChartWidth" height="320" :viewBox="'0 0 ' + overlayChartWidth + ' 320'" preserveAspectRatio="none" style="display: block;">
                    <rect x="45" y="25" :width="overlayChartWidth - 90" height="210" fill="none" stroke="#e5e7eb" stroke-width="1"/>
                    <line v-if="overlayRefLineY != null" x1="45" :y1="overlayRefLineY" :x2="overlayChartWidth - 45" :y2="overlayRefLineY" stroke="#f59e0b" stroke-width="1" stroke-dasharray="4,2"/>
                    <text v-if="overlayRefLineY != null" x="48" :y="overlayRefLineY - 2" font-size="11" fill="#b45309">2.4%</text>
                    <g v-for="(line, idx) in overlayChartPolylines" :key="idx">
                      <polyline :points="line.points" fill="none" :stroke="overlaySeriesColor(idx)" stroke-width="1.5" stroke-linejoin="round"/>
                    </g>
                  </svg>
                </div>
              </div>
            </div>
            <div v-if="selectedGridSeriesItem && selectedGridSeriesItem.cumulative_win_rate_series && selectedGridSeriesItem.cumulative_win_rate_series.length" class="px-4 py-4 border-t bg-gray-50 space-y-2">
              <h4 class="font-medium text-gray-800">선택 조합 회차별 누적 당첨률 <span class="text-xs font-normal text-gray-500">(가로 스크롤 가능)</span></h4>
              <div class="text-xs text-gray-600 mb-1 whitespace-pre-line font-mono bg-white p-2 rounded border">{{ formatParamsForDisplay(selectedGridSeriesItem.params) }}</div>
              <div class="text-xs text-gray-600 mb-0.5">유효 회차 순번 →</div>
              <div class="flex gap-1">
                <div class="text-xs text-gray-600 shrink-0 self-center pr-1" style="writing-mode: vertical-rl; transform: rotate(180deg);">누적 당첨률 (%)</div>
                <div class="max-w-full overflow-x-auto overflow-y-hidden flex-1 min-w-0">
                  <svg :width="cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series)" height="280" :viewBox="'0 0 ' + cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series) + ' 280'" preserveAspectRatio="none" @mousemove="onCumulativeChartMouseMove($event, selectedGridSeriesItem.cumulative_win_rate_series)" @mouseleave="chartTooltip = null">
                    <rect x="45" y="25" :width="cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series) - 90" height="220" fill="none" stroke="#e5e7eb" stroke-width="1"/>
                    <template v-for="t in cumulativeChartXTicks(selectedGridSeriesItem.cumulative_win_rate_series, 45, cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series) - 90)">
                      <line :key="'sx'+t.label" :x1="t.x" :y1="245" :x2="t.x" :y2="25" stroke="#e5e7eb" stroke-width="0.5"/>
                      <text :key="'sxl'+t.label" :x="t.x" y="262" text-anchor="middle" class="text-xs fill-gray-500">{{ t.label }}</text>
                    </template>
                    <template v-for="t in cumulativeChartYTicks(selectedGridSeriesItem.cumulative_win_rate_series, 245, 220)">
                      <line :key="'sy'+t.label" x1="45" :y1="t.y" :x2="cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series) - 45" :y2="t.y" stroke="#e5e7eb" stroke-width="0.5"/>
                      <text :key="'syl'+t.label" x="38" :y="t.y" text-anchor="end" dominant-baseline="middle" class="text-xs fill-gray-500">{{ t.label }}</text>
                    </template>
                    <polyline :points="cumulativeSeriesPolyline(selectedGridSeriesItem.cumulative_win_rate_series, 45, 245, cumulativeChartWidth(selectedGridSeriesItem.cumulative_win_rate_series) - 90, 220)" fill="none" stroke="#3b82f6" stroke-width="1.5" stroke-linejoin="round"/>
                  </svg>
                  <div v-if="chartTooltip" class="absolute z-10 px-2 py-1 text-xs bg-gray-800 text-white rounded shadow-lg pointer-events-none" :style="chartTooltip.style">유효 {{ chartTooltip.valid_draw_index }}회차, 회차 {{ chartTooltip.draw_no }}, 누적 당첨률 {{ chartTooltip.win_rate_pct }}%</div>
                </div>
              </div>
              <div class="overflow-x-auto max-h-48 overflow-y-auto">
                <table class="min-w-full text-xs border border-gray-200 bg-white">
                  <thead class="bg-gray-50 sticky top-0"><tr><th class="px-2 py-1 text-left border-b">회차</th><th class="px-2 py-1 text-right border-b">유효회차순번</th><th class="px-2 py-1 text-right border-b">누적 시행</th><th class="px-2 py-1 text-right border-b">누적 당첨</th><th class="px-2 py-1 text-right border-b">누적 당첨률(%)</th></tr></thead>
                  <tbody>
                    <tr v-for="pt in selectedGridSeriesItem.cumulative_win_rate_series" :key="pt.draw_no"><td class="px-2 py-1 border-b">{{ pt.draw_no }}</td><td class="px-2 py-1 text-right border-b">{{ pt.valid_draw_index }}</td><td class="px-2 py-1 text-right border-b">{{ pt.total_sets }}</td><td class="px-2 py-1 text-right border-b">{{ pt.wins }}</td><td class="px-2 py-1 text-right border-b">{{ (pt.win_rate * 100).toFixed(2) }}</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div class="px-4 py-2 text-xs text-gray-500">실행 시간: {{ gridResult.execution_time }}초</div>
          </div>

          <!-- 비교 결과 -->
          <div v-if="compareResult" class="bg-white rounded-lg shadow overflow-hidden">
            <table class="min-w-full text-sm">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-4 py-2 text-left">순위</th>
                  <th class="px-4 py-2 text-left">알고리즘</th>
                  <th class="px-4 py-2 text-left">등수 분포</th>
                  <th class="px-4 py-2 text-right cursor-pointer select-none hover:bg-gray-200" @click="setCompareSort('win_rate')" title="클릭 시 오름/내림차순">당첨률 <span v-if="compareSortBy==='win_rate'" class="text-gray-500">{{ compareSortDesc ? '▼' : '▲' }}</span></th>
                  <th class="px-4 py-2 text-right cursor-pointer select-none hover:bg-gray-200" @click="setCompareSort('roi')" title="클릭 시 오름/내림차순">ROI <span v-if="compareSortBy==='roi'" class="text-gray-500">{{ compareSortDesc ? '▼' : '▲' }}</span></th>
                  <th class="px-4 py-2 text-right">종합 점수</th>
                  <th class="px-4 py-2">등급</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in compareSortedItems" :key="item.algorithm_id" :class="i % 2 ? 'bg-gray-50' : ''">
                  <td class="px-4 py-2">{{ i + 1 }}</td>
                  <td class="px-4 py-2">{{ item.algorithm_id }}. {{ item.algorithm_name }}</td>
                  <td class="px-4 py-2 text-xs text-gray-600 whitespace-nowrap">{{ formatRankDistributionCompact(item.rank_distribution) }}</td>
                  <td class="px-4 py-2 text-right">{{ (item.win_rate * 100).toFixed(2) }}%</td>
                  <td class="px-4 py-2 text-right">{{ item.roi.toFixed(1) }}%</td>
                  <td class="px-4 py-2 text-right">{{ item.composite_score }}</td>
                  <td class="px-4 py-2">{{ item.grade }}</td>
                </tr>
              </tbody>
            </table>
            <div class="px-4 py-2 text-xs text-gray-500">회차 {{ compareResult.period.start }}~{{ compareResult.period.end }}</div>
          </div>

          <!-- 지표 계산 방식 안내 (006 SSOT) -->
          <details class="bg-white rounded-lg shadow p-4">
            <summary class="cursor-pointer font-semibold text-gray-700 hover:text-gray-900">지표 계산 방식</summary>
            <div class="mt-4 space-y-4 text-sm text-gray-600">
              <div>
                <h4 class="font-medium text-gray-800 mb-1">ROI (투자 수익률)</h4>
                <p class="mb-2">ROI (%) = (총 당첨금 / 총 비용) × 100</p>
                <ul class="list-disc list-inside space-y-0.5 text-xs">
                  <li>총 비용 = 1,000원 × 세트 수</li>
                  <li>총 당첨금 = Σ (등수별 평균 당첨금 × 당첨 횟수)</li>
                </ul>
              </div>
              <div>
                <h4 class="font-medium text-gray-800 mb-1">등수별 평균 당첨금 (006 SSOT)</h4>
                <table class="min-w-full text-xs border border-gray-200 rounded">
                  <thead class="bg-gray-100"><tr><th class="px-2 py-1 text-left">등수</th><th class="px-2 py-1 text-right">평균 당첨금</th></tr></thead>
                  <tbody>
                    <tr class="border-t"><td class="px-2 py-1">1등</td><td class="px-2 py-1 text-right">20억원</td></tr>
                    <tr class="border-t"><td class="px-2 py-1">2등</td><td class="px-2 py-1 text-right">5천만원</td></tr>
                    <tr class="border-t"><td class="px-2 py-1">3등</td><td class="px-2 py-1 text-right">150만원</td></tr>
                    <tr class="border-t"><td class="px-2 py-1">4등</td><td class="px-2 py-1 text-right">5만원</td></tr>
                    <tr class="border-t"><td class="px-2 py-1">5등</td><td class="px-2 py-1 text-right">5천원</td></tr>
                    <tr class="border-t"><td class="px-2 py-1">미당첨</td><td class="px-2 py-1 text-right">0원</td></tr>
                  </tbody>
                </table>
              </div>
              <div>
                <h4 class="font-medium text-gray-800 mb-1">당첨률</h4>
                <p>당첨률 = (1~5등 당첨 횟수 / 전체 세트 수)</p>
              </div>
              <div>
                <h4 class="font-medium text-gray-800 mb-1">종합 점수 (0~100, 006 SSOT)</h4>
                <p class="mb-2">총점 = 당첨률 점수(40) + ROI 점수(30) + 일관성 점수(20) + 고등급 비율 점수(10)</p>
                <ul class="list-disc list-inside space-y-0.5 text-xs">
                  <li>당첨률 점수 = min(당첨률/0.018, 1.0) × 40 (최대 40점)</li>
                  <li>ROI 점수 = min(ROI/100, 1.0) × 30 (최대 30점)</li>
                  <li>일관성 점수 = 0.5 × 20 = 10점 (고정)</li>
                  <li>고등급 비율 점수 = min((1등+2등+3등 횟수/세트 수)×10, 1.0) × 10 (최대 10점)</li>
                </ul>
              </div>
            </div>
          </details>
        </div>
      `,
      data: function () {
        return {
          algorithms: [],
          selectedAlgos: [],
          startDraw: 1000,
          endDraw: null,
          latestDrawNo: null,
          nSets: 5,
          enableDetailedLog: false,
          executionMode: 'single',
          gridInputs: {},
          gridCheckboxes: {},
          excludeNumbers: '',
          includeNumbers: '',
          excludeConsecutive2: false,
          excludeFrequent: false,
          applyRecentPenalty: false,
          penaltyRate: 0.5,
          windowType: 'all',
          windowSize: 100,
          probabilityMode: 'normal',
          temperature: 1.0,
          learningMode: 'non-cumulative',
          patternType: 'range',
          rangeDivisions: 5,
          rankComboSize: 3,
          rankMode: 'cumulative',
          rankWindow: 50,
          analysisWindowType: 'all',
          analysisWindowSize: 100,
          topNPatterns: 10,
          inPatternProbability: 'frequency',
          patternSelectionProbability: 'normal',
          frequencyWeight: 0.3,
          recencyWeight: 0.3,
          zoneWeight: 0.2,
          diversityWeight: 0.2,
          weightedWeightsInput: '0.3, 0.3, 0.2, 0.2',
          recentDraws: 100,
          hotWindow: 20,
          hotCount: 3,
          coldWindow: 50,
          coldCount: 2,
          loading: false,
          progress: null,
          startTime: null,
          error: '',
          algoError: '',
          singleResult: null,
          gridResult: null,
          compareResult: null,
          gridSortBy: 'composite_score',
          gridSortDesc: true,
          compareSortBy: 'composite_score',
          compareSortDesc: true,
          selectedGridSeriesItem: null,
          gridParamFilters: {},
          gridSeriesOverlayItems: [],
          overlayExtendShortSeries: false,
          copyWinningFeedback: null,
          chartTooltip: null,
        };
      },
      computed: {
        gridFilterParamKeys: function () {
          if (!this.gridResult || !this.gridResult.items || !this.gridResult.items.length) return [];
          var p = this.gridResult.items[0].params;
          return p ? Object.keys(p) : [];
        },
        filteredGridItems: function () {
          if (!this.gridResult || !this.gridResult.items || !this.gridResult.items.length) return [];
          var items = this.gridResult.items;
          var f = this.gridParamFilters;
          return items.filter(function (item) {
            for (var k in f) {
              if (!Object.prototype.hasOwnProperty.call(f, k) || !f[k] || !f[k].length) continue;
              var v = item.params && item.params[k];
              var match = f[k].some(function (sel) { return sel == v || String(sel) === String(v); });
              if (!match) return false;
            }
            return true;
          });
        },
        gridSortedItems: function () {
          if (!this.filteredGridItems || !this.filteredGridItems.length) return [];
          var by = this.gridSortBy;
          var desc = this.gridSortDesc;
          return this.filteredGridItems.slice().sort(function (a, b) {
            var va = by === 'win_rate' ? a.win_rate : by === 'roi' ? a.roi : by === 'max_cumulative_win_rate' ? a.max_cumulative_win_rate : by === 'max_cumulative_win_rate_draw_no' ? a.max_cumulative_win_rate_draw_no : by === 'max_cumulative_win_rate_valid_index' ? a.max_cumulative_win_rate_valid_index : a.composite_score;
            var vb = by === 'win_rate' ? b.win_rate : by === 'roi' ? b.roi : by === 'max_cumulative_win_rate' ? b.max_cumulative_win_rate : by === 'max_cumulative_win_rate_draw_no' ? b.max_cumulative_win_rate_draw_no : by === 'max_cumulative_win_rate_valid_index' ? b.max_cumulative_win_rate_valid_index : b.composite_score;
            if (va == null) va = desc ? -Infinity : Infinity;
            if (vb == null) vb = desc ? -Infinity : Infinity;
            if (va < vb) return desc ? 1 : -1;
            if (va > vb) return desc ? -1 : 1;
            return 0;
          });
        },
        compareSortedItems: function () {
          if (!this.compareResult || !this.compareResult.items || !this.compareResult.items.length) return [];
          var by = this.compareSortBy;
          var desc = this.compareSortDesc;
          return this.compareResult.items.slice().sort(function (a, b) {
            var va = by === 'win_rate' ? a.win_rate : by === 'roi' ? a.roi : a.composite_score;
            var vb = by === 'win_rate' ? b.win_rate : by === 'roi' ? b.roi : b.composite_score;
            if (va < vb) return desc ? 1 : -1;
            if (va > vb) return desc ? -1 : 1;
            return 0;
          });
        },
        gridFilterOptions: function () {
          var keys = this.gridFilterParamKeys;
          var items = this.gridResult && this.gridResult.items ? this.gridResult.items : [];
          var out = {};
          keys.forEach(function (k) {
            var set = {};
            items.forEach(function (item) {
              var v = item.params && item.params[k];
              if (v !== undefined && v !== null) set[v] = true;
            });
            out[k] = Object.keys(set).sort(function (a, b) {
              var na = Number(a); var nb = Number(b);
              if (!isNaN(na) && !isNaN(nb)) return na - nb;
              return String(a).localeCompare(String(b));
            });
          });
          return out;
        },
        gridAxesKeys: function () {
          var id = this.selectedAlgos[0];
          if (!id) return [];
          var axes = GRID_AXES[id];
          if (!axes || Object.keys(axes).length === 0) return [];
          return Object.keys(axes);
        },
        canRunSingle: function () {
          return this.selectedAlgos.length === 1 && (this.executionMode !== 'grid');
        },
        overlayChartWidth: function () {
          var items = this.gridSeriesOverlayItems || [];
          var maxN = 0;
          items.forEach(function (it) {
            var s = it.cumulative_win_rate_series;
            if (s && s.length > maxN) maxN = s.length;
          });
          return Math.max(900, 700 + Math.max(0, maxN - 200) * 0.8);
        },
        overlayChartMaxRate: function () {
          var items = this.gridSeriesOverlayItems || [];
          var maxR = 5;
          items.forEach(function (it) {
            var s = it.cumulative_win_rate_series;
            if (!s) return;
            for (var i = 0; i < s.length; i++) {
              var r = (s[i].win_rate || 0) * 100;
              if (r > maxR) maxR = Math.min(20, Math.ceil(r) + 1);
            }
          });
          return maxR < 0.5 ? 0.5 : maxR;
        },
        overlayRefLineY: function () {
          var maxRate = this.overlayChartMaxRate;
          var y1 = 235; var height = 210;
          return y1 - (2.4 / maxRate) * height;
        },
        overlayChartPolylines: function () {
          var items = this.gridSeriesOverlayItems || [];
          var w = this.overlayChartWidth - 90;
          var maxRate = this.overlayChartMaxRate;
          var x0 = 45; var y1 = 235; var height = 210;
          var maxN = 0;
          items.forEach(function (it) {
            var s = it.cumulative_win_rate_series;
            if (s && s.length > maxN) maxN = s.length;
          });
          var extend = this.overlayExtendShortSeries;
          return items.map(function (it) {
            var s = it.cumulative_win_rate_series;
            if (!s || !s.length) return { points: '' };
            var n = s.length;
            var lastY = y1 - ((s[n - 1].win_rate || 0) * 100 / maxRate) * height;
            var pts = [];
            var len = extend ? maxN : n;
            for (var j = 0; j < len; j++) {
              var xi = len > 1 ? x0 + (j / (len - 1)) * w : x0 + w / 2;
              var yi = j < n ? y1 - ((s[j].win_rate || 0) * 100 / maxRate) * height : lastY;
              pts.push(Math.round(xi * 10) / 10 + ',' + Math.round(yi * 10) / 10);
            }
            return { points: pts.join(' ') };
          });
        },
        canRunGrid: function () {
          if (this.selectedAlgos.length !== 1 || this.executionMode !== 'grid') return false;
          if (this.gridAxesKeys.length === 0) return false;
          var g = this.buildGrid();
          return g && Object.keys(g).length > 0;
        },
        progressMessage: function () {
          if (!this.progress) return '';
          var p = this.progress;
          if (p.combo_total != null && p.combo_total > 1) {
            return '조합 ' + (p.combo_current || 0) + '/' + p.combo_total + ', 진행 ' + p.current + '/' + p.total;
          }
          return p.current + '/' + p.total + ' 회차';
        },
        elapsedSeconds: function () {
          if (!this.startTime || !this.loading) return -1;
          return Math.floor((Date.now() - this.startTime) / 1000);
        },
      },
      watch: {
        selectedAlgos: {
          handler: function () {
            this.gridInputs = {};
            this.gridCheckboxes = {};
            var id = this.selectedAlgos[0];
            if (!id) return;
            var axes = GRID_AXES[id];
            if (axes) {
              for (var k in axes) {
                var v = axes[k];
                if (GRID_INPUT_PARAMS.indexOf(k) >= 0) {
                  this.gridInputs[k] = Array.isArray(v) ? v.join(', ') : '';
                } else {
                  // 확률 모드, temperature 등: 각각·복수 선택 가능하도록 빈 배열로 초기화
                  this.gridCheckboxes[k] = [];
                }
              }
            }
          },
          deep: true,
        },
      },
      async mounted() {
        await this.loadAlgorithms();
        await this.loadLatestDraw();
      },
      methods: {
        formatRankDistribution: function (rd) { return formatRankDistribution(rd); },
        formatRankDistributionCompact: function (rd) { return formatRankDistributionCompact(rd); },
        formatParamsForDisplay: function (params) { return formatParamsForDisplay(params); },
        formatParamsFirstLine: function (params) {
          var s = formatParamsForDisplay(params);
          return s ? s.split('\n')[0] : '';
        },
        getWinningValidDrawIndices: function (item) {
          var s = item && item.cumulative_win_rate_series;
          if (!s || !s.length) return [];
          var out = [];
          var prevWins = 0;
          for (var i = 0; i < s.length; i++) {
            var w = s[i].wins != null ? s[i].wins : 0;
            if (w > prevWins && s[i].valid_draw_index != null) out.push(s[i].valid_draw_index);
            prevWins = w;
          }
          return out;
        },
        formatWinningValidDrawIndices: function (item, maxShow) {
          var arr = this.getWinningValidDrawIndices(item);
          if (!arr.length) return '-';
          maxShow = maxShow != null ? maxShow : 12;
          if (arr.length <= maxShow) return arr.join(', ');
          return arr.slice(0, maxShow).join(', ') + ' 외 ' + (arr.length - maxShow) + '건';
        },
        copyWinningValidDrawIndices: function (item) {
          var arr = this.getWinningValidDrawIndices(item);
          if (!arr.length) return;
          var text = arr.join(', ');
          var self = this;
          if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(function () {
              self.copyWinningFeedback = item;
              setTimeout(function () { self.copyWinningFeedback = null; }, 1500);
            }).catch(function () { self.fallbackCopyToClipboard(text, item); });
          } else {
            this.fallbackCopyToClipboard(text, item);
          }
        },
        fallbackCopyToClipboard: function (text, item) {
          var ta = document.createElement('textarea');
          ta.value = text;
          ta.style.position = 'fixed';
          ta.style.opacity = '0';
          document.body.appendChild(ta);
          ta.select();
          try {
            document.execCommand('copy');
            this.copyWinningFeedback = item;
            var self = this;
            setTimeout(function () { self.copyWinningFeedback = null; }, 1500);
          } catch (e) {}
          document.body.removeChild(ta);
        },
        setGridSort: function (by) {
          if (this.gridSortBy === by) {
            this.gridSortDesc = !this.gridSortDesc;
          } else {
            this.gridSortBy = by;
            this.gridSortDesc = true;
          }
        },
        toggleGridParamFilter: function (key, value) {
          var arr = (this.gridParamFilters[key] || []).slice();
          var i = arr.findIndex(function (sel) { return sel == value; });
          if (i >= 0) arr.splice(i, 1); else arr.push(value);
          this.gridParamFilters = Object.assign({}, this.gridParamFilters, { [key]: arr });
        },
        toggleGridOverlayItem: function (item) {
          var idx = this.gridSeriesOverlayItems.indexOf(item);
          if (idx >= 0) this.gridSeriesOverlayItems.splice(idx, 1);
          else if (this.gridSeriesOverlayItems.length < 10) this.gridSeriesOverlayItems.push(item);
        },
        overlaySeriesColor: function (idx) {
          var colors = ['#3b82f6', '#ef4444', '#22c55e', '#eab308', '#8b5cf6', '#ec4899', '#06b6d4', '#f97316', '#84cc16', '#6366f1'];
          return colors[idx % colors.length];
        },
        onCumulativeChartMouseMove: function (ev, series) {
          if (!series || !series.length) return;
          var svg = ev.currentTarget;
          var rect = svg.getBoundingClientRect();
          var x = ev.clientX - rect.left;
          var totalW = this.cumulativeChartWidth(series);
          var plotW = totalW - 90;
          var xInChart = (x / rect.width) * totalW;
          var n = series.length;
          var index = Math.round((xInChart - 45) / plotW * (n - 1));
          if (index < 0) index = 0;
          if (index >= n) index = n - 1;
          var pt = series[index];
          this.chartTooltip = {
            style: { position: 'fixed', left: (ev.clientX + 10) + 'px', top: (ev.clientY + 10) + 'px' },
            valid_draw_index: pt.valid_draw_index,
            draw_no: pt.draw_no,
            win_rate_pct: (pt.win_rate * 100).toFixed(2),
          };
        },
        setCompareSort: function (by) {
          if (this.compareSortBy === by) {
            this.compareSortDesc = !this.compareSortDesc;
          } else {
            this.compareSortBy = by;
            this.compareSortDesc = true;
          }
        },
        formatElapsed: function (sec) {
          if (sec < 0) return '';
          var m = Math.floor(sec / 60);
          var s = sec % 60;
          return m > 0 ? m + '분 ' + s + '초' : s + '초';
        },
        cumulativeChartWidth: function (series) {
          if (!series || !series.length) return 520;
          var n = series.length;
          return 520 + Math.max(0, n - 460);
        },
        getCumulativeChartMaxRate: function (series) {
          if (!series || !series.length) return 5;
          var maxRate = 5;
          for (var i = 0; i < series.length; i++) {
            var r = (series[i].win_rate || 0) * 100;
            if (r > maxRate) maxRate = Math.min(20, Math.ceil(r) + 1);
          }
          return maxRate < 0.5 ? 0.5 : maxRate;
        },
        cumulativeSeriesPolyline: function (series, x0, y1, width, height) {
          if (!series || !series.length) return '';
          var n = series.length;
          var maxRate = this.getCumulativeChartMaxRate(series);
          var pts = [];
          for (var j = 0; j < n; j++) {
            var xi = n > 1 ? x0 + (j / (n - 1)) * width : x0 + width / 2;
            var yi = y1 - ((series[j].win_rate || 0) * 100 / maxRate) * height;
            pts.push(Math.round(xi * 10) / 10 + ',' + Math.round(yi * 10) / 10);
          }
          return pts.join(' ');
        },
        cumulativeChartXTicks: function (series, x0, width) {
          if (!series || !series.length) return [];
          var n = series.length;
          var step = Math.max(1, Math.floor(n / 5));
          var out = [];
          for (var i = 0; i < n; i += step) {
            var x = n > 1 ? x0 + (i / (n - 1)) * width : x0 + width / 2;
            out.push({ x: Math.round(x), label: series[i].valid_draw_index });
          }
          if (n > 0 && (out.length === 0 || out[out.length - 1].label !== series[n - 1].valid_draw_index)) {
            out.push({ x: Math.round(x0 + width), label: series[n - 1].valid_draw_index });
          }
          return out;
        },
        cumulativeChartYTicks: function (series, y1, height) {
          var maxRate = this.getCumulativeChartMaxRate(series);
          var out = [];
          var step = maxRate <= 2 ? 0.5 : maxRate <= 5 ? 1 : 2;
          for (var pct = 0; pct <= maxRate; pct += step) {
            var y = y1 - (pct / maxRate) * height;
            out.push({ y: Math.round(y), label: pct + '%' });
          }
          return out;
        },
        parseExcludeInclude: function (str) {
          if (!str || typeof str !== 'string') return [];
          return str.split(',').map(function (x) { return parseInt(x.trim(), 10); }).filter(function (n) { return !isNaN(n) && n >= 1 && n <= 45; });
        },
        parseWeightedWeights: function (str) {
          var def = [0.3, 0.3, 0.2, 0.2];
          if (!str || typeof str !== 'string') return def;
          var parts = str.split(',').map(function (x) { return parseFloat(x.trim(), 10); });
          return [parts[0], parts[1], parts[2], parts[3]].map(function (v, i) { return (typeof v === 'number' && !isNaN(v)) ? v : def[i]; });
        },
        buildAlgorithmParams: function () {
          var id = this.selectedAlgos[0];
          if (!id || id === 1 || id === 9) return null;
          var p = {};
          if (id === 2) {
            p.window_type = this.windowType;
            p.window_size = this.windowSize;
            p.probability_mode = this.probabilityMode;
            p.temperature = this.temperature;
            if (this.excludeConsecutive2) p.exclude_consecutive_2 = true;
            if (this.excludeFrequent) p.exclude_frequent = true;
            if (this.applyRecentPenalty) { p.apply_recent_penalty = true; p.penalty_rate = this.penaltyRate; }
          } else if (id === 3) {
            p.learning_mode = this.learningMode;
            p.window_size = this.windowSize;
            p.probability_mode = this.probabilityMode;
            p.temperature = this.temperature;
          } else if (id === 4) {
            p.pattern_type = this.patternType;
            p.range_divisions = this.rangeDivisions;
            p.rank_combo_size = this.rankComboSize;
            p.rank_mode = this.rankMode;
            p.rank_window = this.rankWindow;
            p.analysis_window_type = this.analysisWindowType;
            p.analysis_window_size = this.analysisWindowSize;
            p.top_n_patterns = this.topNPatterns;
            p.in_pattern_probability = this.inPatternProbability;
            p.pattern_selection_probability = this.patternSelectionProbability;
          } else if (id === 5) {
            p.recent_draws = this.recentDraws;
            var w = this.parseWeightedWeights(this.weightedWeightsInput);
            p.frequency_weight = w[0];
            p.recency_weight = w[1];
            p.zone_weight = w[2];
            p.diversity_weight = w[3];
          } else if (id === 6) {
            p.recent_draws = this.recentDraws;
            p.temperature = this.temperature;
          } else if (id === 7) {
            p.hot_window = this.hotWindow;
            p.hot_count = this.hotCount;
            p.cold_window = this.coldWindow;
            p.cold_count = this.coldCount;
          } else if (id === 8) {
            p.window_size = this.windowSize;
          }
          return Object.keys(p).length ? p : null;
        },
        isGridInputParam: function (key) {
          return GRID_INPUT_PARAMS.indexOf(key) >= 0;
        },
        gridAxisOptions: function (key) {
          var axes = GRID_AXES[this.selectedAlgos[0]];
          return (axes && axes[key]) || [];
        },
        paramLabel: function (key) {
          return PARAM_LABELS[key] || key;
        },
        gridPlaceholder: function (key) {
          var v = this.gridAxisOptions(key);
          if (Array.isArray(v)) return v.join(', ');
          return '';
        },
        gridAxisLabel: function (key, val) {
          if (key === 'exclude_consecutive_2') return val === true ? '연속 출현 제외' : '미적용';
          if (key === 'exclude_frequent') return val === true ? '고빈도 제외' : '미적용';
          if (key === 'apply_recent_penalty') return val === true ? '직전회차 할인' : '미적용';
          if (key === 'penalty_rate') return typeof val === 'number' ? Math.round(val * 100) + '%' : String(val);
          if (key === 'learning_mode') return val === 'cumulative' ? '누적' : '비누적';
          if (key === 'pattern_type') return val === 'rank' ? '순위패턴' : '범위패턴';
          if (key === 'rank_mode') return val === 'recent' ? '최근' : '누적';
          if (key === 'in_pattern_probability') return val === 'frequency' ? '빈도' : val === 'inverse' ? '역확률' : '균등';
          if (key === 'probability_mode') return val === 'inverse' ? '역확률' : '정확률';
          if (key === 'window_type') return val === 'recent' ? '최근N회' : '전체';
          return String(val);
        },
        buildGrid: function () {
          var grid = {};
          var id = this.selectedAlgos[0];
          var axes = GRID_AXES[id];
          if (!axes) return grid;
          for (var k in axes) {
            if (GRID_INPUT_PARAMS.indexOf(k) >= 0) {
              var val = parseGridValue(this.gridInputs[k]);
              if (val.length > 0) grid[k] = val;
            } else {
              var arr = this.gridCheckboxes[k];
              if (arr && arr.length > 0) {
                grid[k] = arr.map(function (x) {
                  var n = parseFloat(x);
                  return !isNaN(n) ? n : x;
                });
              }
            }
          }
          return grid;
        },
        async loadAlgorithms() {
          this.algoError = '';
          try {
            var res = await api.fetch(cfg.ENDPOINTS?.ALGORITHMS || '/api/algorithms/');
            var data = await res.json();
            this.algorithms = data.algorithms || data || [];
          } catch (e) {
            this.algoError = e.message || '알고리즘 목록 로드 실패';
          }
        },
        async loadLatestDraw() {
          try {
            var url = (cfg.API_BASE || '') + (cfg.ENDPOINTS?.DRAWS_LATEST || '/api/draws/latest');
            var res = await fetch(url, { cache: 'no-store' });
            if (!res.ok) return;
            var data = await res.json();
            var no = data.draw_no;
            if (no != null && no >= 1) {
              this.latestDrawNo = no;
              if (this.endDraw == null || this.endDraw === '' || this.endDraw === 0) {
                this.endDraw = no;
              }
            }
          } catch (e) {}
        },
        effectiveEndDraw: function () {
          var v = this.endDraw;
          if (v != null && v !== '' && v >= 1) return v;
          return this.latestDrawNo || 1100;
        },
        readStream: async function (url, body, onEvent) {
          var res = await api.fetch(url, { method: 'POST', body: JSON.stringify(body) });
          if (!res.ok) {
            var data = await res.json().catch(function () { return {}; });
            onEvent({ type: 'error', detail: data.detail || '실행 실패' });
            return;
          }
          var reader = res.body.getReader();
          var decoder = new TextDecoder();
          var buffer = '';
          var done = false;
          while (!done) {
            var r = await reader.read();
            if (r.done) break;
            buffer += decoder.decode(r.value, { stream: true });
            var lines = buffer.split('\n');
            buffer = lines.pop() || '';
            for (var i = 0; i < lines.length; i++) {
              if (!lines[i].trim()) continue;
              try {
                var obj = JSON.parse(lines[i]);
                onEvent(obj);
                if (obj.type === 'result' || obj.type === 'error') { done = true; break; }
              } catch (e) {}
            }
          }
        },
        async runSingle() {
          var auth = global.AdminAuth || {};
          if (!auth.hasToken || !auth.hasToken()) {
            this.error = '토큰이 없습니다. 로그아웃 후 다시 로그인해 주세요.';
            if (typeof global.AdminRouter !== 'undefined' && global.AdminRouter.navigate) {
              global.AdminRouter.navigate('login');
            }
            return;
          }
          if (this.selectedAlgos.length !== 1) {
            this.error = '단일 백테스트는 알고리즘 1개를 선택하세요.';
            return;
          }
          if (this.startDraw > this.effectiveEndDraw()) {
            this.error = '시작 회차는 종료 회차 이하여야 합니다.';
            return;
          }
          this.error = '';
          this.singleResult = null;
          this.gridResult = null;
          this.selectedGridSeriesItem = null;
          this.gridParamFilters = {};
          this.gridSeriesOverlayItems = [];
          this.compareResult = null;
          this.progress = null;
          this.startTime = Date.now();
          this.loading = true;
          var self = this;
          var excl = this.parseExcludeInclude(this.excludeNumbers);
          var incl = this.parseExcludeInclude(this.includeNumbers);
          var algoParams = this.buildAlgorithmParams();
          try {
            await this.readStream((cfg.ENDPOINTS?.BACKTEST_RUN_STREAM || '/api/admin/backtest/run-stream'), {
              algorithm_id: this.selectedAlgos[0],
              start_draw: this.startDraw,
              end_draw: this.effectiveEndDraw(),
              n_sets: this.nSets,
              enable_detailed_log: this.enableDetailedLog,
              exclude_numbers: excl.length ? excl : undefined,
              include_numbers: incl.length ? incl : undefined,
              algorithm_params: algoParams || undefined,
            }, function (obj) {
              if (obj.type === 'progress') self.progress = obj;
              if (obj.type === 'result') { self.singleResult = obj.data; }
              if (obj.type === 'error') { self.error = obj.detail; }
            });
          } catch (e) {
            self.error = e.message || '백테스트 실행 실패';
          } finally {
            self.loading = false;
            self.progress = null;
            self.startTime = null;
          }
        },
        async runGrid() {
          var auth = global.AdminAuth || {};
          if (!auth.hasToken || !auth.hasToken()) {
            this.error = '토큰이 없습니다. 로그아웃 후 다시 로그인해 주세요.';
            if (typeof global.AdminRouter !== 'undefined' && global.AdminRouter.navigate) {
              global.AdminRouter.navigate('login');
            }
            return;
          }
          if (this.selectedAlgos.length !== 1) {
            this.error = '그리드 루프는 알고리즘 1개를 선택하세요.';
            return;
          }
          var grid = this.buildGrid();
          if (!grid || Object.keys(grid).length === 0) {
            this.error = '루프에 포함할 요소를 입력하세요.';
            return;
          }
          if (this.startDraw > this.effectiveEndDraw()) {
            this.error = '시작 회차는 종료 회차 이하여야 합니다.';
            return;
          }
          this.error = '';
          this.singleResult = null;
          this.gridResult = null;
          this.selectedGridSeriesItem = null;
          this.gridParamFilters = {};
          this.gridSeriesOverlayItems = [];
          this.compareResult = null;
          this.progress = null;
          this.startTime = Date.now();
          this.loading = true;
          var self = this;
          var excl = this.parseExcludeInclude(this.excludeNumbers);
          var incl = this.parseExcludeInclude(this.includeNumbers);
          try {
            await this.readStream((cfg.ENDPOINTS?.BACKTEST_RUN_GRID_STREAM || '/api/admin/backtest/run-grid-stream'), {
              algorithm_id: this.selectedAlgos[0],
              start_draw: this.startDraw,
              end_draw: this.effectiveEndDraw(),
              n_sets: this.nSets,
              grid: grid,
              max_combinations: 300,
              enable_detailed_log: this.enableDetailedLog,
              exclude_numbers: excl.length ? excl : undefined,
              include_numbers: incl.length ? incl : undefined,
            }, function (obj) {
              if (obj.type === 'progress') self.progress = obj;
              if (obj.type === 'result') { self.gridResult = obj.data; self.gridParamFilters = {}; self.gridSeriesOverlayItems = []; }
              if (obj.type === 'error') { self.error = obj.detail; }
            });
          } catch (e) {
            self.error = e.message || '그리드 루프 실행 실패';
          } finally {
            self.loading = false;
            self.progress = null;
            self.startTime = null;
          }
        },
        async runCompare() {
          if (this.selectedAlgos.length < 2) {
            this.error = '비교 백테스트는 알고리즘 2개 이상을 선택하세요.';
            return;
          }
          if (this.startDraw > this.effectiveEndDraw()) {
            this.error = '시작 회차는 종료 회차 이하여야 합니다.';
            return;
          }
          this.error = '';
          this.singleResult = null;
          this.gridResult = null;
          this.selectedGridSeriesItem = null;
          this.gridParamFilters = {};
          this.gridSeriesOverlayItems = [];
          this.compareResult = null;
          this.loading = true;
          try {
            var url = (cfg.ENDPOINTS?.BACKTEST_COMPARE || '/api/admin/backtest/compare') +
              '?algorithm_ids=' + this.selectedAlgos.join(',') +
              '&start_draw=' + this.startDraw +
              '&end_draw=' + this.effectiveEndDraw() +
              '&n_sets=' + this.nSets;
            var res = await api.fetch(url);
            var data = await res.json();
            if (!res.ok) {
              this.error = data?.detail || (typeof data === 'string' ? data : '실행 실패');
              return;
            }
            this.compareResult = data;
          } catch (e) {
            this.error = e.message || '비교 백테스트 실행 실패';
          } finally {
            this.loading = false;
          }
        },
      },
    };
  }

  function BacktestHistoryPage() {
    return {
      template: `
        <div class="space-y-4">
          <h2 class="text-xl font-bold text-gray-800">백테스트 이력</h2>
          <p v-if="loading" class="text-gray-500">로딩 중...</p>
          <div v-else-if="items.length === 0" class="text-gray-500">최근 실행 이력이 없습니다.</div>
          <div v-else class="bg-white rounded-lg shadow overflow-hidden">
            <table class="min-w-full text-sm">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-4 py-2 text-left">시각</th>
                  <th class="px-4 py-2 text-left">알고리즘</th>
                  <th class="px-4 py-2 text-right">회차</th>
                  <th class="px-4 py-2 text-right">당첨률</th>
                  <th class="px-4 py-2 text-right">ROI</th>
                  <th class="px-4 py-2 text-right">종합 점수</th>
                  <th class="px-4 py-2">등급</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in items" :key="item.backtest_id || item.created_at" :class="items.indexOf(item) % 2 ? 'bg-gray-50' : ''">
                  <td class="px-4 py-2 text-xs">{{ item.created_at }}</td>
                  <td class="px-4 py-2">{{ item.algorithm_id }}. {{ item.algorithm_name }}</td>
                  <td class="px-4 py-2 text-right">{{ item.period && item.period.start }}~{{ item.period && item.period.end }}</td>
                  <td class="px-4 py-2 text-right">{{ item.win_rate != null ? (item.win_rate * 100).toFixed(2) + '%' : '-' }}</td>
                  <td class="px-4 py-2 text-right">{{ item.roi != null ? item.roi.toFixed(1) + '%' : '-' }}</td>
                  <td class="px-4 py-2 text-right">{{ item.composite_score != null ? item.composite_score : '-' }}</td>
                  <td class="px-4 py-2">{{ item.grade || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      `,
      data: function () {
        return { items: [], loading: false };
      },
      async mounted() {
        this.loading = true;
        try {
          var res = await api.fetch((cfg.ENDPOINTS?.BACKTEST_HISTORY || '/api/admin/backtest/history') + '?limit=20');
          var data = await res.json();
          this.items = data.items || [];
        } catch (e) {
          this.items = [];
        } finally {
          this.loading = false;
        }
      },
    };
  }

  global.AdminPages = global.AdminPages || {};
  global.AdminPages.Backtest = BacktestPage;
  global.AdminPages.BacktestHistory = BacktestHistoryPage;
})(typeof window !== 'undefined' ? window : this);
