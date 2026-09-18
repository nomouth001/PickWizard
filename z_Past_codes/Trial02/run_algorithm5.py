from prepare_lotto_data import load_lotto_csv_for_lstm
from train_lotto_model import train_lstm_model
from algorithm5 import predict_with_reverse_and_update
import torch

X, y, encoder = load_lotto_csv_for_lstm()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
X, y = X.to(device), y.to(device)

# 초기 모델
window = 100
model = train_lstm_model(X[:window], y[:window], num_epochs=3)

results = []
for i in range(window, len(X)):
    result, model = predict_with_reverse_and_update(
        model, X[i], X[i-1:i], y[i-1:i]
    )
    results.append(result)

print("알고리즘 5 마지막 예측 번호:", results[-1])
