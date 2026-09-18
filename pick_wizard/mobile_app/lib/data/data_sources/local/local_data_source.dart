import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/data/models/lotto_draw.dart';
import 'package:pick_wizard/data/data_sources/local/hive_database.dart';

/// 로컬 데이터 소스
/// 
/// 2026-01-05 16:00:00 EST - 초기 생성
class LocalDataSource {
  // === 생성된 번호 ===
  
  /// 생성된 번호 저장
  Future<void> saveGeneratedNumbers(GeneratedNumbers numbers) async {
    final box = HiveDatabase.getGeneratedNumbersBox();
    await box.put(numbers.id, numbers);
  }
  
  /// 생성된 번호 조회 (ID로)
  GeneratedNumbers? getGeneratedNumbersById(String id) {
    final box = HiveDatabase.getGeneratedNumbersBox();
    return box.get(id);
  }
  
  /// 생성된 번호 전체 조회
  List<GeneratedNumbers> getAllGeneratedNumbers() {
    final box = HiveDatabase.getGeneratedNumbersBox();
    return box.values.toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt)); // 최신순
  }
  
  /// 생성된 번호 삭제
  Future<void> deleteGeneratedNumbers(String id) async {
    final box = HiveDatabase.getGeneratedNumbersBox();
    await box.delete(id);
  }
  
  /// 생성된 번호 전체 삭제
  Future<void> clearGeneratedNumbers() async {
    final box = HiveDatabase.getGeneratedNumbersBox();
    await box.clear();
  }
  
  // === 로또 회차 (캐시) ===
  
  /// 최신 회차 저장
  Future<void> saveLatestDraw(LottoDraw draw) async {
    final box = HiveDatabase.getLottoDrawsBox();
    await box.put('latest', draw.toJson());
  }
  
  /// 최신 회차 조회
  LottoDraw? getLatestDraw() {
    final box = HiveDatabase.getLottoDrawsBox();
    final json = box.get('latest');
    if (json == null) return null;
    return LottoDraw.fromJson(Map<String, dynamic>.from(json));
  }
  
  /// 특정 회차 저장
  Future<void> saveDraw(LottoDraw draw) async {
    final box = HiveDatabase.getLottoDrawsBox();
    await box.put('draw_${draw.drawNo}', draw.toJson());
  }
  
  /// 특정 회차 조회
  LottoDraw? getDraw(int drawNo) {
    final box = HiveDatabase.getLottoDrawsBox();
    final json = box.get('draw_$drawNo');
    if (json == null) return null;
    return LottoDraw.fromJson(Map<String, dynamic>.from(json));
  }
  
  // === 사용자 설정 ===
  
  /// 설정 저장
  Future<void> saveSetting(String key, dynamic value) async {
    final box = HiveDatabase.getUserSettingsBox();
    await box.put(key, {'value': value});
  }
  
  /// 설정 조회
  T? getSetting<T>(String key) {
    final box = HiveDatabase.getUserSettingsBox();
    final data = box.get(key);
    if (data == null) return null;
    return data['value'] as T?;
  }
  
  /// 설정 삭제
  Future<void> deleteSetting(String key) async {
    final box = HiveDatabase.getUserSettingsBox();
    await box.delete(key);
  }
}

