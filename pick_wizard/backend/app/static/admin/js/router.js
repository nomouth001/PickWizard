/**
 * Hash Router (Zero-Config)
 * 2026-02-14 EST - 035 설계안 구현
 */
(function (global) {
  'use strict';

  function getHash() {
    const h = (typeof window !== 'undefined' && window.location?.hash) ? window.location.hash : '';
    return h.replace(/^#\/?/, '') || 'backtest';
  }

  function getRoute() {
    const path = getHash();
    if (path === 'login') return 'login';
    if (path.startsWith('backtest/history')) return 'backtest/history';
    if (path.startsWith('backtest')) return 'backtest';
    return 'backtest';
  }

  function navigate(path) {
    if (typeof window !== 'undefined') {
      const p = path.startsWith('#') ? path : '#/' + path.replace(/^\//, '');
      window.location.hash = p;
    }
  }

  function onHashChange(cb) {
    if (typeof window !== 'undefined') {
      window.addEventListener('hashchange', cb);
      return () => window.removeEventListener('hashchange', cb);
    }
    return () => {};
  }

  global.AdminRouter = {
    getHash,
    getRoute,
    navigate,
    onHashChange,
  };
})(typeof window !== 'undefined' ? window : this);
