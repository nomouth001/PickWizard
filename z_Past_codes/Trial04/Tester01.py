import pandas as pd
import numpy as np
import random
from collections import Counter

df = pd.read_csv("lotto_data.csv")

def number_to_symbol(n):
    if 1 <= n <= 9: return 'A'
    elif 10 <= n <= 18: return 'B'
    elif 19 <= n <= 27: return 'C'
    elif 28 <= n <= 36: return 'D'
    elif 37 <= n <= 45: return 'E'

symbol_ranges = {
    'A': list(range(1, 10)),
    'B': list(range(10, 19)),
    'C': list(range(19, 28)),
    'D': list(range(28, 37)),
    'E': list(range(37, 46)),
}

results = []

# 디버깅 로그 초기화
log = open("lotto_debug_log.txt", "w", encoding="utf-8")

for current_round in range(20, len(df)):
    past_df = df.iloc[:current_round]
    target_row = df.iloc[current_round]

    numbers_used = past_df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()
    number_counts = Counter(numbers_used)

    probability_dict = {}
    for symbol, numbers in symbol_ranges.items():
        total = sum(number_counts.get(n, 0) for n in numbers)
        for n in numbers:
            probability_dict[n] = number_counts.get(n, 0) / total if total > 0 else 1 / len(numbers)

    past_patterns = []
    for _, row in past_df.iterrows():
        symbols = [number_to_symbol(row[f'번호{i}']) for i in range(1, 7)]
        sorted_pattern = ''.join(sorted(symbols))
        past_patterns.append(sorted_pattern)

    top_patterns = [p for p, _ in Counter(past_patterns).most_common(10)]

    win_nums = set(target_row[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']])
    bonus_num = target_row['보너스']

    score_counter = {
        '1등': 0, '2등': 0, '3등': 0, '4등': 0, '5등': 0,
        '2개맞춤': 0, '1개맞춤': 0, '0개맞춤': 0
    }

    for pattern in top_patterns:
        log.write(f"\n🔍 회차 {target_row['회차']} - 패턴: {pattern}\n")
        selected_numbers = set()

        for symbol in pattern:
            pool = [n for n in symbol_ranges[symbol] if n not in selected_numbers]
            if not pool:
                log.write(f"  ⚠️ 기호 {symbol}에 대해 더 이상 선택 가능한 숫자가 없음. 건너뜀.\n")
                continue

            weights = [probability_dict[n] for n in pool]
            probs = np.array(weights) / sum(weights)
            pick = np.random.choice(pool, size=1, replace=False, p=probs)
            selected_numbers.update(pick)

            log.write(f"  ▶ 기호 {symbol} → 선택 풀: {pool}\n")
            log.write(f"    확률: {[round(probability_dict[n], 4) for n in pool]}\n")
            log.write(f"    선택된 숫자: {pick[0]} (확률: {round(probability_dict[pick[0]], 4)})\n")

        # 최종 선택 번호 기록
        sorted_picks = sorted(selected_numbers)
        matched = len(selected_numbers & win_nums)
        bonus_matched = bonus_num in selected_numbers

        # 등수 판별
        if matched == 6:
            rank = '1등'
            score_counter['1등'] += 1
        elif matched == 5 and bonus_matched:
            rank = '2등'
            score_counter['2등'] += 1
        elif matched == 5:
            rank = '3등'
            score_counter['3등'] += 1
        elif matched == 4:
            rank = '4등'
            score_counter['4등'] += 1
        elif matched == 3:
            rank = '5등'
            score_counter['5등'] += 1
        elif matched == 2:
            rank = '2개맞춤'
            score_counter['2개맞춤'] += 1
        elif matched == 1:
            rank = '1개맞춤'
            score_counter['1개맞춤'] += 1
        else:
            rank = '0개맞춤'
            score_counter['0개맞춤'] += 1

        log.write(f"🎯 최종 선택 번호: {sorted_picks}\n")
        log.write(f"✅ 당첨번호: {sorted(win_nums)}, 보너스: {bonus_num}\n")
        log.write(f"🏆 결과: {matched}개 일치, 보너스 {'O' if bonus_matched else 'X'} → {rank}\n")

    # 🔽 이 줄을 반드시 여기에 추가해야 함
    score_counter['회차'] = target_row['회차']
    results.append(score_counter)
    
log.close()

results_df = pd.DataFrame(results)
results_df.to_csv("lotto_pattern_test.csv", index=False)
