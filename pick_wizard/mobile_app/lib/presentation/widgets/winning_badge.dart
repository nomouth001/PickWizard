import 'package:flutter/material.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';

/// 당첨 배지 위젯 (공통)
/// 
/// 2026-01-16 EST - Phase 1.3: 당첨 확인 로직 공통화
class WinningBadge extends StatelessWidget {
  final String? rank;
  final double fontSize;
  final double iconSize;
  
  const WinningBadge({
    super.key,
    required this.rank,
    this.fontSize = 12,
    this.iconSize = 16,
  });
  
  @override
  Widget build(BuildContext context) {
    if (rank == null || rank!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final badgeStyle = _getBadgeStyle(rank!);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeStyle.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeStyle.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeStyle.icon, size: iconSize, color: badgeStyle.color),
          const SizedBox(width: 4),
          Text(
            rank!,
            style: TextStyle(
              color: badgeStyle.color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
  
  _BadgeStyle _getBadgeStyle(String rank) {
    if (rank.contains('1등')) {
      return _BadgeStyle(
        color: const Color(0xFFFFD700), // 금색
        icon: Icons.emoji_events,
      );
    } else if (rank.contains('2등')) {
      return _BadgeStyle(
        color: const Color(0xFFC0C0C0), // 은색
        icon: Icons.emoji_events,
      );
    } else if (rank.contains('3등') || rank.contains('4등') || rank.contains('5등')) {
      return _BadgeStyle(
        color: AppColors.success,
        icon: Icons.check_circle,
      );
    } else {
      return _BadgeStyle(
        color: AppColors.grey400,
        icon: Icons.cancel,
      );
    }
  }
}

class _BadgeStyle {
  final Color color;
  final IconData icon;
  
  _BadgeStyle({required this.color, required this.icon});
}
