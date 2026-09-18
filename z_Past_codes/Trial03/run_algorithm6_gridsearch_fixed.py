
import pandas as pd
import csv
from datetime import datetime
from algorithm6_fixed import prepare_sequences, train_lotto_model, predict_numbers
from ranking import judge_rank

def run_algorithm6_gridsearch(repeat_times, csv_path="lotto_data_.csv"):
    df = pd.read_csv(csv_path)
    total_rounds = len(df)

    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_gridsearch_algorithm6_{now_str}.csv"

    header = [
        "반복번호", "window_size", "1등", "2등", "3등", "4등", "5등", "2개맞음", "1개맞음", "0개맞음",
        "총시행수", "1등확률", "2등확률", "3등확률", "4등확률", "5등확률", "2개맞은 확률", "1개맞은 확률", "0개 맞은 확률"
    ]

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for repeat_index in range(1, repeat_times + 1):
            print(f"=== 반복 {repeat_index} 시작 ===")
            for window_size in range(1, total_rounds - 1):
                counts = {"1등":0, "2등":0, "3등":0, "4등":0, "5등":0, "2개맞음":0, "1개맞음":0, "0개맞음":0}
                for i in range(window_size, total_rounds - 1):
                    sequences = prepare_sequences(df.iloc[:i], window_size)
                    if len(sequences) == 0:
                        continue
                    try:
                        model = train_lotto_model(sequences)
                        predict_sets = [predict_numbers(model) for _ in range(5)]

                        row = df.iloc[i]
                        winning = [row[f"번호{j}"] for j in range(1, 7)]
                        bonus = row["보너스"]

                        for pset in predict_sets:
                            rank, matched = judge_rank(pset, winning, bonus)
                            match_count = len(matched)

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
                    except Exception as e:
                        print(f"[경고] 반복 {repeat_index} window_size={window_size} 처리 중 오류:", e)

                total_trials = sum(counts.values())
                writer.writerow([
                    repeat_index, window_size,
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
                    round(counts["0개맞음"] / total_trials, 15) if total_trials > 0 else 0
                ])
                print(f"반복 {repeat_index} - window_size {window_size} 완료")

    print(f"모든 결과 저장 완료: {result_filename}")

if __name__ == "__main__":
    repeat_times = int(input("window_size 전체 루프를 몇 번 반복할지 입력하세요 (예: 3): ").strip())
    run_algorithm6_gridsearch(repeat_times)
