/// API 엔드포인트 상수
/// 
/// 2026-01-05 15:30:00 EST - 초기 생성
class ApiEndpoints {
  ApiEndpoints._();
  
  // === 환경별 기본 URL ===
  static const String _devBaseUrl = 'http://localhost:8000';
  static const String _prodBaseUrl = 'https://api.luckyai645.com';
  
  /// 현재 환경에 맞는 Base URL 반환
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // === 인증 API ===
  static const String guestLogin = '/api/auth/guest';
  static const String login = '/api/auth/login';  // 034 OAuth
  static const String socialLogin = '/api/auth/social';
  static const String logout = '/api/auth/logout';

  // === 034 사용자/코인 (JWT) ===
  static const String me = '/api/users/me';
  static const String meCoins = '/api/users/me/coins';
  static const String meCoinTransactions = '/api/users/me/coin-transactions';
  
  // === 로또 데이터 API ===
  static const String latestDraw = '/api/draws/latest';
  static const String drawByNumber = '/api/draws/{draw_no}';
  static const String drawRange = '/api/draws/range';
  
  // === 번호 생성 API ===
  // 2026-01-08 06:00:00 EST - /api/generate → /api/generation 수정 (백엔드 엔드포인트와 일치)
  static const String generate = '/api/generation';
  static const String algorithms = '/api/algorithms';
  static const String algorithmById = '/api/algorithms/{id}';
  
  // === 코인 API ===
  static const String coinBalance = '/api/coins/balance';
  static const String dailyLogin = '/api/coins/daily-login';
  static const String watchAd = '/api/coins/watch-ad';
  static const String coinHistory = '/api/coins/history';
  
  // === 내 번호 API ===
  static const String myNumbers = '/api/my-numbers';
  static const String saveNumber = '/api/my-numbers/save';
  static const String checkWinning = '/api/my-numbers/check';
  static const String myNumbersHistory = '/api/my-numbers/history';
  
  // === 결제 API ===
  static const String purchaseCoins = '/api/payment/purchase';
  static const String verifyPurchase = '/api/payment/verify';
  
  // === 통계 API ===
  static const String userStats = '/api/stats/user';
  static const String algorithmStats = '/api/stats/algorithms';
}

