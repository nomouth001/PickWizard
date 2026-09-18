/// 앱 문자열 상수
/// 
/// 2026-01-05 15:30:00 EST - 초기 생성
class AppStrings {
  AppStrings._();
  
  // === 앱 정보 ===
  static const String appName = 'PickWizard';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI 기반 로또 번호 생성 앱';
  
  // === 공통 버튼 ===
  static const String ok = '확인';
  static const String cancel = '취소';
  static const String save = '저장';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String close = '닫기';
  static const String retry = '재시도';
  static const String refresh = '새로고침';
  static const String share = '공유';
  
  // === 홈 화면 ===
  static const String homeTitle = '로또 번호 생성';
  static const String latestDrawTitle = '최신 당첨번호';
  static const String generateNumbersButton = '번호 생성하기';
  static const String myNumbersButton = '내 번호 확인';
  static const String statisticsButton = '통계 보기';
  
  // === 번호 생성 화면 ===
  static const String selectAlgorithm = '알고리즘 선택';
  static const String numberOfSets = '생성 개수';
  static const String excludeNumbers = '제외할 번호';
  static const String includeNumbers = '포함할 번호';
  static const String generateButton = '번호 생성';
  static const String generating = '번호 생성 중...';
  
  // === 알고리즘 이름 ===
  static const String algoRandom = '순수 랜덤';
  static const String algoLSTM = 'LSTM AI';
  static const String algoEnsemble = '앙상블';
  static const String algoPattern = '패턴 분석';
  static const String algoWeighted = '가중치 조합';
  static const String algoFrequency = '빈도 기반';
  static const String algoHotCold = '핫/콜드 넘버';
  
  // === 코인 ===
  static const String coinBalance = '보유 코인';
  static const String coins = '코인';
  static const String getCoinsFree = '무료 코인 받기';
  static const String purchaseCoins = '코인 구매';
  static const String dailyLoginReward = '일일 로그인 보상';
  static const String watchAdReward = '광고 시청 보상';
  static const String insufficientCoins = '코인이 부족합니다';
  
  // === 에러 메시지 ===
  static const String errorGeneral = '오류가 발생했습니다';
  static const String errorNetwork = '네트워크 연결을 확인해주세요';
  static const String errorServer = '서버 오류가 발생했습니다';
  static const String errorTimeout = '요청 시간이 초과되었습니다';
  static const String errorUnknown = '알 수 없는 오류가 발생했습니다';
  
  // === 성공 메시지 ===
  static const String successGenerated = '번호가 생성되었습니다';
  static const String successSaved = '저장되었습니다';
  static const String successDeleted = '삭제되었습니다';
  
  // === 확인 메시지 ===
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String confirmLogout = '로그아웃 하시겠습니까?';
}

