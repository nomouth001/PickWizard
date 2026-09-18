import 'package:flutter/material.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';

/// 1~45 번호 그리드 (포함/제외 선택용, 045)
class NumberGridSelector extends StatelessWidget {
  final Set<int> selected;
  final int maxCount;
  final Set<int> disabled;
  final ValueChanged<int> onNumberTap;

  const NumberGridSelector({
    super.key,
    required this.selected,
    required this.maxCount,
    this.disabled = const {},
    required this.onNumberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(45, (i) {
        final num = i + 1;
        final isSelected = selected.contains(num);
        final isDisabled = disabled.contains(num);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled
                ? null
                : () {
                    if (isSelected) {
                      onNumberTap(num);
                      return;
                    }
                    if (selected.length >= maxCount) return;
                    onNumberTap(num);
                  },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : isSelected
                        ? AppColors.primary
                        : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDisabled
                          ? Colors.grey
                          : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$num',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected || isDisabled
                      ? (isDisabled ? Colors.grey : Colors.white)
                      : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
