"""HTML 분석"""
with open('lotto_debug.html', 'r', encoding='utf-8') as f:
    content = f.read()

# drwNo 찾기
if 'drwNo' in content:
    idx = content.find('drwNo')
    print(f"'drwNo' found at position {idx}")
    print("\nContext:")
    print(content[max(0, idx-300):idx+300])
    print("\n" + "="*50)

# 실제 회차 번호 패턴 찾기
import re
# 1000회 이상의 숫자 패턴
numbers = re.findall(r'1[01]\d{2,3}', content)
if numbers:
    print(f"\nPossible draw numbers: {set(numbers)}")

