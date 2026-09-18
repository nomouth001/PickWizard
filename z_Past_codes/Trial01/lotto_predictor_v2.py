
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim
import os
from copy import deepcopy

CSV_FILE = "lotto_data.csv"
RESULT_LOG_FILE = "evaluation_log.csv"
WINDOW_SIZE = 100
VAL_SIZE = 9
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def load_lotto_data(file_path):
    df = pd.read_csv(file_path)
    all_numbers = []
    for _, row in df.iterrows():
        nums = list(map(int, row[1:8]))  # 번호1~6 + 보너스 포함
        vec = np.zeros(45)
        for n in nums:
            vec[n - 1] = 1
        all_numbers.append(vec)
    return all_numbers

def create_fixed_window_dataset(numbers, window_size=WINDOW_SIZE):
    X, y = [], []
    for i in range(window_size, len(numbers)):
        X.append(numbers[i - window_size:i])
        y.append(numbers[i])
    return np.array(X), np.array(y)

def get_lotto_detailed_result(predicted, target):
    predict_set = set(predicted)
    true_nums = set(np.where(target[:45] == 1)[0] + 1)
    bonus = np.argmax(target[45:]) + 1 if target[45:].sum() > 0 else None
    matched = list(predict_set & true_nums)
    bonus_matched = (bonus in predict_set)

    count = len(matched)
    if count == 6:
        rank = "1등"
    elif count == 5 and bonus_matched:
        rank = "2등"
    elif count == 5:
        rank = "3등"
    elif count == 4:
        rank = "4등"
    elif count == 3:
        rank = "5등"
    else:
        rank = "꽝"

    return {
        "rank": rank,
        "matched_numbers": [int(n) for n in sorted(matched)],
        "bonus_matched": int(bonus) if bonus_matched else None
    }

class LottoLSTM(nn.Module):
    def __init__(self, input_size=45, hidden_size=128, num_layers=1):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, input_size)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        out, _ = self.lstm(x)
        out = out[:, -1, :]
        out = self.fc(out)
        return self.sigmoid(out)

def train_model(model, criterion, optimizer, X_train, y_train, num_epochs=20):
    model.train()
    for epoch in range(num_epochs):
        outputs = model(X_train)
        loss = criterion(outputs, y_train)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

def sample_lotto_numbers(probabilities):
    probabilities /= probabilities.sum()
    numbers = np.random.choice(np.arange(1, 46), size=6, replace=False, p=probabilities)
    return np.sort(numbers)

if __name__ == "__main__":
    numbers = load_lotto_data(CSV_FILE)
    base_data = numbers[:-(VAL_SIZE)]
    future_data = numbers[-(VAL_SIZE):]

    with open(RESULT_LOG_FILE, "w", encoding="utf-8") as f:
        f.write("회차,세트,예측번호,등수,일치번호,보너스번호")

    model = LottoLSTM().to(DEVICE)
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    X_train, y_train = create_fixed_window_dataset(base_data)
    X_train = torch.tensor(X_train, dtype=torch.float32).to(DEVICE)
    y_train = torch.tensor(y_train, dtype=torch.float32).to(DEVICE)
    train_model(model, criterion, optimizer, X_train, y_train)

    print("[검증 단계: 각 회차별 예측 + 평가 + 모델 갱신]")
    current_data = deepcopy(base_data)
    initial_train_len = len(base_data)

    for i, target_result in enumerate(future_data):
        round_no = initial_train_len + i + 1
        last_seq_array = np.array(current_data[-WINDOW_SIZE:])
        last_seq = torch.tensor(last_seq_array, dtype=torch.float32).unsqueeze(0).to(DEVICE)

        print(f"📅 {round_no}회차 예측:")
        with torch.no_grad():
            output = model(last_seq)
            probs = output.squeeze().cpu().numpy()
            for s in range(5):
                prediction = sample_lotto_numbers(probs)
                result = get_lotto_detailed_result(prediction, target_result)

                print(f"세트 {s+1}: {prediction} → {result['rank']}")
                print(f"    ✔ 일치 번호: {result['matched_numbers']}")
                print(f"    ⭕ 보너스 번호 포함됨: {result['bonus_matched'] if result['bonus_matched'] else '없음'}")

                with open(RESULT_LOG_FILE, "a", encoding="utf-8") as f:
                    nums_str = " ".join(map(str, prediction))
                    match_str = " ".join(map(str, result['matched_numbers']))
                    bonus_str = str(result['bonus_matched']) if result['bonus_matched'] else "없음"
                    f.write(f"{round_no},{s+1},{nums_str},{result['rank']},{match_str},{bonus_str}")

        current_data.append(target_result)
        X_new, y_new = create_fixed_window_dataset(current_data)
        X_new = torch.tensor(X_new, dtype=torch.float32).to(DEVICE)
        y_new = torch.tensor(y_new, dtype=torch.float32).to(DEVICE)
        train_model(model, criterion, optimizer, X_new, y_new, num_epochs=20)

        torch.save(model.state_dict(), f"model_checkpoint_{round_no}.pt")

    print("[최신 모델로 다음 회차(1170) 예측]")
    last_seq_array = np.array(current_data[-WINDOW_SIZE:])
    last_seq = torch.tensor(last_seq_array, dtype=torch.float32).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        output = model(last_seq)
        probs = output.squeeze().cpu().numpy()
        for i in range(5):
            prediction = sample_lotto_numbers(probs)
            print(f"1170회차 세트 {i+1}: {prediction}")
