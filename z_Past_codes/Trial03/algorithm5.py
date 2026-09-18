import pandas as pd
import numpy as np

def calculate_recent_probabilities(csv_path="lotto_data_.csv", end_round=100, window_size=50, alpha=0.2):
    """
    최근 window_size개 회차를 기반으로 각 번호(1~45)의 출현 확률을 계산합니다.
    alpha는 최근 출현 숫자를 얼마나 강조할지 결정하는 하이퍼파라미터입니다.
    """
    df = pd.read_csv(csv_path)
    df = df[df['회차'] <= end_round].tail(window_size)

    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()
    counts = np.zeros(45)
    for num in numbers:
        counts[int(num) - 1] += 1

    total_draws = window_size * 6
    base_prob = np.ones(45) / 45
    emphasized_prob = counts / total_draws if total_draws > 0 else np.zeros(45)
    combined = (1 - alpha) * base_prob + alpha * emphasized_prob
    return combined

def reverse_rank_probs(probs):
    """
    확률을 내림차순 정렬한 후 순위를 반영해 확률을 역으로 재구성합니다.
    """
    ranks = probs.argsort()[::-1]
    reversed_probs = np.zeros_like(probs)
    for i, idx in enumerate(ranks[::-1]):
        reversed_probs[idx] = (i + 1)
    reversed_probs = reversed_probs / reversed_probs.sum()
    return reversed_probs

def get_recently_3times_duplicated_numbers(df, end_round):
    """
    직전 3회 연속으로 등장한 숫자를 찾아 제외 대상 리스트로 반환합니다.
    """
    last_three = df[df['회차'] <= end_round].tail(3)
    sets = [
        set(last_three.iloc[i][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']])
        for i in range(3)
    ]
    return sets[0] & sets[1] & sets[2]

def generate_numbers_from_reversed_recent_probs(probs, exclude_numbers, topk=6):
    available_numbers = np.array([i for i in range(1, 46) if i not in exclude_numbers])
    reversed_probs = reverse_rank_probs(probs)
    available_probs = reversed_probs[available_numbers - 1]
    available_probs = available_probs / available_probs.sum()

    if len(available_numbers) < topk:
        raise ValueError("선택 가능한 번호가 부족합니다.")

    chosen = np.random.choice(available_numbers, size=topk, replace=False, p=available_probs)
    return sorted(chosen.tolist())

def generate_5_sets_from_reversed_recent_probs(probs, exclude_numbers):
    return [generate_numbers_from_reversed_recent_probs(probs, exclude_numbers) for _ in range(5)]
