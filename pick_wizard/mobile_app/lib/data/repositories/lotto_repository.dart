import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:pick_wizard/core/errors/failures.dart';
import 'package:pick_wizard/data/models/lotto_draw.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/data/models/algorithm_info.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';
import 'package:pick_wizard/data/data_sources/local/local_data_source.dart';
import 'package:uuid/uuid.dart';

/// 로또 Repository
/// 
/// 2026-01-05 16:15:00 EST - 초기 생성
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
  /// 2026-01-08 05:57:00 EST - AlgorithmListResponse에서 algorithms 추출
  Future<Either<Failure, List<AlgorithmInfo>>> getAlgorithms() async {
    try {
      final response = await _api.getAlgorithms();
      return Right(response.algorithms);  // .algorithms 리스트만 반환
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
      // 2026-01-08 06:36:00 EST - 새 모델 구조에 맞게 수정
      final generated = GeneratedNumbers(
        algorithmId: response.algorithmId,
        algorithmName: response.algorithmName,
        results: response.results.map((r) => NumberSetResult(
          setNo: r.setNo,
          numbers: r.numbers,
        )).toList(),
        timestamp: response.timestamp,
        cost: response.totalCost,
        isSaved: false,
        id: const Uuid().v4(),
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

