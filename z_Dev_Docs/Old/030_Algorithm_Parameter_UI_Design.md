# 030. 알고리즘 파라미터 UI 설계서

**문서 버전**: v1.0  
**작성일**: 2026-01-17 EST  
**작성자**: AI Assistant  
**프로젝트**: LuckyAI 645 - Lotto Number Generator  

---

## 📋 목차

1. [개요](#1-개요)
2. [전체 UI 구조](#2-전체-ui-구조)
3. [알고리즘별 파라미터 설계](#3-알고리즘별-파라미터-설계)
4. [공통 컴포넌트 설계](#4-공통-컴포넌트-설계)
5. [상태 관리 구조](#5-상태-관리-구조)
6. [구현 우선순위](#6-구현-우선순위)
7. [다국어 지원](#7-다국어-지원)

---

## 1. 개요

### 1.1 목적

사용자가 각 알고리즘의 파라미터를 직관적으로 설정하고 번호를 생성할 수 있는 **확장형 UI**를 설계합니다.

### 1.2 핵심 설계 원칙

#### ✅ 확장형 (Expandable) 방식
- 알고리즘 선택 시 해당 알고리즘의 파라미터, 생성 개수, 생성 버튼이 모두 확장 영역에 표시됨
- 한 화면에서 모든 작업 완료 (스크롤 최소화)
- 맥락 유지: 알고리즘 ↔ 설정 ↔ 실행이 시각적으로 연결됨

#### 🎯 기본 동작
1. **앱 시작 시**: "자동선택" 알고리즘이 선택되어 있고 확장되어 있음
2. **다른 알고리즘 선택 시**: 이전 알고리즘은 접히고, 선택한 알고리즘이 확장됨
3. **확장 영역 구성**: 파라미터 설정 → 생성 개수 선택 → 번호 생성 버튼 (상→하 순서)

#### 🎨 시각적 계층
```
알고리즘 선택 (RadioListTile)
└─ 확장 영역 (Container with light background)
    ├─ 파라미터 섹션 (알고리즘별로 다름)
    ├─ Divider
    ├─ 생성 개수 섹션 (공통)
    ├─ Divider
    └─ 번호 생성 버튼 (공통)
```

---

## 2. 전체 UI 구조

### 2.1 화면 레이아웃

```dart
ListView(
  children: [
    Card(
      child: Column(
        children: [
          // 알고리즘 1: 자동선택 (Quick Pick)
          RadioListTile(
            title: "자동선택 (Quick Pick)",
            subtitle: "1~45 중 6개를 완전 무작위로 선택",
            value: algorithm1,
            groupValue: selectedAlgorithm,
            onChanged: (value) { /* 알고리즘 선택 */ },
          ),
          
          // 확장 영역 (알고리즘 1 선택 시)
          if (selectedAlgorithm?.id == 1)
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              child: _buildExpandedSection(
                parameters: null, // 파라미터 없음
                showGeneration: true,
              ),
            ),
          
          Divider(),
          
          // 알고리즘 2: 고급 빈도 분석
          RadioListTile(...),
          if (selectedAlgorithm?.id == 2)
            AnimatedSize(...),
          
          // ... 나머지 알고리즘들
        ],
      ),
    ),
  ],
)
```

### 2.2 확장 영역 구조

```dart
Widget _buildExpandedSection({
  Widget? parameters,
  required bool showGeneration,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    color: Colors.grey[50],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 파라미터 섹션 (있을 경우)
        if (parameters != null) ...[
          parameters,
          Divider(height: 32),
        ],
        
        // 생성 개수 섹션
        _buildNumberOfSetsSelector(),
        
        SizedBox(height: 16),
        
        // 번호 생성 버튼
        _buildGenerateButton(),
      ],
    ),
  );
}
```

---

## 3. 알고리즘별 파라미터 설계

### 3.1 알고리즘 1: 자동선택 (Quick Pick)

#### 파라미터
- **없음** (완전 무작위)

#### UI 구성
```
● 자동선택 (Quick Pick) ▼
  ┌──────────────────────────────┐
  │ (파라미터 없음)               │
  ├──────────────────────────────┤
  │ 📦 생성 개수                  │
  │   [5개] [10개] [직접입력]    │
  ├──────────────────────────────┤
  │ [🎲 번호 생성하기]           │
  └──────────────────────────────┘
```

#### 코스트
- **0 코인** (무료)

---

### 3.2 알고리즘 2: 고급 빈도 분석 (Advanced Frequency)

#### 파라미터 (10개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **A. 분석 범위** |
| window_type | 'all' \| 'recent' | string | 'all' | Radio |
| window_size | int | int | 50 | Slider (10~200) |
| **B. 제외 필터** |
| exclude_consecutive_2 | bool | bool | false | Checkbox |
| exclude_frequent | bool | bool | false | Checkbox |
| frequent_lookback | int | int | 10 | Slider (5~50) |
| frequent_threshold | int | int | 5 | Slider (3~10) |
| apply_recent_penalty | bool | bool | false | Checkbox |
| penalty_rate | float | float | 0.5 | Slider (0.1~1.0) |
| **C. 확률 모드** |
| probability_mode | 'normal' \| 'inverse' | string | 'normal' | Radio |
| **D. 온도** |
| temperature | float | float | 1.0 | Slider (0.5~2.0) |

#### UI 구성
```
● 고급 빈도 분석 (Advanced Frequency) ▼
  ┌──────────────────────────────────┐
  │ 📊 분석 범위                      │
  │   ● 전체 데이터  ○ 최근 N회차    │
  │   회차 수: [50] ──────●──────    │
  │                                   │
  │ 🚫 제외 필터                      │
  │   □ 연속 출현 제외 (직전 2회차)  │
  │   ☑ 고빈도 번호 제외              │
  │     └ 최근 [10]회차에서 [5]회 이상│
  │   ☑ 직전 회차 확률 할인           │
  │     └ 할인율: 50% ──●──          │
  │                                   │
  │ 🎲 확률 모드                      │
  │   ● 정확률  ○ 역확률              │
  │                                   │
  │ 🌡️ 온도 (무작위성)               │
  │   1.0 ──────●──────              │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (1~3 코인)   │
  └──────────────────────────────────┘
```

#### 코스트 계산
```dart
int calculateCost() {
  int cost = 1; // 기본 비용
  
  if (probability_mode == 'inverse') cost += 1;
  if (exclude_consecutive_2 || exclude_frequent || apply_recent_penalty) cost += 1;
  
  return cost; // 1~3 코인
}
```

#### Widget 구조
```dart
Widget _buildAdvancedFrequencyParameters() {
  return Column(
    children: [
      _buildSectionHeader("📊 분석 범위"),
      _buildRadioGroup(...),
      if (windowType == 'recent')
        _buildSlider("회차 수", windowSize, 10, 200),
      
      SizedBox(height: 16),
      
      _buildSectionHeader("🚫 제외 필터"),
      _buildCheckbox("연속 출현 제외", excludeConsecutive2),
      _buildCheckbox("고빈도 번호 제외", excludeFrequent),
      if (excludeFrequent) ...[
        Padding(
          padding: EdgeInsets.only(left: 32),
          child: Column(
            children: [
              _buildSlider("조회 회차", frequentLookback, 5, 50),
              _buildSlider("출현 기준", frequentThreshold, 3, 10),
            ],
          ),
        ),
      ],
      _buildCheckbox("직전 회차 확률 할인", applyRecentPenalty),
      if (applyRecentPenalty)
        Padding(
          padding: EdgeInsets.only(left: 32),
          child: _buildSlider("할인율", penaltyRate, 0.1, 1.0, isPercent: true),
        ),
      
      SizedBox(height: 16),
      
      _buildSectionHeader("🎲 확률 모드"),
      _buildRadioGroup(...),
      
      SizedBox(height: 16),
      
      _buildSectionHeader("🌡️ 온도"),
      _buildSlider("온도", temperature, 0.5, 2.0),
    ],
  );
}
```

---

### 3.3 알고리즘 3: LSTM 고급 분석 (Advanced LSTM)

#### 파라미터 (12개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **A. 학습 방식** |
| learning_mode | 'non-cumulative' \| 'cumulative' | string | 'non-cumulative' | Radio |
| **B. 확률 방식** |
| probability_mode | 'normal' \| 'inverse' | string | 'normal' | Radio |
| **C. 학습 범위** |
| window_size | int | int | 100 | Slider (50~200) |
| **D. 모델 구조** |
| hidden_size | int | int | 128 | Dropdown (64, 128, 256) |
| num_layers | int | int | 2 | Dropdown (1, 2, 3, 4) |
| dropout | float | float | 0.2 | Slider (0.0~0.5) |
| **E. 학습 설정** |
| num_epochs | int | int | 50 | Slider (10~200) |
| learning_rate | float | float | 0.001 | Dropdown (0.0001, 0.001, 0.01) |
| batch_size | int | int | 32 | Dropdown (16, 32, 64) |
| **F. 추가 옵션** |
| apply_recent_penalty | bool | bool | false | Checkbox |
| penalty_rate | float | float | 0.5 | Slider (0.1~1.0) |
| temperature | float | float | 1.0 | Slider (0.5~2.0) |

#### UI 구성
```
● LSTM 고급 분석 (Advanced LSTM) ▼
  ┌──────────────────────────────────┐
  │ 🧠 학습 방식                      │
  │   ● 전체 학습  ○ 증분 학습        │
  │   ℹ️ 증분 학습은 이전 모델 재사용 │
  │                                   │
  │ 🎲 확률 방식                      │
  │   ● 정확률  ○ 역확률              │
  │                                   │
  │ 📊 학습 범위                      │
  │   회차 수: [100] ──────●──────   │
  │                                   │
  │ 🔧 모델 구조 (고급)               │
  │   [▼ 고급 설정 보기]              │
  │   (접힘 상태)                     │
  │                                   │
  │ ⚙️ 학습 설정 (고급)               │
  │   [▼ 고급 설정 보기]              │
  │   (접힘 상태)                     │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (2~5 코인)   │
  └──────────────────────────────────┘
```

**고급 설정 펼침 시**:
```
  │ 🔧 모델 구조 (고급)               │
  │   [▲ 고급 설정 숨기기]            │
  │   Hidden Size: [128▼] (64/128/256)│
  │   Layers: [2▼] (1/2/3/4)          │
  │   Dropout: 0.2 ──●──              │
  │                                   │
  │ ⚙️ 학습 설정 (고급)               │
  │   [▲ 고급 설정 숨기기]            │
  │   Epochs: [50] ──────●──────     │
  │   Learning Rate: [0.001▼]        │
  │   Batch Size: [32▼] (16/32/64)   │
```

#### 코스트 계산
```dart
int calculateCost() {
  final baseMap = {
    ('non-cumulative', 'normal'): 3,
    ('non-cumulative', 'inverse'): 4,
    ('cumulative', 'normal'): 2,
    ('cumulative', 'inverse'): 5,
  };
  
  int cost = baseMap[(learning_mode, probability_mode)] ?? 3;
  
  if (hidden_size >= 256) cost += 1;
  if (num_epochs >= 100) cost += 1;
  
  return cost; // 2~7 코인
}
```

#### 특이사항
- **2단계 확장**: 기본 설정 + 고급 설정
- **긴 학습 시간**: 로딩 인디케이터 + 진행률 표시 필요
- **PyTorch 미설치 시**: 경고 메시지 표시

---

### 3.4 알고리즘 4: 패턴 분석 (Advanced Pattern)

#### 파라미터 (10개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **A. 패턴 타입** |
| pattern_type | 'range' \| 'rank' | string | 'range' | Radio |
| **B-1. 범위 패턴** |
| range_divisions | int | int | 5 | Dropdown (2, 3, 5, 10) |
| custom_ranges | dict? | dict | null | (고급) |
| **B-2. 순위 패턴** |
| rank_combo_size | int | int | 3 | Slider (2~5) |
| rank_mode | 'cumulative' \| 'recent' | string | 'cumulative' | Radio |
| rank_window | int | int | 50 | Slider (10~100) |
| **C. 분석 범위** |
| analysis_window_type | 'all' \| 'recent' | string | 'all' | Radio |
| analysis_window_size | int? | int | 100 | Slider (50~200) |
| **D. 상위 패턴** |
| top_n_patterns | int | int | 10 | Slider (5~20) |
| **E. 패턴 내 확률** |
| in_pattern_probability | 'uniform' \| 'frequency' \| 'inverse' | string | 'frequency' | Radio |

#### UI 구성
```
● 패턴 분석 (Advanced Pattern) ▼
  ┌──────────────────────────────────┐
  │ 🎯 패턴 타입                      │
  │   ● 범위 패턴  ○ 순위 패턴        │
  │                                   │
  │ [범위 패턴 선택 시]               │
  │ 📐 범위 구간                      │
  │   구간 수: [5▼] (2/3/5/10 구간)  │
  │   ℹ️ 5구간: 1-9, 10-18, ...      │
  │                                   │
  │ [순위 패턴 선택 시]               │
  │ 📊 순위 설정                      │
  │   조합 크기: [3] ──●──            │
  │   ● 누적 빈도  ○ 최근 빈도        │
  │   최근 회차: [50] ──────●──────  │
  │                                   │
  │ 📦 분석 범위                      │
  │   ● 전체 데이터  ○ 최근 N회차    │
  │                                   │
  │ 🔝 상위 패턴 개수                 │
  │   [10] ──────●──────              │
  │                                   │
  │ 🎲 패턴 내 번호 선택 방식         │
  │   ○ 균등  ● 빈도  ○ 역확률       │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (2~4 코인)   │
  └──────────────────────────────────┘
```

#### 코스트 계산
```dart
int calculateCost() {
  int cost = 2;
  
  if (in_pattern_probability == 'inverse') cost += 1;
  if (pattern_type == 'range' && range_divisions >= 10) cost += 1;
  if (pattern_type == 'rank' && rank_combo_size >= 4) cost += 1;
  
  return cost; // 2~5 코인
}
```

---

### 3.5 알고리즘 5: 가중치 조합 (Weighted)

#### 파라미터 (6개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **가중치 설정** |
| frequency_weight | float | float | 0.3 | Slider (0.0~1.0) |
| recency_weight | float | float | 0.3 | Slider (0.0~1.0) |
| zone_weight | float | float | 0.2 | Slider (0.0~1.0) |
| diversity_weight | float | float | 0.2 | Slider (0.0~1.0) |
| **데이터 범위** |
| recent_draws | int | int | 100 | Slider (50~200) |

#### UI 구성
```
● 가중치 조합 (Weighted) ▼
  ┌──────────────────────────────────┐
  │ ⚖️ 가중치 설정                    │
  │                                   │
  │ 📊 빈도 가중치                    │
  │   30% ──────●──────              │
  │   └ 자주 나온 번호 우선           │
  │                                   │
  │ ⏰ 최근성 가중치                  │
  │   30% ──────●──────              │
  │   └ 최근에 나온 번호 우선         │
  │                                   │
  │ 📐 구간 균형 가중치               │
  │   20% ──────●──────              │
  │   └ 구간 분포 균형 고려           │
  │                                   │
  │ 🎨 다양성 가중치                  │
  │   20% ──────●──────              │
  │   └ 홀짝/끝자리 다양성 고려       │
  │                                   │
  │ 합계: 100% (자동 정규화)          │
  │                                   │
  │ 📊 분석 범위                      │
  │   최근 [100]회차 ──────●──────   │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (3 코인)      │
  └──────────────────────────────────┘
```

#### 특이사항
- **가중치 합계 표시**: 실시간으로 합계 표시 (자동 정규화)
- **설명 툴팁**: 각 가중치의 의미를 아이콘으로 표시

#### 코스트
- **고정 3 코인**

---

### 3.6 알고리즘 6: 빈도 기반 (Frequency)

#### 파라미터 (2개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **분석 범위** |
| recent_draws | int | int | 100 | Slider (50~200) |
| **확률 조정** |
| temperature | float | float | 1.0 | Slider (0.5~2.0) |

#### UI 구성
```
● 빈도 기반 (Frequency) ▼
  ┌──────────────────────────────────┐
  │ 📊 분석 범위                      │
  │   최근 [100]회차 ──────●──────   │
  │                                   │
  │ 🌡️ 온도 (무작위성)               │
  │   1.0 ──────●──────              │
  │   ℹ️ 낮을수록 고빈도 집중         │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (1 코인)      │
  └──────────────────────────────────┘
```

#### 코스트
- **고정 1 코인**

---

### 3.7 알고리즘 7: 핫/콜드 넘버 (Hot & Cold)

#### 파라미터 (5개)

| 카테고리 | 파라미터 | 타입 | 기본값 | UI 컴포넌트 |
|---------|---------|------|--------|------------|
| **Hot 설정** |
| hot_window | int | int | 20 | Slider (10~50) |
| hot_count | int | int | 3 | Slider (1~5) |
| **Cold 설정** |
| cold_window | int | int | 50 | Slider (20~100) |
| cold_count | int | int | 2 | Slider (1~5) |

#### UI 구성
```
● 핫/콜드 넘버 (Hot & Cold) ▼
  ┌──────────────────────────────────┐
  │ 🔥 Hot 번호 (자주 나온 번호)     │
  │   분석 회차: [20] ──────●──────  │
  │   선택 개수: [3] ──────●──────   │
  │                                   │
  │ ❄️ Cold 번호 (오래 안 나온 번호) │
  │   분석 회차: [50] ──────●──────  │
  │   선택 개수: [2] ──────●──────   │
  │                                   │
  │ ℹ️ 나머지는 무작위 선택           │
  ├──────────────────────────────────┤
  │ 📦 생성 개수                      │
  │   [5개] [10개] [직접입력]        │
  ├──────────────────────────────────┤
  │ [🎲 번호 생성하기] (1 코인)      │
  └──────────────────────────────────┘
```

#### 코스트
- **고정 1 코인**

---

## 4. 공통 컴포넌트 설계

### 4.1 생성 개수 선택 (공통)

**모든 알고리즘에서 동일하게 사용**

```dart
Widget _buildNumberOfSetsSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.numberOfSets,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            context.l10n.numberOfSetsCount(numberOfSets),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 16),
      
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => numberOfSets = 5),
              child: Text("5개"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => numberOfSets = 10),
              child: Text("10개"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showNumberInput(),
              child: Text("직접입력"),
            ),
          ),
        ],
      ),
    ],
  );
}
```

---

### 4.2 번호 생성 버튼 (공통)

**동적 코스트 표시 + 비활성화 처리**

```dart
Widget _buildGenerateButton() {
  final isDisabled = selectedAlgorithm == null || numberOfSets == 0;
  final cost = _calculateCurrentCost();
  
  return ElevatedButton(
    onPressed: isDisabled
        ? () => _showRequirementDialog()
        : () => _generateNumbers(),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 20),
      backgroundColor: isDisabled ? Colors.grey : null,
    ),
    child: isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.casino),
              SizedBox(width: 8),
              Text(
                context.l10n.generateButton,
                style: TextStyle(fontSize: 18),
              ),
              if (cost > 0) ...[
                SizedBox(width: 8),
                Text(
                  "($cost ${context.l10n.coinsUnit})",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
  );
}
```

---

### 4.3 재사용 가능한 위젯들

#### 섹션 헤더
```dart
Widget _buildSectionHeader(String title, {String? subtitle}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (subtitle != null) ...[
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
      SizedBox(height: 12),
    ],
  );
}
```

#### 슬라이더
```dart
Widget _buildSlider(
  String label,
  double value,
  double min,
  double max, {
  int? divisions,
  bool isPercent = false,
  ValueChanged<double>? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isPercent 
                ? "${(value * 100).toInt()}%"
                : value.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    ],
  );
}
```

#### 체크박스
```dart
Widget _buildCheckbox(
  String label,
  bool value,
  ValueChanged<bool?> onChanged, {
  String? subtitle,
}) {
  return CheckboxListTile(
    title: Text(label),
    subtitle: subtitle != null ? Text(subtitle) : null,
    value: value,
    onChanged: onChanged,
    dense: true,
    contentPadding: EdgeInsets.zero,
  );
}
```

#### 라디오 그룹
```dart
Widget _buildRadioGroup<T>(
  String label,
  T value,
  List<RadioOption<T>> options,
  ValueChanged<T?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ...options.map((option) => RadioListTile<T>(
        title: Text(option.label),
        subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
        value: option.value,
        groupValue: value,
        onChanged: onChanged,
        dense: true,
      )),
    ],
  );
}
```

---

## 5. 상태 관리 구조

### 5.1 Riverpod Providers

```dart
// 선택된 알고리즘
final selectedAlgorithmProvider = StateProvider<Algorithm?>((ref) => null);

// 생성 개수
final numberOfSetsProvider = StateProvider<int>((ref) => 5);

// 알고리즘별 파라미터
final algorithmParametersProvider = StateNotifierProvider<
  AlgorithmParametersNotifier,
  Map<int, Map<String, dynamic>>
>((ref) => AlgorithmParametersNotifier());

// 알고리즘 파라미터 Notifier
class AlgorithmParametersNotifier extends StateNotifier<Map<int, Map<String, dynamic>>> {
  AlgorithmParametersNotifier() : super({});
  
  // 파라미터 가져오기
  Map<String, dynamic> getParameters(int algorithmId) {
    return state[algorithmId] ?? _getDefaultParameters(algorithmId);
  }
  
  // 파라미터 업데이트
  void updateParameter(int algorithmId, String key, dynamic value) {
    final current = state[algorithmId] ?? _getDefaultParameters(algorithmId);
    state = {
      ...state,
      algorithmId: {...current, key: value},
    };
  }
  
  // 파라미터 초기화
  void resetParameters(int algorithmId) {
    state = {...state, algorithmId: _getDefaultParameters(algorithmId)};
  }
  
  Map<String, dynamic> _getDefaultParameters(int algorithmId) {
    // 각 알고리즘의 기본 파라미터 반환
    switch (algorithmId) {
      case 1: return {};
      case 2: return {
        'window_type': 'all',
        'window_size': 50,
        // ... 나머지 기본값
      };
      // ... 다른 알고리즘들
      default: return {};
    }
  }
}
```

### 5.2 데이터 흐름

```
User Action (슬라이더 이동)
    ↓
updateParameter(algorithmId, 'temperature', 1.5)
    ↓
algorithmParametersProvider 상태 업데이트
    ↓
UI 자동 리빌드 (Consumer 위젯)
    ↓
번호 생성 버튼에 새로운 파라미터 반영
```

---

## 6. 구현 우선순위

### ✅ Phase 1: 기본 구조 (완료 - 2026-01-17)
- [x] 확장형 UI 레이아웃 구현
- [x] 공통 컴포넌트 제작 (슬라이더, 체크박스 등)
- [x] 알고리즘 1 (자동선택) 완성

**완료일**: 2026-01-17 EST  
**커밋**: `ad62b65` - Phase 1-4 완료

### ✅ Phase 2: 간단한 알고리즘 (완료 - 2026-01-17)
- [x] 알고리즘 6 (빈도 기반) - 2개 파라미터
- [x] 알고리즘 7 (핫/콜드) - 4개 파라미터

**완료일**: 2026-01-17 EST  
**커밋**: `ad62b65` - Phase 1-4 완료

### ✅ Phase 3: 중급 알고리즘 (완료 - 2026-01-17)
- [x] 알고리즘 2 (고급 빈도 분석) - 10개 파라미터
- [x] 알고리즘 5 (가중치 조합) - 5개 파라미터

**완료일**: 2026-01-17 EST  
**커밋**: `ad62b65` - Phase 1-4 완료

### ✅ Phase 4: 고급 알고리즘 (완료 - 2026-01-17)
- [x] 알고리즘 4 (패턴 분석) - 9개 파라미터
- [x] 알고리즘 3 (LSTM) - 3개 기본 파라미터 (고급 설정 기본값 사용)

**완료일**: 2026-01-17 EST  
**커밋**: `ad62b65` - Phase 1-4 완료  
**참고**: LSTM은 기본 설정만 노출, 고급 설정(모델 구조/학습 설정)은 기본값 사용

### ✅ Phase 5: UX 개선 (완료 - 2026-01-17)
- [x] **Phase 5-1**: 슬라이더 → 프리셋 + 직접 입력 교체
  - [x] ParameterPresets 클래스 구현
  - [x] ParameterRanges 클래스 구현
  - [x] 정수형/실수형 입력 위젯 구현
  - [x] 범위 검증 및 오류 모달
  - [x] 20개 파라미터 슬라이더 제거
  
- [x] **Phase 5-2**: 도움말 시스템 구현
  - [x] AlgorithmHelpData 클래스 구현
  - [x] 7개 알고리즘 도움말 작성
  - [x] 31개 파라미터 도움말 작성
  - [x] 알고리즘 도움말 모달
  - [x] 파라미터 도움말 모달
  - [x] UI 통합 (도움말 버튼)

- [ ] **Phase 5-3**: 다듬기 (선택사항)
  - [ ] 애니메이션 최적화
  - [ ] 로딩 상태 개선
  - [ ] 에러 핸들링 강화

**완료일**: 2026-01-17 EST  
**커밋**: `56d575c` - Phase 5 완료

---

## 📊 구현 완료 현황 (2026-01-17 기준)

### 완료된 작업
✅ **7개 알고리즘 전체 구현 완료**
- 알고리즘 1: 자동선택 (파라미터 0개)
- 알고리즘 2: 고급 빈도 분석 (파라미터 10개)
- 알고리즘 3: LSTM (파라미터 3개)
- 알고리즘 4: 패턴 분석 (파라미터 9개)
- 알고리즘 5: 가중치 조합 (파라미터 5개)
- 알고리즘 6: 빈도 기반 (파라미터 2개)
- 알고리즘 7: 핫/콜드 (파라미터 4개)

✅ **총 33개 파라미터 UI 구현**
- 프리셋 버튼 + 직접 입력 방식
- 범위 자동 표시 및 검증
- 도움말 버튼 통합

✅ **도움말 시스템**
- 7개 알고리즘 설명 (개요/동작원리/사용시기)
- 31개 파라미터 설명 (설명/영향/추천값)

✅ **공통 컴포넌트**
- 정수형 입력 (_buildIntInput)
- 실수형 입력 (_buildDoubleInput)
- 체크박스 (_buildCheckbox)
- 라디오 그룹 (_buildRadioGroup)
- 드롭다운 (_buildDropdown)
- 섹션 헤더 (_buildSectionHeader)

### 다음 단계
🎯 **백엔드 연동**
- [ ] API 요청에 파라미터 전달
- [ ] 실제 번호 생성 테스트
- [ ] 오류 처리 및 피드백

🎯 **테스트 및 검증**
- [ ] 모든 알고리즘 파라미터 테스트
- [ ] 도움말 내용 검증
- [ ] 모바일 환경 테스트

---

## 7. 다국어 지원

### 7.1 새로 추가할 키 (ARB 파일)

```json
{
  "algorithmParameters": "알고리즘 파라미터",
  "analysisRange": "분석 범위",
  "allData": "전체 데이터",
  "recentDraws": "최근 N회차",
  "exclusionFilters": "제외 필터",
  "excludeConsecutive": "연속 출현 제외",
  "excludeFrequent": "고빈도 번호 제외",
  "recentPenalty": "직전 회차 확률 할인",
  "probabilityMode": "확률 모드",
  "normalProbability": "정확률",
  "inverseProbability": "역확률",
  "temperature": "온도 (무작위성)",
  "advancedSettings": "고급 설정",
  "showAdvancedSettings": "고급 설정 보기",
  "hideAdvancedSettings": "고급 설정 숨기기",
  "learningMode": "학습 방식",
  "fullTraining": "전체 학습",
  "incrementalTraining": "증분 학습",
  "patternType": "패턴 타입",
  "rangePattern": "범위 패턴",
  "rankPattern": "순위 패턴",
  "weightSettings": "가중치 설정",
  "frequencyWeight": "빈도 가중치",
  "recencyWeight": "최근성 가중치",
  "zoneWeight": "구간 균형 가중치",
  "diversityWeight": "다양성 가중치",
  "hotNumbers": "Hot 번호 (자주 나온 번호)",
  "coldNumbers": "Cold 번호 (오래 안 나온 번호)",
  "costInfo": "{cost}개 코인 소모",
  "@costInfo": {
    "placeholders": {
      "cost": {"type": "int"}
    }
  }
}
```

---

## 8. 참고 자료

### 8.1 관련 문서
- `010.1_Algorithm_Redesign.md` - 알고리즘 2 (고급 빈도 분석)
- `010.2_Algorithm_Redesign_LSTM.md` - 알고리즘 3 (LSTM)
- `010.3_Algorithm_Redesign_Pattern.md` - 알고리즘 4 (패턴 분석)
- `029_Multilingual_System_Design_And_Implementation.md` - 다국어 지원

### 8.2 코드 파일
- `luckyai_645/backend/app/algorithms/algorithm_01_random.py`
- `luckyai_645/backend/app/algorithms/algorithm_02_advanced_frequency.py`
- `luckyai_645/backend/app/algorithms/algorithm_03_advanced_lstm.py`
- `luckyai_645/backend/app/algorithms/algorithm_04_advanced_pattern.py`
- `luckyai_645/backend/app/algorithms/algorithm_05_weighted.py`
- `luckyai_645/backend/app/algorithms/algorithm_06_frequency.py`
- `luckyai_645/backend/app/algorithms/algorithm_07_hot_cold.py`

---

## 9. 결론

이 설계서에 따라 구현하면:
- ✅ 사용자 친화적인 확장형 UI
- ✅ 알고리즘별 맞춤 파라미터 설정
- ✅ 직관적인 흐름: 선택 → 설정 → 생성
- ✅ 확장 가능한 구조 (새 알고리즘 추가 용이)
- ✅ 다국어 지원 준비

**다음 단계**: Phase 1부터 순차적으로 구현 시작!

---

**문서 종료**
