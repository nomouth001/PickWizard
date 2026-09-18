import requests
from bs4 import BeautifulSoup
import csv
import time
import os
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim

CSV_FILE = "lotto_data.csv"
WINDOW_SIZE = 20
VAL_SIZE = 18

# ✅ 보너스 번호 포함 데이터 로딩
def load_lotto_data(file_path):
    df = pd.read_csv(file_path)
    all_numbers = []
    for _, row in df.iterrows():
        nums = list(map(int, row[1:8]))  # 번호1~6 + 보너스까지 포함
        vec = np.zeros(45)
        for n in nums:
            vec[n - 1] = 1
        all_numbers.append(vec)
    return all_numbers

# ✅ 데이터셋 생성 (입력 시퀀스 → 다음 회차 예측)
def create_fixed_window_dataset(numbers, window_size=WINDOW_SIZE):
    X, y = [], []
    for i in range(window_size, len(numbers)):
        X.append(numbers[i - window_size:i])
        y.append(numbers[i])
    return np.array(X), np.array(y)

# ✅ 학습/검증 분할
def split_train_val(numbers, val_size=VAL_SIZE, window_size=WINDOW_SIZE):
    train = numbers[:-(val_size + window_size)]
    val = numbers[-(val_size + window_size):]
    return train, val

# ✅ LSTM 모델
class LottoLSTM(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, input_size)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]
        out = self.fc(out)
        return self.sigmoid(out)

# ✅ 학습 함수
def train_model(model, criterion, optimizer, X_train, y_train, X_val=None, y_val=None, num_epochs=100):
    for epoch in range(num_epochs):
        model.train()
        outputs = model(X_train)
        loss = criterion(outputs, y_train)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        log = f"Epoch [{epoch+1}/{num_epochs}], Loss: {loss.item():.4f}"

        if X_val is not None and y_val is not None:
            model.eval()
            with torch.no_grad():
                val_outputs = model(X_val)
                val_loss = criterion(val_outputs, y_val)
            log += f", Val Loss: {val_loss.item():.4f}"

        print(log)

# ✅ 등수 판별 함수
def get_lotto_rank(predicted, target):
    predict_set = set(predicted)
    true_nums = set(np.where(target[:45] == 1)[0] + 1)
    bonus = np.argmax(target[45:]) + 1 if target[45:].sum() > 0 else None
    matched = len(predict_set & true_nums)
    bonus_matched = (bonus in predict_set)

    if matched == 6:
        return "1등"
    elif matched == 5 and bonus_matched:
        return "2등"
    elif matched == 5:
        return "3등"
    elif matched == 4:
        return "4등"
    elif matched == 3:
        return "5등"
    else:
        return "꽝"

# ✅ 전체 실행
if __name__ == "__main__":
    numbers = load_lotto_data(CSV_FILE)

    # 실험용: 학습 + 검증
    train_numbers, val_numbers = split_train_val(numbers)
    X_train, y_train = create_fixed_window_dataset(train_numbers)
    X_val, y_val = create_fixed_window_dataset(val_numbers)

    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.float32)
    X_val = torch.tensor(X_val, dtype=torch.float32)
    y_val = torch.tensor(y_val, dtype=torch.float32)

    model = LottoLSTM(input_size=45, hidden_size=128, num_layers=1)
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    print("\n[실험 학습 단계]")
    train_model(model, criterion, optimizer, X_train, y_train, X_val, y_val, num_epochs=100)

    # 검증 결과 출력
    print("\n[검증 결과 평가]")
    with torch.no_grad():
        for i in range(len(X_val)):
            output = model(X_val[i].unsqueeze(0))
            probs = output.squeeze().numpy()
            predicted = np.argsort(probs)[-6:] + 1
            predicted = np.sort(predicted)
            actual = y_val[i].numpy()
            rank = get_lotto_rank(predicted, actual)
            print(f"예측: {predicted}, 등수: {rank}")

    # 최종 학습: 전체 데이터 사용
    print("\n[최종 학습 단계 - 전체 데이터]")
    X_all, y_all = create_fixed_window_dataset(numbers)
    X_all = torch.tensor(X_all, dtype=torch.float32)
    y_all = torch.tensor(y_all, dtype=torch.float32)
    model = LottoLSTM(input_size=45, hidden_size=128, num_layers=1)
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    train_model(model, criterion, optimizer, X_all, y_all, num_epochs=100)

    # 다음 회차 예측
    # 경고 없애기
    last_seq_array = np.array(numbers[-WINDOW_SIZE:])  # 리스트 → numpy 배열
    last_seq = torch.tensor(last_seq_array, dtype=torch.float32).unsqueeze(0)

    # 예측
    print("\n[예측된 다음 회차 번호 5세트]")
    with torch.no_grad():
        for i in range(5):
            output = model(last_seq)
            probs = output.squeeze().numpy()
            probs = probs / probs.sum()  # 확률 정규화

            # 확률 기반 무작위 추출
            sampled = np.random.choice(np.arange(1, 46), size=6, replace=False, p=probs)
            sampled.sort()
            print(f"세트 {i+1}: {sampled}")