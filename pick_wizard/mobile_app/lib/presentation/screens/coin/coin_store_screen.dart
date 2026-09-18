import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/constants/feature_flags.dart';
import 'package:pick_wizard/presentation/providers/coin_provider.dart';

/// 코인 스토어 화면
/// 
/// 2026-01-16 EST - 초기 생성
/// 2026-02-20 - 043: useCoinAndWallet false 시 진입 시 안내 후 뒤로가기
class CoinStoreScreen extends ConsumerWidget {
  const CoinStoreScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.useCoinAndWallet) {
      return Scaffold(
        appBar: AppBar(title: const Text('코인 스토어')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  '코인 기능이 일시 비활성화되었습니다.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final coinBalanceAsync = ref.watch(coinBalanceProvider);
    final coinHistoryAsync = ref.watch(coinHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('코인 스토어'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(coinBalanceProvider);
          ref.invalidate(coinHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 코인 잔액 카드
            _buildBalanceCard(context, coinBalanceAsync),
            
            const SizedBox(height: 24),
            
            // 무료 코인 획득
            Text(
              '무료 코인 획득',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            _buildDailyLoginCard(context, ref),
            const SizedBox(height: 12),
            
            _buildAdRewardCard(context, ref),
            
            const SizedBox(height: 24),
            
            // 거래 내역
            Text(
              '거래 내역',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            _buildTransactionHistory(context, coinHistoryAsync),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBalanceCard(BuildContext context, AsyncValue coinBalanceAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: coinBalanceAsync.when(
          data: (balance) {
            if (balance == null) {
              return const Text('코인 정보를 불러올 수 없습니다');
            }
            
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 48,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${balance.totalCoins}',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '보유 코인',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                
                // 코인 상세 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${balance.freeCoins}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '무료 코인',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                    ),
                    Column(
                      children: [
                        Text(
                          '${balance.paidCoins}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '유료 코인',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Text('오류: $error'),
        ),
      ),
    );
  }
  
  Widget _buildDailyLoginCard(BuildContext context, WidgetRef ref) {
    final dailyLoginState = ref.watch(dailyLoginProvider);
    
    return Card(
      child: InkWell(
        onTap: dailyLoginState.isLoading
            ? null
            : () async {
                await ref.read(dailyLoginProvider.notifier).claim();
                
                if (context.mounted) {
                  final state = ref.read(dailyLoginProvider);
                  state.whenOrNull(
                    data: (result) {
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message ?? '일일 로그인 보상 지급!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    error: (error, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$error'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                  );
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 32,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '일일 로그인 보상',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '매일 10코인 무료 지급',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (dailyLoginState.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAdRewardCard(BuildContext context, WidgetRef ref) {
    final adRewardState = ref.watch(adRewardProvider);
    
    return Card(
      child: InkWell(
        onTap: adRewardState.isLoading
            ? null
            : () async {
                await ref.read(adRewardProvider.notifier).claim();
                
                if (context.mounted) {
                  final state = ref.read(adRewardProvider);
                  state.whenOrNull(
                    data: (result) {
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message ?? '광고 시청 보상 지급!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    error: (error, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$error'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                  );
                }
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '광고 시청 보상',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '광고 시청 시 5코인 지급',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (adRewardState.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTransactionHistory(BuildContext context, AsyncValue coinHistoryAsync) {
    return coinHistoryAsync.when(
      data: (history) {
        if (history == null || history.transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '거래 내역이 없습니다',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return Column(
          children: history.transactions.map((tx) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTransactionColor(tx.type).withOpacity(0.1),
                  child: Icon(
                    _getTransactionIcon(tx.type),
                    color: _getTransactionColor(tx.type),
                  ),
                ),
                title: Text(tx.description ?? tx.type),
                subtitle: Text(
                  _formatDate(tx.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${tx.amount > 0 ? '+' : ''}${tx.amount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: tx.amount > 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '잔액: ${tx.balanceAfter}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('오류: $error'),
        ),
      ),
    );
  }
  
  IconData _getTransactionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'EARN':
        return Icons.add_circle;
      case 'SPEND':
        return Icons.remove_circle;
      case 'DAILY_LOGIN':
        return Icons.calendar_today;
      case 'AD_REWARD':
        return Icons.play_circle_fill;
      default:
        return Icons.monetization_on;
    }
  }
  
  Color _getTransactionColor(String type) {
    switch (type.toUpperCase()) {
      case 'EARN':
      case 'DAILY_LOGIN':
      case 'AD_REWARD':
        return AppColors.success;
      case 'SPEND':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}분 전';
      }
      return '${diff.inHours}시간 전';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }
}
