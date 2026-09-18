/**
 * Admin API fetch 래퍼
 * 2026-02-14 EST - 035 설계안 구현
 * 헤더 주입, cache: no-store, 401 처리 중앙화
 */
(function (global) {
  'use strict';
  const cfg = global.AdminConfig || {};
  const auth = global.AdminAuth || {};
  const base = cfg.API_BASE || '';
  const verifyUrl = base + (cfg.ENDPOINTS?.VERIFY || '/api/admin/verify');
  const LOGIN_HASH = '#/login';

  function getHeaders() {
    const h = { 'Content-Type': 'application/json' };
    const token = auth.getToken?.();
    if (token) h['X-Admin-Token'] = token;
    return h;
  }

  async function handleResponse(res) {
    if (res.status === 401) {
      auth.clearToken?.();
      if (typeof window !== 'undefined' && !window.location.hash?.startsWith('#/login')) {
        window.location.replace(window.location.pathname + window.location.search + LOGIN_HASH);
      }
      const data = await res.json().catch(() => ({}));
      throw new Error(data.detail || 'Unauthorized');
    }
    if (res.status === 403) {
      const data = await res.json().catch(() => ({}));
      throw new Error(data.detail || 'Access denied');
    }
    return res;
  }

  async function adminFetch(url, options = {}) {
    const fullUrl = url.startsWith('http') ? url : base + url;
    const opt = {
      ...options,
      cache: 'no-store',
      headers: { ...getHeaders(), ...(options.headers || {}) },
    };
    const res = await fetch(fullUrl, opt);
    return handleResponse(res);
  }

  async function verifyToken() {
    const res = await adminFetch(verifyUrl);
    return res.json();
  }

  async function verifyWithToken(token) {
    const fullUrl = verifyUrl.startsWith('http') ? verifyUrl : base + verifyUrl;
    const res = await fetch(fullUrl, {
      cache: 'no-store',
      headers: { 'Content-Type': 'application/json', 'X-Admin-Token': token || '' },
    });
    if (res.status === 401 || res.status === 403) {
      const data = await res.json().catch(() => ({}));
      throw new Error(data.detail || (res.status === 401 ? 'Invalid token' : 'Access denied'));
    }
    return res.json();
  }

  global.AdminApi = {
    fetch: adminFetch,
    verify: verifyToken,
    verifyWithToken,
    getHeaders,
  };
})(typeof window !== 'undefined' ? window : this);
