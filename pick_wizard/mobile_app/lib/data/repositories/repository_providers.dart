import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/data/repositories/lotto_repository.dart';
import 'package:pick_wizard/data/data_sources/remote/api_providers.dart';
import 'package:pick_wizard/data/data_sources/local/local_data_source.dart';

/// LocalDataSource Provider
/// 
/// 2026-01-05 16:15:00 EST - 초기 생성
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

/// LottoRepository Provider
final lottoRepositoryProvider = Provider<LottoRepository>((ref) {
  final api = ref.watch(lottoApiProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  
  return LottoRepository(
    api: api,
    localDataSource: localDataSource,
  );
});

