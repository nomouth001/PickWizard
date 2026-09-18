import 'package:flutter/material.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';

/// 번호 세트 카드 위젯
/// 
/// 2026-01-05 16:25:00 EST - 초기 생성
/// setLabel이 있으면 사용, 없으면 setNumber로 l10n setNumber 표시
class NumberCard extends StatelessWidget {
  final List<int> numbers;
  final int setNumber;
  final String? setLabel;
  final VoidCallback? onTap;
  final GameType? gameType;

  const NumberCard({
    super.key,
    required this.numbers,
    required this.setNumber,
    this.setLabel,
    this.onTap,
    this.gameType,
  });
  
  @override
  Widget build(BuildContext context) {
    final label = setLabel ?? context.l10n.setNumber(setNumber);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: numbers
                    .map(
                      (n) => LottoBall(
                        number: n,
                        size: 44,
                        gameType: gameType,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

