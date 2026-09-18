import torch
import numpy as np

def predict_next_lotto(model, recent_sequence, topk=6):
    model.eval()
    with torch.no_grad():
        pred = model(recent_sequence.unsqueeze(0))
        probs = torch.softmax(pred.squeeze(0), dim=0).cpu().numpy()
        selected = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=probs)
        return sorted(selected.tolist())
