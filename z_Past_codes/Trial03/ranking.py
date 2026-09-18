def judge_rank(predicted_numbers, winning_numbers, bonus_number):
    """
    예측 번호와 당첨 번호, 보너스 번호를 비교하여 등수와 일치 번호 리스트를 반환합니다.
    일치 번호는 int 타입으로 변환하여 반환합니다.
    """
    matched = set(int(x) for x in (set(predicted_numbers) & set(winning_numbers)))
    match_count = len(matched)
    has_bonus = bonus_number in predicted_numbers

    if match_count == 6:
        return 1, matched
    elif match_count == 5 and has_bonus:
        return 2, matched
    elif match_count == 5:
        return 3, matched
    elif match_count == 4:
        return 4, matched
    elif match_count == 3:
        return 5, matched
    else:
        return 0, matched
