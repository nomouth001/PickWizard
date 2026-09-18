import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pick_wizard/core/models/game_type.dart';

part 'generated_numbers.freezed.dart';
part 'generated_numbers.g.dart';

/// 생성된 번호 세트 모델
/// 
/// 2026-01-05 15:35:00 EST - 초기 생성
/// 2026-01-07 16:00:00 EST - Hive 애노테이션 제거 (별도 Adapter 사용)
/// 2026-01-08 06:32:00 EST - 백엔드 API 응답 구조에 맞게 수정 (results, timestamp)
@freezed
class GeneratedNumbers with _$GeneratedNumbers {
  const factory GeneratedNumbers({
    @Default(GameTypeId.lotto645) GameTypeId gameTypeId,
    @Default(<int>[]) List<int> bonusBalls,
    @JsonKey(name: 'algorithm_id') required int algorithmId,
    @JsonKey(name: 'algorithm_name') required String algorithmName,
    @JsonKey(name: 'results') required List<NumberSetResult> results,
    @JsonKey(name: 'timestamp') required DateTime timestamp,
    @JsonKey(name: 'cost') required int cost,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default(false) bool isSaved,
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,  // 로컬 저장 시 UUID 생성
  }) = _GeneratedNumbers;
  
  factory GeneratedNumbers.fromJson(Map<String, dynamic> json) => 
      _$GeneratedNumbersFromJson(json);
  
  const GeneratedNumbers._();
  
  /// 세트 개수
  int get setCount => results.length;
  
  /// 번호 리스트 (호환성)
  List<List<int>> get numbers => results.map((r) => r.numbers).toList();
  
  /// 첫 번째 세트
  List<int> get firstSet => results.isNotEmpty ? results[0].numbers : [];
  
  /// 생성 시간 (호환성)
  DateTime get generatedAt => timestamp;
}

/// 번호 세트 결과 (백엔드 NumberSet)
/// 
/// 2026-01-08 06:32:00 EST - 초기 생성
@freezed
class NumberSetResult with _$NumberSetResult {
  const factory NumberSetResult({
    @JsonKey(name: 'set_no') required int setNo,
    @JsonKey(name: 'numbers') required List<int> numbers,
  }) = _NumberSetResult;
  
  factory NumberSetResult.fromJson(Map<String, dynamic> json) => 
      _$NumberSetResultFromJson(json);
}

