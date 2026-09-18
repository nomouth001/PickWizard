// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PickWizard：彩票选号助手';

  @override
  String get appSubtitle => '彩票选号辅助应用';

  @override
  String get disclaimerDialogTitle => '使用说明';

  @override
  String get disclaimerDialogMessage =>
      '本应用为希望在购彩时以销售机自动选号以外方式选择号码的用户提供号码抽取辅助功能。本应用不会提高中奖概率，仅供娱乐使用。';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get close => '关闭';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get deleteSavedNumberTitle => '删除已保存的号码';

  @override
  String get deleteSavedNumberMessage => '确定要删除这条保存记录吗？';

  @override
  String get offlineDrawCheckHint => '请到官方渠道核对开奖结果。';

  @override
  String get edit => '编辑';

  @override
  String get view => '查看';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get home => '首页';

  @override
  String get homeTitle => '彩票号码生成';

  @override
  String get generate => '生成';

  @override
  String get generateNumbers => '生成号码';

  @override
  String get history => '历史';

  @override
  String get myNumbers => '我的号码';

  @override
  String get settings => '设置';

  @override
  String get statistics => '统计';

  @override
  String get statisticsComingSoon => '统计功能即将推出';

  @override
  String get latestDraw => '最新期号';

  @override
  String get latestWinningNumbers => '最新开奖号码';

  @override
  String drawNumber(int number) {
    return '第$number期';
  }

  @override
  String get bonusNumber => '特别号';

  @override
  String get drawDate => '开奖日';

  @override
  String get selectAlgorithm => '选择算法';

  @override
  String get algorithmSelection => '选择算法';

  @override
  String get changeOptions => '更改选项';

  @override
  String get numberOfSets => '生成数量';

  @override
  String numberOfSetsCount(int count) {
    return '$count组';
  }

  @override
  String get quickButton5 => '5组';

  @override
  String get quickButton10 => '10组';

  @override
  String get fiveSets => '5组';

  @override
  String get tenSets => '10组';

  @override
  String get directInput => '自定义';

  @override
  String get enterNumberOfSets => '请输入生成组数';

  @override
  String get range1To100 => '1~100';

  @override
  String get rangeHint => '1~100';

  @override
  String get setsUnit => '组';

  @override
  String get generateButton => '生成号码';

  @override
  String get generating => '生成中...';

  @override
  String get algorithm1Name => '随机选号 (Quick Pick)';

  @override
  String get algorithm1Desc => '从1~45中随机选择6个号码，公平无偏。';

  @override
  String algorithm1DescDynamic(int min, int max, int count) {
    return '从$min~$max中随机选择$count个号码，公平无偏。';
  }

  @override
  String get algorithm2Name => '高级频率选号';

  @override
  String get algorithm2Desc => '根据历史出现频率分析选号。';

  @override
  String get algorithm3Name => '深度学习选号';

  @override
  String get algorithm3Desc => '基于深度学习习得的规律选号。';

  @override
  String get algorithm4Name => '规律分析选号';

  @override
  String get algorithm4Desc => '分析奇偶比、连号、区间分布等统计规律。';

  @override
  String get algorithm5Name => '加权组合选号';

  @override
  String get algorithm5Desc => '对频率、近期性、区间、多样性加权后选号。';

  @override
  String get algorithm6Name => '频率选号';

  @override
  String get algorithm6Desc => '优先选择出现频率高的号码。';

  @override
  String get algorithm7Name => '热号/冷号选号';

  @override
  String get algorithm7Desc => '组合近期常出的热号与久未出现的冷号。';

  @override
  String get algorithm8Name => 'AI选择';

  @override
  String get algorithm8Desc => 'AI分析历史开奖号码并推荐号码。';

  @override
  String get free => '免费';

  @override
  String coinsPerSet(int coins) {
    return '$coins币';
  }

  @override
  String get generatedNumbers => '已生成号码';

  @override
  String get generationResult => '生成结果';

  @override
  String generatedCount(int count) {
    return '共生成$count组';
  }

  @override
  String setsGenerated(int count) {
    return '已生成$count组';
  }

  @override
  String setNumber(int number) {
    return '组$number';
  }

  @override
  String get saveToMyNumbers => '保存到我的号码';

  @override
  String get saveAsMyNumbers => '保存为我的号码';

  @override
  String saveSetsMessage(int count) {
    return '将保存$count组号码';
  }

  @override
  String numbersSaved(int count) {
    return '已保存$count组号码';
  }

  @override
  String saveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get memoOptional => '备注（选填）';

  @override
  String get memoExample => '例：每周购买的号码';

  @override
  String get share => '分享';

  @override
  String get generateAgain => '再次生成';

  @override
  String get backToHome => '返回首页';

  @override
  String get maxLimitTitle => '生成数量限制';

  @override
  String get maxLimitMessage => '最多只能生成100组。';

  @override
  String get requirementTitle => '输入确认';

  @override
  String get requirementSelectAlgorithm => '请选择算法。';

  @override
  String get requirementSelectCount => '请选择或输入生成组数（1~100）。';

  @override
  String get requirementSelectBoth => '请选择算法并输入生成组数。';

  @override
  String get errorLoadAlgorithms => '无法加载算法';

  @override
  String get errorLoadingData => '无法加载数据';

  @override
  String errorFormat(String error) {
    return '错误：$error';
  }

  @override
  String get errorOccurred => '发生错误';

  @override
  String get initializationError => '初始化错误';

  @override
  String errorGenerateFailed(String message) {
    return '号码生成失败：$message';
  }

  @override
  String get errorNetwork => '请检查网络连接';

  @override
  String get errorServer => '服务器错误';

  @override
  String get errorUnknown => '发生未知错误';

  @override
  String get language => '语言';

  @override
  String get gameLabel => '游戏';

  @override
  String get selectGame => '选择游戏';

  @override
  String get gameLotto645 => '乐透 6/45';

  @override
  String get gamePowerball => '强力球';

  @override
  String get gameMegaMillions => '超级百万';

  @override
  String get gameWinForLife => 'Win for Life';

  @override
  String get gameAnnuity720 => '年金彩票720+';

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
  String get bonusBallLabel => '奖金球';

  @override
  String get bonusBallNamePowerball => '强力球（红球）';

  @override
  String get gameTypeChangedClearNumbers => '更换游戏后，包含与排除的号码已重置。';

  @override
  String get selectLanguage => '选择语言';

  @override
  String languageChanged(String language) {
    return '已切换为$language';
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
  String get appNameOffline => 'PickWizard：彩票选号助手';

  @override
  String get includeNumbersLabel => '包含的号码';

  @override
  String get excludeNumbersLabel => '排除的号码';

  @override
  String get includeNumbersHint => '例：1, 3, 7（逗号或空格分隔，最多6个）';

  @override
  String mainNumberRange(int min, int max) {
    return '主号码范围：$min~$max';
  }

  @override
  String includeNumbersHintDynamic(int min, int max, int maxCount) {
    return '例：1, 3, 7（逗号或空格分隔，范围 $min~$max，最多 $maxCount 个）';
  }

  @override
  String excludeNumbersHintDynamic(int min, int max, int maxExclude) {
    return '例：2, 5, 10（逗号或空格分隔，范围 $min~$max，最多 $maxExclude 个）';
  }

  @override
  String get excludeNumbersHint => '例：2, 5, 10（逗号或空格分隔，最多39个）';

  @override
  String get mainNumbers => '主号码';

  @override
  String bonusBallSection(String name) {
    return '奖金球（$name）';
  }

  @override
  String includeBonusNumbersLabel(String name) {
    return '要包含的$name号码';
  }

  @override
  String excludeBonusNumbersLabel(String name) {
    return '要排除的$name号码';
  }

  @override
  String includeBonusHint(int max) {
    return '1~$max，最多1个';
  }

  @override
  String excludeBonusHint(int max, int limit) {
    return '1~$max，最多$limit个';
  }

  @override
  String get bonusBallNameMegaBall => '超级球（金球）';

  @override
  String get bonusBallNameLuckyBall => '幸运球（黄球）';

  @override
  String bonusNumberRange(int max) {
    return '奖金号码范围：1~$max';
  }

  @override
  String get filterAll => '全部';

  @override
  String get numberOfSetsHint => '要生成的号码组数（1~100）';

  @override
  String get checkIncludeExclude => '请确认包含/排除条件。';

  @override
  String copySetsCopied(int start, int end) {
    return '第$start~$end组已复制到剪贴板。';
  }

  @override
  String get copyBy5SetsSection => '按5组复制';

  @override
  String copySetsRangeButton(int start, int end) {
    return '复制第$start~$end组';
  }

  @override
  String get algorithm9NameDisplay => '万次抽取6个';

  @override
  String get algorithm9Desc => '随机抽取1万次后，将出现频率最高的6个号码作为一组。';

  @override
  String algorithm9DescDynamic(int count) {
    return '随机抽取1万次后，将出现频率最高的$count个号码作为一组。';
  }

  @override
  String get algorithm1HelpOverview => '完全随机生成号码，每个号码被选中的概率相同。';

  @override
  String get algorithm1HelpHowItWorks => '从1到45中随机选择6个号码。不考虑统计或规律，每个号码独立选择。';

  @override
  String get algorithm1HelpWhenToUse => '当您不想用任何策略、纯粹凭运气时使用。免费且生成速度最快。';

  @override
  String get algorithm9HelpOverview =>
      '从1~45中随机抽取1万次，将出现次数最多的6个号码作为一组。不使用历史数据的纯模拟方式。';

  @override
  String get algorithm9HelpHowItWorks =>
      '1. 从1到45中随机抽取一个数字，重复10,000次。\n2. 统计每个号码出现的次数。\n3. 将出现次数最多的6个号码作为一组。\n4. 次数相同时，号码小的优先。';

  @override
  String get algorithm9HelpWhenToUse => '当您相信重复随机模拟结果而不依赖统计或历史数据时使用。免费且无需额外设置。';

  @override
  String get serialAlgorithm1Name => '串码自动选号';

  @override
  String get serialAlgorithm1HelpHowItWorks =>
      '对6个位置各自从0~9中随机抽取一个数字，填满六位串码。不使用统计或规律，每位独立选择。';

  @override
  String get serialAlgorithm9Name => '每位三千次最高频';

  @override
  String get serialAlgorithm9Desc => '六个位置各自将0~9随机抽取3000次，每个位置取出现次数最多的数字。';

  @override
  String get serialAlgorithm9HelpOverview =>
      '对年金720+的每一位，将0~9随机抽取3000次，在该位选取出现最频繁的数字。不使用历史开奖数据的纯模拟。';

  @override
  String get serialAlgorithm9HelpHowItWorks =>
      '1. 对从左到右六个位置分别执行以下步骤。\n2. 重复3000次：从0~9中随机抽取一个数字。\n3. 统计各数字出现次数，在该位选取次数最多的数字。\n4. 若并列，优先较小的数字。\n5. 六位填满后即为一组。';

  @override
  String get serialAlgorithm9HelpWhenToUse =>
      '希望在保持年金串码位序意义的前提下，采用类似球彩「万次抽取」的频率思路时使用。';

  @override
  String get unsupportedAlgorithm => '不支持该算法。';

  @override
  String includeSelectedLabel(int count, int max) {
    return '已选$count个（最多$max个）';
  }

  @override
  String excludeSelectedLabel(int count, int max) {
    return '已选$count个（最多$max个）';
  }

  @override
  String get myNumbersEmptyTitle => '暂无保存的号码';

  @override
  String get myNumbersEmptyHint => '生成号码后，在结果页面点击「保存为我的号码」即可保存到此。';

  @override
  String get dbResetDialogTitle => '通知';

  @override
  String get dbResetDialogMessage => '由于应用更新，已保存的号码被重置。';
}
