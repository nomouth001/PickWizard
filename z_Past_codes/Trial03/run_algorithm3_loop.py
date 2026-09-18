import pandas as pd
import csv
from datetime import datetime
from algorithm3 import calculate_probabilities, generate_5_sets_from_reversed_probs
from ranking import judge_rank
import numpy as np
import os

def load_lotto_data(csv_path="lotto_data_.csv"):
    return pd.read_csv(csv_path)

def get_sorted_numbers_least_common(df, up_to_round):
    numbers = df[df['회차'] <= up_to_round][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()
    counts = np.zeros(45)
    for num in numbers:
        counts[int(num) - 1] += 1
    sorted_numbers = np.argsort(counts) + 1  # 낮은 빈도순
    return counts, sorted_numbers

def get_win_number_ranks(winning_numbers, counts_sorted):
    ranks = []
    counts_sorted_list = counts_sorted.tolist()
    for num in winning_numbers:
        rank = counts_sorted_list.index(num) + 1
        ranks.append(rank)
    return " ".join(map(str, ranks))

def compare_sets_to_winning_numbers(predict_sets, winning_numbers, bonus_number, algorithm_id, round_no, least_common_numbers, ranks_info):
    results = []
    for idx, pset in enumerate(predict_sets, start=1):
        rank, matched_numbers = judge_rank(pset, winning_numbers, bonus_number)
        match_count = len(matched_numbers)
        matched_str = " ".join(map(str, sorted(matched_numbers)))
        result = {
            "회차": round_no,
            "세트번호": idx,
            "예측번호": " ".join(map(str, pset)),
            "당첨번호": " ".join(map(str, winning_numbers)) + f" +{bonus_number}",
            "일치개수": match_count,
            "일치번호": matched_str,
            "등수": rank,
            "빈도역순정렬": least_common_numbers,
            "당첨번호순위": ranks_info
        }
        results.append(result)
    return results

def run_algorithm3_windowed(window_size, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)
    start_round = window_size
    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_result_algrm3_{now_str}.csv"

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "일치번호", "등수", "빈도역순정렬", "당첨번호순위"])

        for i in range(start_round, total_rounds):
            probs = calculate_probabilities(csv_path=csv_path, start_round=1, end_round=i)
            predict_sets = generate_5_sets_from_reversed_probs(probs)

            row = df.iloc[i]
            round_no = int(row["회차"])
            winning = [row[f"번호{j}"] for j in range(1, 7)]
            bonus = row["보너스"]

            counts, sorted_numbers = get_sorted_numbers_least_common(df, up_to_round=i)
            least_common_numbers = " ".join(map(str, sorted_numbers))
            ranks_info = get_win_number_ranks(winning, sorted_numbers)

            results = compare_sets_to_winning_numbers(predict_sets, winning, bonus, algorithm_id=3, round_no=round_no, least_common_numbers=least_common_numbers, ranks_info=ranks_info)

            for r in results:
                writer.writerow([
                    r["회차"], r["세트번호"], r["예측번호"], r["당첨번호"],
                    r["일치개수"], r["일치번호"], r["등수"], r["빈도역순정렬"], r["당첨번호순위"]
                ])

            print(f"{round_no}회차 완료")

    print(f"\n저장 완료: {result_filename}")

if __name__ == "__main__":
    try:
        window_size = int(input("window_size를 입력하세요 (예: 100): ").strip())
        run_algorithm3_windowed(window_size)
    except Exception as e:
        print("오류 발생:", e)
