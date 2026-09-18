import pandas as pd
import numpy as np

def generate_numbers_algorithm6(csv_path="lotto_data_.csv", topk=6):
    df = pd.read_csv(csv_path)
    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()
    
    counts = np.zeros(45)
    for num in numbers:
        if 1 <= num <= 45:
            counts[num - 1] += 1

    probs = counts / counts.sum()
    chosen = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=probs)
    return sorted(chosen.tolist())
