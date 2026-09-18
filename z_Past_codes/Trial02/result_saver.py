import csv
from datetime import datetime
import os

def save_results_to_csv(results, folder="results"):
    os.makedirs(folder, exist_ok=True)
    filename = datetime.now().strftime("%Y%m%d_%H%M%S") + ".csv"
    filepath = os.path.join(folder, filename)

    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["파일저장일시", "알고리즘", "회차", "세트번호", "번호세트", "일치개수", "등수"])
        for row in results:
            writer.writerow([
                datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                row["알고리즘"],
                row["회차"],
                row["세트번호"],
                " ".join(map(str, row["번호세트"])),
                row["일치개수"],
                row["등수"]
            ])
    print(f"CSV 저장 완료: {filepath}")
