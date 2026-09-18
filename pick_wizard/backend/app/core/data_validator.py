"""
데이터 무결성 검증기

2026-01-04 EST - 초기 생성
"""

from typing import Dict, List, Any

import pandas as pd
from loguru import logger


class DataValidator:
    """
    로또 데이터 검증 클래스
    
    CSV/DataFrame의 무결성 검증
    """
    
    def validate_dataframe(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        DataFrame 전체 검증
        
        Args:
            df: 검증할 DataFrame
            
        Returns:
            Dict: {
                'valid': bool,
                'errors': List[str],
                'warnings': List[str],
                'fatal': bool
            }
        """
        errors = []
        warnings = []
        fatal = False
        
        # 1. 필수 컬럼 확인
        required_cols = ['draw_no', 'draw_date', 'num1', 'num2', 'num3', 
                        'num4', 'num5', 'num6', 'bonus']
        missing_cols = [col for col in required_cols if col not in df.columns]
        
        if missing_cols:
            errors.append(f"필수 컬럼 누락: {missing_cols}")
            fatal = True
            return {
                'valid': False,
                'errors': errors,
                'warnings': [],
                'fatal': True
            }
        
        # 2. 회차 연속성 확인
        missing_draws = self._check_missing_draws(df)
        if missing_draws:
            warnings.append(f"누락된 회차: {missing_draws[:10]}...총 {len(missing_draws)}개")
        
        # 3. 번호 범위 확인
        invalid_numbers = self._check_number_ranges(df)
        if invalid_numbers:
            errors.append(f"범위 초과 번호 발견: {invalid_numbers[:5]}")
        
        # 4. 중복 회차 확인
        duplicates = self._check_duplicates(df)
        if duplicates:
            errors.append(f"중복 회차: {duplicates}")
        
        # 5. 날짜 형식 확인
        invalid_dates = self._check_date_format(df)
        if invalid_dates:
            warnings.append(f"잘못된 날짜 형식: {len(invalid_dates)}개")
        
        # 6. 번호 정렬 확인
        unsorted = self._check_number_sorting(df)
        if unsorted:
            warnings.append(f"정렬 안된 번호: {len(unsorted)}개 회차")
        
        valid = len(errors) == 0
        
        return {
            'valid': valid,
            'errors': errors,
            'warnings': warnings,
            'fatal': fatal
        }
    
    def _check_missing_draws(self, df: pd.DataFrame) -> List[int]:
        """누락된 회차 확인"""
        draws = sorted(df['draw_no'].tolist())
        if not draws:
            return []
        
        expected = set(range(draws[0], draws[-1] + 1))
        actual = set(draws)
        missing = sorted(expected - actual)
        
        return missing
    
    def _check_number_ranges(self, df: pd.DataFrame) -> List[Dict]:
        """번호 범위 확인 (1~45)"""
        invalid = []
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                num = row[f'num{i}']
                if not (1 <= num <= 45):
                    invalid.append({
                        'draw_no': row['draw_no'],
                        'field': f'num{i}',
                        'value': num
                    })
            
            bonus = row['bonus']
            if not (1 <= bonus <= 45):
                invalid.append({
                    'draw_no': row['draw_no'],
                    'field': 'bonus',
                    'value': bonus
                })
        
        return invalid
    
    def _check_duplicates(self, df: pd.DataFrame) -> List[int]:
        """중복 회차 확인"""
        duplicates = df[df.duplicated(subset=['draw_no'], keep=False)]
        return duplicates['draw_no'].tolist()
    
    def _check_date_format(self, df: pd.DataFrame) -> List[int]:
        """날짜 형식 확인"""
        invalid = []
        
        for idx, row in df.iterrows():
            try:
                pd.to_datetime(row['draw_date'])
            except:
                invalid.append(row['draw_no'])
        
        return invalid
    
    def _check_number_sorting(self, df: pd.DataFrame) -> List[int]:
        """번호 정렬 확인"""
        unsorted = []
        
        for idx, row in df.iterrows():
            numbers = [row[f'num{i}'] for i in range(1, 7)]
            if numbers != sorted(numbers):
                unsorted.append(row['draw_no'])
        
        return unsorted

