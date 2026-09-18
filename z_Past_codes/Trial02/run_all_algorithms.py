from datetime import datetime
import pandas as pd

# 알고리즘 함수 import
from algorithm1 import generate_random_lotto_sets
from algorithm6 import generate_numbers_algorithm6
from algorithm7 import generate_numbers_algorithm7
from algorithm8 import generate_numbers_algorithm8
from algorithm9 import generate_numbers_algorithm9

# 평가/저장/시각화 모듈
from evaluator import evaluate_predictions
from result_saver import save_results_to_csv
from visualizer import visualize_rank_distribution

# 최신 회차의 당첨 번호 불러오기
def get_latest_winning_numbers(csv_path="lotto_data_.csv"):
    df = pd.read_csv(csv_path)
    latest = df.iloc[-1]
    round_no = int(latest["회차"])
    winning = [latest[f"번호{i}"] for i in range(1, 7)]
    bonus = latest["보너스"]
    return round_no, winning, bonus

def run():
    csv_path = "lotto_data_.csv"
    round_no, winning, bonus = get_latest_winning_numbers(csv_path)
    all_results = []

    # 알고리즘 1
    a1 = generate_random_lotto_sets()
    r1 = evaluate_predictions(a1, winning, bonus, algorithm_id=1, round_no=round_no)
    all_results.extend(r1)
    visualize_rank_distribution(r1, "알고리즘1")

    # 알고리즘 6
    a6 = [generate_numbers_algorithm6(csv_path) for _ in range(5)]
    r6 = evaluate_predictions(a6, winning, bonus, algorithm_id=6, round_no=round_no)
    all_results.extend(r6)
    visualize_rank_distribution(r6, "알고리즘6")

    # 알고리즘 7
    a7 = [generate_numbers_algorithm7(csv_path) for _ in range(5)]
    r7 = evaluate_predictions(a7, winning, bonus, algorithm_id=7, round_no=round_no)
    all_results.extend(r7)
    visualize_rank_distribution(r7, "알고리즘7")

    # 알고리즘 8
    a8 = [generate_numbers_algorithm8(csv_path, x=50) for _ in range(5)]
    r8 = evaluate_predictions(a8, winning, bonus, algorithm_id=8, round_no=round_no)
    all_results.extend(r8)
    visualize_rank_distribution(r8, "알고리즘8")

    # 알고리즘 9
    a9 = [generate_numbers_algorithm9(csv_path, x=50) for _ in range(5)]
    r9 = evaluate_predictions(a9, winning, bonus, algorithm_id=9, round_no=round_no)
    all_results.extend(r9)
    visualize_rank_distribution(r9, "알고리즘9")

    # 결과 저장
    save_results_to_csv(all_results)

if __name__ == "__main__":
    run()
