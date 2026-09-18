import 'package:freezed_annotation/freezed_annotation.dart';

part 'algorithm_info.freezed.dart';
part 'algorithm_info.g.dart';

/// 알고리즘 정보 모델
/// 
/// 2026-01-05 15:35:00 EST - 초기 생성
/// 2026-01-18 21:30:00 EST - windowSize 필드 추가 (알고리즘 8용)
@freezed
class AlgorithmInfo with _$AlgorithmInfo {
  const factory AlgorithmInfo({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'cost_per_set') required int costPerSet,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'parameters') Map<String, dynamic>? parameters,
    @JsonKey(name: 'window_size') int? windowSize,  // 2026-01-18 21:30:00 EST - AI Selection용
  }) = _AlgorithmInfo;
  
  factory AlgorithmInfo.fromJson(Map<String, dynamic> json) => 
      _$AlgorithmInfoFromJson(json);
  
  const AlgorithmInfo._();
  
  /// 무료 알고리즘 여부
  bool get isFree => costPerSet == 0;
  
  /// 비용 표시 문자열 (예: "무료", "5코인")
  String get costString => isFree ? '무료' : '$costPerSet코인';
}

/// 알고리즘 목록 응답 모델
/// 
/// 2026-01-08 05:55:00 EST - 초기 생성
@freezed
class AlgorithmListResponse with _$AlgorithmListResponse {
  const factory AlgorithmListResponse({
    @JsonKey(name: 'total') required int total,
    @JsonKey(name: 'algorithms') required List<AlgorithmInfo> algorithms,
  }) = _AlgorithmListResponse;
  
  factory AlgorithmListResponse.fromJson(Map<String, dynamic> json) => 
      _$AlgorithmListResponseFromJson(json);
}

