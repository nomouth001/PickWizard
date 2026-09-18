from algorithm3 import reverse_rank_probs
import torch
import numpy as np

def predict_with_reverse_and_update(model, recent_sequence, new_X, new_y, topk=6,
                                    learning_rate=0.001, num_epochs=3, batch_size=16):
    # 모델 누적 학습
    model.train()
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    criterion = torch.nn.MSELoss()

    loader = torch.utils.data.DataLoader(
        torch.utils.data.TensorDataset(new_X, new_y),
        batch_size=batch_size,
        shuffle=True
    )

    for epoch in range(num_epochs):
        for xb, yb in loader:
            optimizer.zero_grad()
            pred = model(xb)
            loss = criterion(pred, yb)
            loss.backward()
            optimizer.step()

    # 예측 및 확률 반전 샘플링
    model.eval()
    with torch.no_grad():
        pred = model(recent_sequence.unsqueeze(0))
        probs = torch.softmax(pred.squeeze(0), dim=0).cpu().numpy()
        reversed_probs = reverse_rank_probs(probs)
        selected = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=reversed_probs)
        return sorted(selected.tolist()), model
