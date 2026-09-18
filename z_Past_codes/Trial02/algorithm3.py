import torch
import numpy as np

def reverse_rank_probs(probs: np.ndarray) -> np.ndarray:
    """확률을 순위 기준으로 역전시켜 새로운 분포 생성"""
    ranks = probs.argsort()[::-1]  # 내림차순 정렬
    reversed_probs = np.zeros_like(probs)
    for i, idx in enumerate(ranks[::-1]):  # 가장 낮은 순위에 높은 확률
        reversed_probs[idx] = (i + 1)
    reversed_probs = reversed_probs / reversed_probs.sum()
    return reversed_probs

def predict_with_reversed_probs(model, recent_sequence, topk=6):
    model.eval()
    with torch.no_grad():
        pred = model(recent_sequence.unsqueeze(0))
        probs = torch.softmax(pred.squeeze(0), dim=0).cpu().numpy()
        reversed_probs = reverse_rank_probs(probs)
        selected = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=reversed_probs)
        return sorted(selected.tolist())
