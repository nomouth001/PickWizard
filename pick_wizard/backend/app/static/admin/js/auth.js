/**
 * Admin 인증 관리
 * 2026-02-14 EST - 035 설계안 구현
 * 토큰 저장/검증/sessionStorage
 */
(function (global) {
  'use strict';
  const KEY = global.AdminConfig?.STORAGE_KEY || 'admin_token';

  function getToken() {
    try {
      return sessionStorage.getItem(KEY);
    } catch {
      return null;
    }
  }

  function setToken(token) {
    try {
      sessionStorage.setItem(KEY, token);
      return true;
    } catch {
      return false;
    }
  }

  function clearToken() {
    try {
      sessionStorage.removeItem(KEY);
      return true;
    } catch {
      return false;
    }
  }

  function hasToken() {
    return !!getToken();
  }

  global.AdminAuth = {
    getToken,
    setToken,
    clearToken,
    hasToken,
  };
})(typeof window !== 'undefined' ? window : this);
