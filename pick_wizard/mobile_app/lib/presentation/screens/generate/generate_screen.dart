import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/constants/parameter_presets.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/data/help/algorithm_help_data.dart';
import 'package:pick_wizard/data/models/algorithm_info.dart';
import 'package:pick_wizard/presentation/providers/lotto_provider.dart';
import 'package:pick_wizard/presentation/screens/generate/result_screen.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';
import 'package:pick_wizard/services/ads/ad_service.dart';

/// 라디오 옵션
class RadioOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final String? helpKey;  // 도움말 키 추가
  
  const RadioOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.helpKey,
  });
}

/// 드롭다운 옵션
class DropdownOption<T> {
  final T value;
  final String label;
  
  const DropdownOption({
    required this.value,
    required this.label,
  });
}

/// 번호 생성 화면
/// 
/// 2026-01-05 16:35:00 EST - 초기 생성
/// 2026-01-16 EST - 생성 개수 UI 개선: 슬라이더 제거, 퀵 버튼(5개/10개) + 숫자 직접 입력 기능 추가
/// 2026-01-16 EST - 기본 알고리즘 선택(자동선택), 5개 버튼 선택, 비활성화 버튼 클릭 시 안내 모달
/// 2026-01-16 EST - 다국어 지원 적용
/// 2026-01-16 EST - 기본 알고리즘 선택 로직 수정: build 메서드에서 알고리즘 로드 후 자동 선택
/// 2026-01-17 EST - 확장형 UI 구조로 변경: 알고리즘 선택 시 파라미터+생성개수+버튼이 확장 영역에 표시
class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});
  
  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  bool _showTextField = false;
  final TextEditingController _numberController = TextEditingController();
  bool _hasSetDefaultAlgorithm = false; // 기본 알고리즘 설정 완료 플래그
  
  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final algorithmsAsync = ref.watch(algorithmsProvider);
    final selectedAlgorithm = ref.watch(selectedAlgorithmProvider);
    final numberOfSets = ref.watch(numberOfSetsProvider);
    final generateState = ref.watch(generateStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.selectAlgorithm),
      ),
      body: algorithmsAsync.when(
        data: (algorithms) {
          if (algorithms.isEmpty) {
            return Center(child: Text(context.l10n.errorLoadAlgorithms));
          }
          
          // 2026-01-16 EST - 알고리즘이 로드되고 아직 선택된 알고리즘이 없으면 기본값 설정
          if (!_hasSetDefaultAlgorithm && selectedAlgorithm == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final defaultAlgorithm = algorithms.firstWhere(
                (algo) => algo.id == 1,
                orElse: () => algorithms.first,
              );
              ref.read(selectedAlgorithmProvider.notifier).state = defaultAlgorithm;
              _hasSetDefaultAlgorithm = true;
            });
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 2026-01-17 EST - 확장형 UI: 알고리즘 선택 + 확장 영역 통합
              _buildAlgorithmSelectorWithExpansion(
                context, 
                algorithms, 
                selectedAlgorithm, 
                numberOfSets, 
                generateState
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${context.l10n.error}: $error')),
      ),
    );
  }
  
  // 2026-01-17 EST - 확장형 알고리즘 선택기 (통합 버전)
  Widget _buildAlgorithmSelectorWithExpansion(
    BuildContext context,
    List algorithms,
    selectedAlgorithm,
    int numberOfSets,
    AsyncValue generateState,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 카드 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l10n.algorithmSelection,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // 알고리즘 목록
          ...algorithms.map((algo) {
            final isSelected = selectedAlgorithm?.id == algo.id;
            
            return Column(
              children: [
                // 알고리즘 선택 타일
                RadioListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          algo.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      _buildAlgorithmHelpButton(algo.id),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(algo.description),
                      const SizedBox(height: 4),
                      Text(
                        algo.costString,
                        style: TextStyle(
                          color: algo.isFree ? AppColors.success : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  value: algo.id,
                  groupValue: selectedAlgorithm?.id,
                  onChanged: (value) {
                    ref.read(selectedAlgorithmProvider.notifier).state = algo;
                  },
                  selected: isSelected,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                
                // 확장 영역 (선택된 알고리즘만 표시)
                if (isSelected)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 파라미터 섹션 (알고리즘별로 다름)
                          // 2026-01-17 EST - Phase 3+4: 모든 알고리즘 파라미터 구현
                          // 038: 알고리즘 9 (몬테카를로 상위 6개) - 파라미터 없음
                          if (algo.id == 9) ...[
                            // 파라미터 없음 (자동선택과 동일)
                          ] else if (algo.id == 2) ...[
                            _buildAdvancedFrequencyParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 3) ...[
                            _buildLSTMParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 4) ...[
                            _buildPatternParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 5) ...[
                            _buildWeightedParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 6) ...[
                            _buildFrequencyParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 7) ...[
                            _buildHotColdParameters(algo.id),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ] else if (algo.id == 8) ...[
                            // 2026-01-18 22:00:00 EST - windowSize 전달
                            _buildAISelectionParameters(algo.id, algo.windowSize),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                          ],
                          
                          // 생성 개수 섹션 (공통)
                          _buildNumberOfSetsInline(context, numberOfSets, selectedAlgorithm),
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // 생성 버튼 (공통)
                          _buildGenerateButtonInline(
                            context, 
                            selectedAlgorithm, 
                            numberOfSets, 
                            generateState
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 구분선 (마지막 알고리즘 제외)
                if (algo != algorithms.last)
                  const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
  
  // 2026-01-17 EST - 인라인 생성 개수 선택 (확장 영역 내부용)
  // 2026-01-18 EST - AI Selection(알고리즘 8)일 때는 5/10만 표시 (직접입력 제거)
  Widget _buildNumberOfSetsInline(BuildContext context, int numberOfSets, AlgorithmInfo? selectedAlgorithm) {
    // AI Selection 여부 확인
    final isAISelection = selectedAlgorithm?.id == 8;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 + 현재 선택된 개수
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.numberOfSets,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.numberOfSetsCount(numberOfSets),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 퀵 선택 버튼 (AI Selection: 2개, 다른 알고리즘: 3개)
        Row(
          children: [
            // [5개] 버튼
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(numberOfSetsProvider.notifier).state = 5;
                  setState(() {
                    _showTextField = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: (numberOfSets == 5 && !_showTextField)
                      ? AppColors.primary.withOpacity(0.1) 
                      : null,
                  side: BorderSide(
                    color: (numberOfSets == 5 && !_showTextField)
                        ? AppColors.primary 
                        : Colors.grey,
                    width: (numberOfSets == 5 && !_showTextField) ? 2 : 1,
                  ),
                ),
                child: Text(
                  context.l10n.quickButton5,
                  style: TextStyle(
                    color: (numberOfSets == 5 && !_showTextField)
                        ? AppColors.primary 
                        : Colors.grey[700],
                    fontWeight: (numberOfSets == 5 && !_showTextField)
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // [10개] 버튼
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref.read(numberOfSetsProvider.notifier).state = 10;
                  setState(() {
                    _showTextField = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: (numberOfSets == 10 && !_showTextField)
                      ? AppColors.primary.withOpacity(0.1) 
                      : null,
                  side: BorderSide(
                    color: (numberOfSets == 10 && !_showTextField)
                        ? AppColors.primary 
                        : Colors.grey,
                    width: (numberOfSets == 10 && !_showTextField) ? 2 : 1,
                  ),
                ),
                child: Text(
                  context.l10n.quickButton10,
                  style: TextStyle(
                    color: (numberOfSets == 10 && !_showTextField)
                        ? AppColors.primary 
                        : Colors.grey[700],
                    fontWeight: (numberOfSets == 10 && !_showTextField)
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            
            // [숫자 직접 입력] 버튼 - AI Selection에서는 숨김
            if (!isAISelection) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showTextField = !_showTextField;
                      if (_showTextField) {
                        _numberController.text = numberOfSets.toString();
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _showTextField 
                        ? AppColors.primary.withOpacity(0.1) 
                        : null,
                    side: BorderSide(
                      color: _showTextField 
                          ? AppColors.primary 
                          : Colors.grey,
                      width: _showTextField ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    context.l10n.directInput,
                    style: TextStyle(
                      color: _showTextField 
                          ? AppColors.primary 
                          : Colors.grey[700],
                      fontWeight: _showTextField 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // TextField (조건부 표시)
        if (_showTextField) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            maxLength: 3,
            decoration: InputDecoration(
              labelText: context.l10n.enterNumberOfSets,
              hintText: context.l10n.range1To100,
              suffixText: context.l10n.setsUnit,
              border: const OutlineInputBorder(),
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isEmpty) return;
              
              final number = int.tryParse(value);
              if (number == null) return;
              
              // 100 초과 시 모달 표시
              if (number > 100) {
                _showMaxLimitDialog(context);
                _numberController.text = '100';
                ref.read(numberOfSetsProvider.notifier).state = 100;
                return;
              }
              
              // 0 이하 시 1로 설정
              if (number < 1) {
                _numberController.text = '1';
                ref.read(numberOfSetsProvider.notifier).state = 1;
                return;
              }
              
              // 정상 범위
              ref.read(numberOfSetsProvider.notifier).state = number;
            },
          ),
        ],
      ],
    );
  }
  
  // 2026-01-17 EST - 인라인 생성 버튼 (확장 영역 내부용)
  Widget _buildGenerateButtonInline(
    BuildContext context,
    selectedAlgorithm,
    int numberOfSets,
    AsyncValue generateState,
  ) {
    final isLoading = generateState.isLoading;
    final isDisabled = selectedAlgorithm == null || isLoading;
    
    return ElevatedButton.icon(
      onPressed: isDisabled
          ? () {
              _showRequirementDialog(context, selectedAlgorithm, numberOfSets);
            }
          : () async {
              // 2026-01-18 EST - AI Selection 알고리즘일 때 특별한 로딩 모달 표시
              if (selectedAlgorithm.id == 8) {
                // AI 분석 중 모달 표시
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => WillPopScope(
                    onWillPop: () async => false,
                    child: Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, 
                                  color: Colors.blue[700], 
                                  size: 28
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI가 번호를 생성 중입니다',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              // 2026-01-18 21:30:00 EST - 하드코딩된 "200회차" 제거, API windowSize 사용
                              '${selectedAlgorithm?.windowSize ?? 100}회차 데이터를 분석하고 있습니다...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '약 5~10초가 소요됩니다',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              // 041: 번호 생성 액션 시 광고 정책용 카운트 증가
              AdService.instance.incrementActionCount();
              // 번호 생성
              final request = GenerateRequest(
                algorithmId: selectedAlgorithm.id,
                nSets: numberOfSets,
              );
              
              await ref.read(generateStateProvider.notifier).generate(request);
              
              // AI Selection 모달 닫기
              if (selectedAlgorithm.id == 8 && context.mounted) {
                Navigator.of(context).pop();
              }
              
              // 결과 확인 및 화면 이동
              if (!context.mounted) return;
              
              final state = ref.read(generateStateProvider);
              
              if (state.hasValue && state.value != null) {
                // 생성 성공 - 결과 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(generated: state.value!),
                  ),
                );
                // 041: 전면 광고 노출 시도 (정책: 간격/횟수/확률은 어댑터에서 처리)
                AdService.instance.showInterstitial();
              } else if (state.hasError) {
                // 생성 실패 - 에러 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.errorGenerateFailed(state.error.toString())),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: isDisabled ? Colors.grey : AppColors.primary,
      ),
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.casino),
      label: Text(
        context.l10n.generateButton,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  // 2026-01-17 EST - 기존 메서드들 (사용 안 함, 삭제 예정)
  /*
  Widget _buildAlgorithmSelector(
    BuildContext context,
    List algorithms,
    selectedAlgorithm,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.algorithmSelection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            ...algorithms.map((algo) {
              final isSelected = selectedAlgorithm?.id == algo.id;
              return RadioListTile(
                title: Text(algo.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(algo.description),
                    const SizedBox(height: 4),
                    Text(
                      algo.costString,
                      style: TextStyle(
                        color: algo.isFree ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: algo.id,
                groupValue: selectedAlgorithm?.id,
                onChanged: (value) {
                  ref.read(selectedAlgorithmProvider.notifier).state = algo;
                },
                selected: isSelected,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  */
  
  /*
  // 2026-01-16 EST - 생성 개수 UI 개선: 퀵 버튼 + 숫자 직접 입력
  Widget _buildNumberOfSets(BuildContext context, int numberOfSets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 + 현재 선택된 개수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.numberOfSets,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  context.l10n.numberOfSetsCount(numberOfSets),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 퀵 선택 버튼 3개
            Row(
              children: [
                // [5개] 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(numberOfSetsProvider.notifier).state = 5;
                      setState(() {
                        _showTextField = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: (numberOfSets == 5 && !_showTextField)
                          ? AppColors.primary.withOpacity(0.1) 
                          : null,
                      side: BorderSide(
                        color: (numberOfSets == 5 && !_showTextField)
                            ? AppColors.primary 
                            : Colors.grey,
                        width: (numberOfSets == 5 && !_showTextField) ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      context.l10n.quickButton5,
                      style: TextStyle(
                        color: (numberOfSets == 5 && !_showTextField)
                            ? AppColors.primary 
                            : Colors.grey[700],
                        fontWeight: (numberOfSets == 5 && !_showTextField)
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // [10개] 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(numberOfSetsProvider.notifier).state = 10;
                      setState(() {
                        _showTextField = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: (numberOfSets == 10 && !_showTextField)
                          ? AppColors.primary.withOpacity(0.1) 
                          : null,
                      side: BorderSide(
                        color: (numberOfSets == 10 && !_showTextField)
                            ? AppColors.primary 
                            : Colors.grey,
                        width: (numberOfSets == 10 && !_showTextField) ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      context.l10n.quickButton10,
                      style: TextStyle(
                        color: (numberOfSets == 10 && !_showTextField)
                            ? AppColors.primary 
                            : Colors.grey[700],
                        fontWeight: (numberOfSets == 10 && !_showTextField)
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // [숫자 직접 입력] 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showTextField = !_showTextField;
                        if (_showTextField) {
                          _numberController.text = numberOfSets.toString();
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _showTextField 
                          ? AppColors.primary.withOpacity(0.1) 
                          : null,
                      side: BorderSide(
                        color: _showTextField 
                            ? AppColors.primary 
                            : Colors.grey,
                        width: _showTextField ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      context.l10n.directInput,
                      style: TextStyle(
                        color: _showTextField 
                            ? AppColors.primary 
                            : Colors.grey[700],
                        fontWeight: _showTextField 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // TextField (조건부 표시)
            if (_showTextField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  labelText: context.l10n.enterNumberOfSets,
                  hintText: context.l10n.rangeHint,
                  suffixText: context.l10n.setsUnit,
                  border: const OutlineInputBorder(),
                  counterText: '', // 2026-01-16 EST - "1/3" 카운터 숨김
                ),
                onChanged: (value) {
                  if (value.isEmpty) return;
                  
                  final number = int.tryParse(value);
                  if (number == null) return;
                  
                  // 100 초과 시 모달 표시
                  if (number > 100) {
                    _showMaxLimitDialog(context);
                    _numberController.text = '100';
                    ref.read(numberOfSetsProvider.notifier).state = 100;
                    return;
                  }
                  
                  // 0 이하 시 1로 설정
                  if (number < 1) {
                    _numberController.text = '1';
                    ref.read(numberOfSetsProvider.notifier).state = 1;
                    return;
                  }
                  
                  // 정상 범위
                  ref.read(numberOfSetsProvider.notifier).state = number;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  */
  
  // 2026-01-17 EST - 100개 초과 시 경고 모달 (유지)
  void _showMaxLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(context.l10n.maxLimitTitle),
          ],
        ),
        content: Text(context.l10n.maxLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }
  
  /*
  // 2026-01-16 EST - 번호 생성 버튼 (비활성화 시 안내 모달 추가)
  Widget _buildGenerateButton(
    BuildContext context,
    selectedAlgorithm,
    int numberOfSets,
    AsyncValue generateState,
  ) {
    final isLoading = generateState.isLoading;
    final isDisabled = selectedAlgorithm == null || isLoading;
    
    return ElevatedButton(
      onPressed: isDisabled
          ? () {
              // 2026-01-16 EST - 비활성화 상태에서 클릭 시 안내 모달
              _showRequirementDialog(context, selectedAlgorithm, numberOfSets);
            }
          : () async {
              // 2026-01-08 06:42:00 EST - 네비게이션 로직 수정
              // 041: 번호 생성 액션 시 광고 정책용 카운트 증가
              AdService.instance.incrementActionCount();
              // 번호 생성
              final request = GenerateRequest(
                algorithmId: selectedAlgorithm.id,
                nSets: numberOfSets,
              );
              
              await ref.read(generateStateProvider.notifier).generate(request);
              
              // 결과 확인 및 화면 이동
              if (!context.mounted) return;
              
              final state = ref.read(generateStateProvider);
              
              if (state.hasValue && state.value != null) {
                // 생성 성공 - 결과 화면으로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(generated: state.value!),
                  ),
                );
                // 041: 전면 광고 노출 시도
                AdService.instance.showInterstitial();
              } else if (state.hasError) {
                // 생성 실패 - 에러 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.errorGenerateFailed(state.error.toString())),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: isDisabled ? Colors.grey : null,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Text(
              context.l10n.generateButton,
              style: const TextStyle(fontSize: 18),
            ),
    );
  }
  */
  
  // 2026-01-16 EST - 필수 입력 안내 모달 (유지)
  void _showRequirementDialog(BuildContext context, selectedAlgorithm, int numberOfSets) {
    String message = '';
    
    if (selectedAlgorithm == null) {
      message = context.l10n.requirementSelectAlgorithm;
    } else if (numberOfSets < 1 || numberOfSets > 100) {
      message = context.l10n.requirementSelectCount;
    } else {
      message = context.l10n.requirementSelectBoth;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(context.l10n.requirementTitle),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }
  
  // ========================================
  // 2026-01-17 EST - Phase 2: 공통 컴포넌트
  // ========================================
  
  /// 섹션 헤더
  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    String? helpKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (helpKey != null) ...[
              const SizedBox(width: 4),
              _buildParameterHelpButton(
                ref.watch(selectedAlgorithmProvider)?.id ?? 1,
                helpKey,
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
  
  /// 슬라이더 (정수형)
  /// 체크박스
  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    int? algorithmId,
    String? helpKey,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            // 도움말 버튼
            if (helpKey != null && algorithmId != null)
              _buildParameterHelpButton(algorithmId, helpKey),
          ],
        ),
      ),
    );
  }
  
  /// 라디오 그룹
  Widget _buildRadioGroup<T>(
    String label,
    T value,
    List<RadioOption<T>> options,
    ValueChanged<T> onChanged, {
    int? algorithmId,
    String? helpKey,
    bool showOptionHelp = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 + 도움말 버튼
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (helpKey != null && algorithmId != null) ...[
              const SizedBox(width: 4),
              _buildParameterHelpButton(algorithmId, helpKey),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...options.map((option) => InkWell(
          onTap: () => onChanged(option.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Radio<T>(
                  value: option.value,
                  groupValue: value,
                  onChanged: (newValue) {
                    if (newValue != null) onChanged(newValue);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.label,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                // 옵션별 도움말 버튼
                if (showOptionHelp && option.helpKey != null && algorithmId != null)
                  _buildParameterHelpButton(algorithmId, option.helpKey!),
              ],
            ),
          ),
        )),
      ],
    );
  }
  
  /// 드롭다운
  Widget _buildDropdown<T>(
    String label,
    T value,
    List<DropdownOption<T>> options,
    ValueChanged<T> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) => DropdownMenuItem<T>(
            value: option.value,
            child: Text(option.label),
          )).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }
  
  // ========================================
  // 2026-01-17 EST - Phase 5-1: 프리셋 + 직접 입력 위젯
  // ========================================
  
  /// 정수형 프리셋 + 직접 입력
  Widget _buildIntInput(
    String label,
    String paramKey,
    int algorithmId,
    int value, {
    bool showHelp = true,
  }) {
    final presets = ParameterPresets.getIntPresets(paramKey);
    final (min, max) = ParameterRanges.getIntRange(paramKey);
    final unit = ParameterRanges.getUnit(paramKey);
    
    // 2026-01-17 19:30:00 EST - 9999를 "전체"로 표시
    String formatValue(int val) {
      if (val == 9999) return '전체';
      return val.toString();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 + 도움말 버튼
        Row(
          children: [
            Text(
              '$label ($min~전체$unit)',
              style: const TextStyle(fontSize: 13),
            ),
            if (showHelp) ...[
              const SizedBox(width: 4),
              _buildParameterHelpButton(algorithmId, paramKey),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // 현재 값 표시
        Text(
          '현재: ${formatValue(value)} $unit',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        
        // 프리셋 버튼들
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((preset) => _buildPresetButton(
              formatValue(preset),
              value == preset,
              () {
                ref.read(algorithmParametersProvider.notifier)
                    .updateParameter(algorithmId, paramKey, preset);
              },
              unit: unit,
            )),
            // 직접 입력 버튼
            _buildDirectInputButton(
              () => _showIntInputDialog(
                context, value, min, max, unit,
                (newValue) {
                  ref.read(algorithmParametersProvider.notifier)
                      .updateParameter(algorithmId, paramKey, newValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 실수형 프리셋 + 직접 입력
  Widget _buildDoubleInput(
    String label,
    String paramKey,
    int algorithmId,
    double value, {
    bool isPercent = false,
    bool showHelp = true,
  }) {
    final presets = ParameterPresets.getDoublePresets(paramKey);
    final (min, max) = ParameterRanges.getDoubleRange(paramKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 + 도움말 버튼
        Row(
          children: [
            Text(
              '$label (${isPercent ? '${(min * 100).toInt()}~${(max * 100).toInt()}%' : '$min~$max'})',
              style: const TextStyle(fontSize: 13),
            ),
            if (showHelp) ...[
              const SizedBox(width: 4),
              _buildParameterHelpButton(algorithmId, paramKey),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // 현재 값 표시
        Text(
          isPercent 
              ? '현재: ${(value * 100).toInt()}%'
              : '현재: ${value.toStringAsFixed(1)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        
        // 프리셋 버튼들
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((preset) => _buildPresetButton(
              isPercent 
                  ? '${(preset * 100).toInt()}%'
                  : preset.toStringAsFixed(1),
              (value - preset).abs() < 0.01,
              () {
                ref.read(algorithmParametersProvider.notifier)
                    .updateParameter(algorithmId, paramKey, preset);
              },
            )),
            // 직접 입력 버튼
            _buildDirectInputButton(
              () => _showDoubleInputDialog(
                context, value, min, max, isPercent,
                (newValue) {
                  ref.read(algorithmParametersProvider.notifier)
                      .updateParameter(algorithmId, paramKey, newValue);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// 프리셋 버튼
  Widget _buildPresetButton(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    String? unit,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected 
            ? AppColors.primary.withOpacity(0.1)
            : null,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(50, 36),
      ),
      child: Text(
        // 2026-01-17 19:30:00 EST - "전체"는 단위 붙이지 않음
        (unit != null && !label.contains(unit) && label != '전체') 
            ? '$label$unit' 
            : label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
  
  /// 직접 입력 버튼
  Widget _buildDirectInputButton(VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(70, 36),
      ),
      child: const Text(
        '직접입력',
        style: TextStyle(fontSize: 13),
      ),
    );
  }
  
  /// 정수 직접 입력 다이얼로그
  void _showIntInputDialog(
    BuildContext context,
    int currentValue,
    int min,
    int max,
    String unit,
    ValueChanged<int> onChanged,
  ) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('직접 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '범위: $min ~ $max $unit',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '값 입력',
                suffixText: unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value == null) {
                Navigator.pop(dialogContext);
                _showRangeErrorDialog(context, '숫자를 입력해주세요.');
                return;
              }
              if (value < min || value > max) {
                Navigator.pop(dialogContext);
                _showRangeErrorDialog(
                  context,
                  '범위를 벗어났습니다.\n$min ~ $max $unit 범위 내에서 입력해주세요.',
                );
                return;
              }
              onChanged(value);
              Navigator.pop(dialogContext);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  /// 실수 직접 입력 다이얼로그
  void _showDoubleInputDialog(
    BuildContext context,
    double currentValue,
    double min,
    double max,
    bool isPercent,
    ValueChanged<double> onChanged,
  ) {
    final displayValue = isPercent 
        ? (currentValue * 100).toInt().toString()
        : currentValue.toStringAsFixed(1);
    final controller = TextEditingController(text: displayValue);
    
    final displayMin = isPercent ? (min * 100).toInt() : min;
    final displayMax = isPercent ? (max * 100).toInt() : max;
    final unit = isPercent ? '%' : '';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('직접 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '범위: $displayMin ~ $displayMax$unit',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: '값 입력',
                suffixText: unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final inputValue = double.tryParse(controller.text);
              if (inputValue == null) {
                Navigator.pop(dialogContext);
                _showRangeErrorDialog(context, '숫자를 입력해주세요.');
                return;
              }
              
              // 퍼센트인 경우 0~100 입력 → 0.0~1.0 변환
              final actualValue = isPercent ? inputValue / 100 : inputValue;
              
              if (actualValue < min || actualValue > max) {
                Navigator.pop(dialogContext);
                _showRangeErrorDialog(
                  context,
                  '범위를 벗어났습니다.\n$displayMin ~ $displayMax$unit 범위 내에서 입력해주세요.',
                );
                return;
              }
              onChanged(actualValue);
              Navigator.pop(dialogContext);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  /// 범위 오류 다이얼로그
  void _showRangeErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('입력 오류'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  // ========================================
  // 2026-01-17 EST - Phase 2+3+4: 알고리즘별 파라미터 위젯
  // ========================================
  
  /// 알고리즘 2: 고급 빈도 분석 파라미터
  Widget _buildAdvancedFrequencyParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📊 분석 범위',
        ),
        
        _buildRadioGroup<String>(
          '데이터 범위',
          params['window_type'] as String,
          const [
            RadioOption(
              value: 'all', 
              label: '전체 데이터',
              helpKey: 'window_type_all',
            ),
            RadioOption(
              value: 'recent', 
              label: '최근 N회차',
              helpKey: 'window_type_recent',
            ),
          ],
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'window_type', value);
          },
          algorithmId: algorithmId,
          helpKey: 'window_type',
          showOptionHelp: true,
        ),
        
        if (params['window_type'] == 'recent') ...[
          const SizedBox(height: 8),
          _buildIntInput(
            '회차 수',
            'window_size',
            algorithmId,
            params['window_size'] as int,
          ),
        ],
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '🚫 제외 필터',
        ),
        
        _buildCheckbox(
          '연속 출현 제외',
          params['exclude_consecutive_2'] as bool,
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'exclude_consecutive_2', value);
          },
          algorithmId: algorithmId,
          helpKey: 'exclude_consecutive_2',
        ),
        
        _buildCheckbox(
          '고빈도 번호 제외',
          params['exclude_frequent'] as bool,
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'exclude_frequent', value);
          },
          algorithmId: algorithmId,
          helpKey: 'exclude_frequent',
        ),
        
        if (params['exclude_frequent'] as bool) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: [
                _buildIntInput(
                  '조회 회차',
                  'frequent_lookback',
                  algorithmId,
                  params['frequent_lookback'] as int,
                ),
                const SizedBox(height: 8),
                _buildIntInput(
                  '출현 기준',
                  'frequent_threshold',
                  algorithmId,
                  params['frequent_threshold'] as int,
                ),
              ],
            ),
          ),
        ],
        
        _buildCheckbox(
          '직전 회차 확률 할인',
          params['apply_recent_penalty'] as bool,
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'apply_recent_penalty', value);
          },
          algorithmId: algorithmId,
          helpKey: 'apply_recent_penalty',
        ),
        
        if (params['apply_recent_penalty'] as bool) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _buildDoubleInput(
              '할인율',
              'penalty_rate',
              algorithmId,
              params['penalty_rate'] as double,
              isPercent: true,
            ),
          ),
        ],
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '🎲 확률 모드',
        ),
        
        _buildRadioGroup<String>(
          '모드 선택',
          params['probability_mode'] as String,
          const [
            RadioOption(
              value: 'normal', 
              label: '정확률',
              helpKey: 'probability_mode_normal',
            ),
            RadioOption(
              value: 'inverse', 
              label: '역확률',
              helpKey: 'probability_mode_inverse',
            ),
          ],
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'probability_mode', value);
          },
          algorithmId: algorithmId,
          helpKey: 'probability_mode',
          showOptionHelp: true,
        ),
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '🎲 무작위성',
        ),
        
        _buildDoubleInput(
          '무작위성',
          'temperature',
          algorithmId,
          params['temperature'] as double,
        ),
      ],
    );
  }
  
  /// 알고리즘 3: LSTM 파라미터
  Widget _buildLSTMParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2026-01-17 19:15:00 EST - 학습 방식 UI 제거
        // 일반 사용자는 항상 'non-cumulative' (전체 학습)만 사용
        // 백엔드 파라미터는 유지 (어드민용 백테스팅에서 활용)
        
        _buildSectionHeader(
          '🎲 확률 방식',
          helpKey: 'probability_mode',
        ),
        
        _buildRadioGroup<String>(
          '모드 선택',
          params['probability_mode'] as String,
          const [
            RadioOption(
              value: 'normal',
              label: '정확률',
              helpKey: 'probability_mode_normal',
            ),
            RadioOption(
              value: 'inverse',
              label: '역확률',
              helpKey: 'probability_mode_inverse',
            ),
          ],
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'probability_mode', value);
          },
        ),
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '📊 학습 범위',
          helpKey: 'window_size',
        ),
        
        _buildIntInput(
          '회차 수',
          'window_size',
          algorithmId,
          params['window_size'] as int,
        ),
        
        const SizedBox(height: 20),
        
        // 고급 설정 안내
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.settings, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '고급 설정 (모델 구조, 학습 설정)은 기본값 사용',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 알고리즘 4: 패턴 분석 파라미터
  Widget _buildPatternParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '🎯 패턴 타입',
          helpKey: 'pattern_type',
        ),
        
        _buildRadioGroup<String>(
          '타입 선택',
          params['pattern_type'] as String,
          const [
            RadioOption(
              value: 'range',
              label: '범위 패턴',
              helpKey: 'pattern_type_range',
            ),
            RadioOption(
              value: 'rank',
              label: '순위 패턴',
              helpKey: 'pattern_type_rank',
            ),
          ],
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'pattern_type', value);
          },
        ),
        
        const SizedBox(height: 20),
        
        if (params['pattern_type'] == 'range') ...[
          _buildSectionHeader(
            '📐 범위 설정',
            helpKey: 'range_divisions',
          ),
          
          _buildDropdown<int>(
            '구간 수',
            params['range_divisions'] as int,
            const [
              DropdownOption(value: 2, label: '2구간 (L/H)'),
              DropdownOption(value: 3, label: '3구간 (L/M/H)'),
              DropdownOption(value: 5, label: '5구간 (A~E)'),
              DropdownOption(value: 10, label: '10구간 (A~J)'),
            ],
            (value) {
              ref.read(algorithmParametersProvider.notifier)
                  .updateParameter(algorithmId, 'range_divisions', value);
            },
          ),
        ] else ...[
          _buildSectionHeader(
            '📊 순위 설정',
            helpKey: 'rank_combo_size',
          ),
          
          _buildIntInput(
            '조합 크기',
            'rank_combo_size',
            algorithmId,
            params['rank_combo_size'] as int,
          ),
          
          const SizedBox(height: 12),
          
          _buildRadioGroup<String>(
            '순위 계산 방식',
            params['rank_mode'] as String,
            const [
              RadioOption(
                value: 'cumulative',
                label: '누적 빈도',
                helpKey: 'rank_mode_cumulative',
              ),
              RadioOption(
                value: 'recent',
                label: '최근 빈도',
                helpKey: 'rank_mode_recent',
              ),
            ],
            (value) {
              ref.read(algorithmParametersProvider.notifier)
                  .updateParameter(algorithmId, 'rank_mode', value);
            },
            helpKey: 'rank_mode',
          ),
          
          if (params['rank_mode'] == 'recent') ...[
            const SizedBox(height: 8),
            _buildIntInput(
              '최근 회차',
              'rank_window',
              algorithmId,
              params['rank_window'] as int,
            ),
          ],
        ],
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '🔝 상위 패턴 개수',
          helpKey: 'top_n_patterns',
        ),
        
        _buildIntInput(
          '패턴 수',
          'top_n_patterns',
          algorithmId,
          params['top_n_patterns'] as int,
        ),
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '🎲 패턴 내 번호 선택',
          helpKey: 'in_pattern_probability',
        ),
        
        _buildRadioGroup<String>(
          '선택 방식',
          params['in_pattern_probability'] as String,
          const [
            RadioOption(
              value: 'uniform',
              label: '균등',
              helpKey: 'in_pattern_probability_uniform',
            ),
            RadioOption(
              value: 'frequency',
              label: '빈도 기반',
              helpKey: 'in_pattern_probability_frequency',
            ),
            RadioOption(
              value: 'inverse',
              label: '역확률',
              helpKey: 'in_pattern_probability_inverse',
            ),
          ],
          (value) {
            ref.read(algorithmParametersProvider.notifier)
                .updateParameter(algorithmId, 'in_pattern_probability', value);
          },
        ),
      ],
    );
  }
  
  /// 알고리즘 5: 가중치 조합 파라미터
  Widget _buildWeightedParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    final total = (params['frequency_weight'] as double) +
                  (params['recency_weight'] as double) +
                  (params['zone_weight'] as double) +
                  (params['diversity_weight'] as double);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '⚖️ 가중치 설정',
          subtitle: '합계: ${(total * 100).toInt()}% (자동 정규화)',
        ),
        
        _buildDoubleInput(
          '📊 빈도 가중치',
          'frequency_weight',
          algorithmId,
          params['frequency_weight'] as double,
          isPercent: true,
        ),
        
        const SizedBox(height: 16),
        
        _buildDoubleInput(
          '⏰ 최근성 가중치',
          'recency_weight',
          algorithmId,
          params['recency_weight'] as double,
          isPercent: true,
        ),
        
        const SizedBox(height: 16),
        
        _buildDoubleInput(
          '📐 구간 균형 가중치',
          'zone_weight',
          algorithmId,
          params['zone_weight'] as double,
          isPercent: true,
        ),
        
        const SizedBox(height: 16),
        
        _buildDoubleInput(
          '🎨 다양성 가중치',
          'diversity_weight',
          algorithmId,
          params['diversity_weight'] as double,
          isPercent: true,
        ),
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '📊 분석 범위',
          helpKey: 'recent_draws',
        ),
        
        _buildIntInput(
          '최근 회차',
          'recent_draws',
          algorithmId,
          params['recent_draws'] as int,
        ),
      ],
    );
  }
  
  /// 알고리즘 6: 빈도 기반 파라미터
  Widget _buildFrequencyParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '📊 분석 범위',
          subtitle: '최근 N회차의 데이터만 사용',
          helpKey: 'recent_draws',
        ),
        
        _buildIntInput(
          '회차 수',
          'recent_draws',
          algorithmId,
          params['recent_draws'] as int,
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionHeader(
          '🎲 무작위성',
          subtitle: '낮을수록 고빈도 번호에 집중',
          helpKey: 'temperature',
        ),
        
        _buildDoubleInput(
          '무작위성',
          'temperature',
          algorithmId,
          params['temperature'] as double,
        ),
      ],
    );
  }
  
  /// 알고리즘 7: 핫/콜드 넘버 파라미터
  Widget _buildHotColdParameters(int algorithmId) {
    final allParams = ref.watch(algorithmParametersProvider);
    final params = allParams[algorithmId] ?? 
        ref.read(algorithmParametersProvider.notifier)
            .getParameters(algorithmId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          '🔥 Hot 번호',
          subtitle: '최근 자주 나온 번호',
          helpKey: 'hot_window',
        ),
        
        _buildIntInput(
          '분석 회차',
          'hot_window',
          algorithmId,
          params['hot_window'] as int,
        ),
        
        const SizedBox(height: 8),
        
        _buildIntInput(
          '선택 개수',
          'hot_count',
          algorithmId,
          params['hot_count'] as int,
        ),
        
        const SizedBox(height: 20),
        
        _buildSectionHeader(
          '❄️ Cold 번호',
          subtitle: '오랫동안 나오지 않은 번호',
          helpKey: 'cold_window',
        ),
        
        _buildIntInput(
          '분석 회차',
          'cold_window',
          algorithmId,
          params['cold_window'] as int,
        ),
        
        const SizedBox(height: 8),
        
        _buildIntInput(
          '선택 개수',
          'cold_count',
          algorithmId,
          params['cold_count'] as int,
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hot ${params['hot_count']}개 + Cold ${params['cold_count']}개 + 랜덤 ${6 - (params['hot_count'] as int) - (params['cold_count'] as int)}개',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 알고리즘 8: 인공지능 선택 파라미터
  /// 2026-01-18 EST - 파라미터 없음 (안내 메시지만 표시)
  /// 2026-01-18 22:00:00 EST - windowSize를 매개변수로 받음
  Widget _buildAISelectionParameters(int algorithmId, int? windowSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[700], size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '인공지능이 분석합니다',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            // 2026-01-18 21:30:00 EST - 하드코딩된 "200회차" 제거, API windowSize 사용
            'AI가 최근 ${windowSize ?? 100}회차의 당첨 번호를 분석하여 추천 번호를 생성합니다.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 6),
              Text(
                '소요 시간: 3~10초',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.wifi, size: 16, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                '안정적인 인터넷 연결 필요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // ========================================
  // 2026-01-17 EST - Phase 5-2: 도움말 시스템
  // ========================================
  
  /// 알고리즘 도움말 버튼
  Widget _buildAlgorithmHelpButton(int algorithmId) {
    return TextButton.icon(
      icon: Icon(
        Icons.help_outline,
        size: 18,
        color: Colors.blue[700],
      ),
      label: Text(
        '도움말',
        style: TextStyle(
          fontSize: 13,
          color: Colors.blue[700],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _showAlgorithmHelpModal(context, algorithmId),
    );
  }
  
  /// 파라미터 도움말 버튼
  Widget _buildParameterHelpButton(int algorithmId, String paramKey) {
    return TextButton.icon(
      icon: Icon(
        Icons.help_outline,
        size: 16,
        color: Colors.blue[600],
      ),
      label: Text(
        '도움말',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[600],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _showParameterHelpModal(context, algorithmId, paramKey),
    );
  }
  
  /// 알고리즘 도움말 모달
  void _showAlgorithmHelpModal(BuildContext context, int algorithmId) {
    final help = AlgorithmHelpData.get(algorithmId);
    if (help == null) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                help.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 개요
              _buildHelpSection(
                icon: Icons.description,
                title: '📖 개요',
                content: help.overview,
              ),
              
              const SizedBox(height: 16),
              
              // 동작 원리
              _buildHelpSection(
                icon: Icons.settings,
                title: '⚙️ 동작 원리',
                content: help.howItWorks,
              ),
              
              const SizedBox(height: 16),
              
              // 언제 사용하면 좋을까요?
              _buildHelpSection(
                icon: Icons.tips_and_updates,
                title: '💡 언제 사용하면 좋을까요?',
                content: help.whenToUse,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  /// 파라미터 도움말 모달
  void _showParameterHelpModal(
    BuildContext context,
    int algorithmId,
    String paramKey,
  ) {
    final help = AlgorithmHelpData.get(algorithmId);
    if (help == null) return;
    
    final paramHelp = help.parameters[paramKey];
    if (paramHelp == null) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue[600], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                paramHelp.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명
              _buildHelpSection(
                icon: Icons.description,
                title: '📝 설명',
                content: paramHelp.description,
              ),
              
              const SizedBox(height: 16),
              
              // 영향
              _buildHelpSection(
                icon: Icons.show_chart,
                title: '📊 영향',
                content: paramHelp.effect,
              ),
              
              const SizedBox(height: 16),
              
              // 추천값
              _buildHelpSection(
                icon: Icons.star,
                title: '💡 추천값',
                content: paramHelp.recommendation,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  /// 도움말 섹션 위젯
  Widget _buildHelpSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

