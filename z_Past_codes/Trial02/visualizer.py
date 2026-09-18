import matplotlib.pyplot as plt
from collections import Counter
plt.rcParams['font.family'] = 'Malgun Gothic'  # Windows용
plt.rcParams['axes.unicode_minus'] = False

def visualize_rank_distribution(results, algorithm_name="알고리즘"):
    ranks = [r["등수"] for r in results if r["등수"] > 0]
    count = Counter(ranks)

    labels = [f"{i}등" for i in range(1, 6)] + ["꽝"]
    values = [count.get(i, 0) for i in range(1, 6)]
    values.append(len(results) - sum(values))  # 꽝

    plt.bar(labels, values, color='skyblue')
    plt.title(f"{algorithm_name} 등수 분포")
    plt.ylabel("세트 수")
    plt.xlabel("등수")
    plt.tight_layout()
    plt.savefig(f"{algorithm_name}_rank_chart.png")
    print(f"{algorithm_name}_rank_chart.png 저장 완료")
