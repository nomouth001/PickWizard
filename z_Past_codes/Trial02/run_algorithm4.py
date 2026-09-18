from prepare_lotto_data import load_lotto_csv_for_lstm
from train_lotto_model import train_lstm_model
from algorithm2 import predict_next_lotto
from algorithm4 import update_lstm_model
import torch

# 전체 데이터 준비
X, y, encoder = load_lotto_csv_for_lstm()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
X, y = X.to(device), y.to(device)

# 초기 모델 학습 (x~x+99 회차)
window = 100
model = train_lstm_model(X[:window], y[:window], num_epochs=3)

# 이후 데이터를 순차적으로 추가 학습 및 예측
results = []
for i in range(window, len(X)):
    model = update_lstm_model(model, X[i-1:i], y[i-1:i])  # 누적 학습
    generated = predict_next_lotto(model, X[i])
    results.append(generated)

print("알고리즘 4 마지막 예측 번호:", results[-1])
