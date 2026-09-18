// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PickWizard: Lottery Picks';

  @override
  String get appSubtitle => 'Lottery number picks helper app';

  @override
  String get disclaimerDialogTitle => 'Notice';

  @override
  String get disclaimerDialogMessage =>
      'This app is a number-draw helper for those who wish to choose lottery numbers by a method other than the terminal’s quick pick when purchasing tickets. It does not increase your chances of winning. Please use it for entertainment only.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSavedNumberTitle => 'Delete saved numbers';

  @override
  String get deleteSavedNumberMessage => 'Delete this saved set?';

  @override
  String get offlineDrawCheckHint =>
      'Check winning numbers at the official lottery.';

  @override
  String get edit => 'Edit';

  @override
  String get view => 'View';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get home => 'Home';

  @override
  String get homeTitle => 'Lotto Number Generation';

  @override
  String get generate => 'Generate';

  @override
  String get generateNumbers => 'Generate Numbers';

  @override
  String get history => 'History';

  @override
  String get myNumbers => 'My Numbers';

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsComingSoon => 'Statistics feature is coming soon';

  @override
  String get latestDraw => 'Latest Draw';

  @override
  String get latestWinningNumbers => 'Latest Winning Numbers';

  @override
  String drawNumber(int number) {
    return 'Draw #$number';
  }

  @override
  String get bonusNumber => 'Bonus';

  @override
  String get drawDate => 'Draw Date';

  @override
  String get selectAlgorithm => 'Select Algorithm';

  @override
  String get algorithmSelection => 'Algorithm Selection';

  @override
  String get changeOptions => 'Change options';

  @override
  String get numberOfSets => 'Number of Sets';

  @override
  String numberOfSetsCount(int count) {
    return '$count sets';
  }

  @override
  String get quickButton5 => '5 Sets';

  @override
  String get quickButton10 => '10 Sets';

  @override
  String get fiveSets => '5 Sets';

  @override
  String get tenSets => '10 Sets';

  @override
  String get directInput => 'Custom';

  @override
  String get enterNumberOfSets => 'Enter number of sets';

  @override
  String get range1To100 => '1~100';

  @override
  String get rangeHint => '1~100';

  @override
  String get setsUnit => 'sets';

  @override
  String get generateButton => 'Generate Numbers';

  @override
  String get generating => 'Generating...';

  @override
  String get algorithm1Name => 'Quick Pick';

  @override
  String get algorithm1Desc =>
      'Randomly select 6 numbers from 1-45. The most fair and unbiased method.';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return 'Randomly select $count numbers from $min–$max. The most fair and unbiased method.';
  }

  @override
  String get algorithm2Name => 'Frequency-Based Selection (Advanced)';

  @override
  String get algorithm2Desc => 'Analyze past draw frequency to select numbers.';

  @override
  String get algorithm3Name => 'Deep Learning Selection';

  @override
  String get algorithm3Desc =>
      'Select numbers based on patterns learned by deep learning.';

  @override
  String get algorithm4Name => 'Pattern-Based Selection';

  @override
  String get algorithm4Desc =>
      'Analyze statistical patterns like odd/even ratio, consecutive numbers, and range distribution.';

  @override
  String get algorithm5Name => 'Weighted Selection';

  @override
  String get algorithm5Desc =>
      'Apply weights to frequency, recency, zone, and diversity to select numbers.';

  @override
  String get algorithm6Name => 'Frequency-Based Selection';

  @override
  String get algorithm6Desc => 'Prioritize numbers with high draw frequency.';

  @override
  String get algorithm7Name => 'Hot & Cold Selection';

  @override
  String get algorithm7Desc =>
      'Combine Hot numbers (recently drawn) and Cold numbers (not drawn for a while).';

  @override
  String get algorithm8Name => 'AI Selection';

  @override
  String get algorithm8Desc =>
      'AI analyzes past winning numbers and recommends numbers.';

  @override
  String get free => 'FREE';

  @override
  String coinsPerSet(int coins) {
    return '$coins coins';
  }

  @override
  String get generatedNumbers => 'Generated Numbers';

  @override
  String get generationResult => 'Generation Result';

  @override
  String generatedCount(int count) {
    return 'Total $count sets generated';
  }

  @override
  String setsGenerated(int count) {
    return '$count sets generated';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get saveToMyNumbers => 'Save to My Numbers';

  @override
  String get saveAsMyNumbers => 'Save as My Numbers';

  @override
  String saveSetsMessage(int count) {
    return 'Save $count number sets';
  }

  @override
  String numbersSaved(int count) {
    return '$count numbers saved successfully';
  }

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get memoOptional => 'Memo (Optional)';

  @override
  String get memoExample => 'e.g., Weekly lottery numbers';

  @override
  String get share => 'Share';

  @override
  String get generateAgain => 'Generate Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get maxLimitTitle => 'Generation Limit';

  @override
  String get maxLimitMessage => 'Maximum 100 sets can be generated.';

  @override
  String get requirementTitle => 'Input Required';

  @override
  String get requirementSelectAlgorithm => 'Please select an algorithm.';

  @override
  String get requirementSelectCount =>
      'Please select or enter the number of sets. (1~100)';

  @override
  String get requirementSelectBoth =>
      'Please select an algorithm and enter the number of sets.';

  @override
  String get errorLoadAlgorithms => 'Failed to load algorithms';

  @override
  String get errorLoadingData => 'Failed to load data';

  @override
  String errorFormat(String error) {
    return 'Error: $error';
  }

  @override
  String get errorOccurred => 'Error occurred';

  @override
  String get initializationError => 'Initialization error';

  @override
  String errorGenerateFailed(String message) {
    return 'Generation failed: $message';
  }

  @override
  String get errorNetwork => 'Please check your network connection';

  @override
  String get errorServer => 'Server error occurred';

  @override
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get language => 'Language';

  @override
  String get gameLabel => 'Game';

  @override
  String get selectGame => 'Select Game';

  @override
  String get gameLotto645 => 'Lotto 6/45';

  @override
  String get gamePowerball => 'Powerball';

  @override
  String get gameMegaMillions => 'Mega Millions';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => 'Annuity 720+';

  @override
  String annuity720GroupBadge(int group) {
    return 'Group $group';
  }

  @override
  String annuity720FullFormat(int group, String digits) {
    return 'Group $group: $digits';
  }

  @override
  String get serialFixedGroupLabel => 'Fix Group';

  @override
  String get serialFixedGroupHint => '1–5, blank = random';

  @override
  String get serialExcludeGroupsLabel => 'Exclude Groups';

  @override
  String get serialExcludeGroupsHint => '1–5, up to 4';

  @override
  String get serialGroupRange => 'Group range: 1–5';

  @override
  String get serialDigitRange => 'Each digit: 0–9';

  @override
  String get bonusBallLabel => 'Bonus Ball';

  @override
  String get bonusBallNamePowerball => 'Powerball (Red)';

  @override
  String get gameTypeChangedClearNumbers =>
      'Game changed. Include/exclude numbers reset.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
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
  String get appNameOffline => 'PickWizard: Lottery Picks';

  @override
  String get includeNumbersLabel => 'Numbers to include';

  @override
  String get excludeNumbersLabel => 'Numbers to exclude';

  @override
  String get includeNumbersHint =>
      'e.g. 1, 3, 7 (comma or space separated, max 6)';

  @override
  String mainNumberRange(int min, int max) {
    return 'Main: $min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return 'e.g. 1, 3, 7 (comma or space separated, range $min~$max, max $maxCount)';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return 'e.g. 2, 5, 10 (comma or space separated, range $min~$max, max $maxExclude)';
  }

  @override
  String get excludeNumbersHint =>
      'e.g. 2, 5, 10 (comma or space separated, max 39)';

  @override
  String get mainNumbers => 'Main Numbers';

  @override
  String bonusBallSection(String name) {
    return 'Bonus Ball ($name)';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return 'Include $name Number';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return 'Exclude $name Numbers';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max, up to 1';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max, up to $limit';
  }

  @override
  String get bonusBallNameMegaBall => 'Mega Ball (Gold)';

  @override
  String get bonusBallNameLuckyBall => 'Lucky Ball (Yellow)';

  @override
  String bonusNumberRange(int max) {
    return 'Bonus: 1~$max';
  }

  @override
  String get filterAll => 'All';

  @override
  String get numberOfSetsHint => 'Number of sets to generate (1–100)';

  @override
  String get checkIncludeExclude => 'Please check include/exclude settings.';

  @override
  String copySetsCopied(int start, int end) {
    return 'Sets $start–$end copied to clipboard.';
  }

  @override
  String get copyBy5SetsSection => 'Copy in sets of 5';

  @override
  String copySetsRangeButton(int start, int end) {
    return 'Copy sets $start–$end';
  }

  @override
  String get algorithm9NameDisplay => '10K Draw Top 6';

  @override
  String get algorithm9Desc =>
      'Pick one number 10,000 times at random, then take the 6 most frequent as one set.';

  @override
  String algorithm9DescDynamic(int count) {
    return 'Pick one number 10,000 times at random, then take the $count most frequent as one set.';
  }

  @override
  String get algorithm1HelpOverview =>
      'Generates numbers completely at random. Every number has the same probability of being selected.';

  @override
  String get algorithm1HelpHowItWorks =>
      'Selects 6 numbers at random from 1 to 45. It does not consider statistics or patterns; each number is chosen independently.';

  @override
  String get algorithm1HelpWhenToUse =>
      'Use when you want to rely purely on luck with no particular strategy. It\'s free and generates numbers the fastest.';

  @override
  String get algorithm9HelpOverview =>
      'Draws from 1 to 45 at random 10,000 times and uses the 6 most frequent numbers as one set. Pure simulation with no past data.';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. Repeat 10,000 times: pick one number at random from 1 to 45.\n2. Count how often each number appears.\n3. Select the 6 numbers that appeared most often as one set.\n4. If tied, the smaller number comes first.';

  @override
  String get algorithm9HelpWhenToUse =>
      'Use when you trust repeated random simulation rather than statistics or past data. Free with no extra settings.';

  @override
  String get serialAlgorithm1Name => 'Serial Quick Pick';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      'For each of the six digit positions, draws one digit at random from 0 to 9. No statistics or patterns are used; each position is chosen independently.';

  @override
  String get serialAlgorithm9Name => 'Per-Digit 3K Top Pick';

  @override
  String get serialAlgorithm9Desc =>
      'For each of the six digit positions, draws 0–9 at random 3,000 times and picks the most frequent digit per position.';

  @override
  String get serialAlgorithm9HelpOverview =>
      'For each position in Annuity 720+, draws 0–9 at random 3,000 times and selects the most frequent digit for that position. Pure simulation with no historical draw data.';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. For each of the six positions (left to right), do the following.\n2. Repeat 3,000 times: pick one digit at random from 0 to 9.\n3. Count occurrences and choose the digit with the highest count for that position.\n4. If tied, prefer the smaller digit.\n5. After filling all six positions, one set is complete.';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      'Use when you want frequency-style picks similar to ball-pick Monte Carlo, while keeping serial digit order meaningful.';

  @override
  String get unsupportedAlgorithm => 'Unsupported algorithm.';

  @override
  String includeSelectedLabel(int count, int max) {
    return '$count selected (max $max)';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return '$count selected (max $max)';
  }

  @override
  String get myNumbersEmptyTitle => 'No saved numbers';

  @override
  String get myNumbersEmptyHint =>
      'Generate numbers, then tap \'Save as My Numbers\' on the result screen to save them here.';

  @override
  String get dbResetDialogTitle => 'Notice';

  @override
  String get dbResetDialogMessage =>
      'Saved numbers were cleared due to an app update.';
}
