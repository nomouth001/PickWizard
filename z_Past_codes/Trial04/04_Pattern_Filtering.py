import pandas as pd

# 1. 파일 경로
lotto_data_path = 'lotto_data.csv'
pattern_analysis_path = 'lotto_data_pattern_analysis.csv'
patterned_data_path = 'lotto_data_pattern.csv'  # 미리 생성된 패턴 포함 데이터 필요

# 2. CSV 파일 읽기
lotto_df = pd.read_csv(lotto_data_path)
pattern_df = pd.read_csv(pattern_analysis_path)
patterned_df = pd.read_csv(patterned_data_path)

# 3. 상위 10개 패턴 가져오기
top10_patterns = pattern_df.head(10)['pattern'].tolist()

# 4. 해당 패턴에 해당하는 회차만 필터링
top10_matches = patterned_df[patterned_df['pattern'].isin(top10_patterns)].copy()

# 5. 패턴 순위대로 정렬
top10_matches['pattern_rank'] = top10_matches['pattern'].apply(lambda p: top10_patterns.index(p))
top10_matches_sorted = top10_matches.sort_values('pattern_rank')

# 6. pattern lookup dict 생성 (round -> pattern)
pattern_lookup = top10_matches_sorted[['round', 'pattern']].set_index('round')

# 7. lotto_data에서 회차 일치하는 것 추출 + pattern 추가
final_df = lotto_df[lotto_df['회차'].isin(pattern_lookup.index)].copy()
final_df['pattern'] = final_df['회차'].map(pattern_lookup['pattern'])

# 8. 패턴 순서대로 정렬
final_df = final_df.set_index('회차').loc[top10_matches_sorted['round']].reset_index()

# 9. 결과 저장
final_df.to_csv('lotto_data_Top10pattern.csv', index=False)
