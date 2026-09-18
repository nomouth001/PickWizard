import pandas as pd
import numpy as np

def generate_numbers_algorithm8(csv_path="lotto_data_.csv", x=50, topk=6):
    df = pd.read_csv(csv_path)
    if len(df) < x + 2:
        raise ValueError("데이터가 부족하여 알고리즘 8 실행 불가")

    # 최근 x회차
    recent_df = df.iloc[-x:]
    recent_numbers = recent_df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()

    # 확률 계산
    counts = np.zeros(45)
    for num in recent_numbers:
        if 1 <= num <= 45:
            counts[num - 1] += 1
    probs = counts / counts.sum()

    # 제외할 숫자 계산 (직전 2회차 모두 등장한 숫자)
    last1 = set(df.iloc[-1][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']])
    last2 = set(df.iloc[-2][['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']])
    exclude_nums = last1 & last2  # 두 회차에 모두 등장한 숫자

    # 제외 처리
    for num in exclude_nums:
        probs[num - 1] = 0
    probs = probs / probs.sum()  # 재정규화

    available_numbers = np.arange(1, 46)
    selected = np.random.choice(available_numbers, size=topk, replace=False, p=probs)
    return sorted(selected.tolist())
