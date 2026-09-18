import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
# from model import LottoLSTMModel

class LottoLSTM(nn.Module):
    def __init__(self, input_size=45, hidden_size=64, num_layers=2, output_size=45, dropout=0.2):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True, dropout=dropout)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out, _ = self.lstm(x)
        out = self.fc(out[:, -1, :])  # 마지막 시점만
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

def train_lotto_model(sequences, num_epochs=50, early_stop_rounds=5):
    if len(sequences) == 0:
        raise ValueError("입력 시퀀스가 비어 있습니다.")

    X, y = zip(*sequences)
    X = np.array(X)
    y = np.array(y)

    # LSTM 입력에 맞게 차원 조정: (batch, seq_len, input_size)
    X_tensor = torch.tensor(X, dtype=torch.float32)
    y_tensor = torch.tensor(y, dtype=torch.float32)

    model = LottoLSTMModel(input_size=45, hidden_size=128, num_layers=2)
    criterion = nn.BCELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

    best_loss = float("inf")
    no_improve_count = 0

    for epoch in range(1, num_epochs + 1):
        model.train()
        optimizer.zero_grad()

        output = model(X_tensor)
        loss = criterion(output, y_tensor)
        loss.backward()
        optimizer.step()

        print(f"[Epoch {epoch}] Loss: {loss.item():.4f}")

        # Early stopping 조건
        if loss.item() < best_loss:
            best_loss = loss.item()
            no_improve_count = 0
        else:
            no_improve_count += 1
            if no_improve_count >= early_stop_rounds:
                print(f"Early stopping triggered at epoch {epoch}")
                break

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
