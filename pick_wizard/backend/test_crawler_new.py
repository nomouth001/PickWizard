"""
크롤러 테스트 스크립트

2026-01-04 EST
"""

import asyncio
import sys
sys.path.insert(0, '.')

from app.core.crawler import LottoCrawler


async def test_crawler():
    """크롤러 테스트"""
    
    print("="*60)
    print("크롤러 테스트 시작")
    print("="*60)
    
    async with LottoCrawler() as crawler:
        # 1. 최신 회차 조회
        print("\n[1/3] 최신 회차 조회...")
        latest = await crawler.get_latest_draw_number()
        print(f"  결과: {latest}회\n")
        
        if latest:
            # 2. 단일 회차 크롤링 (최신 회차)
            print(f"[2/3] {latest}회 크롤링...")
            single_result = await crawler.crawl_single(latest)
            if single_result:
                print(f"  [OK] 성공!")
                print(f"  회차: {single_result['draw_no']}")
                print(f"  날짜: {single_result['draw_date']}")
                print(f"  번호: {single_result['num1']}, {single_result['num2']}, "
                      f"{single_result['num3']}, {single_result['num4']}, "
                      f"{single_result['num5']}, {single_result['num6']}")
                print(f"  보너스: {single_result['bonus']}")
                print(f"  1등 당첨금: {single_result['first_prize_amount']:,}원")
                print(f"  1등 당첨자: {single_result['first_winner_count']}명\n")
            else:
                print(f"  [FAIL] 실패\n")
            
            # 3. 범위 크롤링 (최근 5회차)
            start = max(1, latest - 4)
            print(f"[3/3] {start}~{latest}회 범위 크롤링...")
            range_results = await crawler.crawl_range(start, latest)
            print(f"  [OK] {len(range_results)}개 회차 크롤링 성공\n")
            
            for r in range_results:
                print(f"  {r['draw_no']}회: "
                      f"{r['num1']}, {r['num2']}, {r['num3']}, "
                      f"{r['num4']}, {r['num5']}, {r['num6']} "
                      f"+ {r['bonus']}")
    
    print("\n" + "="*60)
    print("크롤러 테스트 완료!")
    print("="*60)


if __name__ == "__main__":
    asyncio.run(test_crawler())

