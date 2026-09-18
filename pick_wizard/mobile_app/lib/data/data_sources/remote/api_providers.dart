import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/data/data_sources/remote/api_client.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';

/// Lotto API Provider
/// 
/// 2026-01-05 15:40:00 EST - 초기 생성
final lottoApiProvider = Provider<LottoApi>((ref) {
  final dio = ref.watch(dioProvider);
  return LottoApi(dio);
});

