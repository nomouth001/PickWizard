/// 034 OAuth 로그인 화면
/// Google / Apple / Kakao / Naver 소셜 로그인 버튼

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? _error;

  Future<void> _loginWithGoogle() async {
    // 2026-04 배포 기준: Google 로그인 기능 임시 비활성화
    // setState(() => _error = null);
    // try {
    //   final googleSignIn = GoogleSignIn(
    //     scopes: ['email', 'profile'],
    //     // serverClientId: 백엔드와 동일한 웹 클라이언트 ID (선택, serverAuthCode용)
    //   );
    //   final account = await googleSignIn.signIn();
    //   if (account == null) return;
    //   final auth = await account.authentication;
    //   final serverAuthCode = auth.serverAuthCode;
    //   if (serverAuthCode == null || serverAuthCode.isEmpty) {
    //     setState(() => _error = 'Google 서버 인증 코드를 받지 못했습니다.');
    //     return;
    //   }
    //   final request = LoginRequest(
    //     provider: 'google',
    //     code: serverAuthCode,
    //     redirectUri: 'https://api.luckyai645.com/api/auth/google/callback',
    //   );
    //   await ref.read(oauthLoginProvider.notifier).login(request);
    //   if (mounted) Navigator.of(context).pop(true);
    // } catch (e) {
    //   setState(() => _error = e.toString());
    // }
    setState(() => _error = '현재 배포 버전에서는 Google 로그인을 지원하지 않습니다.');
  }

  Future<void> _loginWithKakao() async {
    setState(() => _error = null);
    try {
      // TODO: Kakao SDK 연동 후 access_token 획득
      setState(() => _error = 'Kakao 로그인은 SDK 설정 후 사용 가능합니다.');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loginWithNaver() async {
    setState(() => _error = null);
    try {
      // TODO: Naver SDK 연동 후 access_token 획득
      setState(() => _error = 'Naver 로그인은 SDK 설정 후 사용 가능합니다.');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(oauthLoginProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('소셜 로그인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!, style: TextStyle(color: Colors.red.shade900)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                '계정으로 로그인하면 코인과 번호가 동기화됩니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (loginState.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                FilledButton.icon(
                  onPressed: _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Google로 로그인'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loginWithKakao,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Kakao로 로그인'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loginWithNaver,
                  icon: const Icon(Icons.language),
                  label: const Text('Naver로 로그인'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
