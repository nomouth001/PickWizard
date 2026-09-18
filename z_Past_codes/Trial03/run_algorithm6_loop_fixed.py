
import pandas as pd
from algorithm6_fixed import prepare_sequences, train_lotto_model, predict_numbers
from ranking import judge_rank
from datetime import datetime
import csv

def run():
    csv_path = "lotto_data_.csv"
    df = pd.read_csv(csv_path)
    window_size = int(input("window_size를 입력하세요 (예: 50): ").strip())
    results = []

    for i in range(window_size, len(df) - 1):
        sequences = prepare_sequences(df.iloc[:i], window_size)
        if len(sequences) == 0:
            continue
        try:
            model = train_lotto_model(sequences)
            predict_sets = [predict_numbers(model) for _ in range(5)]

            actual = df.iloc[i][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].tolist()
            bonus = df.iloc[i]['보너스']
            round_no = int(df.iloc[i]['회차'])

            for idx, pset in enumerate(predict_sets):
                rank, matched = judge_rank(pset, actual, bonus)
                results.append([
                    round_no, idx + 1, " ".join(map(str, pset)), " ".join(map(str, actual)),
                    len(matched), rank
                ])
        except Exception as e:
            print(f"오류 발생 (회차 {i}):", e)

    now = datetime.now().strftime("%y%m%d%H%M%S")
    filename = f"lotto_result_algorithm6_{now}.csv"
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["회차", "세트번호", "예측번호", "당첨번호", "일치개수", "등수"])
        writer.writerows(results)

    print(f"결과 저장 완료: {filename}")

if __name__ == "__main__":
    run()
