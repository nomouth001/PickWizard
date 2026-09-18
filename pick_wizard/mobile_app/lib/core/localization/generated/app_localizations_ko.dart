// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '픽위자드 - 복권 번호 추천';

  @override
  String get appSubtitle => '복권 번호 추천 보조 앱';

  @override
  String get disclaimerDialogTitle => '앱 이용 안내';

  @override
  String get disclaimerDialogMessage =>
      '본 앱은 로또 구매 시 판매기 자동선택(Quick Pick) 이외의 방식으로 번호를 선택하고 싶은 분들을 위한 번호 추첨 보조 도구입니다. 당첨 확률을 높여 주지 않으며, 오락 목적으로만 이용해 주시기 바랍니다.';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get close => '닫기';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get deleteSavedNumberTitle => '저장된 번호 삭제';

  @override
  String get deleteSavedNumberMessage => '이 저장 번호를 삭제하시겠습니까?';

  @override
  String get offlineDrawCheckHint => '당첨 확인은 동행복권에서 해 주세요.';

  @override
  String get edit => '수정';

  @override
  String get view => '보기';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  @override
  String get home => '홈';

  @override
  String get homeTitle => '로또 번호 생성';

  @override
  String get generate => '번호 생성';

  @override
  String get generateNumbers => '번호 생성하기';

  @override
  String get history => '히스토리';

  @override
  String get myNumbers => '내 번호';

  @override
  String get settings => '설정';

  @override
  String get statistics => '통계';

  @override
  String get statisticsComingSoon => '통계 기능은 준비 중입니다';

  @override
  String get latestDraw => '최신 회차';

  @override
  String get latestWinningNumbers => '최신 당첨번호';

  @override
  String drawNumber(int number) {
    return '제 $number회';
  }

  @override
  String get bonusNumber => '보너스';

  @override
  String get drawDate => '추첨일';

  @override
  String get selectAlgorithm => '알고리즘 선택';

  @override
  String get algorithmSelection => '알고리즘 선택';

  @override
  String get changeOptions => '옵션 변경';

  @override
  String get numberOfSets => '생성 개수';

  @override
  String numberOfSetsCount(int count) {
    return '$count개';
  }

  @override
  String get quickButton5 => '5개';

  @override
  String get quickButton10 => '10개';

  @override
  String get fiveSets => '5개';

  @override
  String get tenSets => '10개';

  @override
  String get directInput => '직접 입력';

  @override
  String get enterNumberOfSets => '생성 개수를 입력하세요';

  @override
  String get range1To100 => '1~100';

  @override
  String get rangeHint => '1~100';

  @override
  String get setsUnit => '개';

  @override
  String get generateButton => '번호 생성';

  @override
  String get generating => '생성 중...';

  @override
  String get algorithm1Name => '자동선택 (Quick Pick)';

  @override
  String get algorithm1Desc => '1~45 중 6개를 완전 무작위로 선택합니다. 가장 공정하고 편향 없는 방법입니다.';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return '$min~$max 중 $count개를 완전 무작위로 선택합니다. 가장 공정하고 편향 없는 방법입니다.';
  }

  @override
  String get algorithm2Name => '출현 번호 빈도 기반 선택 (고급)';

  @override
  String get algorithm2Desc => '과거 출현 빈도를 분석하여 번호를 선택합니다.';

  @override
  String get algorithm3Name => '딥러닝 선택';

  @override
  String get algorithm3Desc => '딥러닝이 학습한 패턴을 바탕으로 번호를 선택합니다.';

  @override
  String get algorithm4Name => '출현 번호 패턴 기반 선택';

  @override
  String get algorithm4Desc => '홀/짝 비율, 연속번호, 구간 분포 등 통계적 패턴을 분석합니다.';

  @override
  String get algorithm5Name => '가중치 조합 선택';

  @override
  String get algorithm5Desc => '빈도, 최근성, 구간, 다양성에 가중치를 적용하여 번호를 선택합니다.';

  @override
  String get algorithm6Name => '출현 번호 빈도 기반 선택';

  @override
  String get algorithm6Desc => '출현 빈도가 높은 번호를 우선적으로 선택합니다.';

  @override
  String get algorithm7Name => '핫/콜드 넘버 선택';

  @override
  String get algorithm7Desc => '최근 자주 나온 Hot 번호와 오래 안 나온 Cold 번호를 조합합니다.';

  @override
  String get algorithm8Name => '인공지능 선택';

  @override
  String get algorithm8Desc => 'AI가 과거 당첨 번호를 분석하여 추천합니다.';

  @override
  String get free => '무료';

  @override
  String coinsPerSet(int coins) {
    return '$coins코인';
  }

  @override
  String get generatedNumbers => '생성된 번호';

  @override
  String get generationResult => '생성 결과';

  @override
  String generatedCount(int count) {
    return '총 $count개 생성됨';
  }

  @override
  String setsGenerated(int count) {
    return '$count개 생성 완료';
  }

  @override
  String setNumber(int number) {
    return '세트 $number';
  }

  @override
  String get saveToMyNumbers => '내 번호에 저장';

  @override
  String get saveAsMyNumbers => '내 번호로 저장';

  @override
  String saveSetsMessage(int count) {
    return '$count개의 번호 세트를 저장합니다';
  }

  @override
  String numbersSaved(int count) {
    return '$count개 번호가 저장되었습니다';
  }

  @override
  String saveFailed(String error) {
    return '저장 실패: $error';
  }

  @override
  String get memoOptional => '메모 (선택)';

  @override
  String get memoExample => '예: 매주 구매하는 번호';

  @override
  String get share => '공유';

  @override
  String get generateAgain => '다시 생성';

  @override
  String get backToHome => '홈으로';

  @override
  String get maxLimitTitle => '생성 개수 제한';

  @override
  String get maxLimitMessage => '최대 100개까지만 생성 가능합니다.';

  @override
  String get requirementTitle => '입력 확인';

  @override
  String get requirementSelectAlgorithm => '알고리즘을 선택해주세요.';

  @override
  String get requirementSelectCount => '생성 개수를 선택하거나 입력해주세요. (1~100개)';

  @override
  String get requirementSelectBoth => '알고리즘을 선택하고, 생성 개수를 입력해주세요.';

  @override
  String get errorLoadAlgorithms => '알고리즘을 불러올 수 없습니다';

  @override
  String get errorLoadingData => '데이터를 불러올 수 없습니다';

  @override
  String errorFormat(String error) {
    return '오류: $error';
  }

  @override
  String get errorOccurred => '오류 발생';

  @override
  String get initializationError => '초기화 오류';

  @override
  String errorGenerateFailed(String message) {
    return '번호 생성 실패: $message';
  }

  @override
  String get errorNetwork => '네트워크 연결을 확인해주세요';

  @override
  String get errorServer => '서버 오류가 발생했습니다';

  @override
  String get errorUnknown => '알 수 없는 오류가 발생했습니다';

  @override
  String get language => '언어';

  @override
  String get gameLabel => '게임';

  @override
  String get selectGame => '게임 선택';

  @override
  String get gameLotto645 => '로또 6/45';

  @override
  String get gamePowerball => '파워볼';

  @override
  String get gameMegaMillions => '메가밀리언';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => '연금복권720+';

  @override
  String annuity720GroupBadge(int group) {
    return '$group조';
  }

  @override
  String annuity720FullFormat(int group, String digits) {
    return '$group조 $digits';
  }

  @override
  String get serialFixedGroupLabel => '조 고정';

  @override
  String get serialFixedGroupHint => '1~5 중 1개 (빈칸=무작위)';

  @override
  String get serialExcludeGroupsLabel => '조 제외';

  @override
  String get serialExcludeGroupsHint => '1~5, 최대 4개';

  @override
  String get serialGroupRange => '조 범위: 1~5';

  @override
  String get serialDigitRange => '각 자리: 0~9';

  @override
  String get bonusBallLabel => '보너스 볼';

  @override
  String get bonusBallNamePowerball => '파워볼 (빨간 공)';

  @override
  String get gameTypeChangedClearNumbers => '게임 변경으로 포함/제외 번호가 초기화되었습니다';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String languageChanged(String language) {
    return '$language(으)로 변경되었습니다';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageThai => 'ภาษาไทย';

  @override
  String get languageJapanese => '日本語';

  @override
  String get appNameOffline => '픽위자드 - 복권 번호 추천';

  @override
  String get includeNumbersLabel => '포함할 번호';

  @override
  String get excludeNumbersLabel => '제외할 번호';

  @override
  String get includeNumbersHint => '예: 1, 3, 7 (쉼표 또는 공백 구분, 최대 6개)';

  @override
  String mainNumberRange(int min, int max) {
    return '메인 번호 범위: $min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return '예: 1, 3, 7 (쉼표 또는 공백 구분, 범위 $min~$max, 최대 $maxCount개)';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return '예: 2, 5, 10 (쉼표 또는 공백 구분, 범위 $min~$max, 최대 $maxExclude개)';
  }

  @override
  String get excludeNumbersHint => '예: 2, 5, 10 (쉼표 또는 공백 구분, 최대 39개)';

  @override
  String get mainNumbers => '메인 번호';

  @override
  String bonusBallSection(String name) {
    return '보너스 볼 ($name)';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return '포함할 $name 번호';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return '제외할 $name 번호';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max, 최대 1개';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max, 최대 $limit개';
  }

  @override
  String get bonusBallNameMegaBall => '메가볼 (금색 공)';

  @override
  String get bonusBallNameLuckyBall => '럭키볼 (노란 공)';

  @override
  String bonusNumberRange(int max) {
    return '보너스 번호 범위: 1~$max';
  }

  @override
  String get filterAll => '전체';

  @override
  String get numberOfSetsHint => '생성할 번호 세트 개수 (1~100)';

  @override
  String get checkIncludeExclude => '포함/제외 조건을 확인해 주세요.';

  @override
  String copySetsCopied(int start, int end) {
    return '$start~$end세트가 클립보드에 복사되었습니다.';
  }

  @override
  String get copyBy5SetsSection => '5세트 단위 복사';

  @override
  String copySetsRangeButton(int start, int end) {
    return '$start~$end세트 복사';
  }

  @override
  String get algorithm9NameDisplay => '만 번 뽑기 6개';

  @override
  String get algorithm9Desc => '10,000회 랜덤 추출 후 빈도 상위 6개를 한 세트로 합니다.';

  @override
  String algorithm9DescDynamic(int count) {
    return '10,000회 랜덤 추출 후 빈도 상위 $count개를 한 세트로 합니다.';
  }

  @override
  String get algorithm1HelpOverview =>
      '완전한 무작위로 번호를 생성합니다. 모든 번호가 동일한 확률로 선택됩니다.';

  @override
  String get algorithm1HelpHowItWorks =>
      '1부터 45까지의 숫자 중 무작위로 6개를 선택합니다. 통계나 패턴을 고려하지 않으며, 각 번호는 독립적으로 선택됩니다.';

  @override
  String get algorithm1HelpWhenToUse =>
      '특별한 전략 없이 순수하게 운에 맡기고 싶을 때 사용하세요. 무료이며 가장 빠르게 번호를 생성할 수 있습니다.';

  @override
  String get algorithm9HelpOverview =>
      '1~45를 10,000번 무작위로 뽑아 가장 많이 나온 6개를 한 세트로 합니다. 과거 데이터를 사용하지 않는 순수 시뮬레이션 방식입니다.';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. 1부터 45까지의 숫자 중 하나를 무작위로 뽑는 시행을 10,000회 반복합니다.\n2. 각 번호가 나온 횟수를 세어 빈도를 계산합니다.\n3. 가장 많이 나온 6개 번호를 한 세트로 선택합니다.\n4. 동점일 경우 번호가 작은 쪽을 우선합니다.';

  @override
  String get algorithm9HelpWhenToUse =>
      '통계나 과거 데이터 없이, 반복 랜덤 시뮬레이션 결과를 믿고 싶을 때 사용하세요. 무료이며 별도 설정이 없습니다.';

  @override
  String get serialAlgorithm1Name => '시리얼 자동선택';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      '0부터 9까지의 숫자 중 하나를 무작위로 뽑아 6자리를 채웁니다. 통계나 패턴을 고려하지 않으며, 각 자리는 독립적으로 선택됩니다.';

  @override
  String get serialAlgorithm9Name => '자리별 3천회 최빈';

  @override
  String get serialAlgorithm9Desc =>
      '여섯 자리 각각에서 0~9를 3,000번 무작위로 뽑아, 자리마다 가장 많이 나온 숫자를 채웁니다.';

  @override
  String get serialAlgorithm9HelpOverview =>
      '연금복권720+의 각 자리마다 0~9를 3,000회 무작위 추출하고, 그 자리에서 가장 자주 나온 숫자를 선택합니다. 과거 당첨 데이터를 쓰지 않는 순수 시뮬레이션입니다.';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. 왼쪽부터 여섯 자리 각각에 대해 다음을 수행합니다.\n2. 0부터 9까지 중 하나를 무작위로 뽑는 시행을 3,000회 반복합니다.\n3. 각 숫자의 출현 횟수를 세어, 그 자리에서 가장 많이 나온 숫자를 채택합니다.\n4. 동점이면 더 작은 숫자를 우선합니다.\n5. 여섯 자리를 모두 채우면 한 세트가 완성됩니다.';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      '볼 픽의「만 번 뽑기」와 같이 빈도 기반으로 고르고 싶지만, 연금 시리얼처럼 자리 순서가 의미 있을 때 사용하세요.';

  @override
  String get unsupportedAlgorithm => '지원하지 않는 알고리즘입니다.';

  @override
  String includeSelectedLabel(int count, int max) {
    return '$count개 선택 (최대 $max개)';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return '$count개 선택 (최대 $max개)';
  }

  @override
  String get myNumbersEmptyTitle => '저장된 번호가 없습니다';

  @override
  String get myNumbersEmptyHint => '번호 생성 후 결과 화면에서 \'내 번호로 저장\'을 눌러 저장하세요.';

  @override
  String get dbResetDialogTitle => '알림';

  @override
  String get dbResetDialogMessage => '앱 업데이트로 저장된 번호가 초기화되었습니다.';
}
