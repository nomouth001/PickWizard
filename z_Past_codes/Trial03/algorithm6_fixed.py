
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim

class LottoLSTM(nn.Module):
    def __init__(self, input_size=45, hidden_size=128, num_layers=2, output_size=45, dropout=0.2):
        super(LottoLSTM, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True, dropout=dropout)
        self.fc = nn.Linear(hidden_size, output_size)
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        out, _ = self.lstm(x)
        out = self.fc(out[:, -1, :])
        return self.sigmoid(out)

def prepare_sequences(df, window_size):
    sequences = []
    for i in range(len(df) - window_size):
        seq = df.iloc[i:i+window_size][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values
        target = df.iloc[i + window_size][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values
        input_vec = np.zeros((window_size, 45))
        target_vec = np.zeros(45)
        for j in range(window_size):
            for num in seq[j]:
                input_vec[j, int(num) - 1] = 1
        for num in target:
            target_vec[int(num) - 1] = 1
        sequences.append((input_vec, target_vec))
    return sequences

def train_lotto_model(sequences, num_epochs=50, early_stop_threshold=1e-4, patience=5):
    model = LottoLSTM()
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    X, y = zip(*sequences)
    X = torch.tensor(np.array(X), dtype=torch.float32)
    y = torch.tensor(np.array(y), dtype=torch.float32)

    prev_loss = float('inf')
    no_improve_count = 0

    for epoch in range(num_epochs):
        model.train()
        outputs = model(X)
        loss = criterion(outputs, y)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        print(f"[Epoch {epoch+1}] Loss: {loss.item():.4f}")

        if abs(prev_loss - loss.item()) < early_stop_threshold:
            no_improve_count += 1
            if no_improve_count >= patience:
                print("Early stopping triggered.")
                break
        else:
            no_improve_count = 0
        prev_loss = loss.item()

    return model

def predict_numbers(model, topk=6):
    model.eval()
    with torch.no_grad():
        x_dummy = torch.zeros((1, 10, 45))  # dummy input
        output = model(x_dummy).numpy().flatten()
        indices = np.argsort(output)[-topk:]
        return sorted((indices + 1).tolist())
