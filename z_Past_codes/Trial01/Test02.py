import csv
import numpy as np

# ✅ 통일된 윈도우 크기
WINDOW_SIZE = 500

# 로또 번호 불러오기
def load_lotto_data(filename='lotto_data.csv'):
    numbers = []
    with open(filename, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)  # 헤더 스킵
        for row in reader:
            nums = list(map(int, row[1:8]))  # 보너스 번호 제외
            numbers.append(nums)
    return numbers

# one-hot 인코딩 (길이 45)
def numbers_to_one_hot(numbers):
    one_hot = np.zeros(45)
    for num in numbers:
        one_hot[num - 1] = 1
    return one_hot

# 고정된 WINDOW_SIZE 회차를 입력으로 사용하는 데이터셋 생성
def create_fixed_window_dataset(numbers):
    X = []
    y = []
    for i in range(len(numbers) - WINDOW_SIZE):
        input_seq = numbers[i : i + WINDOW_SIZE]
        target = numbers[i + WINDOW_SIZE]

        input_one_hot = [numbers_to_one_hot(draw) for draw in input_seq]
        X.append(np.array(input_one_hot))
        y.append(numbers_to_one_hot(target))
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)

# 학습/검증용 번호 분할
def split_train_val(numbers, val_size=9):
    # 검증셋 생성 위해 뒤에서 WINDOW_SIZE + val_size 만큼 확보
    train = numbers[:-(val_size + WINDOW_SIZE)]
    val = numbers[-(val_size + WINDOW_SIZE):]
    return train, val

# 실행 예시
if __name__ == "__main__":
    numbers = load_lotto_data()

    # 데이터 분할
    train_numbers, val_numbers = split_train_val(numbers, val_size=9)

    # 학습/검증셋 생성
    X_train, y_train = create_fixed_window_dataset(train_numbers)
    X_val, y_val = create_fixed_window_dataset(val_numbers)

    print(f"[Train] X: {X_train.shape}, y: {y_train.shape}")
    print(f"[ Val ] X: {X_val.shape}, y: {y_val.shape}")
