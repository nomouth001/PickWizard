import 'package:equatable/equatable.dart';

/// 에러 추상 클래스
/// 
/// 2026-01-05 16:10:00 EST - 초기 생성
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

