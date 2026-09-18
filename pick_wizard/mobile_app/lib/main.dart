import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/app.dart';
import 'package:pick_wizard/data/data_sources/local/hive_database.dart';

/// 앱 진입점
/// 
/// 2026-01-05 16:00:00 EST - 초기 생성
void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 초기화
  await HiveDatabase.initialize();
  
  // 앱 실행
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
