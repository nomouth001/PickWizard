import pandas as pd

# 1. 로또 번호 → 패턴 문자로 변환하는 함수
def number_to_pattern(n):
    if 1 <= n <= 9:
        return 'A'
    elif 10 <= n <= 18:
        return 'B'
    elif 19 <= n <= 27:
        return 'C'
    elif 28 <= n <= 36:
        return 'D'
    elif 37 <= n <= 45:
        return 'E'
    else:
        return 'X'  # 예외 처리

# 2. lotto_data.csv 읽기
df = pd.read_csv('lotto_data.csv')  # 경로는 실행 환경에 맞게 조정

# 3. 번호 컬럼 지정
number_columns = ['번호1', '번호2', '번호3', '번호4', '번호5', '번호6']

# 4. 각 번호 → 패턴 변환 및 패턴 컬럼 생성
for col in number_columns:
    df[f'{col}-pattern'] = df[col].apply(number_to_pattern)

# 5. 전체 패턴 조합 문자열 생성
pattern_columns = [f'{col}-pattern' for col in number_columns]
df['pattern'] = df[pattern_columns].agg(''.join, axis=1)

# 6. 컬럼명 변경 및 정렬
df = df[['회차'] + number_columns + pattern_columns + ['pattern']]
df.columns = [
    'round', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6',
    'num1-pattern', 'num2-pattern', 'num3-pattern',
    'num4-pattern', 'num5-pattern', 'num6-pattern', 'pattern'
]

# 7. 결과 저장
df.to_csv('lotto_data_pattern.csv', index=False)
