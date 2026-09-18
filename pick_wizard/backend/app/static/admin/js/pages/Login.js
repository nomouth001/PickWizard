/**
 * Admin 로그인 페이지
 * 2026-02-14 EST - 035 설계안 구현
 */
(function (global) {
  'use strict';
  const api = global.AdminApi;
  const auth = global.AdminAuth;
  const router = global.AdminRouter;

  function LoginPage() {
    return {
      template: `
        <div class="max-w-md mx-auto mt-16 p-6 bg-white rounded-lg shadow-lg">
          <h2 class="text-xl font-bold mb-4 text-gray-800">Admin 로그인</h2>
          <p class="text-sm text-gray-500 mb-4">관리자 토큰을 입력하세요. (서버 .env의 ADMIN_SECRET_TOKEN과 동일해야 합니다)</p>
          <form @submit.prevent="onSubmit" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">토큰</label>
              <input v-model="token" type="password" class="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-gray-500 focus:border-gray-500" placeholder="Admin Token" required />
            </div>
            <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
            <button type="submit" :disabled="loading" class="w-full py-2 px-4 bg-gray-800 text-white rounded hover:bg-gray-700 disabled:opacity-50">
              {{ loading ? '확인 중...' : '로그인' }}
            </button>
          </form>
        </div>
      `,
      data() {
        return { token: '', error: '', loading: false };
      },
      methods: {
        async onSubmit() {
          this.error = '';
          this.loading = true;
          try {
            await api.verifyWithToken(this.token);
            auth.setToken(this.token);
            const returnTo = new URLSearchParams(window.location.hash.slice(1).split('?')[1] || '').get('returnTo') || 'backtest';
            router.navigate(returnTo);
          } catch (e) {
            this.error = e.message || '토큰이 올바르지 않습니다.';
          } finally {
            this.loading = false;
          }
        },
      },
    };
  }

  global.AdminPages = global.AdminPages || {};
  global.AdminPages.Login = LoginPage;
})(typeof window !== 'undefined' ? window : this);
