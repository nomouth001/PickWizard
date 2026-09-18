# Phase 3: Flutter 앱 기본 구조 - Part 2
## Hive, Repository, Provider, UI 화면

---

**Phase**: 3 - Flutter Mobile App Foundation (Part 2)  
**예상 기간**: 2-2.5일 (16-20시간)  
**선행 조건**: Phase 3 Part 1 완료 (모델, API 클라이언트)  
**목표**: 로컬 저장소, Repository 패턴, 상태 관리, UI 화면 완성

---

## 📋 Part 2 개요

### 주요 산출물
- [x] Hive 로컬 데이터베이스
- [x] Repository Pattern 구현
- [x] Riverpod Provider (상태 관리)
- [x] UI 화면 (스플래시, 홈, 번호 생성, 결과)
- [x] 공통 위젯

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 3.4 Hive 로컬 저장소 | 4시간 | 4h |
| 3.5 Repository 구현 | 6시간 | 10h |
| 3.6 Riverpod Provider | 6시간 | 16h |
| 3.7 UI 화면 구현 | 4시간 | 20h |

---

## 작업 3.4: Hive 로컬 저장소 (4시간)

### 목표
Hive NoSQL 데이터베이스로 로컬 데이터 저장 및 관리

### Step 3.4.1: Hive Adapter 작성

**파일**: `lib/data/data_sources/local/adapters/generated_numbers_adapter.dart`

```dart
import 'package:hive/hive.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';

/// GeneratedNumbers Hive Adapter
/// 
/// 2026-01-06 EST - 초기 생성
class GeneratedNumbersAdapter extends TypeAdapter<GeneratedNumbers> {
  @override
  final int typeId = 0;  // ⚠️ 주의: typeId는 고유해야 함
  
  @override
  GeneratedNumbers read(BinaryReader reader) {
    return GeneratedNumbers(
      id: reader.readString(),
      algorithmId: reader.readInt(),
      algorithmName: reader.readString(),
      numbers: (reader.readList() as List).map((e) => 
        (e as List).map((n) => n as int).toList()
      ).toList(),
      generatedAt: DateTime.parse(reader.readString()),
      cost: reader.readInt(),
      isSaved: reader.readBool(),
    );
  }
  
  @override
  void write(BinaryWriter writer, GeneratedNumbers obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.algorithmId);
    writer.writeString(obj.algorithmName);
    writer.writeList(obj.numbers);
    writer.writeString(obj.generatedAt.toIso8601String());
    writer.writeInt(obj.cost ?? 0);
    writer.writeBool(obj.isSaved);
  }
}
```

**⚠️ TypeId 관리**:
```dart
// Adapter TypeId 목록 (중복 방지)
// 0: GeneratedNumbers
// 1: LottoDraw (예약)
// 2: UserSettings (예약)
// 3-9: 확장용
```

---

### Step 3.4.2: Hive 데이터베이스 초기화

**파일**: `lib/data/data_sources/local/hive_database.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/data_sources/local/adapters/generated_numbers_adapter.dart';

/// Hive 데이터베이스 매니저
/// 
/// 2026-01-06 EST - 초기 생성
class HiveDatabase {
  // Box 이름 상수
  static const String generatedNumbersBox = 'generated_numbers';
  static const String lottoDrawsBox = 'lotto_draws';
  static const String userSettingsBox = 'user_settings';
  
  /// Hive 초기화
  static Future<void> initialize() async {
    // Hive 초기화 (Flutter 전용)
    await Hive.initFlutter();
    
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
```

---

### Step 3.4.3: 로컬 데이터 소스 구현

**파일**: `lib/data/data_sources/local/local_data_source.dart`

```dart
import 'package:hive/hive.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/data_sources/local/hive_database.dart';

/// 로컬 데이터 소스
/// 
/// 2026-01-06 EST - 초기 생성
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
```

---

### Step 3.4.4: main.dart에 Hive 초기화 추가

**파일**: `lib/main.dart` (수정)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/app.dart';
import 'package:luckyai_645/data/data_sources/local/hive_database.dart';

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
```

### 완료 기준 체크리스트
- [ ] Hive Adapter 작성
- [ ] `HiveDatabase.initialize()` 성공
- [ ] 데이터 저장/조회 테스트 통과
- [ ] 앱 재시작 시 데이터 유지 확인

---

## 작업 3.5: Repository 구현 (6시간)

### 목표
Repository Pattern으로 데이터 소스 추상화

### Step 3.5.1: Failure 클래스 정의

**파일**: `lib/core/errors/failures.dart`

```dart
import 'package:equatable/equatable.dart';

/// 에러 추상 클래스
/// 
/// 2026-01-06 EST - 초기 생성
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure([String message = '서버 오류가 발생했습니다']) : super(message);
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure([String message = '네트워크 연결을 확인해주세요']) : super(message);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure([String message = '로컬 데이터 오류가 발생했습니다']) : super(message);
}

/// 인증 에러
class AuthFailure extends Failure {
  const AuthFailure([String message = '인증이 필요합니다']) : super(message);
}

/// 잔액 부족 에러
class InsufficientCoinsFailure extends Failure {
  const InsufficientCoinsFailure([String message = '코인이 부족합니다']) : super(message);
}

/// 파라미터 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure([String message = '잘못된 입력입니다']) : super(message);
}

/// 알 수 없는 에러
class UnknownFailure extends Failure {
  const UnknownFailure([String message = '알 수 없는 오류가 발생했습니다']) : super(message);
}
```

---

### Step 3.5.2: LottoRepository 구현

**파일**: `lib/data/repositories/lotto_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:luckyai_645/core/errors/failures.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/data/models/algorithm_info.dart';
import 'package:luckyai_645/data/data_sources/remote/lotto_api.dart';
import 'package:luckyai_645/data/data_sources/remote/api_client.dart';
import 'package:luckyai_645/data/data_sources/local/local_data_source.dart';
import 'package:uuid/uuid.dart';

/// 로또 Repository
/// 
/// 2026-01-06 EST - 초기 생성
class LottoRepository {
  final LottoApi _api;
  final LocalDataSource _localDataSource;
  
  LottoRepository({
    required LottoApi api,
    required LocalDataSource localDataSource,
  }) : _api = api,
       _localDataSource = localDataSource;
  
  // === 로또 회차 데이터 ===
  
  /// 최신 회차 조회
  Future<Either<Failure, LottoDraw>> getLatestDraw() async {
    try {
      // 1. 로컬 캐시 확인
      final cached = _localDataSource.getLatestDraw();
      if (cached != null && _isFresh(cached.drawDate)) {
        return Right(cached);
      }
      
      // 2. API 호출
      final draw = await _api.getLatestDraw();
      
      // 3. 로컬 저장
      await _localDataSource.saveLatestDraw(draw);
      
      return Right(draw);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  /// 특정 회차 조회
  Future<Either<Failure, LottoDraw>> getDrawByNumber(int drawNo) async {
    try {
      // 1. 로컬 캐시 확인
      final cached = _localDataSource.getDraw(drawNo);
      if (cached != null) {
        return Right(cached);
      }
      
      // 2. API 호출
      final draw = await _api.getDrawByNumber(drawNo);
      
      // 3. 로컬 저장
      await _localDataSource.saveDraw(draw);
      
      return Right(draw);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  /// 범위 조회
  Future<Either<Failure, List<LottoDraw>>> getDrawRange(
    int start,
    int end,
  ) async {
    try {
      final draws = await _api.getDrawRange(start, end);
      
      // 로컬 저장 (비동기)
      for (final draw in draws) {
        _localDataSource.saveDraw(draw);
      }
      
      return Right(draws);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  // === 알고리즘 ===
  
  /// 알고리즘 목록 조회
  Future<Either<Failure, List<AlgorithmInfo>>> getAlgorithms() async {
    try {
      final algorithms = await _api.getAlgorithms();
      return Right(algorithms);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  /// 알고리즘 상세 조회
  Future<Either<Failure, AlgorithmInfo>> getAlgorithmById(int id) async {
    try {
      final algorithm = await _api.getAlgorithmById(id);
      return Right(algorithm);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  // === 번호 생성 ===
  
  /// 번호 생성
  Future<Either<Failure, GeneratedNumbers>> generateNumbers(
    GenerateRequest request,
  ) async {
    try {
      // API 호출
      final response = await _api.generateNumbers(request);
      
      // GeneratedNumbers 객체 생성
      final generated = GeneratedNumbers(
        id: const Uuid().v4(),
        algorithmId: response.algorithmId,
        algorithmName: response.algorithmName,
        numbers: response.results.map((r) => r.numbers).toList(),
        generatedAt: response.timestamp,
        cost: response.totalCost,
        isSaved: false,
      );
      
      // 로컬 저장
      await _localDataSource.saveGeneratedNumbers(generated);
      
      return Right(generated);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  // === 로컬 데이터 관리 ===
  
  /// 생성된 번호 전체 조회
  Future<Either<Failure, List<GeneratedNumbers>>> getLocalGeneratedNumbers() async {
    try {
      final numbers = _localDataSource.getAllGeneratedNumbers();
      return Right(numbers);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  /// 생성된 번호 삭제
  Future<Either<Failure, void>> deleteGeneratedNumbers(String id) async {
    try {
      await _localDataSource.deleteGeneratedNumbers(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  // === 유틸리티 ===
  
  /// 캐시 신선도 확인 (1시간)
  bool _isFresh(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    return diff.inHours < 1;
  }
  
  /// Dio 에러 처리
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('요청 시간이 초과되었습니다');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 401:
            return const AuthFailure();
          case 402:
            return const InsufficientCoinsFailure();
          case 400:
            return ValidationFailure(
              error.response?.data['detail'] ?? '잘못된 요청입니다'
            );
          case 500:
            return const ServerFailure();
          default:
            return ServerFailure('서버 오류 ($statusCode)');
        }
        
      case DioExceptionType.connectionError:
        return const NetworkFailure();
        
      default:
        return UnknownFailure(error.message ?? '알 수 없는 오류');
    }
  }
}
```

---

### Step 3.5.3: Repository Provider 정의

**파일**: `lib/data/repositories/repository_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/data/repositories/lotto_repository.dart';
import 'package:luckyai_645/data/data_sources/remote/api_providers.dart';
import 'package:luckyai_645/data/data_sources/local/local_data_source.dart';

/// LocalDataSource Provider
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
```

### 완료 기준 체크리스트
- [ ] `Failure` 클래스 정의
- [ ] `LottoRepository` 구현
- [ ] Either 패턴으로 에러 처리
- [ ] Repository Provider 정의
- [ ] API 호출 테스트 성공

---

## 작업 3.6: Riverpod Provider (6시간)

### 목표
Riverpod으로 상태 관리 및 비즈니스 로직 구현

### Step 3.6.1: Lotto Provider

**파일**: `lib/presentation/providers/lotto_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/data/models/algorithm_info.dart';
import 'package:luckyai_645/data/repositories/repository_providers.dart';
import 'package:luckyai_645/data/data_sources/remote/lotto_api.dart';

/// 최신 회차 Provider
/// 
/// 2026-01-06 EST - 초기 생성
final latestDrawProvider = FutureProvider<LottoDraw?>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getLatestDraw();
  
  return result.fold(
    (failure) {
      print('최신 회차 조회 실패: ${failure.message}');
      return null;
    },
    (draw) => draw,
  );
});

/// 알고리즘 목록 Provider
final algorithmsProvider = FutureProvider<List<AlgorithmInfo>>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getAlgorithms();
  
  return result.fold(
    (failure) {
      print('알고리즘 목록 조회 실패: ${failure.message}');
      return [];
    },
    (algorithms) => algorithms,
  );
});

/// 생성된 번호 목록 Provider
final generatedNumbersProvider = FutureProvider<List<GeneratedNumbers>>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getLocalGeneratedNumbers();
  
  return result.fold(
    (failure) => [],
    (numbers) => numbers,
  );
});

/// 번호 생성 State Provider
final generateStateProvider = StateNotifierProvider<GenerateNotifier, AsyncValue<GeneratedNumbers?>>((ref) {
  return GenerateNotifier(ref);
});

/// 번호 생성 State Notifier
class GenerateNotifier extends StateNotifier<AsyncValue<GeneratedNumbers?>> {
  final Ref ref;
  
  GenerateNotifier(this.ref) : super(const AsyncValue.data(null));
  
  /// 번호 생성
  Future<void> generate(GenerateRequest request) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(lottoRepositoryProvider);
    final result = await repository.generateNumbers(request);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (generated) => AsyncValue.data(generated),
    );
    
    // 생성 성공 시 목록 갱신
    if (state.hasValue) {
      ref.invalidate(generatedNumbersProvider);
    }
  }
  
  /// 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 선택된 알고리즘 Provider
final selectedAlgorithmProvider = StateProvider<AlgorithmInfo?>((ref) => null);

/// 제외 번호 Provider
final excludeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 포함 번호 Provider
final includeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 생성 세트 수 Provider
final numberOfSetsProvider = StateProvider<int>((ref) => 5);
```

---

### Step 3.6.2: 앱 초기화 Provider

**파일**: `lib/presentation/providers/app_initialization_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 초기화 상태
enum AppInitStatus {
  initializing,
  initialized,
  error,
}

/// 앱 초기화 Provider
/// 
/// 2026-01-06 EST - 초기 생성
final appInitializationProvider = FutureProvider<AppInitStatus>((ref) async {
  try {
    // 1. 설정 로드
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2. 로컬 데이터 확인
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 3. 최신 회차 동기화
    ref.read(latestDrawProvider);
    
    return AppInitStatus.initialized;
  } catch (e) {
    print('앱 초기화 오류: $e');
    return AppInitStatus.error;
  }
});
```

### 완료 기준 체크리스트
- [ ] `latestDrawProvider` 동작 확인
- [ ] `algorithmsProvider` 동작 확인
- [ ] `GenerateNotifier` 번호 생성 테스트
- [ ] 상태 변경 시 UI 반응 확인

---

## 작업 3.7: UI 화면 구현 (4시간)

### 목표
스플래시, 홈, 번호 생성 화면 및 공통 위젯 구현

### Step 3.7.1: 스플래시 화면

**파일**: `lib/presentation/screens/splash/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';
import 'package:luckyai_645/presentation/providers/app_initialization_provider.dart';
import 'package:luckyai_645/presentation/screens/home/home_screen.dart';

/// 스플래시 화면
/// 
/// 2026-01-06 EST - 초기 생성
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);
    
    // 초기화 완료 시 홈으로 이동
    initState.whenData((status) {
      if (status == AppInitStatus.initialized) {
        Future.microtask(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        });
      }
    });
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              const Icon(
                Icons.stars,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              
              // 앱 이름
              const Text(
                'LuckyAI 645',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'AI 기반 로또 번호 생성',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              
              // 로딩 인디케이터
              initState.when(
                data: (status) {
                  if (status == AppInitStatus.error) {
                    return const Text(
                      '초기화 오류',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                },
                loading: () => const CircularProgressIndicator(
                  color: Colors.white,
                ),
                error: (_, __) => const Text(
                  '오류 발생',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Step 3.7.2: 홈 화면

**파일**: `lib/presentation/screens/home/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';
import 'package:luckyai_645/core/constants/app_strings.dart';
import 'package:luckyai_645/presentation/providers/lotto_provider.dart';
import 'package:luckyai_645/presentation/widgets/lotto_ball.dart';
import 'package:luckyai_645/presentation/screens/generate/generate_screen.dart';

/// 홈 화면
/// 
/// 2026-01-06 EST - 초기 생성
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDrawAsync = ref.watch(latestDrawProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          // 코인 잔액 (추후 구현)
          IconButton(
            icon: const Icon(Icons.monetization_on),
            onPressed: () {
              // TODO: 코인 스토어 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestDrawProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 최신 당첨번호 카드
            _buildLatestDrawCard(context, latestDrawAsync),
            
            const SizedBox(height: 24),
            
            // 번호 생성 버튼
            _buildGenerateButton(context),
            
            const SizedBox(height: 16),
            
            // 내 번호 버튼
            _buildMyNumbersButton(context),
            
            const SizedBox(height: 16),
            
            // 통계 버튼
            _buildStatisticsButton(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLatestDrawCard(BuildContext context, AsyncValue latestDrawAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.latestDrawTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // TODO: 당첨 상세 보기
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            latestDrawAsync.when(
              data: (draw) {
                if (draw == null) {
                  return const Text('데이터를 불러올 수 없습니다');
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draw.drawTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      draw.drawDateString,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // 당첨번호
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...draw.numbers.map((num) => LottoBall(number: num)),
                        const SizedBox(width: 8),
                        const Icon(Icons.add, size: 16),
                        const SizedBox(width: 8),
                        LottoBall(number: draw.bonus, isBonus: true),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Text('오류: $error'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGenerateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GenerateScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 28),
          const SizedBox(width: 12),
          Text(
            AppStrings.generateNumbersButton,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMyNumbersButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: 내 번호 화면 이동
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(AppStrings.myNumbersButton),
    );
  }
  
  Widget _buildStatisticsButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: 통계 화면 이동
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(AppStrings.statisticsButton),
    );
  }
}
```

---

### Step 3.7.3: 번호 생성 화면

**파일**: `lib/presentation/screens/generate/generate_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';
import 'package:luckyai_645/core/constants/app_strings.dart';
import 'package:luckyai_645/presentation/providers/lotto_provider.dart';
import 'package:luckyai_645/presentation/screens/generate/result_screen.dart';
import 'package:luckyai_645/data/data_sources/remote/lotto_api.dart';

/// 번호 생성 화면
/// 
/// 2026-01-06 EST - 초기 생성
class GenerateScreen extends ConsumerWidget {
  const GenerateScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final algorithmsAsync = ref.watch(algorithmsProvider);
    final selectedAlgorithm = ref.watch(selectedAlgorithmProvider);
    final numberOfSets = ref.watch(numberOfSetsProvider);
    final generateState = ref.watch(generateStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectAlgorithm),
      ),
      body: algorithmsAsync.when(
        data: (algorithms) {
          if (algorithms.isEmpty) {
            return const Center(child: Text('알고리즘을 불러올 수 없습니다'));
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 알고리즘 선택
              _buildAlgorithmSelector(context, ref, algorithms, selectedAlgorithm),
              
              const SizedBox(height: 24),
              
              // 생성 개수
              _buildNumberOfSets(context, ref, numberOfSets),
              
              const SizedBox(height: 24),
              
              // 제외/포함 번호 (TODO: Phase 4에서 구현)
              
              const SizedBox(height: 32),
              
              // 생성 버튼
              _buildGenerateButton(context, ref, selectedAlgorithm, numberOfSets, generateState),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('오류: $error')),
      ),
    );
  }
  
  Widget _buildAlgorithmSelector(
    BuildContext context,
    WidgetRef ref,
    List algorithms,
    selectedAlgorithm,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '알고리즘 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            ...algorithms.map((algo) {
              final isSelected = selectedAlgorithm?.id == algo.id;
              return RadioListTile(
                title: Text(algo.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(algo.description),
                    const SizedBox(height: 4),
                    Text(
                      algo.costString,
                      style: TextStyle(
                        color: algo.isFree ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: algo.id,
                groupValue: selectedAlgorithm?.id,
                onChanged: (value) {
                  ref.read(selectedAlgorithmProvider.notifier).state = algo;
                },
                selected: isSelected,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNumberOfSets(BuildContext context, WidgetRef ref, int numberOfSets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '생성 개수',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$numberOfSets개',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: numberOfSets.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$numberOfSets개',
              onChanged: (value) {
                ref.read(numberOfSetsProvider.notifier).state = value.toInt();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGenerateButton(
    BuildContext context,
    WidgetRef ref,
    selectedAlgorithm,
    int numberOfSets,
    AsyncValue generateState,
  ) {
    final isLoading = generateState.isLoading;
    
    return ElevatedButton(
      onPressed: (selectedAlgorithm == null || isLoading)
          ? null
          : () async {
              // 번호 생성
              final request = GenerateRequest(
                algorithmId: selectedAlgorithm.id,
                nSets: numberOfSets,
              );
              
              await ref.read(generateStateProvider.notifier).generate(request);
              
              // 결과 화면으로 이동
              final state = ref.read(generateStateProvider);
              state.whenData((generated) {
                if (generated != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(generated: generated),
                    ),
                  );
                }
              });
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const Text(
              AppStrings.generateButton,
              style: TextStyle(fontSize: 18),
            ),
    );
  }
}
```

---

### Step 3.7.4: 결과 화면

**파일**: `lib/presentation/screens/generate/result_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:luckyai_645/core/constants/app_strings.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/presentation/widgets/number_card.dart';

/// 번호 생성 결과 화면
/// 
/// 2026-01-06 EST - 초기 생성
class ResultScreen extends StatelessWidget {
  final GeneratedNumbers generated;
  
  const ResultScreen({
    super.key,
    required this.generated,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('생성 결과'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 공유 기능
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 알고리즘 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    generated.algorithmName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${generated.setCount}개 생성 완료',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 생성된 번호 세트들
          ...generated.numbers.asMap().entries.map((entry) {
            final index = entry.key;
            final numbers = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NumberCard(
                numbers: numbers,
                setNumber: index + 1,
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // 저장 버튼
          ElevatedButton(
            onPressed: () {
              // TODO: 내 번호로 저장
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.successSaved)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('내 번호로 저장'),
          ),
        ],
      ),
    );
  }
}
```

---

### Step 3.7.5: 공통 위젯 - 로또 공

**파일**: `lib/presentation/widgets/lotto_ball.dart`

```dart
import 'package:flutter/material.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';

/// 로또 공 위젯
/// 
/// 2026-01-06 EST - 초기 생성
class LottoBall extends StatelessWidget {
  final int number;
  final bool isBonus;
  final double size;
  
  const LottoBall({
    super.key,
    required this.number,
    this.isBonus = false,
    this.size = 48,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = AppColors.getBallColor(number, isBonus: isBonus);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

---

### Step 3.7.6: 공통 위젯 - 번호 카드

**파일**: `lib/presentation/widgets/number_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:luckyai_645/presentation/widgets/lotto_ball.dart';

/// 번호 세트 카드 위젯
/// 
/// 2026-01-06 EST - 초기 생성
class NumberCard extends StatelessWidget {
  final List<int> numbers;
  final int setNumber;
  final VoidCallback? onTap;
  
  const NumberCard({
    super.key,
    required this.numbers,
    required this.setNumber,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '세트 $setNumber',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: numbers.map((num) => 
                  LottoBall(number: num, size: 44)
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 완료 기준 체크리스트
- [ ] 스플래시 화면 표시 및 홈으로 이동
- [ ] 홈 화면에서 최신 회차 표시
- [ ] 번호 생성 화면에서 알고리즘 선택
- [ ] 번호 생성 성공 및 결과 화면 표시
- [ ] 로또 공, 번호 카드 위젯 정상 동작

---

## Phase 3 Part 2 최종 통합 테스트

### 테스트 시나리오

1. **앱 실행**
   - [ ] 스플래시 화면 표시 (2-3초)
   - [ ] 홈 화면으로 자동 이동

2. **홈 화면**
   - [ ] 최신 회차 표시 (번호, 날짜)
   - [ ] 새로고침 (Pull to Refresh) 동작

3. **번호 생성**
   - [ ] 알고리즘 선택 가능
   - [ ] 생성 개수 슬라이더 동작
   - [ ] 번호 생성 버튼 클릭
   - [ ] 로딩 인디케이터 표시
   - [ ] 결과 화면으로 이동

4. **결과 화면**
   - [ ] 생성된 번호 세트 표시
   - [ ] 각 세트 번호 정렬 확인
   - [ ] 로또 공 색상 올바름

5. **데이터 영속성**
   - [ ] 앱 종료 후 재실행
   - [ ] 로컬 데이터 유지 확인

---

## 문제 해결 (Troubleshooting)

### Hive 초기화 오류
```
Error: Bad state: Cannot open box while another box is being initialized
```
**해결책**: `main.dart`에서 순차적으로 Box 열기

### Provider not found 오류
```
Error: Could not find the correct Provider
```
**해결책**: `ProviderScope`가 앱 최상위에 있는지 확인

### API 호출 오류
```
DioException: Connection refused
```
**해결책**: 
1. 백엔드 서버 실행 확인
2. `api_endpoints.dart`에서 URL 확인
3. Android 에뮬레이터는 `10.0.2.2:8000` 사용

---

## 다음 단계

Phase 3 완료 후:
- [ ] 전체 플로우 테스트 (스플래시 → 홈 → 생성 → 결과)
- [ ] 에러 처리 확인 (네트워크 오류, 서버 오류)
- [ ] Phase 4로 이동 (사용자 인증, 코인 시스템)

---

---

## 🧪 Phase 3 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `mobile_app/test/phase3_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/models/generate_request.dart';

void main() {
  group('Phase 3 모델 테스트', () {
    test('LottoDraw fromJson', () {
      final json = {
        'draw_no': 1,
        'draw_date': '2024-01-01',
        'numbers': [1, 2, 3, 4, 5, 6],
        'bonus': 7,
      };
      
      final draw = LottoDraw.fromJson(json);
      
      expect(draw.drawNo, 1);
      expect(draw.numbers.length, 6);
      expect(draw.bonus, 7);
    });
    
    test('GenerateRequest toJson', () {
      final request = GenerateRequest(
        algorithmId: 1,
        nSets: 5,
      );
      
      final json = request.toJson();
      
      expect(json['algorithm_id'], 1);
      expect(json['n_sets'], 5);
    });
  });
}
```

**실행**:
```bash
cd mobile_app
flutter test
```

---

### 자동 테스트 체크리스트

- [ ] ✅ 모델 직렬화/역직렬화
- [ ] ✅ Freezed 코드 생성 완료
- [ ] ✅ 단위 테스트 통과

---

### 수동 테스트 체크리스트

#### 1. Flutter 앱 빌드 및 실행
```bash
cd mobile_app
flutter run
```
**확인 사항**:
- [ ] 빌드 성공
- [ ] 스플래시 화면 표시
- [ ] 홈 화면 전환

#### 2. 홈 화면 확인
**확인 사항**:
- [ ] 최신 회차 표시
- [ ] 로딩 인디케이터 동작
- [ ] "번호 생성" 버튼 존재

#### 3. 번호 생성 화면 확인
**확인 사항**:
- [ ] 알고리즘 목록 표시
- [ ] 알고리즘 선택 가능
- [ ] 생성 옵션 (세트 수) 조정 가능
- [ ] "생성하기" 버튼 클릭 → 번호 생성
- [ ] 생성된 번호 6개씩 표시

#### 4. 히스토리 화면 확인
**확인 사항**:
- [ ] 저장된 번호 목록 표시
- [ ] Hive 로컬 DB 저장 동작
- [ ] 번호 상세 보기 가능

#### 5. API 연동 테스트
**backend 서버 실행 후**:
```bash
cd backend
uvicorn app.main:app --host 0.0.0.0
```
**앱에서 확인**:
- [ ] 최신 회차 데이터 로드
- [ ] 알고리즘 목록 로드
- [ ] 번호 생성 요청 성공
- [ ] 네트워크 오류 처리 (서버 중지 시)

---

**Phase 3 완료**

다음: [Phase 4 Part 1 - 인증 시스템](013_Phase_4_Business_Logic_Part1.md)

