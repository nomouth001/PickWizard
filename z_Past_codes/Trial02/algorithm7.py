import pandas as pd
import numpy as np
from algorithm3 import reverse_rank_probs

def generate_numbers_algorithm7(csv_path="lotto_data_.csv", topk=6):
    df = pd.read_csv(csv_path)
    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.flatten()

    counts = np.zeros(45)
    for num in numbers:
        if 1 <= num <= 45:
            counts[num - 1] += 1

    probs = counts / counts.sum()
    reversed_probs = reverse_rank_probs(probs)

    selected = np.random.choice(np.arange(1, 46), size=topk, replace=False, p=reversed_probs)
    return sorted(selected.tolist())
