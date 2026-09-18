import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:pick_wizard/core/constants/api_endpoints.dart';
import 'package:pick_wizard/data/models/lotto_draw.dart';
import 'package:pick_wizard/data/models/algorithm_info.dart';

part 'lotto_api.g.dart';

/// Lotto API 인터페이스
/// 
/// 2026-01-05 15:40:00 EST - 초기 생성
/// 2026-01-08 05:56:00 EST - AlgorithmListResponse 추가
@RestApi(baseUrl: '')
abstract class LottoApi {
  factory LottoApi(Dio dio, {String baseUrl}) = _LottoApi;
  
  // === 로또 데이터 API ===
  
  /// 최신 회차 조회
  @GET(ApiEndpoints.latestDraw)
  Future<LottoDraw> getLatestDraw();
  
  /// 특정 회차 조회
  @GET(ApiEndpoints.drawByNumber)
  Future<LottoDraw> getDrawByNumber(@Path('draw_no') int drawNo);
  
  /// 범위 조회
  @GET(ApiEndpoints.drawRange)
  Future<List<LottoDraw>> getDrawRange(
    @Query('start') int start,
    @Query('end') int end,
  );
  
  // === 알고리즘 API ===
  
  /// 알고리즘 목록 조회
  /// 2026-01-08 05:56:00 EST - AlgorithmListResponse로 변경
  @GET(ApiEndpoints.algorithms)
  Future<AlgorithmListResponse> getAlgorithms();
  
  /// 알고리즘 상세 조회
  @GET(ApiEndpoints.algorithmById)
  Future<AlgorithmInfo> getAlgorithmById(@Path('id') int id);
  
  // === 번호 생성 API ===
  
  /// 번호 생성
  @POST(ApiEndpoints.generate)
  Future<GenerateResponse> generateNumbers(
    @Body() GenerateRequest request,
  );
  
  // === 인증 API ===
  
  /// Guest 로그인
  @POST(ApiEndpoints.guestLogin)
  Future<GuestLoginResponse> guestLogin(@Body() GuestLoginRequest request);

  /// 034 OAuth 로그인
  @POST(ApiEndpoints.login)
  Future<LoginResponse> login(@Body() LoginRequest request);
  
  /// 034 JWT 인증: 내 코인 잔액 (원장 집계)
  @GET(ApiEndpoints.meCoins)
  Future<MeCoinsResponse> getMeCoins();

  /// 034 JWT 인증: 내 코인 거래 내역
  @GET(ApiEndpoints.meCoinTransactions)
  Future<MeCoinTransactionsResponse> getMeCoinTransactions(
    @Query('cursor') String? cursor,
    @Query('limit') int? limit,
  );
  
  // === 코인 API ===
  
  /// 코인 잔액 조회
  @GET(ApiEndpoints.coinBalance)
  Future<CoinBalanceResponse> getCoinBalance(@Query('user_id') String userId);
  
  /// 일일 로그인 보상
  @POST(ApiEndpoints.dailyLogin)
  Future<CoinBalanceResponse> claimDailyLogin(@Body() Map<String, String> body);
  
  /// 광고 시청 보상
  @POST(ApiEndpoints.watchAd)
  Future<CoinBalanceResponse> claimAdReward(@Body() Map<String, String> body);
  
  /// 코인 거래 내역
  @GET(ApiEndpoints.coinHistory)
  Future<CoinHistoryResponse> getCoinHistory(
    @Query('user_id') String userId,
    @Query('limit') int? limit,
  );
  
  // === 내 번호 API ===
  
  /// 내 번호 저장
  @POST(ApiEndpoints.myNumbers)
  Future<MyNumberResponse> saveMyNumbers(@Body() SaveMyNumbersRequest request);
  
  /// 내 번호 목록 조회
  @GET(ApiEndpoints.myNumbers)
  Future<MyNumbersListResponse> getMyNumbers(
    @Query('user_id') String userId,
    @Query('skip') int? skip,
    @Query('limit') int? limit,
  );
  
  /// 당첨 확인
  @POST('${ApiEndpoints.myNumbers}/check-winning')
  Future<CheckWinningResponse> checkWinning(@Body() CheckWinningRequest request);
  
  /// 내 번호 삭제
  @DELETE('${ApiEndpoints.myNumbers}/{id}')
  Future<void> deleteMyNumber(
    @Path('id') int id,
    @Query('user_id') String userId,
  );
}

/// 번호 생성 요청 모델
class GenerateRequest {
  final int algorithmId;
  final int nSets;
  final List<int>? excludeNumbers;
  final List<int>? includeNumbers;
  final Map<String, dynamic>? extraParams;
  
  GenerateRequest({
    required this.algorithmId,
    required this.nSets,
    this.excludeNumbers,
    this.includeNumbers,
    this.extraParams,
  });
  
  Map<String, dynamic> toJson() => {
    'algorithm_id': algorithmId,
    'n_sets': nSets,
    if (excludeNumbers != null) 'exclude_numbers': excludeNumbers,
    if (includeNumbers != null) 'include_numbers': includeNumbers,
    if (extraParams != null) ...extraParams!,
  };
}

/// 번호 생성 응답 모델
class GenerateResponse {
  final int algorithmId;
  final String algorithmName;
  final List<NumberSet> results;
  final DateTime timestamp;
  final int totalCost;
  
  GenerateResponse({
    required this.algorithmId,
    required this.algorithmName,
    required this.results,
    required this.timestamp,
    required this.totalCost,
  });
  
  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      algorithmId: json['algorithm_id'],
      algorithmName: json['algorithm_name'],
      results: (json['results'] as List)
          .map((e) => NumberSet.fromJson(e))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      totalCost: json['cost'],  // 2026-01-08 06:45:00 EST - 백엔드는 'cost'로 반환
    );
  }
}

/// 번호 세트 모델
class NumberSet {
  final List<int> numbers;
  final int setNo;
  
  NumberSet({
    required this.numbers,
    required this.setNo,
  });
  
  factory NumberSet.fromJson(Map<String, dynamic> json) {
    return NumberSet(
      numbers: List<int>.from(json['numbers']),
      setNo: json['set_no'],
    );
  }
}

// === 인증 API 모델 ===

/// Guest 로그인 요청
class GuestLoginRequest {
  final String deviceId;
  final String? fcmToken;
  
  GuestLoginRequest({
    required this.deviceId,
    this.fcmToken,
  });
  
  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    if (fcmToken != null) 'fcm_token': fcmToken,
  };
}

/// Guest 로그인 응답
class GuestLoginResponse {
  final String userId;
  final bool isNewUser;
  final int freeCoins;
  final int paidCoins;
  
  GuestLoginResponse({
    required this.userId,
    required this.isNewUser,
    required this.freeCoins,
    required this.paidCoins,
  });
  
  factory GuestLoginResponse.fromJson(Map<String, dynamic> json) {
    return GuestLoginResponse(
      userId: json['user_id'],
      isNewUser: json['is_new_user'] ?? false,
      freeCoins: json['free_coins'] ?? 0,
      paidCoins: json['paid_coins'] ?? 0,
    );
  }
}

// === 034 OAuth 로그인 모델 ===

class LoginRequest {
  final String provider;
  final String? code;
  final String? idToken;
  final String? accessToken;
  final String? redirectUri;

  LoginRequest({
    required this.provider,
    this.code,
    this.idToken,
    this.accessToken,
    this.redirectUri,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    if (code != null) 'code': code,
    if (idToken != null) 'id_token': idToken,
    if (accessToken != null) 'access_token': accessToken,
    if (redirectUri != null) 'redirect_uri': redirectUri,
  };
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String userId;
  final String? email;
  final String? displayName;
  final bool isNewUser;

  LoginResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.userId,
    this.email,
    this.displayName,
    this.isNewUser = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'bearer',
      userId: json['user_id'],
      email: json['email'],
      displayName: json['display_name'],
      isNewUser: json['is_new_user'] ?? false,
    );
  }
}

class MeCoinsResponse {
  final int coins;

  MeCoinsResponse({required this.coins});

  factory MeCoinsResponse.fromJson(Map<String, dynamic> json) {
    return MeCoinsResponse(coins: json['coins'] ?? 0);
  }
}

class MeCoinTransactionsResponse {
  final List<MeCoinTransactionItem> items;
  final String? nextCursor;

  MeCoinTransactionsResponse({required this.items, this.nextCursor});

  factory MeCoinTransactionsResponse.fromJson(Map<String, dynamic> json) {
    return MeCoinTransactionsResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => MeCoinTransactionItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      nextCursor: json['next_cursor'],
    );
  }
}

class MeCoinTransactionItem {
  final int id;
  final int delta;
  final String? reason;
  final String? referenceType;
  final String? referenceId;
  final String? createdAt;

  MeCoinTransactionItem({
    required this.id,
    required this.delta,
    this.reason,
    this.referenceType,
    this.referenceId,
    this.createdAt,
  });

  factory MeCoinTransactionItem.fromJson(Map<String, dynamic> json) {
    return MeCoinTransactionItem(
      id: json['id'],
      delta: json['delta'],
      reason: json['reason'],
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      createdAt: json['created_at'],
    );
  }
}

// === 코인 API 모델 ===

/// 코인 잔액 응답
class CoinBalanceResponse {
  final String userId;
  final int freeCoins;
  final int paidCoins;
  final int totalCoins;
  final String? message;
  
  CoinBalanceResponse({
    required this.userId,
    required this.freeCoins,
    required this.paidCoins,
    required this.totalCoins,
    this.message,
  });
  
  factory CoinBalanceResponse.fromJson(Map<String, dynamic> json) {
    return CoinBalanceResponse(
      userId: json['user_id'],
      freeCoins: json['free_coins'],
      paidCoins: json['paid_coins'],
      totalCoins: json['total_coins'],
      message: json['message'],
    );
  }
}

/// 코인 거래 내역 응답
class CoinHistoryResponse {
  final int total;
  final List<CoinTransaction> transactions;
  
  CoinHistoryResponse({
    required this.total,
    required this.transactions,
  });
  
  factory CoinHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CoinHistoryResponse(
      total: json['total'],
      transactions: (json['transactions'] as List)
          .map((e) => CoinTransaction.fromJson(e))
          .toList(),
    );
  }
}

/// 코인 거래 내역
class CoinTransaction {
  final int id;
  final String type;
  final int amount;
  final String coinType;
  final int balanceAfter;
  final String? description;
  final DateTime createdAt;
  
  CoinTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.coinType,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
  });
  
  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'],
      coinType: json['coin_type'],
      balanceAfter: json['balance_after'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// === 내 번호 API 모델 ===

/// 내 번호 저장 요청
class SaveMyNumbersRequest {
  final String userId;
  final List<int> numbers;
  final int? algorithmId;
  final String? algorithmName;
  final String? memo;
  
  SaveMyNumbersRequest({
    required this.userId,
    required this.numbers,
    this.algorithmId,
    this.algorithmName,
    this.memo,
  });
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'numbers': numbers,
    if (algorithmId != null) 'algorithm_id': algorithmId,
    if (algorithmName != null) 'algorithm_name': algorithmName,
    if (memo != null) 'memo': memo,
  };
}

/// 내 번호 응답
class MyNumberResponse {
  final int id;
  final String userId;
  final List<int> numbers;
  final int? algorithmId;
  final String? algorithmName;
  final String? memo;
  final bool isChecked;
  final int? checkedDrawNo;
  final String? winningRank;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  MyNumberResponse({
    required this.id,
    required this.userId,
    required this.numbers,
    this.algorithmId,
    this.algorithmName,
    this.memo,
    required this.isChecked,
    this.checkedDrawNo,
    this.winningRank,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory MyNumberResponse.fromJson(Map<String, dynamic> json) {
    return MyNumberResponse(
      id: json['id'],
      userId: json['user_id'],
      numbers: List<int>.from(json['numbers']),
      algorithmId: json['algorithm_id'],
      algorithmName: json['algorithm_name'],
      memo: json['memo'],
      isChecked: json['is_checked'] ?? false,
      checkedDrawNo: json['checked_draw_no'],
      winningRank: json['winning_rank'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// 내 번호 목록 응답
class MyNumbersListResponse {
  final int total;
  final List<MyNumberResponse> numbers;
  
  MyNumbersListResponse({
    required this.total,
    required this.numbers,
  });
  
  factory MyNumbersListResponse.fromJson(Map<String, dynamic> json) {
    return MyNumbersListResponse(
      total: json['total'],
      numbers: (json['numbers'] as List)
          .map((e) => MyNumberResponse.fromJson(e))
          .toList(),
    );
  }
}

/// 당첨 확인 요청
class CheckWinningRequest {
  final String userId;
  final List<int> userNumberIds;
  final int? drawNo;
  
  CheckWinningRequest({
    required this.userId,
    required this.userNumberIds,
    this.drawNo,
  });
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_number_ids': userNumberIds,
    if (drawNo != null) 'draw_no': drawNo,
  };
}

/// 당첨 확인 응답
class CheckWinningResponse {
  final int totalChecked;
  final List<WinningResult> results;
  
  CheckWinningResponse({
    required this.totalChecked,
    required this.results,
  });
  
  factory CheckWinningResponse.fromJson(Map<String, dynamic> json) {
    return CheckWinningResponse(
      totalChecked: json['total_checked'],
      results: (json['results'] as List)
          .map((e) => WinningResult.fromJson(e))
          .toList(),
    );
  }
}

/// 당첨 결과
class WinningResult {
  final int id;
  final String userId;
  final int userNumberId;
  final int drawNo;
  final List<int> winningNumbers;
  final int bonusNumber;
  final int matchedCount;
  final bool hasBonus;
  final String winningRank;
  final bool notificationSent;
  final DateTime createdAt;
  
  WinningResult({
    required this.id,
    required this.userId,
    required this.userNumberId,
    required this.drawNo,
    required this.winningNumbers,
    required this.bonusNumber,
    required this.matchedCount,
    required this.hasBonus,
    required this.winningRank,
    required this.notificationSent,
    required this.createdAt,
  });
  
  factory WinningResult.fromJson(Map<String, dynamic> json) {
    return WinningResult(
      id: json['id'],
      userId: json['user_id'],
      userNumberId: json['user_number_id'],
      drawNo: json['draw_no'],
      winningNumbers: List<int>.from(json['winning_numbers']),
      bonusNumber: json['bonus_number'],
      matchedCount: json['matched_count'],
      hasBonus: json['has_bonus'] ?? false,
      winningRank: json['winning_rank'],
      notificationSent: json['notification_sent'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
