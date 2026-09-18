import requests
from bs4 import BeautifulSoup
import csv
import time
import os

CSV_FILE = "lotto_data.csv"

# def get_lotto_numbers(draw_no):
#     url = f"https://www.dhlottery.co.kr/gameResult.do?method=byWin&drwNo={draw_no}"
#     response = requests.get(url)
#     soup = BeautifulSoup(response.text, "html.parser")

#     numbers = soup.select("div.num.win span.ball_645")
#     if len(numbers) < 6:
#         return None

#     result = [int(num.text) for num in numbers]
#     bonus = int(soup.select_one("div.num.bonus span.ball_645").text)
#     return [draw_no] + result + [bonus]

def get_lotto_numbers(draw_no):
    url = f"https://www.dhlottery.co.kr/gameResult.do?method=byWin&drwNo={draw_no}"
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")

    numbers = soup.select("div.num.win span.ball_645")
    bonus_elem = soup.select_one("div.num.bonus span.ball_645")

    # 번호가 부족하거나 보너스 번호가 없으면 발표 안 된 회차로 간주
    if len(numbers) < 6 or bonus_elem is None or bonus_elem.text.strip() == "":
        return None

    try:
        result = [int(num.text) for num in numbers]
        bonus = int(bonus_elem.text)
        return [draw_no] + result + [bonus]
    except ValueError:
        return None  # 혹시라도 이상한 값이 있으면 안전하게 처리

def read_last_draw_no(filename=CSV_FILE):
    if not os.path.exists(filename):
        return 0
    with open(filename, "r", encoding="utf-8") as f:
        lines = f.readlines()
        if len(lines) <= 1:
            return 0
        last_line = lines[-1]
        last_draw_no = int(last_line.split(",")[0])
        return last_draw_no

def collect_new_data(start_no, delay=0.5):
    new_data = []
    while True:
        data = get_lotto_numbers(start_no)
        if data:
            new_data.append(data)
            print(f"{start_no}회차 수집 완료: {data}")
            start_no += 1
            time.sleep(delay)
        else:
            print(f"{start_no}회차는 아직 발표되지 않음. 종료.")
            break
    return new_data

def append_to_csv(data, filename=CSV_FILE):
    file_exists = os.path.exists(filename)
    with open(filename, "a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        if not file_exists:
            writer.writerow(["회차", "번호1", "번호2", "번호3", "번호4", "번호5", "번호6", "보너스"])
        writer.writerows(data)
    print(f"{filename} 갱신 완료")

# 실행
if __name__ == "__main__":
    last_draw = read_last_draw_no()
    print(f"현재 저장된 마지막 회차: {last_draw}")
    new_data = collect_new_data(last_draw + 1)
    if new_data:
        append_to_csv(new_data)
    else:
        print("추가된 데이터 없음.")
