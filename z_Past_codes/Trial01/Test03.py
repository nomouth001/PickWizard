import csv
import numpy as np

# ✅ 통일된 윈도우 크기
WINDOW_SIZE = 100

# 로또 번호 불러오기
def load_lotto_data(filename='lotto_data.csv'):
    numbers = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)  # 헤더 스킵
        for row in reader:
            nums = list(map(int, row[1:8]))  # 보너스 번호 제외
            numbers.append(nums)
    return numbers

# one-hot 인코딩 (길이 45)
def numbers_to_one_hot(numbers):
    one_hot = np.zeros(45)
    for num in numbers:
        one_hot[num - 1] = 1
    return one_hot

# 고정된 WINDOW_SIZE 회차를 입력으로 사용하는 데이터셋 생성
def create_fixed_window_dataset(numbers):
    X = []
    y = []
    for i in range(len(numbers) - WINDOW_SIZE):
        input_seq = numbers[i : i + WINDOW_SIZE]
        target = numbers[i + WINDOW_SIZE]

        input_one_hot = [numbers_to_one_hot(draw) for draw in input_seq]
        X.append(np.array(input_one_hot))
        y.append(numbers_to_one_hot(target))
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)

# 학습/검증용 번호 분할
def split_train_val(numbers, val_size=9):
    # 검증셋 생성 위해 뒤에서 WINDOW_SIZE + val_size 만큼 확보
    train = numbers[:-(val_size + WINDOW_SIZE)]
    val = numbers[-(val_size + WINDOW_SIZE):]
    return train, val

# 실행 예시
if __name__ == "__main__":
    numbers = load_lotto_data()

    # 데이터 분할
    train_numbers, val_numbers = split_train_val(numbers, val_size=9)

    # 학습/검증셋 생성
    X_train, y_train = create_fixed_window_dataset(train_numbers)
    X_val, y_val = create_fixed_window_dataset(val_numbers)

    print(f"[Train] X: {X_train.shape}, y: {y_train.shape}")
    print(f"[ Val ] X: {X_val.shape}, y: {y_val.shape}")


import torch
import torch.nn as nn

class LottoLSTM(nn.Module):
    def __init__(self, input_size=45, hidden_size=128, num_layers=2, output_size=45):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)
        self.sigmoid = nn.Sigmoid()  # 확률 값으로 출력 (0~1)

    def forward(self, x):
        out, _ = self.lstm(x)  # out shape: (batch, seq_len, hidden)
        out = out[:, -1, :]    # 마지막 시점의 출력만 사용
        out = self.fc(out)
        out = self.sigmoid(out)
        return out

import torch.optim as optim
from sklearn.metrics import accuracy_score

# 하이퍼파라미터
EPOCHS = 100
BATCH_SIZE = 32
LEARNING_RATE = 0.001

def train_model(X_train, y_train, X_val, y_val):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    model = LottoLSTM().to(device)
    criterion = nn.BCELoss()  # Binary Cross Entropy
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

    # 데이터 텐서 변환
    X_train = torch.tensor(X_train, dtype=torch.float32).to(device)
    y_train = torch.tensor(y_train, dtype=torch.float32).to(device)
    X_val = torch.tensor(X_val, dtype=torch.float32).to(device)
    y_val = torch.tensor(y_val, dtype=torch.float32).to(device)

    for epoch in range(1, EPOCHS + 1):
        model.train()
        optimizer.zero_grad()

        outputs = model(X_train)
        loss = criterion(outputs, y_train)
        loss.backward()
        optimizer.step()

        # 검증
        model.eval()
        with torch.no_grad():
            val_outputs = model(X_val)
            val_loss = criterion(val_outputs, y_val)

        print(f"Epoch [{epoch}/{EPOCHS}], Loss: {loss.item():.4f}, Val Loss: {val_loss.item():.4f}")

    return model

