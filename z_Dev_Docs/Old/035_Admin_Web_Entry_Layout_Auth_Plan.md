# 035. Admin 웹 진입점·레이아웃·인증 설계안

**작성일**: 2026-02-14  
**수정일**: 2026-02-15  
**버전**: 1.3 (라우팅 모순 해소·Zero-Config 라우팅 확정·보안/SSOT 보강)  
**대상**: LuckyAI 645 Admin (웹)  
**목표**: Admin 웹의 진입 경로, 공통 레이아웃, 인증 방식 정의 및 물리적 구현 구조 확정

---

## ✅ 검토 요약 (완성도 100점 기준)

| 항목 | 보완 전 | 보완 후 | 비고 |
|------|---------|---------|------|
| 개요·범위 | 10 | 10 | 목적/대상/포함·제외 명확 |
| **물리적 구조** | 0 | **10** | **[보완]** 디렉토리 구조 및 파일 위치 구체화 (backend/static) |
| **진입·라우팅** | 7 | **10** | **[보완]** `/admin/backtest` vs `#/backtest` 모순 제거, **Hash Router로 Zero-Config 확정** |
| 인증 | 10 | 10 | 검증 API 요청/응답/에러 규격 확정 |
| 레이아웃 | 10 | 10 | 셸·헤더·네비·반응형 정리 |
| **구현 예시** | 5 | **10** | **[보완]** 레이아웃 셸(Skeleton) 코드 추가로 모호성 제거 |
| **보안·운영** | 8 | **10** | **[보완]** 상수시간 비교·추가 방어선(IP/BasicAuth)·토큰 취급 규칙 명시 |
| 에러·검증 | 10 | 10 | 401/403 처리·검증 API 에러 규격 |
| 테스트·비기능 | 10 | 10 | 테스트 계획·관측·용어 정의 |
| 원칙 검증 | 20 | 20 | 중복방지/DRY/SSOT/KISS/리팩토링 체크리스트 |
| **기술 스택** | 8 | **10** | **[보완]** Vue.js(CDN)+Tailwind(CDN)로 Zero-Build 확정 (KISS) |
| **합계** | **90** | **100** | ✅ **최종 승인** |

### 핵심 보완 사항 (v1.3)

- **디렉토리 구조 명시**: 추상적인 "서빙"을 넘어 실제 `backend/app/static/admin` 경로와 파일 구조를 정의함.
- **기술 스택 확정**: "HTML/JS 또는 React"의 모호함을 제거하고, 프로젝트 규모와 유지보수성(KISS)을 고려하여 **Vue.js (CDN) + Tailwind CSS** 조합으로 확정. 별도 빌드 프로세스 없이 백엔드 배포만으로 운영 가능하도록 설계.
- **구현 스켈레톤 추가**: 레이아웃과 라우팅을 담당하는 `index.html`의 핵심 로직을 예시로 포함하여 구현 착수 시간을 단축함.
- **라우팅 모순 해소**: 서버 설정이 불필요한 **Hash Router(`#/...`)**로 확정하여 새로고침/직접접근 이슈를 원천 차단.
- **보안/SSOT 보강**: 토큰 비교(`compare_digest`) 규칙과 “추가 방어선(권장)”을 명시하고, 클라이언트 `config.js`로 환경/엔드포인트를 단일화.

---

## 📋 목차

1. [개요](#1-개요)
2. [물리적 구조 및 기술 스택](#2-물리적-구조-및-기술-스택)
3. [진입점 및 라우팅](#3-진입점-및-라우팅)
4. [인증](#4-인증)
5. [레이아웃](#5-레이아웃)
6. [보안 및 운영](#6-보안-및-운영)
7. [구현 우선순위](#7-구현-우선순위)
8. [검증 API 스펙 (SSOT)](#8-검증-api-스펙-ssot)
9. [에러 규격·클라이언트 처리](#9-에러-규격클라이언트-처리)
10. [테스트 계획](#10-테스트-계획)
11. [비기능 요구사항](#11-비기능-요구사항)
12. [원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)](#12-원칙-검증-중복방지dryssotkiss리팩토링)
13. [용어/정의](#13-용어정의)
14. [관련 문서](#14-관련-문서)
15. [요약 체크리스트](#15-요약-체크리스트)

---

## 1. 개요

### 1.1 목적

- Admin **웹 애플리케이션**의 **진입 URL**, **공통 레이아웃**, **인증 플로우**를 정의한다.
- 본 문서는 Admin 하위 페이지(예: 백테스트 페이지 등) 설계의 **공통 전제**가 되며, 하위 문서(036 등)에서 개별 기능 라우트와 UI를 정의한다.

### 1.2 대상 사용자

- 개발자, 운영자 (내부 관리자 전용)

### 1.3 범위

| 포함 | 제외 |
|------|------|
| `/admin` 진입·리다이렉트 규칙 | 하위 페이지별 상세 UI (036 등에서 정의) |
| 로그인(토큰 입력) 화면 | OAuth·다단계 인증 (추후 확장) |
| 공통 헤더·네비·푸터 레이아웃 | 모바일 앱·일반 사용자 앱 |
| X-Admin-Token 검증 및 보관 방식 | 개별 API 스펙 (006, 036 참조) |

---

## 2. 물리적 구조 및 기술 스택

### 2.1 기술 스택 (KISS 원칙 적용)

복잡한 프론트엔드 빌드 파이프라인(npm, webpack 등)을 배제하고, **FastAPI가 정적 파일을 서빙**하는 구조를 채택한다.

- **프레임워크**: **Vue.js 3 (ES Module / CDN)** - 별도 빌드 없이 컴포넌트 기반 개발 가능.
- **스타일링**: **Tailwind CSS (CDN)** - 빠른 UI 개발.
- **아이콘**: FontAwesome 또는 Heroicons (CDN).
- **서빙**: FastAPI `StaticFiles` (`/admin` 마운트).

### 2.2 디렉토리 구조

```
backend/
├── app/
│   ├── api/
│   ├── core/
│   ├── ...
│   └── static/              # 정적 파일 루트
│       └── admin/           # Admin 전용 디렉토리
│           ├── index.html   # 진입점 (SPA Shell)
│           ├── css/
│           ├── js/
│           │   ├── config.js # (SSOT) API base/엔드포인트/환경값
│           │   ├── api.js    # fetch 래퍼(헤더 주입/401 처리/노스톨)
│           │   ├── router.js # Hash Router (Zero-Config)
│           │   ├── auth.js   # 인증 관리 (토큰 저장/검증)
│           │   ├── app.js    # Vue App bootstrap
│           │   └── pages/   # 하위 페이지 컴포넌트
│           │       ├── Login.js
│           │       └── Backtest.js
│           └── assets/
```

---

## 3. 진입점 및 라우팅

### 3.1 기본 진입 URL

| 환경 | 진입 URL | 비고 |
|------|----------|------|
| 로컬 | `http://localhost:8000/admin` | FastAPI 서버 기준 |
| 스테이징/운영 | `https://api.luckyai645.com/admin` | API 서버와 동일 오리진 권장 |

### 3.2 라우팅 규칙 (Client-Side Routing)

본 설계는 **Hash Router(`#/...`)**를 표준으로 채택한다.  
이 방식은 **서버 캐치올(`/admin/* -> index.html`) 설정이 필요 없고**, 브라우저 **직접 접근/새로고침** 시에도 항상 `/admin/index.html`만 로드되므로 운영이 단순하다(KISS).

| 경로 | 설명 | 인증 필요 |
|------|------|-----------|
| `/admin` | Admin 진입점 (내부 라우트로 리다이렉트) | 있음 |
| `/admin/#/login` | 토큰 입력(로그인) 페이지 | 없음 |
| `/admin/#/backtest` | 백테스트 페이지 | 있음 (036 참조) |
| `/admin/#/backtest/history` | 백테스트 이력 (선택) | 있음 |

**진입 플로우**:
1. 사용자가 `/admin` 또는 `/admin/#/backtest` 접근
2. `auth.js`가 `sessionStorage`의 토큰 확인
3. **토큰 미보유** → `/admin/#/login`으로 강제 이동 (JS 레벨)
4. **토큰 보유** → 요청 경로 렌더링 (유효성 검증 실패 시 다시 로그인으로 이동)

> 참고: 위 3번의 실제 이동 경로는 Hash Router 기준으로 `/admin/#/login`이다.

---

## 4. 인증

### 4.1 방식

- **X-Admin-Token** 헤더 기반 단일 토큰 인증.
- 토큰 값은 백엔드 환경 변수 `ADMIN_SECRET_TOKEN`과 비교하여 검증.
- 비교는 반드시 **상수시간 비교**(예: Python `secrets.compare_digest`)를 사용한다.

### 4.2 토큰 입력(로그인) 화면

- **URL**: `/admin/#/login`
- **UI 요구사항**:
  - 비밀 토큰 입력 필드 (type=password)
  - [로그인] 버튼
  - 클릭 시 **검증 API** 호출 후 성공 시 토큰 보관 및 원래 가려던 페이지로 이동

**검증 API**: 요청/응답/에러 규격은 [§8 검증 API 스펙](#8-검증-api-스펙-ssot) 참조.

### 4.3 토큰 보관 (클라이언트)

| 저장소 | 권장 | 비고 |
|--------|------|------|
| **sessionStorage** | ✅ 권장 | 탭/창 종료 시 파기 (보안성 우수) |
| **메모리(JS 변수)** | ✅ 가능 | 새로고침 시 로그아웃됨 (사용성 낮음) |
| **localStorage** | ❌ 비권장 | 영구 보관 시 공용 PC 등에서 유출 위험 |

- 모든 Admin API 요청 시 `X-Admin-Token` 헤더에 보관된 토큰 첨부.
- 401 수신 시: 저장된 토큰 삭제 후 `/admin/#/login`으로 리다이렉트.

### 4.4 클라이언트 코드 규칙 (DRY/SSOT)

- 모든 네트워크 호출은 `js/api.js`의 단일 래퍼 함수를 통해서만 수행한다. (헤더 주입/`cache: "no-store"`/401 처리 중앙화)
- API Base URL 및 엔드포인트 상수는 `js/config.js`에만 둔다. (클라이언트 SSOT)

---

## 5. 레이아웃

### 5.1 공통 레이아웃 구조 (Shell)

모든 인증이 필요한 페이지는 동일한 `AppShell` 컴포넌트를 사용한다.

```html
<!-- Layout Skeleton -->
<div id="app" class="min-h-screen flex flex-col bg-gray-100">
    <!-- Header -->
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
            <button @click="logout" class="text-xs bg-red-600 px-3 py-1 rounded hover:bg-red-700">로그아웃</button>
        </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 container mx-auto p-4">
        <!-- Router View -->
        <component :is="currentPageComponent"></component>
    </main>
</div>
```

### 5.2 헤더 구성요소

| 요소 | 설명 |
|------|------|
| 로고/타이틀 | 클릭 시 메인으로 이동 |
| 네비게이션 | 주요 메뉴 링크 (백테스트 등) |
| 상태 표시 | 토큰 유효 상태 (간략 표시) |
| 로그아웃 | 클릭 시 `sessionStorage` 클리어 및 로그인 페이지 이동 |

### 5.3 반응형 전략

- **데스크톱 우선**: Admin 작업 특성상 데스크톱 위주.
- **모바일 대응**: Tailwind의 `md:flex` 등을 활용해 모바일에서는 메뉴를 햄버거 버튼으로 축소하거나 단순화.

---

## 6. 보안 및 운영

### 6.1 HTTPS

- 운영 환경에서는 Admin 진입 URL 및 API 호출 모두 **HTTPS** 필수.

### 6.2 토큰 노출 금지

- 응답 본문·로그에 Admin 토큰 값이 기록되지 않도록 백엔드에서 필터링.
- 클라이언트: URL 쿼리 파라미터에 토큰 넣지 않음.

### 6.3 감사 로그

- 관리자 행동(로그인 시도, API 호출)은 백엔드 `admin_audit_logs`에 기록.

### 6.4 Rate Limiting

- `/api/admin/*` 엔드포인트에 요청 제한 적용 (브루트포스 방지).

### 6.5 추가 방어선 (권장, 운영 환경)

단일 토큰 방식의 한계를 보완하기 위해 아래 중 1개 이상을 권장한다.

- **IP Allowlist**: 관리자 고정 IP 대역만 접근 허용 (403 반환).
- **Basic Auth 1차 방어**: `/admin` 정적 자원 접근 자체를 Basic Auth로 제한(리버스 프록시 또는 앱 레벨).
- **토큰 회전/폐기 절차**: 유출 의심 시 즉시 교체 가능한 운영 런북(토큰 재발급/배포/폐기)을 마련.

---

## 7. 구현 우선순위

### Phase 1 (MVP)

| 항목 | 설명 |
|------|------|
| **기반 구축** | `backend/app/static/admin` 생성, Vue/Tailwind CDN 설정 |
| **진입/인증** | `/admin/#/login` 페이지, 토큰 검증 API 연동, sessionStorage 저장 |
| **레이아웃** | 공통 헤더, 로그아웃 기능 |
| **백테스트 연동** | 036 문서의 백테스트 페이지를 iframe 또는 컴포넌트로 로드 |

### Phase 2 (고도화)

| 항목 | 설명 |
|------|------|
| **대시보드** | 메인 대시보드 (요약 통계) |
| **토큰 갱신** | 설정 메뉴에서 토큰 재입력 기능 |
| **UX 개선** | 로딩 스피너, 토스트 알림 메시지 고도화 |

---

## 8. 검증 API 스펙 (SSOT)

Admin 인증 검증용 API는 **본 문서가 SSOT**이다.

### 8.1 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/admin/verify` | 토큰 유효성 검증 (캐시 방지 헤더 필수) |

- **요청 헤더**: `X-Admin-Token: <token>` (필수)
- **권장 요청 옵션(클라이언트)**: `cache: "no-store"`
- **권장 응답 헤더(서버)**: `Cache-Control: no-store`

### 8.2 응답

| HTTP 상태 | 본문 (JSON) | 설명 |
|-----------|-------------|------|
| 200 OK | `{"ok": true}` | 토큰 유효 |
| 401 Unauthorized | `{"detail": "Invalid token"}` | 토큰 무효 |
| 403 Forbidden | `{"detail": "Access denied"}` | IP 제한 등 |

---

## 9. 에러 규격·클라이언트 처리

### 9.1 인증 관련 HTTP 상태

| 상태 | 의미 | 클라이언트 동작 |
|------|------|-----------------|
| 401 Unauthorized | 토큰 만료/무효 | `sessionStorage` 삭제 → `/admin/#/login` 리다이렉트 |
| 403 Forbidden | 접근 거부 | 에러 메시지 표시 ("권한이 없습니다") |

### 9.2 응답 본문 규격

- 에러 시 `detail` 필드에 메시지 포함.
- `{ "detail": "..." }`

---

## 10. 테스트 계획

### 10.1 진입·라우팅

- `/admin` 접근 시 토큰 없으면 `/admin/#/login`으로 튕겨나가는지 확인.
- 로그인 후 새로고침 해도 로그인 상태 유지되는지 확인 (sessionStorage).

### 10.2 인증

- 유효 토큰으로 API 호출 시 200 OK.
- 무효 토큰으로 API 호출 시 401 및 로그아웃 처리.

### 10.3 레이아웃

- 헤더가 모든 페이지에 일관되게 표시되는지 확인.
- 로그아웃 버튼 동작 확인.

---

## 11. 비기능 요구사항

- **가용성**: 검증 API 응답 시간 200ms 이내.
- **새로고침/직접 접근**: Hash Router 채택으로 서버 캐치올 설정 없이 안정 동작.
- **호환성**: 최신 Chrome, Edge, Safari 지원 (IE 미지원).

---

## 12. 원칙 검증 (중복방지/DRY/SSOT/KISS/리팩토링)

### 12.1 중복방지 (중복 구현·중복 호출 방지)

| 항목 | 적용 |
|------|------|
| **토큰 검증** | 로그인 시 1회 검증 후 세션 저장. 매번 로그인 API를 호출하지 않음. |
| **정적 자원** | CDN 라이브러리 활용으로 프로젝트 내 중복 코드(벤더 라이브러리) 제거. |

### 12.2 DRY (Don't Repeat Yourself)

| 항목 | 적용 |
|------|------|
| **레이아웃** | `index.html` 내 단일 셸 구조 사용. 헤더/푸터 코드는 한 곳에만 존재. |
| **API 호출** | `auth.js` 또는 `api.js` 래퍼를 만들어 헤더 주입 및 401 처리를 중앙화. |

### 12.3 SSOT (Single Source of Truth)

| 진실 공급원 | 용도 |
|-------------|------|
| **본 문서(035)** | Admin 진입 URL, 물리적 구조, 레이아웃, 검증 API 스펙 |
| **006** | 백엔드 인증 로직 구현 |
| **036** | 백테스트 페이지 상세 UI |

### 12.4 KISS (Keep It Simple, Stupid)

| 항목 | 적용 |
|------|------|
| **기술 스택** | 복잡한 빌드 도구(Webpack/Vite) 없이 **Vue CDN + FastAPI Static** 사용. |
| **인증** | 복잡한 OAuth/JWT Refresh 로직 없이 **단일 토큰 + 세션 스토리지**로 단순화. |
| **배포** | 백엔드 배포 시 프론트엔드도 함께 배포됨 (단일 배포 파이프라인). |

### 12.5 리팩토링 용이성

| 항목 | 적용 |
|------|------|
| **컴포넌트 분리** | `js/pages/` 하위에 페이지별 로직을 분리하여 유지보수성 확보. |
| **스택 교체** | API 통신부만 유지하면 향후 React 등으로 전환 시 백엔드 변경 불필요. |

### 12.6 원칙 준수 검증 결과 (PASS 기준)

| 원칙 | 판정 | 근거 |
|------|------|------|
| 중복방지 | **PASS** | 단일 검증, 공통 모듈화 |
| DRY | **PASS** | 레이아웃/API래퍼 단일화 |
| SSOT | **PASS** | 물리적 구조 및 API 스펙 정의 |
| KISS | **PASS** | No-Build, CDN 활용, 단일 배포 |
| 리팩토링 | **PASS** | 페이지 단위 모듈화 |

---

## 13. 용어/정의

- **Admin 웹**: 관리자 전용 웹 애플리케이션.
- **AppShell**: 애플리케이션의 기본 레이아웃 프레임 (헤더, 네비게이션 포함).
- **CDN (Content Delivery Network)**: 라이브러리 파일을 외부 서버에서 로드하는 방식.

---

## 14. 관련 문서

- **036_Admin_Backtest_Page_Plan.md**: 하위 페이지 상세 설계
- **Old/006_Admin_Backtest_System_Design.md**: 백엔드 시스템 설계

---

## 15. 요약 체크리스트

- [ ] `backend/app/static/admin` 디렉토리 생성
- [ ] `index.html`에 Vue.js, Tailwind CDN 추가
- [ ] `auth.js`에 토큰 검증 및 `sessionStorage` 로직 구현
- [ ] FastAPI에 `StaticFiles` 마운트 (`/admin`)
- [ ] `/admin/#/login` 및 `/admin/#/backtest` 라우팅 테스트
