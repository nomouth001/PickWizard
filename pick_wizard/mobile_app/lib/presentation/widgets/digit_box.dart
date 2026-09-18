import 'package:flutter/material.dart';

const Color _kDigitBoxBackground = Color(0xFFF5F5F5);
const Color _kDigitBoxHighlight = Color(0xFF7B1FA2);

/// 연금복권720+ 등 시리얼 한 자리(0~9) 표시 박스.
class DigitBox extends StatelessWidget {
  const DigitBox({
    super.key,
    required this.digit,
    this.isHighlighted = false,
  });

  final int digit;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isHighlighted ? _kDigitBoxHighlight : _kDigitBoxBackground;
    final textColor = isHighlighted ? Colors.white : Colors.black;
    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '$digit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
