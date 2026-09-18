import pandas as pd
import numpy as np

def calculate_probabilities(csv_path="lotto_data_.csv", end_round=None, window_size=50):
    import pandas as pd
    import numpy as np

    df = pd.read_csv(csv_path)
    if end_round is None:
        end_round = len(df)

    df = df[df['회차'] <= end_round]
    df = df.tail(window_size)

    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()
    counts = np.zeros(45)
    for num in numbers:
        if 1 <= num <= 45:
            counts[int(num) - 1] += 1

    probs = counts / counts.sum()
    return probs

def generate_numbers_from_probabilities(probs, topk=6):
    """
    주어진 확률 분포에 따라 번호 6개를 랜덤 추출합니다.
    """
    chosen = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=probs)
    return sorted(chosen.tolist())

def generate_5_sets_from_probabilities(probs):
    """
    확률 기반으로 5세트 번호를 생성합니다.
    """
    return [generate_numbers_from_probabilities(probs) for _ in range(5)]
