"""
동행복권 사이트 크롤링 테스트

2026-01-04 EST
"""

import requests
from bs4 import BeautifulSoup

url = 'https://www.dhlottery.co.kr/gameResult.do?method=byWin'

print("동행복권 사이트 크롤링 테스트...")
print(f"URL: {url}\n")

try:
    # User-Agent 추가
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    response = requests.get(url, headers=headers, timeout=10)
    response.encoding = 'euc-kr'  # 동행복권 사이트 인코딩
    
    print(f"Status Code: {response.status_code}")
    print(f"Encoding: {response.encoding}")
    print(f"Content Length: {len(response.text)} chars\n")
    
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # 회차 번호 찾기
    print("=== 1. 회차 번호 찾기 ===")
    
    # 방법 1: 특정 div의 strong 태그
    draw_no_div = soup.find('div', class_='win_result')
    if draw_no_div:
        print(f"[OK] win_result div 찾음")
        strong = draw_no_div.find('strong')
        if strong:
            print(f"  회차 정보: {strong.text.strip()}")
        h4 = draw_no_div.find('h4')
        if h4:
            print(f"  H4: {h4.text.strip()}")
    else:
        print("[FAIL] win_result div 못 찾음")
    
    # 방법 2: 모든 strong 태그
    all_strong = soup.find_all('strong')
    print(f"\n모든 strong 태그 ({len(all_strong)}개):")
    for i, tag in enumerate(all_strong[:10]):
        print(f"  {i+1}. {tag.text.strip()}")
    
    # 당첨번호 찾기
    print("\n=== 2. 당첨번호 찾기 ===")
    
    # 방법 1: ball_645 클래스
    balls = soup.find_all('span', class_='ball_645')
    print(f"ball_645 span: {len(balls)}개")
    if balls:
        for i, ball in enumerate(balls[:7]):
            print(f"  번호 {i+1}: {ball.text.strip()}")
    
    # 방법 2: 다른 클래스 패턴
    num_pattern_classes = ['num', 'ball', 'lotto_num', 'win_num']
    for cls in num_pattern_classes:
        found = soup.find_all(class_=lambda x: x and cls in x if x else False)
        if found:
            print(f"\n'{cls}' 포함 클래스: {len(found)}개")
            for i, elem in enumerate(found[:5]):
                print(f"  {i+1}. class='{elem.get('class')}' text='{elem.text.strip()}'")
    
    # HTML 저장
    with open('lotto_debug.html', 'w', encoding='utf-8') as f:
        f.write(response.text)
    print(f"\n[OK] HTML 저장: lotto_debug.html")
    
except Exception as e:
    print(f"[ERROR] 오류: {e}")
    import traceback
    traceback.print_exc()

