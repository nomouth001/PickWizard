import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/constants/feature_flags.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/presentation/providers/lotto_provider.dart';
import 'package:pick_wizard/presentation/providers/coin_provider.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';
import 'package:pick_wizard/presentation/widgets/banner_ad_widget.dart';
import 'package:pick_wizard/presentation/screens/generate/generate_screen.dart';
import 'package:pick_wizard/presentation/screens/my_numbers/my_numbers_screen.dart';
import 'package:pick_wizard/presentation/screens/coin/coin_store_screen.dart';
import 'package:pick_wizard/presentation/screens/settings/settings_screen.dart';

/// 홈 화면
/// 
/// 2026-01-05 16:30:00 EST - 초기 생성
/// 2026-01-16 EST - 코인 시스템 추가, 네비게이션 연결, 언어 선택 UI 추가
/// 2026-01-16 EST - 다국어 문자열 적용 (context.l10n 사용)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDrawAsync = ref.watch(latestDrawProvider);
    final coinBalanceAsync = FeatureFlags.useCoinAndWallet
        ? ref.watch(coinBalanceProvider)
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeTitle),
        actions: [
          // 코인 잔액 표시 (043: useCoinAndWallet false 시 숨김)
          if (FeatureFlags.useCoinAndWallet)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CoinStoreScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: coinBalanceAsync.when(
                  data: (balance) {
                    if (balance == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${balance.totalCoins}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  error: (_, __) => const Icon(Icons.error_outline),
                ),
              ),
            ),
          // 설정 버튼
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestDrawProvider);
          if (FeatureFlags.useCoinAndWallet) {
            ref.invalidate(coinBalanceProvider);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 최신 당첨번호 카드
            _buildLatestDrawCard(context, latestDrawAsync),
            
            const SizedBox(height: 24),
            
            // 번호 생성 버튼
            _buildGenerateButton(context),
            
            const SizedBox(height: 16),
            
            // 내 번호 버튼
            _buildMyNumbersButton(context),
            
            const SizedBox(height: 16),
            
            // 통계 버튼
            _buildStatisticsButton(context),
            
            const SizedBox(height: 32),
            
            // 언어 선택 섹션
            // 2026-01-16 EST - 다국어 지원: 하단 국기 버튼으로 언어 선택
            _buildLanguageSelector(context, ref),
            const SizedBox(height: 16),
            // 041: 배너 광고
            const Center(child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLatestDrawCard(BuildContext context, AsyncValue latestDrawAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.latestWinningNumbers,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // TODO: 당첨 상세 보기
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            latestDrawAsync.when(
              data: (draw) {
                if (draw == null) {
                  return Text(context.l10n.errorLoadingData);
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draw.drawTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      draw.drawDateString,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // 당첨번호
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...draw.numbers.map((num) => LottoBall(number: num)),
                        const SizedBox(width: 8),
                        const Icon(Icons.add, size: 16),
                        const SizedBox(width: 8),
                        LottoBall(number: draw.bonus, isBonus: true),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Text(context.l10n.errorFormat(error.toString())),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGenerateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GenerateScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 28),
          const SizedBox(width: 12),
          Text(
            context.l10n.generateNumbers,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMyNumbersButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyNumbersScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(context.l10n.myNumbers),
    );
  }
  
  Widget _buildStatisticsButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: 통계 화면 이동 (Phase 7+)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.statisticsComingSoon)),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(context.l10n.statistics),
    );
  }
  
  // 2026-01-16 EST - 언어 선택 섹션 (하단 국기 버튼)
  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              context.l10n.selectLanguage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 국기 버튼들
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: SupportedLocales.locales.map((locale) {
                final isSelected = currentLocale.languageCode == locale.languageCode;
                
                return GestureDetector(
                  onTap: () {
                    // 언어 변경
                    ref.read(localeProvider.notifier).state = locale;
                    
                    // 변경 완료 메시지
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.languageChanged(
                            SupportedLocales.getLanguageName(locale.languageCode),
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 국기 이모지 (크게)
                        Text(
                          SupportedLocales.getLanguageFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 4),
                        // 언어 코드
                        Text(
                          locale.languageCode.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // 현재 선택된 언어 이름
            Center(
              child: Text(
                SupportedLocales.getLanguageName(currentLocale.languageCode),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

