import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
from lstm_model import LottoLSTM
from prepare_lotto_data import load_lotto_csv_for_lstm
import numpy as np

def train_lstm_model(X, y, hidden_size=128, num_layers=2, dropout=0.2,
                     learning_rate=0.001, num_epochs=10, batch_size=32):

    input_size = X.shape[2]
    model = LottoLSTM(input_size, hidden_size, num_layers, dropout)
    model = model.to(X.device)

    dataset = TensorDataset(X, y)
    loader = DataLoader(dataset, batch_size=batch_size, shuffle=True)

    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

    model.train()
    for epoch in range(num_epochs):
        total_loss = 0
        for xb, yb in loader:
            optimizer.zero_grad()
            pred = model(xb)
            loss = criterion(pred, yb)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        print(f"[Epoch {epoch+1}] Loss: {total_loss:.4f}")

    return model
