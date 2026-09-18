import 'package:flutter/material.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';

import 'digit_box.dart';

const Color _kGroupBadgeColor = Color(0xFF7B1FA2);

/// 연금복권720+ 한 세트: 조 배지 + 6자리 DigitBox.
class SerialNumberRow extends StatelessWidget {
  const SerialNumberRow({
    super.key,
    required this.group,
    required this.digits,
  });

  final int group;
  final List<int> digits;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final digitBoxes = <Widget>[];
    for (var i = 0; i < digits.length; i++) {
      final box = DigitBox(digit: digits[i]);
      if (i < digits.length - 1) {
        digitBoxes.add(
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: box,
          ),
        );
      } else {
        digitBoxes.add(box);
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _kGroupBadgeColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            l10n.annuity720GroupBadge(group),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ...digitBoxes,
      ],
    );
  }
}
