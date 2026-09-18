import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/data/help/algorithm_help_data.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:pick_wizard/offline/utils/game_preferences.dart';
import 'package:pick_wizard/offline/utils/locale_preferences.dart';
import 'package:pick_wizard/offline/screens/offline_result_screen.dart';
import 'package:pick_wizard/offline/screens/offline_my_numbers_screen.dart';
import 'package:pick_wizard/offline/services/local_lotto_service.dart';

bool offlineMainPickFeasible(
  GameType gt,
  List<int> include,
  List<int> exclude,
) {
  final poolSize =
      gt.mainMax - gt.mainMin + 1 - exclude.length - include.length;
  final need = gt.mainCount - include.length;
  return poolSize >= need;
}

bool offlineBonusPickFeasible(
  GameType gt,
  int? bonusInclude,
  List<int> bonusExclude,
) {
  if (!gt.hasBonus) return true;
  final min = gt.bonusMin!;
  final max = gt.bonusMax!;
  final full = {for (var i = min; i <= max; i++) i};
  final ex = bonusExclude.toSet();
  final pool = full.difference(ex);
  if (bonusInclude != null) {
    if (!full.contains(bonusInclude)) return false;
    if (ex.contains(bonusInclude)) return false;
    return true;
  }
  return pool.isNotEmpty;
}

String offlineBonusBallDisplayName(AppLocalizations l10n, GameTypeId id) {
  switch (id) {
    case GameTypeId.powerball:
      return l10n.bonusBallNamePowerball;
    case GameTypeId.megaMillions:
      return l10n.bonusBallNameMegaBall;
    case GameTypeId.winForLife:
      return l10n.bonusBallNameLuckyBall;
    case GameTypeId.annuity720:
      return '';
    case GameTypeId.lotto645:
      return '';
  }
}

/// 오프라인 홈 + 번호 생성 화면 (045 — 화면 1)
class OfflineHomeScreen extends ConsumerStatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  ConsumerState<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends ConsumerState<OfflineHomeScreen> {
  bool _hasShownDisclaimer = false;

  @override
  void initState() {
    super.initState();
    _restoreSavedGameType();
  }

  Future<void> _restoreSavedGameType() async {
    final id = await loadGameType();
    if (!mounted) return;
    ref.read(offlineSelectedGameTypeProvider.notifier).state =
        GameTypes.fromId(id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showDisclaimerIfNeeded(BuildContext context) {
    if (_hasShownDisclaimer) return;
    _hasShownDisclaimer = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.disclaimerDialogTitle),
          content: SingleChildScrollView(
            child: Text(context.l10n.disclaimerDialogMessage),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.confirm),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _showDisclaimerIfNeeded(context);
    final algorithms = ref.watch(offlineAlgorithmsProvider);
    final selectedAlgo = ref.watch(offlineSelectedAlgorithmProvider);
    ref.watch(offlineIncludeNumbersProvider);
    ref.watch(offlineExcludeNumbersProvider);
    ref.watch(offlineNumberOfSetsProvider);
    final generateState = ref.watch(offlineGenerateProvider);

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appNameOffline),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const OfflineMyNumbersScreen(),
                ),
              );
            },
            tooltip: context.l10n.myNumbers,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 테스트/스크린샷용: 광고 비표시 (애셋 제작 시 주석 해제하여 복원)
          // const Center(child: BannerAdWidget()),
          const SizedBox(height: 12),
          // 당첨 확인 안내 (045: 오프라인에서는 최신 회차 대신 안내 문구)
          Text(
            context.l10n.offlineDrawCheckHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 게임·언어 선택 (같은 화면)
          _buildGameAndLanguageCard(context, currentLocale),
          const SizedBox(height: 16),

          // 알고리즘 선택 (탭 시 옵션 모달)
          _buildAlgorithmCard(context, algorithms, selectedAlgo),
          const SizedBox(height: 16),
          // 번호 생성 버튼
          _buildGenerateButton(context, generateState),
          const SizedBox(height: 16),
          // 푸터 배너 (테스트/스크린샷용 비표시)
          // const Center(child: BannerAdWidget()),
        ],
      ),
    );
  }

  void _openAlgorithmOptionsModal(
    BuildContext context,
    OfflineAlgorithmInfo algorithm, {
    bool isChangingOptions = false,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _AlgorithmOptionsSheetContent(
        algorithm: algorithm,
        isChangingOptions: isChangingOptions,
        onConfirm: () {
          if (!isChangingOptions) {
            ref.read(offlineSelectedAlgorithmProvider.notifier).state = algorithm;
          }
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Widget _buildAlgorithmCard(
    BuildContext context,
    List<OfflineAlgorithmInfo> algorithms,
    OfflineAlgorithmInfo? selectedAlgo,
  ) {
    final l10n = context.l10n;
    final gameType = ref.watch(offlineSelectedGameTypeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.algorithmSelection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            if (selectedAlgo != null) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedAlgo.id == 1
                          ? l10n.algorithm1Name
                          : (gameType.isSerial
                              ? l10n.serialAlgorithm9Name
                              : l10n.algorithm9NameDisplay),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openAlgorithmOptionsModal(
                      context,
                      selectedAlgo,
                      isChangingOptions: true,
                    ),
                    child: Text(l10n.changeOptions),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            ...algorithms.map((algo) {
              final name = algo.id == 1
                  ? l10n.algorithm1Name
                  : (gameType.isSerial
                      ? l10n.serialAlgorithm9Name
                      : l10n.algorithm9NameDisplay);
              final desc = algo.id == 1
                  ? l10n.algorithm1DescDynamic(
                      gameType.mainMin,
                      gameType.mainMax,
                      gameType.mainCount,
                    )
                  : (gameType.isSerial
                      ? l10n.serialAlgorithm9Desc
                      : l10n.algorithm9DescDynamic(gameType.mainCount));
              final isSelected = selectedAlgo?.id == algo.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _openAlgorithmOptionsModal(context, algo),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // 선택 표시용 라디오 (둘 중 하나 선택이 직관적으로 보이도록)
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Transform.scale(
                                scale: 1.5,
                                child: Radio<int>(
                                  value: algo.id,
                                  groupValue: selectedAlgo?.id ?? 0,
                                  onChanged: (value) {
                                    if (value != null) {
                                      _openAlgorithmOptionsModal(context, algo);
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildHelpButton(context, algo.id),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(
    BuildContext context,
    AsyncValue<GeneratedNumbers?> generateState,
  ) {
    final canGenerate = _canGenerate();
    return ElevatedButton.icon(
      key: const ValueKey('offline_generate_button'),
      onPressed: canGenerate && !generateState.isLoading
          ? () async {
              await ref.read(offlineGenerateProvider.notifier).generate();
              if (!mounted) return;
              final state = ref.read(offlineGenerateProvider);
              state.whenOrNull(
                data: (generated) {
                  if (generated != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            OfflineResultScreen(generated: generated),
                      ),
                    );
                  }
                },
                error: (e, _) {
                  final msg = e is ArgumentError
                      ? _localizedErrorMessage(context, e.message ?? '')
                      : '${context.l10n.error}: $e';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
              );
            }
          : () {
              if (!canGenerate) {
                final algo = ref.read(offlineSelectedAlgorithmProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      algo == null
                          ? context.l10n.requirementSelectAlgorithm
                          : context.l10n.checkIncludeExclude,
                    ),
                  ),
                );
              }
            },
      icon: generateState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.casino),
      label: Text(
        generateState.isLoading
            ? context.l10n.generating
            : context.l10n.generateButton,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: canGenerate && !generateState.isLoading
            ? AppColors.primary
            : Colors.grey,
      ),
    );
  }

  Widget _buildHelpButton(BuildContext context, int algorithmId) {
    final gameType = ref.read(offlineSelectedGameTypeProvider);
    final help = gameType.isSerial && algorithmId == 9
        ? AlgorithmHelpData.getSerial9()
        : AlgorithmHelpData.get(algorithmId);
    if (help == null) return const SizedBox.shrink();
    return TextButton.icon(
      icon: Icon(Icons.help_outline, size: 18, color: AppColors.info),
      label: Text(
        '?',
        style: TextStyle(fontSize: 14, color: AppColors.info),
      ),
      onPressed: () => _showHelpDialog(
            context,
            algorithmId,
            help,
            gameType: gameType,
          ),
    );
  }

  void _showHelpDialog(
    BuildContext context,
    int algorithmId,
    dynamic help, {
    required GameType gameType,
  }) {
    final l10n = context.l10n;
    final useL10n = algorithmId == 1 || algorithmId == 9;
    final name = useL10n
        ? (algorithmId == 1
            ? (gameType.isSerial
                ? l10n.serialAlgorithm1Name
                : l10n.algorithm1Name)
            : (gameType.isSerial
                ? l10n.serialAlgorithm9Name
                : l10n.algorithm9NameDisplay))
        : help.name;
    final overview = useL10n
        ? (algorithmId == 1
            ? l10n.algorithm1HelpOverview
            : (gameType.isSerial
                ? l10n.serialAlgorithm9HelpOverview
                : l10n.algorithm9HelpOverview))
        : help.overview;
    final howItWorks = useL10n
        ? (algorithmId == 1
            ? (gameType.isSerial
                ? l10n.serialAlgorithm1HelpHowItWorks
                : l10n.algorithm1HelpHowItWorks)
            : (gameType.isSerial
                ? l10n.serialAlgorithm9HelpHowItWorks
                : l10n.algorithm9HelpHowItWorks))
        : help.howItWorks;
    final whenToUse = useL10n
        ? (algorithmId == 1
            ? l10n.algorithm1HelpWhenToUse
            : (gameType.isSerial
                ? l10n.serialAlgorithm9HelpWhenToUse
                : l10n.algorithm9HelpWhenToUse))
        : help.whenToUse;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(overview),
              const SizedBox(height: 12),
              Text(
                howItWorks,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(whenToUse, style: TextStyle(color: AppColors.grey700)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  bool _canGenerate() {
    final algo = ref.read(offlineSelectedAlgorithmProvider);
    if (algo == null) return false;
    final gameType = ref.read(offlineSelectedGameTypeProvider);
    if (gameType.isSerial) {
      final excludeGroups = ref.read(offlineSerialExcludeGroupsProvider);
      final fixedGroup = ref.read(offlineSerialFixedGroupProvider);
      if (fixedGroup != null && excludeGroups.contains(fixedGroup)) {
        return false;
      }
      final available = 5 - excludeGroups.length;
      return available >= 1;
    }
    final include = ref.read(offlineIncludeNumbersProvider);
    final exclude = ref.read(offlineExcludeNumbersProvider);
    if (!offlineMainPickFeasible(gameType, include, exclude)) {
      return false;
    }
    if (gameType.hasBonus) {
      final bonusExclude = ref.read(offlineBonusExcludeNumbersProvider);
      final bonusInclude = ref.read(offlineBonusIncludeNumberProvider);
      if (!offlineBonusPickFeasible(gameType, bonusInclude, bonusExclude)) {
        return false;
      }
    }
    return true;
  }

  String _localizedErrorMessage(BuildContext context, String message) {
    if (message.contains('알고리즘을 선택')) {
      return context.l10n.requirementSelectAlgorithm;
    }
    if (message.contains('지원하지 않는')) {
      return context.l10n.unsupportedAlgorithm;
    }
    if (message.isNotEmpty) {
      return '${context.l10n.error}: $message';
    }
    return context.l10n.error;
  }

  Widget _buildGameAndLanguageCard(
    BuildContext context,
    Locale currentLocale,
  ) {
    final l10n = context.l10n;
    final gameType = ref.watch(offlineSelectedGameTypeProvider);
    final localeValue = SupportedLocales.findLocale(currentLocale.languageCode) ??
        SupportedLocales.fallbackLocale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    l10n.gameLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: DropdownButton<GameType>(
                    key: const ValueKey('offline_game_dropdown'),
                    isExpanded: true,
                    value: gameType,
                    items: GameTypes.all
                        .map(
                          (g) => DropdownMenuItem<GameType>(
                            value: g,
                            child: Text(_gameDropdownItemLabel(context, g)),
                          ),
                        )
                        .toList(),
                    onChanged: (next) => _onGameTypeChanged(context, next),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: DropdownButton<Locale>(
                    key: const ValueKey('offline_language_dropdown'),
                    isExpanded: true,
                    value: localeValue,
                    items: SupportedLocales.locales
                        .map(
                          (loc) => DropdownMenuItem<Locale>(
                            value: loc,
                            child: Text(
                              '${SupportedLocales.getLanguageFlag(loc.languageCode)} '
                              '${SupportedLocales.getLanguageName(loc.languageCode)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (loc) {
                      if (loc == null) return;
                      ref.read(localeProvider.notifier).state = loc;
                      saveLocale(loc);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onGameTypeChanged(BuildContext context, GameType? next) {
    if (next == null) return;
    final prev = ref.read(offlineSelectedGameTypeProvider);
    if (prev.id == next.id) return;

    ref.read(offlineIncludeNumbersProvider.notifier).state = [];
    ref.read(offlineExcludeNumbersProvider.notifier).state = [];
    ref.read(offlineBonusIncludeNumberProvider.notifier).state = null;
    ref.read(offlineBonusExcludeNumbersProvider.notifier).state = [];
    ref.read(offlineSerialFixedGroupProvider.notifier).state = null;
    ref.read(offlineSerialExcludeGroupsProvider.notifier).state = [];
    ref.read(offlineSelectedGameTypeProvider.notifier).state = next;
    saveGameType(next.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.gameTypeChangedClearNumbers)),
    );
  }

  String _gameDropdownItemLabel(BuildContext context, GameType g) {
    final l10n = context.l10n;
    final name = switch (g.id) {
      GameTypeId.lotto645 => l10n.gameLotto645,
      GameTypeId.powerball => l10n.gamePowerball,
      GameTypeId.megaMillions => l10n.gameMegaMillions,
      GameTypeId.winForLife => l10n.gameWinForLife,
      GameTypeId.annuity720 => l10n.gameAnnuity720,
    };
    return '${_flagEmojiForGame(g.id)} $name';
  }

  String _flagEmojiForGame(GameTypeId id) {
    return switch (id) {
      GameTypeId.lotto645 => '🇰🇷',
      GameTypeId.annuity720 => '🇰🇷',
      _ => '🇺🇸',
    };
  }
}

/// 알고리즘 선택 시 뜨는 옵션 모달 시트 (포함/제외 번호, 생성 개수)
class _AlgorithmOptionsSheetContent extends ConsumerStatefulWidget {
  const _AlgorithmOptionsSheetContent({
    required this.algorithm,
    required this.isChangingOptions,
    required this.onConfirm,
  });

  final OfflineAlgorithmInfo algorithm;
  final bool isChangingOptions;
  final VoidCallback onConfirm;

  @override
  ConsumerState<_AlgorithmOptionsSheetContent> createState() =>
      _AlgorithmOptionsSheetContentState();
}

class _AlgorithmOptionsSheetContentState
    extends ConsumerState<_AlgorithmOptionsSheetContent> {
  bool _showNumberOfSetsInput = false;
  late final TextEditingController _numberOfSetsController;
  late final TextEditingController _includeController;
  late final TextEditingController _excludeController;
  late final TextEditingController _bonusIncludeController;
  late final TextEditingController _bonusExcludeController;
  late final TextEditingController _serialFixedGroupController;
  late final TextEditingController _serialExcludeGroupsController;

  /// 입력 문자열을 번호 리스트로 파싱. exclude에 있는 번호는 제외, 최대 maxCount개.
  List<int> _parseNumberList(
    String s, {
    required int maxCount,
    required Set<int> exclude,
  }) {
    final gameType = ref.read(offlineSelectedGameTypeProvider);
    final min = gameType.mainMin;
    final max = gameType.mainMax;
    final parts = s.split(RegExp(r'[\s,]+'));
    final list = <int>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final n = int.tryParse(p.trim());
      if (n == null || n < min || n > max) continue;
      if (list.contains(n)) continue;
      if (exclude.contains(n)) continue;
      list.add(n);
      if (list.length >= maxCount) break;
    }
    return list..sort();
  }

  void _applyBonusIncludeInput(String v, GameType gt) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) {
      ref.read(offlineBonusIncludeNumberProvider.notifier).state = null;
      return;
    }
    final min = gt.bonusMin!;
    final max = gt.bonusMax!;
    for (final p in v.split(RegExp(r'[\s,]+'))) {
      if (p.isEmpty) continue;
      final n = int.tryParse(p.trim());
      if (n == null) return;
      if (n < min || n > max) return;
      ref.read(offlineBonusIncludeNumberProvider.notifier).state = n;
      final ex = ref.read(offlineBonusExcludeNumbersProvider);
      if (ex.contains(n)) {
        final filtered = ex.where((e) => e != n).toList()..sort();
        ref.read(offlineBonusExcludeNumbersProvider.notifier).state = filtered;
        _bonusExcludeController.text = filtered.join(', ');
      }
      return;
    }
  }

  List<int> _parseBonusExcludeList(
    String s, {
    required GameType gt,
    required int maxCount,
    required Set<int> forbid,
  }) {
    final min = gt.bonusMin!;
    final max = gt.bonusMax!;
    final parts = s.split(RegExp(r'[\s,]+'));
    final list = <int>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final n = int.tryParse(p.trim());
      if (n == null || n < min || n > max) continue;
      if (forbid.contains(n)) continue;
      if (list.contains(n)) continue;
      list.add(n);
      if (list.length >= maxCount) break;
    }
    return list..sort();
  }

  void _applySerialFixedGroupInput(String v) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) {
      ref.read(offlineSerialFixedGroupProvider.notifier).state = null;
      return;
    }
    final n = int.tryParse(trimmed);
    if (n == null || n < 1 || n > 5) {
      ref.read(offlineSerialFixedGroupProvider.notifier).state = null;
      return;
    }
    ref.read(offlineSerialFixedGroupProvider.notifier).state = n;
  }

  void _applySerialExcludeGroupsInput(String v) {
    final parts = v.split(RegExp(r'[\s,]+'));
    final list = <int>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final n = int.tryParse(p.trim());
      if (n == null || n < 1 || n > 5) continue;
      if (list.contains(n)) continue;
      list.add(n);
      if (list.length >= 4) break;
    }
    list.sort();
    ref.read(offlineSerialExcludeGroupsProvider.notifier).state = list;
  }

  @override
  void initState() {
    super.initState();
    _numberOfSetsController = TextEditingController();
    _includeController = TextEditingController(
      text: ref.read(offlineIncludeNumbersProvider).join(', '),
    );
    _excludeController = TextEditingController(
      text: ref.read(offlineExcludeNumbersProvider).join(', '),
    );
    final bi = ref.read(offlineBonusIncludeNumberProvider);
    _bonusIncludeController = TextEditingController(
      text: bi == null ? '' : '$bi',
    );
    _bonusExcludeController = TextEditingController(
      text: ref.read(offlineBonusExcludeNumbersProvider).join(', '),
    );
    final fixedG = ref.read(offlineSerialFixedGroupProvider);
    _serialFixedGroupController = TextEditingController(
      text: fixedG == null ? '' : '$fixedG',
    );
    _serialExcludeGroupsController = TextEditingController(
      text: ref.read(offlineSerialExcludeGroupsProvider).join(', '),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final n = ref.read(offlineNumberOfSetsProvider);
    if (_showNumberOfSetsInput && _numberOfSetsController.text != n.toString()) {
      _numberOfSetsController.text = n.toString();
    }
  }

  @override
  void dispose() {
    _numberOfSetsController.dispose();
    _includeController.dispose();
    _excludeController.dispose();
    _bonusIncludeController.dispose();
    _bonusExcludeController.dispose();
    _serialFixedGroupController.dispose();
    _serialExcludeGroupsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gameType = ref.watch(offlineSelectedGameTypeProvider);
    final maxExcludeCap = gameType.mainPoolSize - gameType.mainCount;
    final include = ref.watch(offlineIncludeNumbersProvider);
    final exclude = ref.watch(offlineExcludeNumbersProvider);
    final numberOfSets = ref.watch(offlineNumberOfSetsProvider);
    final algoName = widget.algorithm.id == 1
        ? l10n.algorithm1Name
        : (gameType.isSerial
            ? l10n.serialAlgorithm9Name
            : l10n.algorithm9NameDisplay);
    final includeHint = l10n.includeNumbersHintDynamic(
      gameType.mainMin,
      gameType.mainMax,
      gameType.mainCount,
    );
    final excludeHint = l10n.excludeNumbersHintDynamic(
      gameType.mainMin,
      gameType.mainMax,
      maxExcludeCap,
    );
    final bonusIncludeWatch = ref.watch(offlineBonusIncludeNumberProvider);
    final bonusExcludeWatch = ref.watch(offlineBonusExcludeNumbersProvider);
    ref.watch(offlineSerialFixedGroupProvider);
    ref.watch(offlineSerialExcludeGroupsProvider);
    final canConfirm = gameType.isSerial
        ? validateSerialParameters(
            nSets: numberOfSets,
            fixedGroup: ref.read(offlineSerialFixedGroupProvider),
            excludeGroups: ref.read(offlineSerialExcludeGroupsProvider),
          ).$1
        : offlineMainPickFeasible(gameType, include, exclude) &&
            offlineBonusPickFeasible(
              gameType,
              bonusIncludeWatch,
              bonusExcludeWatch,
            );
    final bonusDisplayName = offlineBonusBallDisplayName(l10n, gameType.id);
    final bonusPoolSz = gameType.bonusPoolSize ?? 0;
    final maxBonusExcludeCap = bonusPoolSz;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  algoName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (gameType.isSerial) ...[
                      _sectionLabel(
                        context,
                        l10n.serialFixedGroupLabel,
                        () {
                          _showParamHelp(
                            context,
                            l10n.serialFixedGroupLabel,
                            l10n.serialFixedGroupHint,
                          );
                        },
                      ),
                      TextField(
                        key: const ValueKey('offline_serial_fixed_group_field'),
                        controller: _serialFixedGroupController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: l10n.serialFixedGroupHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: _applySerialFixedGroupInput,
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        context,
                        l10n.serialExcludeGroupsLabel,
                        () {
                          _showParamHelp(
                            context,
                            l10n.serialExcludeGroupsLabel,
                            l10n.serialExcludeGroupsHint,
                          );
                        },
                      ),
                      TextField(
                        key: const ValueKey(
                            'offline_serial_exclude_groups_field'),
                        controller: _serialExcludeGroupsController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: l10n.serialExcludeGroupsHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: _applySerialExcludeGroupsInput,
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                    _sectionLabel(context, l10n.includeNumbersLabel, () {
                      _showParamHelp(
                        context,
                        l10n.includeNumbersLabel,
                        includeHint,
                      );
                    }),
                    TextField(
                      key: const ValueKey('offline_main_include_field'),
                      controller: _includeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: includeHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        final excludeSet =
                            ref.read(offlineExcludeNumbersProvider).toSet();
                        final newList = _parseNumberList(
                          v,
                          maxCount: gameType.mainCount,
                          exclude: excludeSet,
                        );
                        ref.read(offlineIncludeNumbersProvider.notifier).state =
                            newList;
                      },
                    ),
                    Text(
                      l10n.includeSelectedLabel(
                        include.length,
                        gameType.mainCount,
                      ),
                      style: TextStyle(fontSize: 12, color: AppColors.grey600),
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel(context, l10n.excludeNumbersLabel, () {
                      _showParamHelp(
                        context,
                        l10n.excludeNumbersLabel,
                        excludeHint,
                      );
                    }),
                    TextField(
                      key: const ValueKey('offline_main_exclude_field'),
                      controller: _excludeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: excludeHint,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        final includeSet =
                            ref.read(offlineIncludeNumbersProvider).toSet();
                        final newList = _parseNumberList(
                          v,
                          maxCount: maxExcludeCap,
                          exclude: includeSet,
                        );
                        ref.read(offlineExcludeNumbersProvider.notifier).state =
                            newList;
                      },
                    ),
                    Text(
                      l10n.excludeSelectedLabel(
                        exclude.length,
                        maxExcludeCap,
                      ),
                      style: TextStyle(fontSize: 12, color: AppColors.grey600),
                    ),
                    const SizedBox(height: 20),
                    if (gameType.hasBonus) ...[
                      Column(
                        key: const ValueKey('offline_bonus_section'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.bonusBallSection(bonusDisplayName),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _sectionLabel(
                            context,
                            l10n.includeBonusNumbersLabel(bonusDisplayName),
                            () {
                              _showParamHelp(
                                context,
                                l10n.includeBonusNumbersLabel(bonusDisplayName),
                                l10n.includeBonusHint(
                                  gameType.bonusMax!,
                                ),
                              );
                            },
                          ),
                          TextField(
                            key: const ValueKey('offline_bonus_include_field'),
                            controller: _bonusIncludeController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: l10n.includeBonusHint(
                                gameType.bonusMax!,
                              ),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) =>
                                _applyBonusIncludeInput(v, gameType),
                          ),
                          const SizedBox(height: 16),
                          _sectionLabel(
                            context,
                            l10n.excludeBonusNumbersLabel(bonusDisplayName),
                            () {
                              _showParamHelp(
                                context,
                                l10n.excludeBonusNumbersLabel(bonusDisplayName),
                                l10n.excludeBonusHint(
                                  gameType.bonusMax!,
                                  maxBonusExcludeCap,
                                ),
                              );
                            },
                          ),
                          TextField(
                            key: const ValueKey('offline_bonus_exclude_field'),
                            controller: _bonusExcludeController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: l10n.excludeBonusHint(
                                gameType.bonusMax!,
                                maxBonusExcludeCap,
                              ),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) {
                              final inc = ref.read(
                                offlineBonusIncludeNumberProvider,
                              );
                              final forbid =
                                  inc != null ? <int>{inc} : <int>{};
                              final newList = _parseBonusExcludeList(
                                v,
                                gt: gameType,
                                maxCount: maxBonusExcludeCap,
                                forbid: forbid,
                              );
                              ref
                                  .read(
                                    offlineBonusExcludeNumbersProvider
                                        .notifier,
                                  )
                                  .state = newList;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    ],
                    _sectionLabel(context, l10n.numberOfSets, () {
                      _showParamHelp(
                        context,
                        l10n.numberOfSets,
                        l10n.numberOfSetsHint,
                      );
                    }),
                    Row(
                      children: [
                        _quickSetButton(5, numberOfSets),
                        const SizedBox(width: 8),
                        _quickSetButton(10, numberOfSets),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showNumberOfSetsInput = !_showNumberOfSetsInput;
                              if (_showNumberOfSetsInput) {
                                _numberOfSetsController.text =
                                    ref.read(offlineNumberOfSetsProvider).toString();
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _showNumberOfSetsInput
                                ? AppColors.primary.withOpacity(0.1)
                                : null,
                          ),
                          child: Text(l10n.directInput),
                        ),
                      ],
                    ),
                    if (_showNumberOfSetsInput) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _numberOfSetsController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        decoration: InputDecoration(
                          labelText: l10n.enterNumberOfSets,
                          hintText: l10n.range1To100,
                          suffixText: l10n.setsUnit,
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null && n >= 1 && n <= 100) {
                            ref
                                .read(offlineNumberOfSetsProvider.notifier)
                                .state = n;
                          }
                        },
                      ),
                    ],
                    Text(
                      l10n.numberOfSetsCount(numberOfSets),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const ValueKey('offline_options_confirm_button'),
              onPressed: canConfirm ? widget.onConfirm : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    canConfirm ? AppColors.primary : Colors.grey,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(
    BuildContext context,
    String label,
    VoidCallback onHelpTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onHelpTap,
            child: Text('?', style: TextStyle(color: AppColors.info)),
          ),
        ],
      ),
    );
  }

  Widget _quickSetButton(int value, int current) {
    final isSelected = current == value && !_showNumberOfSetsInput;
    final l10n = context.l10n;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          ref.read(offlineNumberOfSetsProvider.notifier).state = value;
          setState(() => _showNumberOfSetsInput = false);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isSelected ? AppColors.primary.withOpacity(0.1) : null,
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          value == 5 ? l10n.quickButton5 : l10n.quickButton10,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showParamHelp(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }
}
