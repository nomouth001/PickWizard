import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/presentation/providers/my_numbers_provider.dart';
import 'package:pick_wizard/presentation/providers/lotto_provider.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';

/// 당첨 확인 화면
/// 
/// 2026-01-16 EST - 초기 생성
class WinningCheckScreen extends ConsumerStatefulWidget {
  const WinningCheckScreen({super.key});
  
  @override
  ConsumerState<WinningCheckScreen> createState() => _WinningCheckScreenState();
}

class _WinningCheckScreenState extends ConsumerState<WinningCheckScreen> {
  final Set<int> _selectedIds = {};
  int? _selectedDrawNo;
  
  @override
  Widget build(BuildContext context) {
    final myNumbersAsync = ref.watch(myNumbersProvider);
    final latestDrawAsync = ref.watch(latestDrawProvider);
    final checkWinningState = ref.watch(checkWinningProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('당첨 확인'),
      ),
      body: Column(
        children: [
          // 회차 선택 카드
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '확인할 회차',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  latestDrawAsync.when(
                    data: (draw) {
                      if (draw == null) {
                        return const Text('최신 회차를 불러올 수 없습니다');
                      }
                      
                      final drawNo = _selectedDrawNo ?? draw.drawNo;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${drawNo}회',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedDrawNo == null)
                                    Text(
                                      '최신 회차',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.grey600,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  // 당첨번호 표시
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ...draw.numbers.map((num) => LottoBall(number: num, size: 32)),
                                      const SizedBox(width: 4),
                                      LottoBall(number: draw.bonus, size: 32, isBonus: true),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('오류가 발생했습니다'),
                  ),
                ],
              ),
            ),
          ),
          
          // 내 번호 선택
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '확인할 번호 선택',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final numbers = ref.read(myNumbersProvider).value ?? [];
                      if (_selectedIds.length == numbers.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(numbers.map((n) => n.id));
                      }
                    });
                  },
                  child: Text(_selectedIds.isEmpty ? '전체 선택' : '선택 해제'),
                ),
              ],
            ),
          ),
          
          // 내 번호 목록
          Expanded(
            child: myNumbersAsync.when(
              data: (numbers) {
                if (numbers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '저장된 번호가 없습니다',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: numbers.length,
                  itemBuilder: (context, index) {
                    final number = numbers[index];
                    final isSelected = _selectedIds.contains(number.id);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(number.id);
                            } else {
                              _selectedIds.add(number.id);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedIds.add(number.id);
                                    } else {
                                      _selectedIds.remove(number.id);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (number.algorithmName != null)
                                      Text(
                                        number.algorithmName!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: number.numbers.map((num) {
                                        return LottoBall(number: num, size: 36);
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('오류가 발생했습니다')),
            ),
          ),
          
          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty || checkWinningState.isLoading
                    ? null
                    : () async {
                        final drawNo = _selectedDrawNo ?? 
                            (ref.read(latestDrawProvider).value?.drawNo);
                        
                        await ref.read(checkWinningProvider.notifier).check(
                          userNumberIds: _selectedIds.toList(),
                          drawNo: drawNo,
                        );
                        
                        if (mounted) {
                          final state = ref.read(checkWinningProvider);
                          state.whenOrNull(
                            data: (result) {
                              if (result != null) {
                                _showResultDialog(context, result);
                              }
                            },
                            error: (error, _) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('오류: $error'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            },
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: checkWinningState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        '${_selectedIds.length}개 번호 확인하기',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showResultDialog(BuildContext context, dynamic result) {
    final winCount = result.results.where((r) => !r.winningRank.contains('없음')).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              winCount > 0 ? Icons.celebration : Icons.info_outline,
              color: winCount > 0 ? AppColors.success : AppColors.grey600,
            ),
            const SizedBox(width: 8),
            const Text('당첨 확인 결과'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: winCount > 0 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${result.totalChecked}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('확인 완료'),
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
                          '$winCount',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: winCount > 0 ? AppColors.success : null,
                          ),
                        ),
                        const Text('당첨'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              ...result.results.map<Widget>((r) {
                final isWin = !r.winningRank.contains('없음');
                
                return Card(
                  color: isWin 
                      ? AppColors.success.withOpacity(0.1)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.winningRank,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isWin ? AppColors.success : AppColors.grey600,
                              ),
                            ),
                            Text('${r.matchedCount}개 일치'),
                          ],
                        ),
                        if (r.hasBonus)
                          Text(
                            '보너스 번호 일치',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
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
