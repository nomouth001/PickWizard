import 'package:hive_flutter/hive_flutter.dart';
import 'package:pick_wizard/data/data_sources/local/adapters/generated_numbers_adapter.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hive 데이터베이스 매니저
/// 
/// 2026-01-05 16:00:00 EST - 초기 생성
class HiveDatabase {
  // Box 이름 상수
  static const String generatedNumbersBox = 'generated_numbers';
  static const String lottoDrawsBox = 'lotto_draws';
  static const String userSettingsBox = 'user_settings';
  static const int dbSchemaVersion = 2;
  static const String _schemaVersionKey = 'db_schema_version';
  static const String _dbResetDialogFlagKey = 'show_db_reset_dialog';
  
  /// Hive 초기화
  static Future<void> initialize() async {
    // Hive 초기화 (Flutter 전용)
    await Hive.initFlutter();

    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    if (savedVersion < dbSchemaVersion) {
      // 기존 박스 데이터 삭제 후 버전 업데이트
      // (박스가 아직 열리지 않은 상태이므로 Hive.deleteBoxFromDisk 사용)
      await Hive.deleteBoxFromDisk(generatedNumbersBox);
      await prefs.setInt(_schemaVersionKey, dbSchemaVersion);
      // 마이그레이션 플래그 저장 (앱에서 다이얼로그 표시용)
      await prefs.setBool(_dbResetDialogFlagKey, true);
    }
    
    // Adapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GeneratedNumbersAdapter());
    }
    
    // Box 열기
    await Hive.openBox<GeneratedNumbers>(generatedNumbersBox);
    await Hive.openBox<Map>(lottoDrawsBox);
    await Hive.openBox<Map>(userSettingsBox);
    
    print('✅ Hive 초기화 완료');
  }
  
  /// 모든 Box 닫기
  static Future<void> close() async {
    await Hive.close();
  }
  
  /// Box 가져오기
  static Box<GeneratedNumbers> getGeneratedNumbersBox() {
    return Hive.box<GeneratedNumbers>(generatedNumbersBox);
  }
  
  static Box<Map> getLottoDrawsBox() {
    return Hive.box<Map>(lottoDrawsBox);
  }
  
  static Box<Map> getUserSettingsBox() {
    return Hive.box<Map>(userSettingsBox);
  }
  
  /// 데이터 삭제 (디버그용)
  static Future<void> clearAll() async {
    await getGeneratedNumbersBox().clear();
    await getLottoDrawsBox().clear();
    await getUserSettingsBox().clear();
    print('🗑️ Hive 데이터 전체 삭제');
  }
}

