import 'package:flutter/material.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/models/game_type.dart';

/// 로또 공 위젯
///
/// 2026-01-05 16:25:00 EST - 초기 생성
/// 게임 타입별 구간 색상 · 보너스 볼 ARGB (GameType 확장)
class LottoBall extends StatelessWidget {
  final int number;
  final bool isBonus;
  final double size;
  final GameType? gameType;

  const LottoBall({
    super.key,
    required this.number,
    this.isBonus = false,
    this.size = 48,
    this.gameType,
  });

  static Color _mainZoneColor(int zone) {
    switch (zone) {
      case 0:
        return AppColors.ball1to10;
      case 1:
        return AppColors.ball11to20;
      case 2:
        return AppColors.ball21to30;
      case 3:
        return AppColors.ball31to40;
      default:
        return AppColors.ball41to45;
    }
  }

  static Color _bonusPaintColor(GameType gt) {
    final argb = gt.bonusBallColorArgb;
    if (argb == 0) {
      return AppColors.ballBonus;
    }
    return Color.fromARGB(
      (argb >> 24) & 0xFF,
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
    );
  }

  Color _resolveColor() {
    final gt = gameType ?? GameTypes.lotto645;
    if (isBonus) {
      return _bonusPaintColor(gt);
    }
    final zone = gt.colorZoneFor(number);
    return _mainZoneColor(zone);
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
