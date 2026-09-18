import pandas as pd
import csv
from datetime import datetime
from algorithm5 import (
    calculate_recent_probabilities,
    get_recently_3times_duplicated_numbers,
    generate_5_sets_from_reversed_recent_probs,
)
from ranking import judge_rank
import numpy as np
import os

def load_lotto_data(csv_path="lotto_data_.csv"):
    return pd.read_csv(csv_path)

def run_algorithm5_loop(window_size, alpha=0.2, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)
    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_result_algrm5_{now_str}.csv"

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "일치번호", "등수"])

        for i in range(window_size + 3, total_rounds):
            probs = calculate_recent_probabilities(csv_path, end_round=i, window_size=window_size, alpha=alpha)
            exclude = get_recently_3times_duplicated_numbers(df, i)
            try:
                pred_sets = generate_5_sets_from_reversed_recent_probs(probs, exclude)
            except ValueError as ve:
                print(f"[경고] {i}회차: {ve}")
                continue

            row = df.iloc[i]
            round_no = int(row["회차"])
            winning = [row[f"번호{j}"] for j in range(1, 7)]
            bonus = row["보너스"]

            for idx, pset in enumerate(pred_sets, start=1):
                rank, matched_numbers = judge_rank(pset, winning, bonus)
                writer.writerow([
                    round_no,
                    idx,
                    " ".join(map(str, pset)),
                    " ".join(map(str, winning)) + f" +{bonus}",
                    len(matched_numbers),
                    " ".join(map(str, sorted(matched_numbers))),
                    rank
                ])

            print(f"{round_no}회차 완료")

    print(f"저장 완료: {result_filename}")

if __name__ == "__main__":
    try:
        window_size = int(input("window_size를 입력하세요 (예: 50): ").strip())
        alpha = float(input("alpha 값을 입력하세요 (예: 0.2): ").strip())
        run_algorithm5_loop(window_size, alpha)
    except Exception as e:
        print("오류 발생:", e)
