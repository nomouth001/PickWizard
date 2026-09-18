import pandas as pd
from datetime import datetime
from algorithm4 import (
    calculate_recent_probabilities_with_alpha_and_exclusion,
    generate_5_sets_from_recent_probabilities
)
from ranking import judge_rank
import csv

def run_loop(window_size=5, alpha=0.2, csv_path="lotto_data_.csv"):
    df = pd.read_csv(csv_path)
    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_result_algorithm4_loop_{now_str}.csv"

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "등수", "일치번호"])

        for i in range(window_size, len(df)):
            probs = calculate_recent_probabilities_with_alpha_and_exclusion(
                csv_path=csv_path, end_round=i, window_size=window_size, alpha=alpha
            )
            exclude = set()
            pred_sets = generate_5_sets_from_recent_probabilities(probs, exclude)
            win_row = df.iloc[i]
            win_nums = [win_row[f"번호{j}"] for j in range(1, 7)]
            bonus = win_row["보너스"]

            for idx, pset in enumerate(pred_sets):
                rank, matched = judge_rank(pset, win_nums, bonus)
                writer.writerow([
                    win_row["회차"], idx + 1,
                    " ".join(map(str, pset)),
                    " ".join(map(str, win_nums)) + f" +{bonus}",
                    len(matched), rank,
                    str(matched)
                ])

    print(f"결과 저장 완료: {result_filename}")

if __name__ == "__main__":
    window = int(input("window_size를 입력하세요 (예: 50): ").strip())
    alpha = float(input("alpha 값을 입력하세요 (예: 0.2): ").strip())
    run_loop(window_size=window, alpha=alpha)
