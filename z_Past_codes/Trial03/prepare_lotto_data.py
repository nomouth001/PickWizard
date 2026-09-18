import pandas as pd
import numpy as np
import torch
from sklearn.preprocessing import OneHotEncoder

def load_lotto_csv_for_lstm(filename="lotto_data_.csv", seq_len=100, max_number=45):
    df = pd.read_csv(filename)
    numbers = df[['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']].values.astype(int)

    encoder = OneHotEncoder(categories=[list(range(1, max_number + 1))], sparse_output=False)
    all_encoded = np.array([encoder.fit_transform(n.reshape(-1, 1)).sum(axis=0) for n in numbers])

    sequences, labels = [], []
    for i in range(len(all_encoded) - seq_len):
        sequences.append(all_encoded[i:i+seq_len])
        labels.append(all_encoded[i+seq_len])
    
    X = torch.tensor(np.array(sequences), dtype=torch.float32)
    y = torch.tensor(labels, dtype=torch.float32)
    return X, y, encoder
