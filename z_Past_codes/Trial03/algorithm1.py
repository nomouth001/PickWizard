import random

def generate_random_lotto_set():
    """
    1세트의 랜덤 로또 번호(6개)를 반환합니다.
    번호는 1~45 사이의 중복 없는 숫자이며, 정렬된 상태로 반환됩니다.
    """
    return sorted(random.sample(range(1, 46), 6))

def generate_random_lotto_sets(n_sets=10):
    """
    n_sets 개수만큼의 로또 번호 세트를 생성하여 리스트로 반환합니다.
    각 세트는 6개의 번호로 구성됩니다.
    """
    return [generate_random_lotto_set() for _ in range(n_sets)]
