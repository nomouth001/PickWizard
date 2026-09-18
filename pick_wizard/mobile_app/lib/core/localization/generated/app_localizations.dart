import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
    Locale('vi'),
    Locale('zh')
  ];

  /// 앱 타이틀
  ///
  /// In ko, this message translates to:
  /// **'픽위자드 - 복권 번호 추천'**
  String get appTitle;

  /// 앱 부제목
  ///
  /// In ko, this message translates to:
  /// **'복권 번호 추천 보조 앱'**
  String get appSubtitle;

  /// No description provided for @disclaimerDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 이용 안내'**
  String get disclaimerDialogTitle;

  /// No description provided for @disclaimerDialogMessage.
  ///
  /// In ko, this message translates to:
  /// **'본 앱은 로또 구매 시 판매기 자동선택(Quick Pick) 이외의 방식으로 번호를 선택하고 싶은 분들을 위한 번호 추첨 보조 도구입니다. 당첨 확률을 높여 주지 않으며, 오락 목적으로만 이용해 주시기 바랍니다.'**
  String get disclaimerDialogMessage;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @deleteSavedNumberTitle.
  ///
  /// In ko, this message translates to:
  /// **'저장된 번호 삭제'**
  String get deleteSavedNumberTitle;

  /// No description provided for @deleteSavedNumberMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 저장 번호를 삭제하시겠습니까?'**
  String get deleteSavedNumberMessage;

  /// No description provided for @offlineDrawCheckHint.
  ///
  /// In ko, this message translates to:
  /// **'당첨 확인은 동행복권에서 해 주세요.'**
  String get offlineDrawCheckHint;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @view.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get view;

  /// No description provided for @loading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ko, this message translates to:
  /// **'성공'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ko, this message translates to:
  /// **'경고'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get info;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'로또 번호 생성'**
  String get homeTitle;

  /// No description provided for @generate.
  ///
  /// In ko, this message translates to:
  /// **'번호 생성'**
  String get generate;

  /// No description provided for @generateNumbers.
  ///
  /// In ko, this message translates to:
  /// **'번호 생성하기'**
  String get generateNumbers;

  /// No description provided for @history.
  ///
  /// In ko, this message translates to:
  /// **'히스토리'**
  String get history;

  /// No description provided for @myNumbers.
  ///
  /// In ko, this message translates to:
  /// **'내 번호'**
  String get myNumbers;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In ko, this message translates to:
  /// **'통계'**
  String get statistics;

  /// No description provided for @statisticsComingSoon.
  ///
  /// In ko, this message translates to:
  /// **'통계 기능은 준비 중입니다'**
  String get statisticsComingSoon;

  /// No description provided for @latestDraw.
  ///
  /// In ko, this message translates to:
  /// **'최신 회차'**
  String get latestDraw;

  /// No description provided for @latestWinningNumbers.
  ///
  /// In ko, this message translates to:
  /// **'최신 당첨번호'**
  String get latestWinningNumbers;

  /// 회차 번호
  ///
  /// In ko, this message translates to:
  /// **'제 {number}회'**
  String drawNumber(int number);

  /// No description provided for @bonusNumber.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get bonusNumber;

  /// No description provided for @drawDate.
  ///
  /// In ko, this message translates to:
  /// **'추첨일'**
  String get drawDate;

  /// No description provided for @selectAlgorithm.
  ///
  /// In ko, this message translates to:
  /// **'알고리즘 선택'**
  String get selectAlgorithm;

  /// No description provided for @algorithmSelection.
  ///
  /// In ko, this message translates to:
  /// **'알고리즘 선택'**
  String get algorithmSelection;

  /// No description provided for @changeOptions.
  ///
  /// In ko, this message translates to:
  /// **'옵션 변경'**
  String get changeOptions;

  /// No description provided for @numberOfSets.
  ///
  /// In ko, this message translates to:
  /// **'생성 개수'**
  String get numberOfSets;

  /// 생성 개수 표시
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String numberOfSetsCount(int count);

  /// No description provided for @quickButton5.
  ///
  /// In ko, this message translates to:
  /// **'5개'**
  String get quickButton5;

  /// No description provided for @quickButton10.
  ///
  /// In ko, this message translates to:
  /// **'10개'**
  String get quickButton10;

  /// No description provided for @fiveSets.
  ///
  /// In ko, this message translates to:
  /// **'5개'**
  String get fiveSets;

  /// No description provided for @tenSets.
  ///
  /// In ko, this message translates to:
  /// **'10개'**
  String get tenSets;

  /// No description provided for @directInput.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get directInput;

  /// No description provided for @enterNumberOfSets.
  ///
  /// In ko, this message translates to:
  /// **'생성 개수를 입력하세요'**
  String get enterNumberOfSets;

  /// No description provided for @range1To100.
  ///
  /// In ko, this message translates to:
  /// **'1~100'**
  String get range1To100;

  /// No description provided for @rangeHint.
  ///
  /// In ko, this message translates to:
  /// **'1~100'**
  String get rangeHint;

  /// No description provided for @setsUnit.
  ///
  /// In ko, this message translates to:
  /// **'개'**
  String get setsUnit;

  /// No description provided for @generateButton.
  ///
  /// In ko, this message translates to:
  /// **'번호 생성'**
  String get generateButton;

  /// No description provided for @generating.
  ///
  /// In ko, this message translates to:
  /// **'생성 중...'**
  String get generating;

  /// 알고리즘 1: 자동선택
  ///
  /// In ko, this message translates to:
  /// **'자동선택 (Quick Pick)'**
  String get algorithm1Name;

  /// No description provided for @algorithm1Desc.
  ///
  /// In ko, this message translates to:
  /// **'1~45 중 6개를 완전 무작위로 선택합니다. 가장 공정하고 편향 없는 방법입니다.'**
  String get algorithm1Desc;

  /// No description provided for @algorithm1DescDynamic.
  ///
  /// In ko, this message translates to:
  /// **'{min}~{max} 중 {count}개를 완전 무작위로 선택합니다. 가장 공정하고 편향 없는 방법입니다.'**
  String algorithm1DescDynamic(int min, int max, int count);

  /// No description provided for @algorithm2Name.
  ///
  /// In ko, this message translates to:
  /// **'출현 번호 빈도 기반 선택 (고급)'**
  String get algorithm2Name;

  /// No description provided for @algorithm2Desc.
  ///
  /// In ko, this message translates to:
  /// **'과거 출현 빈도를 분석하여 번호를 선택합니다.'**
  String get algorithm2Desc;

  /// No description provided for @algorithm3Name.
  ///
  /// In ko, this message translates to:
  /// **'딥러닝 선택'**
  String get algorithm3Name;

  /// No description provided for @algorithm3Desc.
  ///
  /// In ko, this message translates to:
  /// **'딥러닝이 학습한 패턴을 바탕으로 번호를 선택합니다.'**
  String get algorithm3Desc;

  /// No description provided for @algorithm4Name.
  ///
  /// In ko, this message translates to:
  /// **'출현 번호 패턴 기반 선택'**
  String get algorithm4Name;

  /// No description provided for @algorithm4Desc.
  ///
  /// In ko, this message translates to:
  /// **'홀/짝 비율, 연속번호, 구간 분포 등 통계적 패턴을 분석합니다.'**
  String get algorithm4Desc;

  /// No description provided for @algorithm5Name.
  ///
  /// In ko, this message translates to:
  /// **'가중치 조합 선택'**
  String get algorithm5Name;

  /// No description provided for @algorithm5Desc.
  ///
  /// In ko, this message translates to:
  /// **'빈도, 최근성, 구간, 다양성에 가중치를 적용하여 번호를 선택합니다.'**
  String get algorithm5Desc;

  /// No description provided for @algorithm6Name.
  ///
  /// In ko, this message translates to:
  /// **'출현 번호 빈도 기반 선택'**
  String get algorithm6Name;

  /// No description provided for @algorithm6Desc.
  ///
  /// In ko, this message translates to:
  /// **'출현 빈도가 높은 번호를 우선적으로 선택합니다.'**
  String get algorithm6Desc;

  /// No description provided for @algorithm7Name.
  ///
  /// In ko, this message translates to:
  /// **'핫/콜드 넘버 선택'**
  String get algorithm7Name;

  /// No description provided for @algorithm7Desc.
  ///
  /// In ko, this message translates to:
  /// **'최근 자주 나온 Hot 번호와 오래 안 나온 Cold 번호를 조합합니다.'**
  String get algorithm7Desc;

  /// No description provided for @algorithm8Name.
  ///
  /// In ko, this message translates to:
  /// **'인공지능 선택'**
  String get algorithm8Name;

  /// No description provided for @algorithm8Desc.
  ///
  /// In ko, this message translates to:
  /// **'AI가 과거 당첨 번호를 분석하여 추천합니다.'**
  String get algorithm8Desc;

  /// No description provided for @free.
  ///
  /// In ko, this message translates to:
  /// **'무료'**
  String get free;

  /// 세트당 코인 비용
  ///
  /// In ko, this message translates to:
  /// **'{coins}코인'**
  String coinsPerSet(int coins);

  /// No description provided for @generatedNumbers.
  ///
  /// In ko, this message translates to:
  /// **'생성된 번호'**
  String get generatedNumbers;

  /// No description provided for @generationResult.
  ///
  /// In ko, this message translates to:
  /// **'생성 결과'**
  String get generationResult;

  /// 생성된 번호 개수
  ///
  /// In ko, this message translates to:
  /// **'총 {count}개 생성됨'**
  String generatedCount(int count);

  /// 세트 생성 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'{count}개 생성 완료'**
  String setsGenerated(int count);

  /// 세트 번호
  ///
  /// In ko, this message translates to:
  /// **'세트 {number}'**
  String setNumber(int number);

  /// No description provided for @saveToMyNumbers.
  ///
  /// In ko, this message translates to:
  /// **'내 번호에 저장'**
  String get saveToMyNumbers;

  /// No description provided for @saveAsMyNumbers.
  ///
  /// In ko, this message translates to:
  /// **'내 번호로 저장'**
  String get saveAsMyNumbers;

  /// 번호 세트 저장 메시지
  ///
  /// In ko, this message translates to:
  /// **'{count}개의 번호 세트를 저장합니다'**
  String saveSetsMessage(int count);

  /// 번호 저장 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'{count}개 번호가 저장되었습니다'**
  String numbersSaved(int count);

  /// 저장 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String saveFailed(String error);

  /// No description provided for @memoOptional.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get memoOptional;

  /// No description provided for @memoExample.
  ///
  /// In ko, this message translates to:
  /// **'예: 매주 구매하는 번호'**
  String get memoExample;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// No description provided for @generateAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 생성'**
  String get generateAgain;

  /// No description provided for @backToHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get backToHome;

  /// No description provided for @maxLimitTitle.
  ///
  /// In ko, this message translates to:
  /// **'생성 개수 제한'**
  String get maxLimitTitle;

  /// No description provided for @maxLimitMessage.
  ///
  /// In ko, this message translates to:
  /// **'최대 100개까지만 생성 가능합니다.'**
  String get maxLimitMessage;

  /// No description provided for @requirementTitle.
  ///
  /// In ko, this message translates to:
  /// **'입력 확인'**
  String get requirementTitle;

  /// No description provided for @requirementSelectAlgorithm.
  ///
  /// In ko, this message translates to:
  /// **'알고리즘을 선택해주세요.'**
  String get requirementSelectAlgorithm;

  /// No description provided for @requirementSelectCount.
  ///
  /// In ko, this message translates to:
  /// **'생성 개수를 선택하거나 입력해주세요. (1~100개)'**
  String get requirementSelectCount;

  /// No description provided for @requirementSelectBoth.
  ///
  /// In ko, this message translates to:
  /// **'알고리즘을 선택하고, 생성 개수를 입력해주세요.'**
  String get requirementSelectBoth;

  /// No description provided for @errorLoadAlgorithms.
  ///
  /// In ko, this message translates to:
  /// **'알고리즘을 불러올 수 없습니다'**
  String get errorLoadAlgorithms;

  /// No description provided for @errorLoadingData.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 불러올 수 없습니다'**
  String get errorLoadingData;

  /// 오류 메시지 포맷
  ///
  /// In ko, this message translates to:
  /// **'오류: {error}'**
  String errorFormat(String error);

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'오류 발생'**
  String get errorOccurred;

  /// No description provided for @initializationError.
  ///
  /// In ko, this message translates to:
  /// **'초기화 오류'**
  String get initializationError;

  /// 번호 생성 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'번호 생성 실패: {message}'**
  String errorGenerateFailed(String message);

  /// No description provided for @errorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In ko, this message translates to:
  /// **'서버 오류가 발생했습니다'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다'**
  String get errorUnknown;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @gameLabel.
  ///
  /// In ko, this message translates to:
  /// **'게임'**
  String get gameLabel;

  /// No description provided for @selectGame.
  ///
  /// In ko, this message translates to:
  /// **'게임 선택'**
  String get selectGame;

  /// No description provided for @gameLotto645.
  ///
  /// In ko, this message translates to:
  /// **'로또 6/45'**
  String get gameLotto645;

  /// No description provided for @gamePowerball.
  ///
  /// In ko, this message translates to:
  /// **'파워볼'**
  String get gamePowerball;

  /// No description provided for @gameMegaMillions.
  ///
  /// In ko, this message translates to:
  /// **'메가밀리언'**
  String get gameMegaMillions;

  /// No description provided for @gameWinForLife.
  ///
  /// In ko, this message translates to:
  /// **'Win for Life'**
  String get gameWinForLife;

  /// No description provided for @gameAnnuity720.
  ///
  /// In ko, this message translates to:
  /// **'연금복권720+'**
  String get gameAnnuity720;

  /// No description provided for @annuity720GroupBadge.
  ///
  /// In ko, this message translates to:
  /// **'{group}조'**
  String annuity720GroupBadge(int group);

  /// No description provided for @annuity720FullFormat.
  ///
  /// In ko, this message translates to:
  /// **'{group}조 {digits}'**
  String annuity720FullFormat(int group, String digits);

  /// No description provided for @serialFixedGroupLabel.
  ///
  /// In ko, this message translates to:
  /// **'조 고정'**
  String get serialFixedGroupLabel;

  /// No description provided for @serialFixedGroupHint.
  ///
  /// In ko, this message translates to:
  /// **'1~5 중 1개 (빈칸=무작위)'**
  String get serialFixedGroupHint;

  /// No description provided for @serialExcludeGroupsLabel.
  ///
  /// In ko, this message translates to:
  /// **'조 제외'**
  String get serialExcludeGroupsLabel;

  /// No description provided for @serialExcludeGroupsHint.
  ///
  /// In ko, this message translates to:
  /// **'1~5, 최대 4개'**
  String get serialExcludeGroupsHint;

  /// No description provided for @serialGroupRange.
  ///
  /// In ko, this message translates to:
  /// **'조 범위: 1~5'**
  String get serialGroupRange;

  /// No description provided for @serialDigitRange.
  ///
  /// In ko, this message translates to:
  /// **'각 자리: 0~9'**
  String get serialDigitRange;

  /// No description provided for @bonusBallLabel.
  ///
  /// In ko, this message translates to:
  /// **'보너스 볼'**
  String get bonusBallLabel;

  /// No description provided for @bonusBallNamePowerball.
  ///
  /// In ko, this message translates to:
  /// **'파워볼 (빨간 공)'**
  String get bonusBallNamePowerball;

  /// No description provided for @gameTypeChangedClearNumbers.
  ///
  /// In ko, this message translates to:
  /// **'게임 변경으로 포함/제외 번호가 초기화되었습니다'**
  String get gameTypeChangedClearNumbers;

  /// No description provided for @selectLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get selectLanguage;

  /// 언어 변경 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'{language}(으)로 변경되었습니다'**
  String languageChanged(String language);

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In ko, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageVietnamese.
  ///
  /// In ko, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageThai.
  ///
  /// In ko, this message translates to:
  /// **'ภาษาไทย'**
  String get languageThai;

  /// No description provided for @languageJapanese.
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @appNameOffline.
  ///
  /// In ko, this message translates to:
  /// **'픽위자드 - 복권 번호 추천'**
  String get appNameOffline;

  /// No description provided for @includeNumbersLabel.
  ///
  /// In ko, this message translates to:
  /// **'포함할 번호'**
  String get includeNumbersLabel;

  /// No description provided for @excludeNumbersLabel.
  ///
  /// In ko, this message translates to:
  /// **'제외할 번호'**
  String get excludeNumbersLabel;

  /// No description provided for @includeNumbersHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 1, 3, 7 (쉼표 또는 공백 구분, 최대 6개)'**
  String get includeNumbersHint;

  /// No description provided for @mainNumberRange.
  ///
  /// In ko, this message translates to:
  /// **'메인 번호 범위: {min}~{max}'**
  String mainNumberRange(int min, int max);

  /// No description provided for @includeNumbersHintDynamic.
  ///
  /// In ko, this message translates to:
  /// **'예: 1, 3, 7 (쉼표 또는 공백 구분, 범위 {min}~{max}, 최대 {maxCount}개)'**
  String includeNumbersHintDynamic(int min, int max, int maxCount);

  /// No description provided for @excludeNumbersHintDynamic.
  ///
  /// In ko, this message translates to:
  /// **'예: 2, 5, 10 (쉼표 또는 공백 구분, 범위 {min}~{max}, 최대 {maxExclude}개)'**
  String excludeNumbersHintDynamic(int min, int max, int maxExclude);

  /// No description provided for @excludeNumbersHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 2, 5, 10 (쉼표 또는 공백 구분, 최대 39개)'**
  String get excludeNumbersHint;

  /// No description provided for @mainNumbers.
  ///
  /// In ko, this message translates to:
  /// **'메인 번호'**
  String get mainNumbers;

  /// No description provided for @bonusBallSection.
  ///
  /// In ko, this message translates to:
  /// **'보너스 볼 ({name})'**
  String bonusBallSection(String name);

  /// No description provided for @includeBonusNumbersLabel.
  ///
  /// In ko, this message translates to:
  /// **'포함할 {name} 번호'**
  String includeBonusNumbersLabel(String name);

  /// No description provided for @excludeBonusNumbersLabel.
  ///
  /// In ko, this message translates to:
  /// **'제외할 {name} 번호'**
  String excludeBonusNumbersLabel(String name);

  /// No description provided for @includeBonusHint.
  ///
  /// In ko, this message translates to:
  /// **'1~{max}, 최대 1개'**
  String includeBonusHint(int max);

  /// No description provided for @excludeBonusHint.
  ///
  /// In ko, this message translates to:
  /// **'1~{max}, 최대 {limit}개'**
  String excludeBonusHint(int max, int limit);

  /// No description provided for @bonusBallNameMegaBall.
  ///
  /// In ko, this message translates to:
  /// **'메가볼 (금색 공)'**
  String get bonusBallNameMegaBall;

  /// No description provided for @bonusBallNameLuckyBall.
  ///
  /// In ko, this message translates to:
  /// **'럭키볼 (노란 공)'**
  String get bonusBallNameLuckyBall;

  /// No description provided for @bonusNumberRange.
  ///
  /// In ko, this message translates to:
  /// **'보너스 번호 범위: 1~{max}'**
  String bonusNumberRange(int max);

  /// No description provided for @filterAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get filterAll;

  /// No description provided for @numberOfSetsHint.
  ///
  /// In ko, this message translates to:
  /// **'생성할 번호 세트 개수 (1~100)'**
  String get numberOfSetsHint;

  /// No description provided for @checkIncludeExclude.
  ///
  /// In ko, this message translates to:
  /// **'포함/제외 조건을 확인해 주세요.'**
  String get checkIncludeExclude;

  /// No description provided for @copySetsCopied.
  ///
  /// In ko, this message translates to:
  /// **'{start}~{end}세트가 클립보드에 복사되었습니다.'**
  String copySetsCopied(int start, int end);

  /// No description provided for @copyBy5SetsSection.
  ///
  /// In ko, this message translates to:
  /// **'5세트 단위 복사'**
  String get copyBy5SetsSection;

  /// No description provided for @copySetsRangeButton.
  ///
  /// In ko, this message translates to:
  /// **'{start}~{end}세트 복사'**
  String copySetsRangeButton(int start, int end);

  /// No description provided for @algorithm9NameDisplay.
  ///
  /// In ko, this message translates to:
  /// **'만 번 뽑기 6개'**
  String get algorithm9NameDisplay;

  /// No description provided for @algorithm9Desc.
  ///
  /// In ko, this message translates to:
  /// **'10,000회 랜덤 추출 후 빈도 상위 6개를 한 세트로 합니다.'**
  String get algorithm9Desc;

  /// No description provided for @algorithm9DescDynamic.
  ///
  /// In ko, this message translates to:
  /// **'10,000회 랜덤 추출 후 빈도 상위 {count}개를 한 세트로 합니다.'**
  String algorithm9DescDynamic(int count);

  /// No description provided for @algorithm1HelpOverview.
  ///
  /// In ko, this message translates to:
  /// **'완전한 무작위로 번호를 생성합니다. 모든 번호가 동일한 확률로 선택됩니다.'**
  String get algorithm1HelpOverview;

  /// No description provided for @algorithm1HelpHowItWorks.
  ///
  /// In ko, this message translates to:
  /// **'1부터 45까지의 숫자 중 무작위로 6개를 선택합니다. 통계나 패턴을 고려하지 않으며, 각 번호는 독립적으로 선택됩니다.'**
  String get algorithm1HelpHowItWorks;

  /// No description provided for @algorithm1HelpWhenToUse.
  ///
  /// In ko, this message translates to:
  /// **'특별한 전략 없이 순수하게 운에 맡기고 싶을 때 사용하세요. 무료이며 가장 빠르게 번호를 생성할 수 있습니다.'**
  String get algorithm1HelpWhenToUse;

  /// No description provided for @algorithm9HelpOverview.
  ///
  /// In ko, this message translates to:
  /// **'1~45를 10,000번 무작위로 뽑아 가장 많이 나온 6개를 한 세트로 합니다. 과거 데이터를 사용하지 않는 순수 시뮬레이션 방식입니다.'**
  String get algorithm9HelpOverview;

  /// No description provided for @algorithm9HelpHowItWorks.
  ///
  /// In ko, this message translates to:
  /// **'1. 1부터 45까지의 숫자 중 하나를 무작위로 뽑는 시행을 10,000회 반복합니다.\n2. 각 번호가 나온 횟수를 세어 빈도를 계산합니다.\n3. 가장 많이 나온 6개 번호를 한 세트로 선택합니다.\n4. 동점일 경우 번호가 작은 쪽을 우선합니다.'**
  String get algorithm9HelpHowItWorks;

  /// No description provided for @algorithm9HelpWhenToUse.
  ///
  /// In ko, this message translates to:
  /// **'통계나 과거 데이터 없이, 반복 랜덤 시뮬레이션 결과를 믿고 싶을 때 사용하세요. 무료이며 별도 설정이 없습니다.'**
  String get algorithm9HelpWhenToUse;

  /// No description provided for @serialAlgorithm1Name.
  ///
  /// In ko, this message translates to:
  /// **'시리얼 자동선택'**
  String get serialAlgorithm1Name;

  /// No description provided for @serialAlgorithm1HelpHowItWorks.
  ///
  /// In ko, this message translates to:
  /// **'0부터 9까지의 숫자 중 하나를 무작위로 뽑아 6자리를 채웁니다. 통계나 패턴을 고려하지 않으며, 각 자리는 독립적으로 선택됩니다.'**
  String get serialAlgorithm1HelpHowItWorks;

  /// No description provided for @serialAlgorithm9Name.
  ///
  /// In ko, this message translates to:
  /// **'자리별 3천회 최빈'**
  String get serialAlgorithm9Name;

  /// No description provided for @serialAlgorithm9Desc.
  ///
  /// In ko, this message translates to:
  /// **'여섯 자리 각각에서 0~9를 3,000번 무작위로 뽑아, 자리마다 가장 많이 나온 숫자를 채웁니다.'**
  String get serialAlgorithm9Desc;

  /// No description provided for @serialAlgorithm9HelpOverview.
  ///
  /// In ko, this message translates to:
  /// **'연금복권720+의 각 자리마다 0~9를 3,000회 무작위 추출하고, 그 자리에서 가장 자주 나온 숫자를 선택합니다. 과거 당첨 데이터를 쓰지 않는 순수 시뮬레이션입니다.'**
  String get serialAlgorithm9HelpOverview;

  /// No description provided for @serialAlgorithm9HelpHowItWorks.
  ///
  /// In ko, this message translates to:
  /// **'1. 왼쪽부터 여섯 자리 각각에 대해 다음을 수행합니다.\n2. 0부터 9까지 중 하나를 무작위로 뽑는 시행을 3,000회 반복합니다.\n3. 각 숫자의 출현 횟수를 세어, 그 자리에서 가장 많이 나온 숫자를 채택합니다.\n4. 동점이면 더 작은 숫자를 우선합니다.\n5. 여섯 자리를 모두 채우면 한 세트가 완성됩니다.'**
  String get serialAlgorithm9HelpHowItWorks;

  /// No description provided for @serialAlgorithm9HelpWhenToUse.
  ///
  /// In ko, this message translates to:
  /// **'볼 픽의「만 번 뽑기」와 같이 빈도 기반으로 고르고 싶지만, 연금 시리얼처럼 자리 순서가 의미 있을 때 사용하세요.'**
  String get serialAlgorithm9HelpWhenToUse;

  /// No description provided for @unsupportedAlgorithm.
  ///
  /// In ko, this message translates to:
  /// **'지원하지 않는 알고리즘입니다.'**
  String get unsupportedAlgorithm;

  /// No description provided for @includeSelectedLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택 (최대 {max}개)'**
  String includeSelectedLabel(int count, int max);

  /// No description provided for @excludeSelectedLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택 (최대 {max}개)'**
  String excludeSelectedLabel(int count, int max);

  /// No description provided for @myNumbersEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'저장된 번호가 없습니다'**
  String get myNumbersEmptyTitle;

  /// No description provided for @myNumbersEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'번호 생성 후 결과 화면에서 \'내 번호로 저장\'을 눌러 저장하세요.'**
  String get myNumbersEmptyHint;

  /// No description provided for @dbResetDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get dbResetDialogTitle;

  /// No description provided for @dbResetDialogMessage.
  ///
  /// In ko, this message translates to:
  /// **'앱 업데이트로 저장된 번호가 초기화되었습니다.'**
  String get dbResetDialogMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'ja',
        'ko',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
