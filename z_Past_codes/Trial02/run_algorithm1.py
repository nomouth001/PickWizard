from algorithm1 import generate_random_lotto_sets

if __name__ == "__main__":
    results = generate_random_lotto_sets()
    print("알고리즘 1 (완전 랜덤 번호 5세트):")
    for i, numbers in enumerate(results, start=1):
        print(f"세트 {i}: {numbers}")
