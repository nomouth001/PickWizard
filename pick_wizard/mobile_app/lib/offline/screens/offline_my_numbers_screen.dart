import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';
import 'package:pick_wizard/presentation/widgets/number_card.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/offline/utils/offline_algorithm_display.dart';

String _gameFlagEmoji(GameTypeId id) {
  return switch (id) {
    GameTypeId.lotto645 => '🇰🇷',
    GameTypeId.annuity720 => '🇰🇷',
    _ => '🇺🇸',
  };
}

String _localizedGameName(AppLocalizations l10n, GameTypeId id) {
  return switch (id) {
    GameTypeId.lotto645 => l10n.gameLotto645,
    GameTypeId.powerball => l10n.gamePowerball,
    GameTypeId.megaMillions => l10n.gameMegaMillions,
    GameTypeId.winForLife => l10n.gameWinForLife,
    GameTypeId.annuity720 => l10n.gameAnnuity720,
  };
}

/// 연금복권720+ 한 세트 표시: `{group}조  {d0}{d1}...` (조와 숫자 사이 공백 2칸)
String _serialSetDisplayLine(int group, List<int> digits) {
  return '$group조  ${digits.join()}';
}

/// 삭제 확인 후 저장된 번호 삭제
void _confirmDeleteSaved(
  BuildContext context,
  WidgetRef ref,
  GeneratedNumbers item,
) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteSavedNumberTitle),
      content: Text(l10n.deleteSavedNumberMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final id = item.id;
            if (id != null) {
              final ds = ref.read(offlineLocalDataSourceProvider);
              await ds.deleteGeneratedNumbers(id);
              ref.invalidate(offlineSavedNumbersProvider);
            }
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}

/// 저장된 번호 상세(전체 세트) 보기
void _showSavedDetail(BuildContext context, GeneratedNumbers item) {
  final l10n = context.l10n;
  final algoName = offlineAlgorithmDisplayLabel(l10n, item);
  final gameType = GameTypes.fromId(item.gameTypeId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    algoName,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Text(
              l10n.setsGenerated(item.setCount),
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: item.results.length,
                itemBuilder: (_, i) {
                  final r = item.results[i];
                  final bonus =
                      i < item.bonusBalls.length ? item.bonusBalls[i] : null;
                  if (gameType.isSerial) {
                    final g = bonus ?? 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _serialSetDisplayLine(g, r.numbers),
                        style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: gameType.hasBonus
                        ? _FivePlusOneSavedSetCard(
                            gameType: gameType,
                            result: r,
                            setLabel: l10n.setNumber(r.setNo),
                            bonusBall: bonus,
                          )
                        : NumberCard(
                            numbers: r.numbers,
                            setNumber: r.setNo,
                            setLabel: l10n.setNumber(r.setNo),
                            gameType: gameType,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 오프라인 앱 내 번호 목록 화면
class OfflineMyNumbersScreen extends ConsumerStatefulWidget {
  const OfflineMyNumbersScreen({super.key});

  @override
  ConsumerState<OfflineMyNumbersScreen> createState() =>
      _OfflineMyNumbersScreenState();
}

class _OfflineMyNumbersScreenState extends ConsumerState<OfflineMyNumbersScreen> {
  GameTypeId? _filterGameType;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(offlineSavedNumbersProvider);
    final l10n = context.l10n;
    final filtered = _filterGameType == null
        ? list
        : list.where((g) => g.gameTypeId == _filterGameType).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myNumbers),
      ),
      body: list.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.numbers_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.myNumbersEmptyTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.myNumbersEmptyHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: DropdownButton<GameTypeId?>(
                    key: const ValueKey('offline_my_numbers_game_filter'),
                    isExpanded: true,
                    value: _filterGameType,
                    items: [
                      DropdownMenuItem<GameTypeId?>(
                        value: null,
                        child: Text(l10n.filterAll),
                      ),
                      ...GameTypes.all.map(
                        (g) => DropdownMenuItem<GameTypeId?>(
                          value: g.id,
                          child: Text(
                            '${_gameFlagEmoji(g.id)} ${_localizedGameName(l10n, g.id)}',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _filterGameType = v),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.myNumbersEmptyTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _SavedNumbersCard(
                              generated: item,
                              onTap: () => _showSavedDetail(context, item),
                              onDelete: () =>
                                  _confirmDeleteSaved(context, ref, item),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _SavedNumbersCard extends StatelessWidget {
  final GeneratedNumbers generated;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _SavedNumbersCard({
    required this.generated,
    this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gt = GameTypes.fromId(generated.gameTypeId);
    final algoName = offlineAlgorithmDisplayLabel(l10n, generated);
    final badgeKey =
        'offline_saved_game_badge_${generated.id ?? generated.timestamp.millisecondsSinceEpoch}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      algoName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: l10n.delete,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Chip(
                key: ValueKey(badgeKey),
                avatar: Text(
                  _gameFlagEmoji(generated.gameTypeId),
                  style: const TextStyle(fontSize: 14),
                ),
                label: Text(_localizedGameName(l10n, generated.gameTypeId)),
                backgroundColor: generated.gameTypeId == GameTypeId.annuity720
                    ? const Color(0xFF7B1FA2)
                    : null,
                labelStyle:
                    generated.gameTypeId == GameTypeId.annuity720
                        ? const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )
                        : null,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.setsGenerated(generated.setCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              ...generated.results.take(5).toList().asMap().entries.map((e) {
                final setIdx = e.key;
                final r = e.value;
                if (gt.isSerial) {
                  final bonus = setIdx < generated.bonusBalls.length
                      ? generated.bonusBalls[setIdx]
                      : 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _serialSetDisplayLine(bonus, r.numbers),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  );
                }
                final bonus = setIdx < generated.bonusBalls.length
                    ? generated.bonusBalls[setIdx]
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: gt.hasBonus
                      ? _FivePlusOneSavedSetCard(
                          gameType: gt,
                          result: r,
                          setLabel: l10n.setNumber(r.setNo),
                          bonusBall: bonus,
                        )
                      : NumberCard(
                          numbers: r.numbers,
                          setNumber: r.setNo,
                          setLabel: l10n.setNumber(r.setNo),
                          gameType: gt,
                        ),
                );
              }),
              if (generated.results.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '... +${generated.results.length - 5}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5+1 게임: 메인 볼 + '+' + 보너스 볼 (보너스 없으면 메인만).
class _FivePlusOneSavedSetCard extends StatelessWidget {
  final GameType gameType;
  final NumberSetResult result;
  final String setLabel;
  final int? bonusBall;

  const _FivePlusOneSavedSetCard({
    required this.gameType,
    required this.result,
    required this.setLabel,
    required this.bonusBall,
  });

  @override
  Widget build(BuildContext context) {
    final mains =
        result.numbers.take(gameType.mainCount).toList(growable: false);
    final bonus = bonusBall;
    final showBonus = bonus != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              setLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...mains.map(
                  (n) => LottoBall(
                    number: n,
                    size: 44,
                    gameType: gameType,
                    isBonus: false,
                  ),
                ),
                if (showBonus) ...[
                  Text(
                    '+',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  LottoBall(
                    number: bonus,
                    size: 44,
                    gameType: gameType,
                    isBonus: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
