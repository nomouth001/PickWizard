/**
 * Admin Vue App bootstrap
 * 2026-02-14 EST - 035 설계안 구현
 */
(function (global) {
  'use strict';
  const Vue = global.Vue;
  const router = global.AdminRouter;
  const auth = global.AdminAuth;
  const pages = global.AdminPages || {};

  function getCurrentRoute() {
    return router.getRoute();
  }

  function getComponentForRoute(route) {
    if (route === 'login') return pages.Login ? pages.Login() : { template: '<div>Login</div>' };
    if (route === 'backtest/history') return pages.BacktestHistory ? pages.BacktestHistory() : { template: '<div>History</div>' };
    return pages.Backtest ? pages.Backtest() : { template: '<div>Backtest</div>' };
  }

  function createApp() {
    return Vue.createApp({
      template: `
        <div id="app-shell" class="min-h-screen flex flex-col bg-gray-100">
          <template v-if="isLoginPage">
            <main class="flex-1 flex items-center justify-center">
              <component :is="currentPageComponent"></component>
            </main>
          </template>
          <template v-else>
            <header class="bg-gray-800 text-white p-4 shadow-md flex justify-between items-center">
              <div class="flex items-center gap-4">
                <h1 class="text-xl font-bold cursor-pointer" @click="goHome">LuckyAI Admin</h1>
                <nav class="hidden md:flex gap-4 text-sm">
                  <a href="#/backtest" :class="{ 'text-yellow-400': currentRoute === 'backtest' }">백테스트</a>
                  <a href="#/backtest/history" :class="{ 'text-yellow-400': currentRoute === 'backtest/history' }">이력</a>
                </nav>
              </div>
              <div class="flex items-center gap-4">
                <span class="text-xs text-green-400">● Connected</span>
                <button type="button" @click="logout" class="text-xs bg-red-600 px-3 py-1 rounded hover:bg-red-700">로그아웃</button>
              </div>
            </header>
            <main class="flex-1 container mx-auto p-4">
              <component :is="currentPageComponent"></component>
            </main>
          </template>
        </div>
      `,
      data() {
        return { currentRoute: getCurrentRoute() };
      },
      computed: {
        isLoginPage() {
          return this.currentRoute === 'login';
        },
        currentPageComponent() {
          return getComponentForRoute(this.currentRoute);
        },
      },
      methods: {
        goHome() {
          router.navigate('backtest');
        },
        logout() {
          try {
            if (auth && auth.clearToken) auth.clearToken();
          } catch (e) {}
          router.navigate('login');
          this.currentRoute = 'login';
        },
        updateRoute() {
          this.currentRoute = getCurrentRoute();
        },
      },
      mounted() {
        if (!this.isLoginPage && !auth.hasToken()) {
          router.navigate('login');
          return;
        }
        router.onHashChange(() => {
          if (getCurrentRoute() !== 'login' && !auth.hasToken()) {
            router.navigate('login');
            return;
          }
          this.updateRoute();
        });
      },
    });
  }

  global.AdminApp = { createApp };
})(typeof window !== 'undefined' ? window : this);
