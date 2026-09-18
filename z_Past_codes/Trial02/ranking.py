def judge_rank(predicted_numbers, winning_numbers, bonus_number):
    """
    예측 번호와 당첨 번호, 보너스 번호를 비교하여 등수를 반환합니다.
    - predicted_numbers: 예측된 번호 리스트 (6개)
    - winning_numbers: 당첨 번호 리스트 (6개)
    - bonus_number: 보너스 번호 (정수)
    """
    match_count = len(set(predicted_numbers) & set(winning_numbers))
    has_bonus = bonus_number in predicted_numbers

    if match_count == 6:
        return 1
    elif match_count == 5 and has_bonus:
        return 2
    elif match_count == 5:
        return 3
    elif match_count == 4:
        return 4
    elif match_count == 3:
        return 5
    else:
        return 0  # 꽝
