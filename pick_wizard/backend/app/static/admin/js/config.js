/**
 * Admin 클라이언트 설정 (SSOT)
 * 2026-02-14 EST - 035 설계안 구현
 * API Base URL 및 엔드포인트 상수만 정의
 */
(function (global) {
  'use strict';
  const API_BASE = (typeof window !== 'undefined' && window.location?.origin) ? window.location.origin : '';
  global.AdminConfig = {
    API_BASE,
    ENDPOINTS: {
      VERIFY: '/api/admin/verify',
      ALGORITHMS: '/api/algorithms/',
      ALGORITHM: '/api/algorithms/',
      BACKTEST_RUN: '/api/admin/backtest/run',
      BACKTEST_RUN_STREAM: '/api/admin/backtest/run-stream',
      BACKTEST_COMPARE: '/api/admin/backtest/compare',
      BACKTEST_RUN_GRID: '/api/admin/backtest/run-grid',
      BACKTEST_RUN_GRID_STREAM: '/api/admin/backtest/run-grid-stream',
      BACKTEST_HISTORY: '/api/admin/backtest/history',
      DRAWS_LATEST: '/api/draws/latest',
    },
    STORAGE_KEY: 'admin_token',
  };
})(typeof window !== 'undefined' ? window : this);
