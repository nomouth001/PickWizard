import pandas as pd
import numpy as np

def calculate_recent_probabilities_with_alpha_and_exclusion(
    csv_path="lotto_data_.csv",
    end_round=100,
    window_size=50,
    alpha=0.2
):
    """
    최근 window_size 회차 기준으로 출현 빈도 기반 확률을 계산하되,
    - alpha 비율로 균등 분포와 섞고,
    - 3회 연속 출현한 번호는 제외하고,
    - 해당 번호의 확률은 나머지 번호에 균등 재분배합니다.
    """
    df = pd.read_csv(csv_path)
    df = df[df["회차"] <= end_round]
    df = df.tail(window_size)

    numbers = df[[f"번호{i}" for i in range(1, 7)]].values.flatten()
    counts = np.zeros(45)
    for num in numbers:
        if 1 <= num <= 45:
            counts[num - 1] += 1
    freq = counts / counts.sum()

    base = np.ones(45) / 45
    probs = (1 - alpha) * base + alpha * freq

    # 3연속 출현 번호 제외
    three_dup = find_three_consecutive_numbers(df)
    if three_dup:
        total_removed = np.sum([probs[n - 1] for n in three_dup])
        for n in three_dup:
            probs[n - 1] = 0
        redistribute_indices = [i for i in range(45) if (i + 1) not in three_dup]
        probs[redistribute_indices] += total_removed / len(redistribute_indices)

    return probs

def find_three_consecutive_numbers(df):
    """
    주어진 DataFrame에서 3회 연속 출현한 번호를 찾아 반환합니다.
    """
    numbers_cols = [f"번호{i}" for i in range(1, 7)]
    counts = {i: 0 for i in range(1, 46)}
    result = set()

    for _, row in df.iterrows():
        current_numbers = set(row[numbers_cols])
        for i in range(1, 46):
            if i in current_numbers:
                counts[i] += 1
                if counts[i] >= 3:
                    result.add(i)
            else:
                counts[i] = 0
    return result

def generate_numbers_from_recent_probabilities(probs, exclude_numbers, topk=6):
    """
    제외할 번호를 빼고, 주어진 확률 기반으로 번호 6개를 무작위 추출합니다.
    예외 처리: 남은 번호가 부족할 경우 전체 풀에서 무작위 추출
    """
    available_numbers = np.array([i for i in range(1, 46) if i not in exclude_numbers])

    if len(available_numbers) < topk:
        print(f"[경고] 제외 후 남은 번호가 {len(available_numbers)}개 뿐 → 전체 번호에서 무작위 추출")
        return sorted(np.random.choice(np.arange(1, 46), size=topk, replace=False))

    available_probs = probs[available_numbers - 1]
    available_probs = available_probs / available_probs.sum()

    chosen = np.random.choice(available_numbers, size=topk, replace=False, p=available_probs)
    return sorted(chosen.tolist())

def generate_5_sets_from_recent_probabilities(probs, exclude_numbers):
    """
    확률 기반으로 번호 5세트를 생성합니다.
    """
    return [generate_numbers_from_recent_probabilities(probs, exclude_numbers) for _ in range(5)]
