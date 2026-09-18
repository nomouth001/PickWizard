import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/presentation/providers/auth_provider.dart';

/// 설정 화면
/// 
/// 2026-01-16 EST - 초기 생성
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 사용자 정보
          _buildSection(
            context,
            title: '사용자 정보',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('사용자 ID'),
                subtitle: Text(userId ?? '로그인 필요'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // TODO: 클립보드 복사
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ID가 복사되었습니다')),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('로그인 타입'),
                subtitle: const Text('게스트'),
              ),
              // 2026-04 배포 기준: 소셜 로그인은 이번 릴리스에서 비활성화
              // ListTile(
              //   leading: const Icon(Icons.login),
              //   title: const Text('소셜 로그인 (034)'),
              //   subtitle: const Text('Google / Kakao / Naver'),
              //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              //   onTap: () async {
              //     final result = await Navigator.of(context).push<bool>(
              //       MaterialPageRoute(builder: (_) => const LoginScreen()),
              //     );
              //     if (result == true && context.mounted) {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text('로그인되었습니다')),
              //       );
              //     }
              //   },
              // ),
            ],
          ),
          
          const Divider(height: 1),
          
          // 앱 설정
          _buildSection(
            context,
            title: '앱 설정',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('다크 모드'),
                subtitle: const Text('어두운 테마 사용'),
                value: false, // TODO: 테마 Provider 연동
                onChanged: (value) {
                  // TODO: 테마 변경 로직
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('다크 모드 준비 중입니다')),
                  );
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('알림'),
                subtitle: const Text('당첨 알림 받기'),
                value: true, // TODO: 알림 Provider 연동
                onChanged: (value) {
                  // TODO: 알림 설정 로직
                },
              ),
            ],
          ),
          
          const Divider(height: 1),
          
          // 앱 정보
          _buildSection(
            context,
            title: '앱 정보',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('앱 버전'),
                subtitle: const Text('1.0.0 (Beta)'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('이용약관'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showTermsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('개인정보 처리방침'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('오픈소스 라이선스'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: context.l10n.appTitle,
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
          
          const Divider(height: 1),
          
          // 고객 지원
          _buildSection(
            context,
            title: '고객 지원',
            children: [
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('도움말'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('문의하기'),
                subtitle: const Text('support@luckyai645.com'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: 이메일 앱 열기
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 개발자 정보 (Beta)
          Center(
            child: Column(
              children: [
                Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.appSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2026 PickWizard',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
  
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: const SingleChildScrollView(
          child: Text(
            '제 1 조 (목적)\n'
            '본 약관은 픽위자드 - 복권 번호 추천(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.\n\n'
            '제 2 조 (정의)\n'
            '1. "서비스"란 픽위자드 - 복권 번호 추천이 제공하는 복권 번호 추천 보조 서비스를 말합니다.\n'
            '2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 자를 말합니다.\n\n'
            '제 3 조 (약관의 효력 및 변경)\n'
            '본 약관은 서비스 화면에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력이 발생합니다.\n\n'
            '제 4 조 (면책조항)\n'
            '1. 본 서비스는 로또 번호 생성을 위한 참고 자료를 제공할 뿐, 당첨을 보장하지 않습니다.\n'
            '2. 서비스 이용으로 인한 결과에 대해 회사는 책임을 지지 않습니다.\n\n'
            '[전문 내용은 앱 내 또는 웹사이트에서 확인하실 수 있습니다.]',
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
  
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: const SingleChildScrollView(
          child: Text(
            '1. 수집하는 개인정보 항목\n'
            '- 디바이스 ID (게스트 로그인용)\n'
            '- 서비스 이용 기록\n\n'
            '2. 개인정보의 수집 및 이용목적\n'
            '- 서비스 제공 및 본인 확인\n'
            '- 서비스 개선 및 통계 분석\n\n'
            '3. 개인정보의 보유 및 이용기간\n'
            '- 회원 탈퇴 시까지\n\n'
            '4. 개인정보의 제3자 제공\n'
            '- 원칙적으로 개인정보를 제3자에게 제공하지 않습니다.\n\n'
            '5. 개인정보의 파기절차 및 방법\n'
            '- 목적 달성 후 즉시 파기합니다.\n\n'
            '[전문 내용은 앱 내 또는 웹사이트에서 확인하실 수 있습니다.]',
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
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.l10n.appTitle} 사용 방법',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('1. 번호 생성\n'
                  '   - 홈 화면에서 "번호 생성" 버튼 클릭\n'
                  '   - 원하는 알고리즘 선택\n'
                  '   - 생성할 세트 수 입력\n'
                  '   - "생성하기" 버튼 클릭\n\n'
                  '2. 내 번호 저장\n'
                  '   - 생성 결과 화면에서 "내 번호로 저장" 클릭\n'
                  '   - 메모 입력 (선택사항)\n\n'
                  '3. 당첨 확인\n'
                  '   - "내 번호" 화면에서 "당첨 확인" 버튼 클릭\n'
                  '   - 최신 회차와 자동 비교\n\n'
                  '4. 코인 획득\n'
                  '   - 일일 로그인: 10코인\n'
                  '   - 광고 시청: 5코인\n\n'
                  '더 궁금하신 점은 문의하기를 이용해주세요.'),
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
