import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/constants/app_strings.dart';
import 'package:pick_wizard/presentation/providers/my_numbers_provider.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';
import 'package:pick_wizard/presentation/widgets/winning_badge.dart'; // 2026-01-16 EST - Phase 1.3: 공통 위젯 import

/// 내 번호 화면
/// 
/// 2026-01-16 EST - 초기 생성
class MyNumbersScreen extends ConsumerWidget {
  const MyNumbersScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myNumbersAsync = ref.watch(myNumbersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myNumbersButton),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(myNumbersProvider);
            },
          ),
        ],
      ),
      body: myNumbersAsync.when(
        data: (numbers) {
          if (numbers.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myNumbersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                final number = numbers[index];
                return _buildNumberCard(context, ref, number);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myNumbersProvider),
                child: const Text('재시도'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCheckWinningDialog(context, ref);
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('당첨 확인'),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 100,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 24),
          Text(
            '저장된 번호가 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '번호 생성 후 "내 번호로 저장"을 눌러주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add),
            label: const Text('번호 생성하러 가기'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberCard(BuildContext context, WidgetRef ref, dynamic number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (number.algorithmName != null)
                        Text(
                          number.algorithmName!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      if (number.memo != null)
                        Text(
                          number.memo!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      Text(
                        '생성일: ${_formatDate(number.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 당첨 여부 배지
                if (number.isChecked)
                  // 2026-01-16 EST - Phase 1.3: 공통 위젯 사용
                  WinningBadge(rank: number.winningRank),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            
            // 로또 번호
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: number.numbers.map<Widget>((num) {
                return LottoBall(number: num, size: 44);
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // 하단 액션 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (number.isChecked && number.checkedDrawNo != null)
                  Text(
                    '${number.checkedDrawNo}회 확인 완료',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _confirmDelete(context, ref, number.id);
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('삭제'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 2026-01-16 EST - Phase 1.3: _buildWinningBadge 삭제 (공통 위젯으로 대체)
  // Widget _buildWinningBadge(String? rank) { ... }
  
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, int numberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('번호 삭제'),
        content: const Text('이 번호를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(deleteMyNumberProvider.notifier).delete(numberId);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('번호가 삭제되었습니다')),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
  
  void _showCheckWinningDialog(BuildContext context, WidgetRef ref) {
    final numbers = ref.read(myNumbersProvider).value ?? [];
    
    if (numbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('확인할 번호가 없습니다')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('당첨 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${numbers.length}개의 번호를 확인하시겠습니까?'),
            const SizedBox(height: 8),
            Text(
              '최신 회차와 비교합니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final numberIds = numbers.map((n) => n.id).toList();
              await ref.read(checkWinningProvider.notifier).check(
                userNumberIds: numberIds,
              );
              
              if (context.mounted) {
                final result = ref.read(checkWinningProvider).value;
                if (result != null) {
                  _showWinningResults(context, result);
                }
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  void _showWinningResults(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('당첨 확인 결과'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('총 ${result.totalChecked}개 확인 완료'),
              const SizedBox(height: 16),
              ...result.results.map<Widget>((r) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // 2026-01-16 EST - Phase 1.3: 공통 위젯 사용
                      WinningBadge(rank: r.winningRank),
                      const SizedBox(width: 8),
                      Text('${r.matchedCount}개 일치'),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
