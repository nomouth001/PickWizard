// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PickWizard：宝くじ番号ナビ';

  @override
  String get appSubtitle => '宝くじ番号の補助アプリ';

  @override
  String get disclaimerDialogTitle => 'ご利用案内';

  @override
  String get disclaimerDialogMessage =>
      '本アプリは、ロト購入時に販売機のクイックピック以外の方法で番号を選びたい方のための番号抽選補助ツールです。当選確率を高めるものではありません。娯楽目的でご利用ください。';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get deleteSavedNumberTitle => '保存番号を削除';

  @override
  String get deleteSavedNumberMessage => 'この保存を削除しますか？';

  @override
  String get offlineDrawCheckHint => '当選確認は公式サイトで行ってください。';

  @override
  String get edit => '編集';

  @override
  String get view => '表示';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '情報';

  @override
  String get home => 'ホーム';

  @override
  String get homeTitle => 'ロト番号生成';

  @override
  String get generate => '生成';

  @override
  String get generateNumbers => '番号を生成';

  @override
  String get history => '履歴';

  @override
  String get myNumbers => 'マイ番号';

  @override
  String get settings => '設定';

  @override
  String get statistics => '統計';

  @override
  String get statisticsComingSoon => '統計機能は準備中です';

  @override
  String get latestDraw => '最新回';

  @override
  String get latestWinningNumbers => '最新当選番号';

  @override
  String drawNumber(int number) {
    return '第$number回';
  }

  @override
  String get bonusNumber => 'ボーナス';

  @override
  String get drawDate => '抽選日';

  @override
  String get selectAlgorithm => 'アルゴリズム選択';

  @override
  String get algorithmSelection => 'アルゴリズム選択';

  @override
  String get changeOptions => 'オプション変更';

  @override
  String get numberOfSets => '生成数';

  @override
  String numberOfSetsCount(int count) {
    return '$countセット';
  }

  @override
  String get quickButton5 => '5セット';

  @override
  String get quickButton10 => '10セット';

  @override
  String get fiveSets => '5セット';

  @override
  String get tenSets => '10セット';

  @override
  String get directInput => '直接入力';

  @override
  String get enterNumberOfSets => '生成数を入力';

  @override
  String get range1To100 => '1〜100';

  @override
  String get rangeHint => '1〜100';

  @override
  String get setsUnit => 'セット';

  @override
  String get generateButton => '番号生成';

  @override
  String get generating => '生成中...';

  @override
  String get algorithm1Name => 'クイックピック';

  @override
  String get algorithm1Desc => '1〜45から6個を完全ランダムに選択します。公平で偏りのない方法です。';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return '$min〜$maxから$count個を完全ランダムに選択します。公平で偏りのない方法です。';
  }

  @override
  String get algorithm2Name => '頻度分析（上級）';

  @override
  String get algorithm2Desc => '過去の出現頻度を分析して番号を選択します。';

  @override
  String get algorithm3Name => 'ディープラーニング';

  @override
  String get algorithm3Desc => 'ディープラーニングが学習したパターンに基づき番号を選択します。';

  @override
  String get algorithm4Name => 'パターン分析';

  @override
  String get algorithm4Desc => '奇数/偶数比、連番、区間分布などの統計的パターンを分析します。';

  @override
  String get algorithm5Name => '加重選択';

  @override
  String get algorithm5Desc => '頻度・新しさ・ゾーン・多様性に重みを付けて番号を選択します。';

  @override
  String get algorithm6Name => '頻度ベース';

  @override
  String get algorithm6Desc => '出現頻度の高い番号を優先して選択します。';

  @override
  String get algorithm7Name => 'ホット/コールド';

  @override
  String get algorithm7Desc => '最近よく出るホット番号と久しく出ていないコールド番号を組み合わせます。';

  @override
  String get algorithm8Name => 'AI選択';

  @override
  String get algorithm8Desc => 'AIが過去の当選番号を分析して番号を推薦します。';

  @override
  String get free => '無料';

  @override
  String coinsPerSet(int coins) {
    return '$coinsコイン';
  }

  @override
  String get generatedNumbers => '生成された番号';

  @override
  String get generationResult => '生成結果';

  @override
  String generatedCount(int count) {
    return '合計$countセット生成';
  }

  @override
  String setsGenerated(int count) {
    return '$countセット生成完了';
  }

  @override
  String setNumber(int number) {
    return 'セット$number';
  }

  @override
  String get saveToMyNumbers => 'マイ番号に保存';

  @override
  String get saveAsMyNumbers => 'マイ番号として保存';

  @override
  String saveSetsMessage(int count) {
    return '$countセットを保存します';
  }

  @override
  String numbersSaved(int count) {
    return '$countセットを保存しました';
  }

  @override
  String saveFailed(String error) {
    return '保存失敗: $error';
  }

  @override
  String get memoOptional => 'メモ（任意）';

  @override
  String get memoExample => '例：毎週購入する番号';

  @override
  String get share => '共有';

  @override
  String get generateAgain => '再生成';

  @override
  String get backToHome => 'ホームへ';

  @override
  String get maxLimitTitle => '生成数制限';

  @override
  String get maxLimitMessage => '最大100セットまで生成できます。';

  @override
  String get requirementTitle => '入力確認';

  @override
  String get requirementSelectAlgorithm => 'アルゴリズムを選択してください。';

  @override
  String get requirementSelectCount => '生成数を選択または入力してください。（1〜100）';

  @override
  String get requirementSelectBoth => 'アルゴリズムを選択し、生成数を入力してください。';

  @override
  String get errorLoadAlgorithms => 'アルゴリズムを読み込めません';

  @override
  String get errorLoadingData => 'データを読み込めません';

  @override
  String errorFormat(String error) {
    return 'エラー: $error';
  }

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get initializationError => '初期化エラー';

  @override
  String errorGenerateFailed(String message) {
    return '番号生成失敗: $message';
  }

  @override
  String get errorNetwork => 'ネットワーク接続を確認してください';

  @override
  String get errorServer => 'サーバーエラーが発生しました';

  @override
  String get errorUnknown => '不明なエラーが発生しました';

  @override
  String get language => '言語';

  @override
  String get gameLabel => 'ゲーム';

  @override
  String get selectGame => 'ゲーム選択';

  @override
  String get gameLotto645 => 'ロト 6/45';

  @override
  String get gamePowerball => 'パワーボール';

  @override
  String get gameMegaMillions => 'メガミリオンズ';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => '年金くじ720+';

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
  String get bonusBallLabel => 'ボーナスボール';

  @override
  String get bonusBallNamePowerball => 'パワーボール（赤球）';

  @override
  String get gameTypeChangedClearNumbers => 'ゲームを変更したため、含める／除外する番号がリセットされました。';

  @override
  String get selectLanguage => '言語選択';

  @override
  String languageChanged(String language) {
    return '$languageに変更しました';
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
  String get appNameOffline => 'PickWizard：宝くじ番号ナビ';

  @override
  String get includeNumbersLabel => '含める番号';

  @override
  String get excludeNumbersLabel => '除外する番号';

  @override
  String get includeNumbersHint => '例：1, 3, 7（カンマまたはスペース区切り、最大6個）';

  @override
  String mainNumberRange(int min, int max) {
    return 'メイン番号の範囲: $min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return '例：1, 3, 7（カンマまたはスペース区切り、範囲 $min~$max、最大 $maxCount 個）';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return '例：2, 5, 10（カンマまたはスペース区切り、範囲 $min~$max、最大 $maxExclude 個）';
  }

  @override
  String get excludeNumbersHint => '例：2, 5, 10（カンマまたはスペース区切り、最大39個）';

  @override
  String get mainNumbers => 'メイン番号';

  @override
  String bonusBallSection(String name) {
    return 'ボーナスボール（$name）';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return '含める$name番号';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return '除外する$name番号';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max、最大1個';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max、最大$limit個';
  }

  @override
  String get bonusBallNameMegaBall => 'メガボール（金球）';

  @override
  String get bonusBallNameLuckyBall => 'ラッキーボール（黄球）';

  @override
  String bonusNumberRange(int max) {
    return 'ボーナス番号の範囲: 1~$max';
  }

  @override
  String get filterAll => 'すべて';

  @override
  String get numberOfSetsHint => '生成するセット数（1〜100）';

  @override
  String get checkIncludeExclude => '含める/除外する条件を確認してください。';

  @override
  String copySetsCopied(int start, int end) {
    return 'セット$start〜$endをクリップボードにコピーしました。';
  }

  @override
  String get copyBy5SetsSection => '5セット単位でコピー';

  @override
  String copySetsRangeButton(int start, int end) {
    return 'セット$start〜$endをコピー';
  }

  @override
  String get algorithm9NameDisplay => '1万回抽選トップ6';

  @override
  String get algorithm9Desc => '1〜45を1万回ランダムに抽選し、出現頻度の高い6個を1セットにします。';

  @override
  String algorithm9DescDynamic(int count) {
    return '1万回ランダムに抽選し、出現頻度の高い$count個を1セットにします。';
  }

  @override
  String get algorithm1HelpOverview => '完全ランダムで番号を生成します。すべての番号が同じ確率で選ばれます。';

  @override
  String get algorithm1HelpHowItWorks =>
      '1から45の数字からランダムに6個を選択します。統計やパターンは考慮せず、各番号は独立して選ばれます。';

  @override
  String get algorithm1HelpWhenToUse =>
      '特別な戦略なしに運だけに任せたいときにご利用ください。無料で最も速く番号を生成できます。';

  @override
  String get algorithm9HelpOverview =>
      '1〜45を1万回ランダムに抽選し、最も多く出た6個を1セットにします。過去データを使わない純粋なシミュレーション方式です。';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. 1から45のいずれか1つをランダムに抽選する試行を1万回繰り返します。\n2. 各番号の出現回数を数えて頻度を計算します。\n3. 最も多く出た6個の番号を1セットとして選択します。\n4. 同点の場合は番号の小さい方を優先します。';

  @override
  String get algorithm9HelpWhenToUse =>
      '統計や過去データではなく、繰り返しランダムシミュレーションの結果を信じたいときにご利用ください。無料で追加設定はありません。';

  @override
  String get serialAlgorithm1Name => 'シリアル自動選択';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      '0〜9の数字の中から1つをランダムに選び、6桁を埋めます。統計やパターンは使用せず、各桁は独立して選択されます。';

  @override
  String get serialAlgorithm9Name => '桁ごと3千回最多桁';

  @override
  String get serialAlgorithm9Desc =>
      '6桁それぞれで0〜9を3,000回ランダムに抽選し、桁ごとに最も多く出た数字を選びます。';

  @override
  String get serialAlgorithm9HelpOverview =>
      '年金ロト720+の各桁について、0〜9を3,000回ランダムに抽選し、その桁で最も出現頻度が高い数字を選びます。過去の抽選データは使いません。';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. 左から6桁それぞれについて次を行います。\n2. 0〜9のいずれかをランダムに選ぶ試行を3,000回繰り返します。\n3. 各数字の出現回数を数え、その桁で最も多かった数字を採用します。\n4. 同点の場合はより小さい数字を優先します。\n5. 6桁すべて埋まったら1セット完成です。';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      'ボールピックのアルゴリズム9のように頻度で選びたいが、年金シリアルのように桁の順序を保ちたいときにご利用ください。';

  @override
  String get unsupportedAlgorithm => 'サポートされていないアルゴリズムです。';

  @override
  String includeSelectedLabel(int count, int max) {
    return '$count個選択（最大$max個）';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return '$count個選択（最大$max個）';
  }

  @override
  String get myNumbersEmptyTitle => '保存された番号はありません';

  @override
  String get myNumbersEmptyHint =>
      '番号を生成したあと、結果画面で「マイ番号として保存」をタップするとここに保存されます。';

  @override
  String get dbResetDialogTitle => 'お知らせ';

  @override
  String get dbResetDialogMessage => 'アプリのアップデートにより、保存された番号がリセットされました。';
}
