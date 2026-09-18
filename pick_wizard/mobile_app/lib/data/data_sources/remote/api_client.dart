import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pick_wizard/core/constants/api_endpoints.dart';
import 'package:pick_wizard/data/auth_service.dart';

/// Dio 클라이언트 Provider
/// 
/// 2026-01-05 15:40:00 EST - 초기 생성
/// 2026-01-18 EST - AI Selection 전용 타임아웃 추가 (60초)
/// 034 EST - JWT Bearer 인터셉터 추가
final dioProvider = Provider<Dio>((ref) {
  final auth = ref.watch(authServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // === 인터셉터 추가 ===
  
  // 0. AI Selection 전용 타임아웃 (2026-01-18 EST)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // generation API는 60초 타임아웃 (AI Selection 대응)
        if (options.path.contains('/generation')) {
          options.connectTimeout = const Duration(seconds: 60);
          options.receiveTimeout = const Duration(seconds: 60);
          options.sendTimeout = const Duration(seconds: 60);
        }
        handler.next(options);
      },
    ),
  );
  
  // 1. Pretty Logger (개발 모드만)
  if (!const bool.fromEnvironment('dart.vm.product')) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }
  
  // 2. 인증 인터셉터 (034 OAuth JWT)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await auth.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 Unauthorized 처리
        if (error.response?.statusCode == 401) {
          // TODO: 토큰 갱신 로직
          // final refreshed = await ref.read(authServiceProvider).refreshToken();
          // if (refreshed) {
          //   return handler.resolve(await _retry(error.requestOptions));
          // }
        }
        
        handler.next(error);
      },
    ),
  );
  
  return dio;
});

/// 에러 처리 유틸리티
class DioErrorHandler {
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '요청 시간이 초과되었습니다';
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '잘못된 요청입니다';
          case 401:
            return '인증이 필요합니다';
          case 402:
            return '코인이 부족합니다';
          case 403:
            return '권한이 없습니다';
          case 404:
            return '요청한 데이터를 찾을 수 없습니다';
          case 500:
            return '서버 오류가 발생했습니다';
          default:
            return '오류가 발생했습니다 ($statusCode)';
        }
        
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다';
        
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요';
        
      default:
        return '알 수 없는 오류가 발생했습니다';
    }
  }
}

