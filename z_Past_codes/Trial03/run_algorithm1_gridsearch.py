import pandas as pd
import csv
from datetime import datetime
from algorithm1 import generate_random_lotto_sets
from ranking import judge_rank

def load_lotto_data(csv_path="lotto_data_.csv"):
    return pd.read_csv(csv_path)

def run_algorithm1_gridsearch(repeat_times, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)

    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_gridsearch_algorithm1_{now_str}.csv"

    header = [
        "반복번호", "회차", "1등", "2등", "3등", "4등", "5등",
        "2개맞음", "1개맞음", "0개맞음", "총시행수",
        "1등확률", "2등확률", "3등확률", "4등확률", "5등확률",
        "2개맞은 확률", "1개맞은 확률", "0개 맞은 확률"
    ]

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for repeat_index in range(1, repeat_times + 1):
            print(f"=== 반복 {repeat_index} 시작 ===")
            for i in range(0, total_rounds - 1):  # 마지막 회차는 제외 (n_sets=0 되므로)
                row = df.iloc[i]
                winning = [row[f"번호{j}"] for j in range(1, 7)]
                bonus = row["보너스"]

                n_sets = (total_rounds - i - 1) * 5  # 1회차에 가장 많고 점점 줄어듦
                predict_sets = generate_random_lotto_sets(n_sets)

                counts = {"1등":0, "2등":0, "3등":0, "4등":0, "5등":0,
                          "2개맞음":0, "1개맞음":0, "0개맞음":0}

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

                total_trials = len(predict_sets)
                def safe_ratio(n): return round(n / total_trials, 15) if total_trials > 0 else 0

                writer.writerow([
                    repeat_index, row["회차"],
                    counts["1등"], counts["2등"], counts["3등"], counts["4등"], counts["5등"],
                    counts["2개맞음"], counts["1개맞음"], counts["0개맞음"],
                    total_trials,
                    safe_ratio(counts["1등"]), safe_ratio(counts["2등"]), safe_ratio(counts["3등"]),
                    safe_ratio(counts["4등"]), safe_ratio(counts["5등"]),
                    safe_ratio(counts["2개맞음"]), safe_ratio(counts["1개맞음"]), safe_ratio(counts["0개맞음"])
                ])
            print(f"반복 {repeat_index} 완료")

    print(f"\n모든 결과 저장 완료: {result_filename}")

if __name__ == "__main__":
    repeat_times = int(input("랜덤 추첨을 몇 번 반복할지 입력하세요 (예: 3): ").strip())
    run_algorithm1_gridsearch(repeat_times)
