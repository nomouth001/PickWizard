from ranking import judge_rank

def evaluate_predictions(predicted_sets, winning_numbers, bonus_number, algorithm_id, round_no):
    """
    여러 세트의 번호와 당첨번호 비교하여 평가 결과 리스트 반환
    """
    results = []
    for idx, numbers in enumerate(predicted_sets, start=1):
        rank = judge_rank(numbers, winning_numbers, bonus_number)
        results.append({
            "알고리즘": algorithm_id,
            "세트번호": idx,
            "회차": round_no,
            "번호세트": numbers,
            "일치개수": len(set(numbers) & set(winning_numbers)),
            "등수": rank
        })
    return results
