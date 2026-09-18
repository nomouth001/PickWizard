import pandas as pd
import csv
from datetime import datetime
from algorithm3 import calculate_probabilities, generate_5_sets_from_reversed_probs
from ranking import judge_rank
import numpy as np
import os

def load_lotto_data(csv_path="lotto_data_.csv"):
    return pd.read_csv(csv_path)

def run_algorithm3_gridsearch(repeat_times, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)

    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_gridsearch_algorithm3_{now_str}.csv"

    header = [
        "반복번호", "window_size", "1등", "2등", "3등", "4등", "5등", "2개맞음", "1개맞음", "0개맞음",
        "총시행수", "1등확률", "2등확률", "3등확률", "4등확률", "5등확률", "2개맞은 확률", "1개맞은 확률", "0개 맞은 확률"
    ]

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for repeat_index in range(1, repeat_times + 1):
            print(f"=== 반복 {repeat_index} 시작 ===")
            for window_size in range(1, total_rounds):
                counts = {"1등":0, "2등":0, "3등":0, "4등":0, "5등":0, "2개맞음":0, "1개맞음":0, "0개맞음":0}

                for i in range(window_size, total_rounds):
                    probs = calculate_probabilities(csv_path=csv_path, start_round=1, end_round=i)
                    predict_sets = generate_5_sets_from_reversed_probs(probs)

                    row = df.iloc[i]
                    winning = [row[f"번호{j}"] for j in range(1, 7)]
                    bonus = row["보너스"]

                    for pset in predict_sets:
                        rank, matched_numbers = judge_rank(pset, winning, bonus)
                        match_count = len(matched_numbers)

                        if rank == 1:
                            counts["1등"] += 1
                        elif rank == 2:
                            counts["2등"] += 1
                        elif rank == 3:
                            counts["3등"] += 1
                        elif rank == 4:
                            counts["4등"] += 1
                        elif rank == 5:
                            counts["5등"] += 1
                        else:
                            if match_count == 2:
                                counts["2개맞음"] += 1
                            elif match_count == 1:
                                counts["1개맞음"] += 1
                            else:
                                counts["0개맞음"] += 1

                total_trials = sum(counts.values())
                writer.writerow([
                    repeat_index,
                    window_size,
                    counts["1등"], counts["2등"], counts["3등"], counts["4등"], counts["5등"],
                    counts["2개맞음"], counts["1개맞음"], counts["0개맞음"],
                    total_trials,
                    round(counts["1등"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["2등"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["3등"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["4등"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["5등"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["2개맞음"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["1개맞음"] / total_trials, 15) if total_trials > 0 else 0,
                    round(counts["0개맞음"] / total_trials, 15) if total_trials > 0 else 0,
                ])
                print(f"반복 {repeat_index} - window_size {window_size} 완료")

    print(f"\n모든 결과 저장 완료: {result_filename}")

if __name__ == "__main__":
    repeat_times = int(input("window_size 전체 루프를 몇 번 반복할지 입력하세요 (예: 3): ").strip())
    run_algorithm3_gridsearch(repeat_times)
