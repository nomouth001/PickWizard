import pandas as pd
import numpy as np

def calculate_probabilities(csv_path="lotto_data_.csv", start_round=1, end_round=100):
    """
    1회차부터 end_round까지 출현 데이터 기반 확률을 계산합니다.
    """
    df = pd.read_csv(csv_path)
    df = df[df['회차'] >= start_round]
    df = df[df['회차'] <= end_round]

    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()

    counts = np.zeros(45)
    for num in numbers:
        if 1 <= num <= 45:
            counts[num - 1] += 1

    probs = counts / counts.sum()
    return probs

def reverse_rank_probs(probs):
    """
    주어진 확률을 내림차순으로 정렬 후, 순위를 반전하여 새로운 확률을 생성합니다.
    """
    ranks = probs.argsort()[::-1]
    reversed_probs = np.zeros_like(probs)
    for i, idx in enumerate(ranks[::-1]):
        reversed_probs[idx] = (i + 1)
    reversed_probs = reversed_probs / reversed_probs.sum()
    return reversed_probs

def generate_numbers_from_reversed_probs(probs, topk=6):
    """
    반전된 확률 분포를 이용해 번호 6개를 무작위로 추출합니다.
    """
    reversed_probs = reverse_rank_probs(probs)
    chosen = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=reversed_probs)
    return sorted(chosen.tolist())

def generate_5_sets_from_reversed_probs(probs):
    """
    반전 확률 기반으로 5세트 번호를 생성합니다.
    """
    return [generate_numbers_from_reversed_probs(probs) for _ in range(5)]
