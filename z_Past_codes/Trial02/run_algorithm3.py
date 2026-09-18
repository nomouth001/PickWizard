from prepare_lotto_data import load_lotto_csv_for_lstm
from train_lotto_model import train_lstm_model
from algorithm3 import predict_with_reversed_probs
import torch

# 데이터 및 모델 준비
X, y, encoder = load_lotto_csv_for_lstm()
X = X.to(torch.device("cuda" if torch.cuda.is_available() else "cpu"))
y = y.to(X.device)

model = train_lstm_model(X, y, num_epochs=5)

# 가장 최근 시퀀스로 예측
latest_seq = X[-1]
generated_set = predict_with_reversed_probs(model, latest_seq)
print("알고리즘 3 생성 번호:", generated_set)
