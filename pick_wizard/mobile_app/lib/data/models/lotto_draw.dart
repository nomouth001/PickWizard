import 'package:freezed_annotation/freezed_annotation.dart';

part 'lotto_draw.freezed.dart';
part 'lotto_draw.g.dart';

/// 로또 회차 모델
/// 
/// 2026-01-05 15:35:00 EST - 초기 생성
@freezed
class LottoDraw with _$LottoDraw {
  const factory LottoDraw({
    @JsonKey(name: 'draw_no') required int drawNo,
    @JsonKey(name: 'draw_date') required DateTime drawDate,
    @JsonKey(name: 'numbers') required List<int> numbers,
    @JsonKey(name: 'bonus') required int bonus,
    @JsonKey(name: 'first_prize_amount') int? firstPrizeAmount,
    @JsonKey(name: 'first_winner_count') int? firstWinnerCount,
  }) = _LottoDraw;
  
  factory LottoDraw.fromJson(Map<String, dynamic> json) => 
      _$LottoDrawFromJson(json);
  
  /// 생성자 본문 (추가 메서드용)
  const LottoDraw._();
  
  /// 번호 문자열 반환 (예: "1, 7, 14, 21, 28, 35")
  String get numbersString => numbers.join(', ');
  
  /// 전체 번호 (번호 + 보너스)
  List<int> get allNumbers => [...numbers, bonus];
  
  /// 회차 표시 문자열 (예: "1169회")
  String get drawTitle => '$drawNo회';
  
  /// 추첨일 문자열 (예: "2024년 12월 30일")
  String get drawDateString {
    return '${drawDate.year}년 ${drawDate.month}월 ${drawDate.day}일';
  }
}

