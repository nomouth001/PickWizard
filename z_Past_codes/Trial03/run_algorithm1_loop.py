import pandas as pd
from datetime import datetime
import csv
from algorithm1 import generate_random_lotto_sets
from ranking import judge_rank
import os

def load_lotto_data(csv_path="lotto_data_.csv"):
    df = pd.read_csv(csv_path)
    return df

def compare_sets_to_winning_numbers(predict_sets, winning_numbers, bonus_number, algorithm_id, round_no):
    results = []
    for idx, pset in enumerate(predict_sets, start=1):
        rank, matched_numbers = judge_rank(pset, winning_numbers, bonus_number)
        match_count = len(matched_numbers)
        matched_str = " ".join(map(str, sorted(matched_numbers)))  # 일치 번호를 깔끔하게 문자열로 변환

        result = {
            "회차": round_no,
            "세트번호": idx,
            "예측번호": " ".join(map(str, pset)),
            "당첨번호": " ".join(map(str, winning_numbers)) + f" +{bonus_number}",
            "일치개수": match_count,
            "일치번호": matched_str,
            "등수": rank
        }
        results.append(result)
    return results

def run_algorithm1_windowed(window_size, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)
    start_round = window_size
    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_result_algrm1_{now_str}.csv"

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "일치번호", "등수"])

        for i in range(start_round, total_rounds):
            row = df.iloc[i]
            round_no = int(row["회차"])
            winning = [row[f"번호{j}"] for j in range(1, 7)]
            bonus = row["보너스"]

            predict_sets = generate_random_lotto_sets()
            results = compare_sets_to_winning_numbers(predict_sets, winning, bonus, algorithm_id=1, round_no=round_no)

            for r in results:
                writer.writerow([r["회차"], r["세트번호"], r["예측번호"], r["당첨번호"], r["일치개수"], r["일치번호"], r["등수"]])

            print(f"{round_no}회차 완료")

    print(f"\n저장 완료: {result_filename}")

if __name__ == "__main__":
    try:
        window_size = int(input("window_size를 입력하세요 (예: 100): ").strip())
        run_algorithm1_windowed(window_size)
    except Exception as e:
        print("오류 발생:", e)
