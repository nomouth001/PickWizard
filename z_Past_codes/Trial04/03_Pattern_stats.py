import pandas as pd

# 1. CSV 파일 읽기
df = pd.read_csv('lotto_data_pattern.csv')  # 경로는 필요 시 수정

# 2. pattern 컬럼 기준으로 출현 횟수 집계
pattern_counts = df['pattern'].value_counts().reset_index()
pattern_counts.columns = ['pattern', 'count']  # 컬럼 이름 정리

# 3. 결과 CSV로 저장
pattern_counts.to_csv('lotto_data_pattern_analysis.csv', index=False)
