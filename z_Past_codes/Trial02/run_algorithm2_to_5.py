from prepare_lotto_data import load_lotto_csv_for_lstm
from train_lotto_model import train_lstm_model
from algorithm2 import predict_next_lotto
from algorithm3 import predict_with_reversed_probs
from algorithm4 import update_lstm_model
from algorithm5 import predict_with_reverse_and_update

from evaluator import evaluate_predictions
from result_saver import save_results_to_csv
from visualizer import visualize_rank_distribution
from ranking import judge_rank

import torch
import pandas as pd

def get_latest_winning_numbers(csv_path="lotto_data_.csv"):
    df = pd.read_csv(csv_path)
    latest = df.iloc[-1]
    round_no = int(latest["회차"])
    winning = [latest[f"번호{i}"] for i in range(1, 7)]
    bonus = latest["보너스"]
    return round_no, winning, bonus

def run():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    X, y, encoder = load_lotto_csv_for_lstm()
    X, y = X.to(device), y.to(device)
    round_no, winning, bonus = get_latest_winning_numbers()

    all_results = []
    window = 100

    # 알고리즘 2
    model2 = train_lstm_model(X[:window], y[:window], num_epochs=3)
    result2 = [predict_next_lotto(model2, X[-1]) for _ in range(5)]
    r2 = evaluate_predictions(result2, winning, bonus, algorithm_id=2, round_no=round_no)
    all_results.extend(r2)
    visualize_rank_distribution(r2, "알고리즘2")

    # 알고리즘 3
    model3 = train_lstm_model(X[:window], y[:window], num_epochs=3)
    result3 = [predict_with_reversed_probs(model3, X[-1]) for _ in range(5)]
    r3 = evaluate_predictions(result3, winning, bonus, algorithm_id=3, round_no=round_no)
    all_results.extend(r3)
    visualize_rank_distribution(r3, "알고리즘3")

    # 알고리즘 4
    model4 = train_lstm_model(X[:window], y[:window], num_epochs=3)
    for i in range(window, len(X)):
        model4 = update_lstm_model(model4, X[i-1:i], y[i-1:i])
    result4 = [predict_next_lotto(model4, X[-1]) for _ in range(5)]
    r4 = evaluate_predictions(result4, winning, bonus, algorithm_id=4, round_no=round_no)
    all_results.extend(r4)
    visualize_rank_distribution(r4, "알고리즘4")

   # 알고리즘 5
    model5 = train_lstm_model(X[:window], y[:window], num_epochs=3)
    for i in range(window, len(X)):
        _, model5 = predict_with_reverse_and_update(model5, X[i], X[i-1:i], y[i-1:i])
    result5 = [predict_with_reversed_probs(model5, X[-1]) for _ in range(5)]
    r5 = evaluate_predictions(result5, winning, bonus, algorithm_id=5, round_no=round_no)
    all_results.extend(r5)
    visualize_rank_distribution(r5, "알고리즘5")

    save_results_to_csv(all_results)

if __name__ == "__main__":
    run()