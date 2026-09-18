import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/presentation/widgets/number_card.dart';
import 'package:pick_wizard/presentation/providers/my_numbers_provider.dart';

/// 번호 생성 결과 화면
/// 
/// 2026-01-05 16:35:00 EST - 초기 생성
/// 2026-01-16 EST - 저장 기능 추가 (my_numbers_provider 연동)
/// 2026-01-16 EST - 다국어 문자열 적용 (context.l10n 사용)
class ResultScreen extends ConsumerWidget {
  final GeneratedNumbers generated;
  
  const ResultScreen({
    super.key,
    required this.generated,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saveState = ref.watch(saveMyNumbersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.generationResult),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 공유 기능
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 알고리즘 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    generated.algorithmName,
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
          
          // 생성된 번호 세트들
          // 2026-01-08 06:33:00 EST - results 리스트 사용
          ...generated.results.map((result) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NumberCard(
                numbers: result.numbers,
                setNumber: result.setNo,
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // 저장 버튼
          ElevatedButton(
            onPressed: saveState.isLoading
                ? null
                : () {
                    _showSaveDialog(context, ref);
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: saveState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(context.l10n.saveAsMyNumbers),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  void _showSaveDialog(BuildContext context, WidgetRef ref) {
    final memoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.saveAsMyNumbers),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.saveSetsMessage(generated.setCount),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memoController,
              decoration: InputDecoration(
                labelText: context.l10n.memoOptional,
                hintText: context.l10n.memoExample,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // 각 세트를 개별 저장
              for (final result in generated.results) {
                await ref.read(saveMyNumbersProvider.notifier).save(
                  numbers: result.numbers,
                  algorithmId: generated.algorithmId,
                  algorithmName: generated.algorithmName,
                  memo: memoController.text.isEmpty ? null : memoController.text,
                );
              }
              
              if (context.mounted) {
                final state = ref.read(saveMyNumbersProvider);
                state.whenOrNull(
                  data: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.numbersSaved(generated.setCount)),
                        backgroundColor: AppColors.success,
                        action: SnackBarAction(
                          label: context.l10n.view,
                          textColor: Colors.white,
                          onPressed: () {
                            // TODO: 내 번호 화면으로 이동
                          },
                        ),
                      ),
                    );
                  },
                  error: (error, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.saveFailed(error.toString())),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                );
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}

