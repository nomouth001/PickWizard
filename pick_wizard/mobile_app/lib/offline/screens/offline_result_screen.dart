import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';
import 'package:pick_wizard/presentation/widgets/number_card.dart';
import 'package:pick_wizard/presentation/widgets/serial_number_row.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/offline/utils/offline_algorithm_display.dart';

/// 오프라인 결과 화면 (045 — 화면 2: 헤더 배너 + 번호세트 + 배너 여러 겹 + 푸터)
class OfflineResultScreen extends ConsumerWidget {
  final GeneratedNumbers generated;

  const OfflineResultScreen({super.key, required this.generated});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameType = GameTypes.fromId(generated.gameTypeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appNameOffline),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // §4.2 헤더 배너 (테스트/스크린샷용 비표시)
          const SizedBox(height: 8),
          // const BannerAdWidget(),
          const SizedBox(height: 16),

          // 알고리즘명 · N개 세트
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offlineAlgorithmDisplayLabel(
                      context.l10n,
                      generated,
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.setsGenerated(generated.setCount),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 생성된 번호 세트
          ...generated.results.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final result = entry.value;
            final setLabel = context.l10n.setNumber(result.setNo);
            final Widget card;
            if (gameType.isSerial) {
              final group = setIndex < generated.bonusBalls.length
                  ? generated.bonusBalls[setIndex]
                  : 1;
              card = _SerialResultCard(
                key: ValueKey('offline_serial_result_set_$setIndex'),
                setLabel: setLabel,
                group: group,
                digits: result.numbers,
              );
            } else if (gameType.hasBonus) {
              final bonusBall = setIndex < generated.bonusBalls.length
                  ? generated.bonusBalls[setIndex]
                  : null;
              card = _FivePlusOneResultCard(
                gameType: gameType,
                result: result,
                setLabel: setLabel,
                bonusBall: bonusBall,
              );
            } else {
              card = NumberCard(
                numbers: result.numbers,
                setNumber: result.setNo,
                setLabel: setLabel,
                gameType: gameType,
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            );
          }),
          const SizedBox(height: 16),

          // 5세트 단위 복사
          _CopyBy5SetsSection(generated: generated),
          const SizedBox(height: 24),

          // 내 번호로 저장 (로컬 Hive에 저장)
          ElevatedButton(
            onPressed: () async {
              final ds = ref.read(offlineLocalDataSourceProvider);
              final toSave = generated.copyWith(isSaved: true);
              await ds.saveGeneratedNumbers(toSave);
              ref.invalidate(offlineSavedNumbersProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.numbersSaved(generated.setCount)),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(context.l10n.saveAsMyNumbers),
          ),
          const SizedBox(height: 24),

          // §4.2 생성된 번호세트 아래 배너 (테스트/스크린샷용 비표시)
          // const BannerAdWidget(),
          // const SizedBox(height: 12),
          // const BannerAdWidget(),
          // const SizedBox(height: 12),
          // const BannerAdWidget(),
          const SizedBox(height: 24),

          // §4.1 푸터 배너 (테스트/스크린샷용 비표시)
          // const BannerAdWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 연금복권720+ 등 시리얼 결과: 조 배지 + 6자리.
class _SerialResultCard extends StatelessWidget {
  const _SerialResultCard({
    super.key,
    required this.setLabel,
    required this.group,
    required this.digits,
  });

  final String setLabel;
  final int group;
  final List<int> digits;

  @override
  Widget build(BuildContext context) {
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
            SerialNumberRow(
              group: group,
              digits: digits,
            ),
          ],
        ),
      ),
    );
  }
}

/// 5+1 게임 결과: 메인 볼 + 구분자 + 보너스 볼 (보너스 없으면 메인만).
class _FivePlusOneResultCard extends StatelessWidget {
  final GameType gameType;
  final NumberSetResult result;
  final String setLabel;
  final int? bonusBall;

  const _FivePlusOneResultCard({
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

/// 5세트 단위로 클립보드에 복사
class _CopyBy5SetsSection extends StatelessWidget {
  final GeneratedNumbers generated;

  const _CopyBy5SetsSection({required this.generated});

  static const int _chunkSize = 5;

  String _formatChunk(BuildContext context, List<NumberSetResult> chunk) {
    return chunk
        .map((r) => '${context.l10n.setNumber(r.setNo)}: ${r.numbers.join(', ')}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final results = generated.results;
    if (results.isEmpty) return const SizedBox.shrink();

    final chunks = <List<NumberSetResult>>[];
    for (var i = 0; i < results.length; i += _chunkSize) {
      chunks.add(
        results.sublist(i, i + _chunkSize > results.length ? results.length : i + _chunkSize),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.copyBy5SetsSection,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chunks.asMap().entries.map((entry) {
            final start = entry.key * _chunkSize + 1;
            final end = start + entry.value.length - 1;
            final label = context.l10n.copySetsRangeButton(start, end);
            return OutlinedButton.icon(
              icon: const Icon(Icons.copy, size: 18),
              label: Text(label),
              onPressed: () {
                final text = _formatChunk(context, entry.value);
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.copySetsCopied(start, end)),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

