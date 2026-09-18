from prepare_lotto_data import load_lotto_csv_for_lstm
from train_lotto_model import train_lstm_model
from algorithm2 import predict_next_lotto
import torch

# 데이터 로딩 및 학습
X, y, encoder = load_lotto_csv_for_lstm()
X = X.to(torch.device("cuda" if torch.cuda.is_available() else "cpu"))
y = y.to(X.device)

model = train_lstm_model(X, y, num_epochs=5)  # 빠른 테스트를 위해 5 epoch만

# 가장 최근 시퀀스로 예측
latest_seq = X[-1]
generated_set = predict_next_lotto(model, latest_seq)
print("알고리즘 2 생성 번호:", generated_set)
