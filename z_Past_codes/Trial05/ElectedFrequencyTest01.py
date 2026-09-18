import pandas as pd
from collections import Counter
from itertools import combinations
import os

# 1. Read lotto_data.csv
df = pd.read_csv("lotto_data.csv")
number_cols = ['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']

# 결과 저장용 리스트
results = []

# 로그 디렉토리
log_dir = "lotto_logs"
os.makedirs(log_dir, exist_ok=True)
log_buffer = []
log_file_count = 1

# 누적 출현빈도 저장
cumulative_freqs = []
cumulative_counts = Counter()
for i in range(len(df)):
    if i >= 1:
        for num in df.loc[i - 1, number_cols]:
            cumulative_counts[num] += 1
    cumulative_freqs.append(cumulative_counts.copy())

# 출현순위 패턴 저장
rank_patterns_per_round = []

# 전체 회차 반복
for i in range(len(df)):
    round_no = df.loc[i, '회차']
    actual_numbers = df.loc[i, number_cols].tolist()
    bonus = df.loc[i, '보너스']

    freq_counter = cumulative_freqs[i]
    sorted_nums = sorted(freq_counter.items(), key=lambda x: (-x[1], x[0]))
    sorted_by_freq = [num for num, _ in sorted_nums]
    rank_dict = {num: rank + 1 for rank, num in enumerate(sorted_by_freq)}
    current_ranks = [rank_dict.get(num, 46) for num in actual_numbers]
    rank_patterns_per_round.append(tuple(sorted(current_ranks)))

    # 출현순위 패턴 집계 (i >= 10일 때만)
    pattern_counter = Counter()
    if i >= 10:
        for prev_pattern in rank_patterns_per_round[:i - 1]:
            for comb in combinations(prev_pattern, 3):
                pattern_counter[tuple(sorted(comb))] += 1
        top_patterns = [pat for pat, _ in pattern_counter.most_common(10)]
    else:
        top_patterns = []

    # 예측 번호 생성
    predictions = []
    for pattern in top_patterns:
        match_nums = [num for num in sorted_by_freq if rank_dict.get(num, 46) in pattern]
        match_nums = list(dict.fromkeys(match_nums))[:3]
        pred = match_nums.copy()
        for num in sorted_by_freq:
            if num not in pred:
                pred.append(num)
            if len(pred) == 6:
                break
        predictions.append(pred)

    # 평가 함수
    def evaluate(predicted, actual, bonus):
        match = len(set(predicted) & set(actual))
        if match == 6:
            return "1등"
        elif match == 5 and bonus in predicted:
            return "2등"
        elif match == 5:
            return "3등"
        elif match == 4:
            return "4등"
        elif match == 3:
            return "5등"
        elif match == 2:
            return "2개 맞음"
        elif match == 1:
            return "1개 맞음"
        else:
            return "0개 맞음"

    for pred in predictions:
        result = evaluate(pred, actual_numbers, bonus)
        results.append({
            "회차": round_no,
            "예측번호": pred,
            "당첨번호": actual_numbers,
            "보너스": bonus,
            "결과": result
        })

    # 로그 기록
    log_entry = f"[{round_no}회차]\n"
    log_entry += f"당첨번호: {actual_numbers}, 보너스: {bonus}\n"
    log_entry += f"출현빈도 정렬: {sorted_by_freq}\n"
    log_entry += f"사용한 3개 순위 패턴 10개: {top_patterns}\n"
    log_entry += f"예측 개수: {len(predictions)}\n"
    log_buffer.append(log_entry)

    # 100회차마다 로그 저장
    if (i + 1) % 100 == 0:
        with open(f"{log_dir}/log_{log_file_count:03d}.txt", "w", encoding="utf-8") as f:
            f.write("\n\n".join(log_buffer))
        log_buffer = []
        log_file_count += 1

# 마지막 로그 저장
if log_buffer:
    with open(f"{log_dir}/log_{log_file_count:03d}.txt", "w", encoding="utf-8") as f:
        f.write("\n\n".join(log_buffer))

# 결과 저장
results_df = pd.DataFrame(results)
results_df.to_csv("lotto_prediction_results.csv", index=False)
print("예측 완료. 결과 파일: lotto_prediction_results.csv")
