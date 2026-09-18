import requests
from bs4 import BeautifulSoup
import csv
import time
import os

CSV_FILE = "lotto_data.csv"

def get_lotto_numbers(draw_no):
    url = f"https://www.dhlottery.co.kr/gameResult.do?method=byWin&drwNo={draw_no}"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")

    numbers = soup.select("div.num.win span.ball_645")
    bonus_elem = soup.select_one("div.num.bonus span.ball_645")

    # 번호가 부족하거나 보너스 번호가 없으면 발표 안 된 회차로 간주
    if len(numbers) < 6 or bonus_elem is None or bonus_elem.text.strip() == "":
        return None

    try:
        result = [int(num.text) for num in numbers]
        bonus = int(bonus_elem.text)
        return [draw_no] + result + [bonus]
    except ValueError:
        return None  # 혹시라도 이상한 값이 있으면 안전하게 처리

def read_last_draw_no(filename=CSV_FILE):
    if not os.path.exists(filename):
        return 0
    with open(filename, "r", encoding="utf-8") as f:
        lines = f.readlines()
        if len(lines) <= 1:
            return 0
        last_line = lines[-1]
        last_draw_no = int(last_line.split(",")[0])
        return last_draw_no

def collect_new_data(start_no, delay=0.5):
    new_data = []
    while True:
        data = get_lotto_numbers(start_no)
        if data:
            new_data.append(data)
            print(f"{start_no}회차 수집 완료: {data}")
            start_no += 1
            time.sleep(delay)
        else:
            print(f"{start_no}회차는 아직 발표되지 않음. 종료.")
            break
    return new_data

def append_to_csv(data, filename=CSV_FILE):
    file_exists = os.path.exists(filename)
    with open(filename, "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        if not file_exists:
            writer.writerow(["회차", "번호1", "번호2", "번호3", "번호4", "번호5", "번호6", "보너스"])
        writer.writerows(data)
    print(f"{filename} 갱신 완료")

# 실행
if __name__ == "__main__":
    last_draw = read_last_draw_no()
    print(f"현재 저장된 마지막 회차: {last_draw}")
    new_data = collect_new_data(last_draw + 1)
    if new_data:
        append_to_csv(new_data)
    else:
        print("추가된 데이터 없음.")

import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim

# 설정값
WINDOW_SIZE = 100  # 고정된 윈도우 크기 (과거 몇 회차를 볼지 설정)
    # 설명: LSTM 모델이 입력으로 받을 시퀀스 길이 (과거 몇 회차를 보고 예측할지)
    # 영향: 너무 작으면 정보 부족, 너무 크면 잡음 많아짐
    # 추천 범위: 5~30

# 데이터 로드 함수
def load_lotto_data(file_path):
    df = pd.read_csv(file_path)
    numbers = df[[f'번호{i}' for i in range(1, 7)]].values.tolist()
    one_hot = []
    for nums in numbers:
        vec = np.zeros(45)
        for n in nums:
            vec[n - 1] = 1
        one_hot.append(vec)
    return one_hot

# 데이터셋 생성 함수 (고정 길이 윈도우)
def create_fixed_window_dataset(numbers, window_size=WINDOW_SIZE):
    X, y = [], []
    for i in range(window_size, len(numbers)):
        X.append(numbers[i - window_size:i])
        y.append(numbers[i])
    return np.array(X), np.array(y)

# 학습/검증 분할 함수
def split_train_val(numbers, val_size=100, window_size=WINDOW_SIZE):
    train = numbers[:-(val_size + window_size)]
    val = numbers[-(val_size + window_size):]
    return train, val

# LSTM 모델 정의
class LottoLSTM(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, input_size)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]  # 마지막 시점 출력
        out = self.fc(out)
        return self.sigmoid(out)
    


# 학습 함수
def train_model(model, criterion, optimizer, X_train, y_train, X_val, y_val, num_epochs=100):
    for epoch in range(num_epochs):
        model.train()
        outputs = model(X_train)
        loss = criterion(outputs, y_train)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        model.eval()
        with torch.no_grad():
            val_outputs = model(X_val)
            val_loss = criterion(val_outputs, y_val)

        print(f"Epoch [{epoch+1}/{num_epochs}], Loss: {loss.item():.4f}, Val Loss: {val_loss.item():.4f}")

    # num_epochs
        # 설명: 전체 데이터를 몇 번 반복 학습할지
        # 영향: 너무 적으면 학습 부족, 너무 많으면 과적합
        # 추천 범위: 30 ~ 300 (Early stopping 도입 가능)



# 실행 코드
if __name__ == "__main__":
    numbers = load_lotto_data('lotto_data.csv')

    train_numbers, val_numbers = split_train_val(numbers)
    X_train, y_train = create_fixed_window_dataset(train_numbers)
    X_val, y_val = create_fixed_window_dataset(val_numbers)

    print(f"[Train] X: {X_train.shape}, y: {y_train.shape}")
    print(f"[ Val ] X: {X_val.shape}, y: {y_val.shape}")

    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.float32)
    X_val = torch.tensor(X_val, dtype=torch.float32)
    y_val = torch.tensor(y_val, dtype=torch.float32)

    model = LottoLSTM(input_size=45, hidden_size=128, num_layers=1)
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    # hidden_size (LSTM 은닉 상태 차원)
        # 설명: LSTM이 정보를 요약하는 공간의 크기
        # 영향: 클수록 모델의 표현력이 높아지지만 과적합 위험 ↑
        # 추천 범위: 32, 64, 128, 256

    # num_layers (LSTM 층 수)
        # 설명: LSTM이 몇 층으로 구성되는지
        # 영향: 층이 많아질수록 복잡한 패턴 학습 가능. 다만 학습 어려워질 수 있음
        # 추천 범위: 1~3
    

    # 모델 학습
    train_model(model, criterion, optimizer, X_train, y_train, X_val, y_val)

 
# 예측을 위한 데이터 준비 (마지막 window_size 길이의 시퀀스)
with torch.no_grad():
    input_seq = X_val[-1].unsqueeze(0)  # 마지막 시퀀스를 가져옴, shape: [1, window_size, input_size]
    model.eval()

    print("예측된 번호 5세트:")
    for i in range(5):
        output = model(input_seq)
        probabilities = torch.sigmoid(output).squeeze().numpy()  # 확률값으로 변환 (0~1)

        # 상위 6개 번호 선택
        predicted_numbers = np.argsort(probabilities)[-6:] + 1
        predicted_numbers = np.sort(predicted_numbers)  # 오름차순 정렬

        print(f"세트 {i+1}: {predicted_numbers}")