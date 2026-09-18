import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim

class LottoLSTM(nn.Module):
    def __init__(self, input_size=45, hidden_size=64, num_layers=2, output_size=45, dropout=0.2):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True, dropout=dropout)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out, _ = self.lstm(x)
        out = self.fc(out[:, -1, :])  # 마지막 timestep 출력
        return out

def prepare_sequences(df, window_size):
    sequences = []
    for i in range(len(df) - window_size):
        seq = df.iloc[i:i+window_size][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values
        input_vec = np.zeros((window_size, 45))
        for j in range(window_size):
            for num in seq[j]:
                input_vec[j, int(num) - 1] = 1
        sequences.append(input_vec)
    return sequences

def train_lotto_model(model, sequences, num_epochs=1, learning_rate=0.001):
    """
    model이 주어지면 이어서 추가 학습합니다.
    (만약 model=None이면 새 모델을 생성합니다.)
    """
    if model is None:
        model = LottoLSTM()

    criterion = nn.BCEWithLogitsLoss()
    optimizer = optim.Adam(model.parameters(), lr=learning_rate)

    X = torch.tensor(sequences, dtype=torch.float32)
    y = torch.tensor([seq[-1] for seq in sequences], dtype=torch.float32)

    for epoch in range(num_epochs):
        model.train()
        optimizer.zero_grad()
        outputs = model(X)
        loss = criterion(outputs, y)
        loss.backward()
        optimizer.step()
        print(f"[Epoch {epoch+1}] Loss: {loss.item():.4f}")

    return model

def predict_lotto(model, last_sequence):
    model.eval()
    with torch.no_grad():
        input_tensor = torch.tensor(last_sequence, dtype=torch.float32).unsqueeze(0)
        outputs = model(input_tensor)
        probs = torch.sigmoid(outputs).squeeze().numpy()
    return probs

def generate_numbers_from_probs(probs, topk=6):
    selected = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=probs / probs.sum())
    return sorted(selected.tolist())

def generate_5_sets_from_probs(probs):
    return [generate_numbers_from_probs(probs) for _ in range(5)]
