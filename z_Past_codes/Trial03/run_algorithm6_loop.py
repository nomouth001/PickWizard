import pandas as pd
import csv
from datetime import datetime
from algorithm6 import prepare_sequences, train_lotto_model, predict_lotto, generate_5_sets_from_probs
from ranking import judge_rank
import numpy as np
import os

def load_lotto_data(csv_path="lotto_data_.csv"):
    return pd.read_csv(csv_path)

def compare_sets_to_winning_numbers(predict_sets, winning_numbers, bonus_number, round_no):
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
            "등수": rank
        }
        results.append(result)
    return results

def run_algorithm6(window_size, csv_path="lotto_data_.csv"):
    df = load_lotto_data(csv_path)
    total_rounds = len(df)
    now_str = datetime.now().strftime("%y%m%d%H%M%S")
    result_filename = f"lotto_result_algrm6_{now_str}.csv"

    with open(result_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "일치번호", "등수"])

        for i in range(window_size, total_rounds):
            train_df = df.iloc[i-window_size:i]
            sequences = prepare_sequences(train_df, window_size=window_size-1)
            model = train_lotto_model(sequences)

            # [수정된 부분]: 학습한 시퀀스의 마지막을 사용
            last_sequence = sequences[-1]

            probs = predict_lotto(model, last_sequence)
            predict_sets = generate_5_sets_from_probs(probs)

            row = df.iloc[i]
            round_no = int(row["회차"])
            winning = [row[f"번호{j}"] for j in range(1, 7)]
            bonus = row["보너스"]

            results = compare_sets_to_winning_numbers(predict_sets, winning, bonus, round_no)

            for r in results:
                writer.writerow([
                    r["회차"], r["세트번호"], r["예측번호"], r["당첨번호"],
                    r["일치개수"], r["일치번호"], r["등수"]
                ])

            print(f"{round_no}회차 완료")

    print(f"\n저장 완료: {result_filename}")

if __name__ == "__main__":
    try:
        window_size = int(input("window_size를 입력하세요 (예: 50): ").strip())
        run_algorithm6(window_size)
    except Exception as e:
        print("오류 발생:", e)
