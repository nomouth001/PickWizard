from train_lotto_model import train_lstm_model
import torch

def update_lstm_model(model, new_X, new_y,
                      learning_rate=0.001, num_epochs=3, batch_size=16):
    """기존 모델에 새로운 데이터를 추가 학습시켜 갱신"""
    model.train()
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    criterion = torch.nn.MSELoss()

    dataset = torch.utils.data.TensorDataset(new_X, new_y)
    loader = torch.utils.data.DataLoader(dataset, batch_size=batch_size, shuffle=True)

    for epoch in range(num_epochs):
        for xb, yb in loader:
            optimizer.zero_grad()
            pred = model(xb)
            loss = criterion(pred, yb)
            loss.backward()
            optimizer.step()

    return model
