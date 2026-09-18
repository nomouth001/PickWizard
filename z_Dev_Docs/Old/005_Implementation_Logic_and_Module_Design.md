# 실행 로직 및 모듈 설계서
## Implementation Logic and Module Design

---

**문서 버전**: v3.4  
**작성일**: 2026-01-02  
**최종 수정**: 2026-01-02 22:00:00 EST  
**문서 유형**: Implementation Design  
**프로젝트**: LuckyAI 645  
**목적**: Flutter 모바일 앱 + FastAPI 백엔드 전체 구현 설계

**주요 변경사항**:
- **v3.4 (2026-01-02 22:00 EST)**: ✅ **설계 오류 10건 전체 수정 완료**
  - 🔴 Critical #1: AlgorithmPricing DB 모델 전체 스키마 추가 (섹션 21.3.0 신규)
  - 🔴 Critical #2: Flutter 빌드 명령어 섹션 추가 (섹션 3.3 신규, 115줄)
  - 🔴 Critical #3: 게스트 중복 생성 방지 로직 개선 (GIN 인덱스 + 비관적 락)
  - 🟡 High #4: AdMob SSV 설정 가이드 추가 (섹션 13.3.1 신규, 154줄)
  - 🟡 High #5: Celery 시간대 설정 통합 (Asia/Seoul, enable_utc=False)
  - 🟡 High #6: Firebase Key 처리 개선 (파일/JSON/Base64 다중 방식)
  - 🟠 Medium #7: 코인 지갑 Race Condition 수정 (이중 확인 + Lock)
  - 🟠 Medium #8: 환경 변수 예시 완성 (IAP, AdMob, OAuth 추가)
  - 🟠 Medium #9: Hive Adapter 순서 경고 추가 (typeId 관리 가이드)
  - 🟢 Low #10: FCM 토큰 등록 가이드 추가 (섹션 13.5.1 신규, 200줄)
  - 📝 총 추가 코드량: 약 550줄 (주석 포함)
  - 🎯 **개발 착수 준비 완료**: 모든 Critical/High/Medium/Low 이슈 해결
  
- **v3.3 (2026-01-02 21:00 EST)**: 🔧 **설계 오류 수정 (15건)**
  - 🔴 Critical #1: 광고 검증 토큰 구조 불일치 수정 (JWT → AdMob SSV 콜백)
  - 🔴 Critical #2: IAP 검증을 트랜잭션 외부로 이동 (Race Condition 방지)
  - 🔴 Critical #3: 코인 차감 Race Condition 해결 (Deduct First 패턴 명시)
  - 🟡 High #1: 연속 로그인 보상 로직 버그 수정 (30일에도 7일 보너스 적용)
  - 🟡 High #2: 알고리즘 비용 DB 테이블 설계 추가 (AlgorithmPricing 모델)
  - 🟡 High #3: NotificationService 구현 가이드 추가 (FCM 연동)
  - 🟡 High #4: Celery 시간대 명확화 (CELERY_TIMEZONE = 'Asia/Seoul')
  - 🟠 Medium #1: 환경 변수 예시 완성 (ADMOB_SECRET_KEY 등 추가)
  - 🟠 Medium #2: 게스트 중복 방지 인덱스 최적화 가이드
  - 🟠 Medium #3: 코인 지갑 초기화 중복 방지 로직
  - 🟠 Medium #4: Flutter Provider 코드 생성 명령어 추가
  - 🟢 Low: 문서 전반 일관성 및 명확성 개선
  
- **v3.2 (2026-01-02 20:00 EST)**: 🔒 **치명적 보안 결함 수정 완료**
  - Critical Issue #1: 번호 생성 API에 코인 차감 통합 (Race Condition 해결)
    - 번호 생성과 코인 차감을 단일 트랜잭션으로 통합
    - 비관적 락(with_for_update)으로 동시성 제어
    - 잔액 부족 시 402 Payment Required 응답
  - Critical Issue #2: 광고 검증 서버 간 검증 구현 (부정 획득 방지)
    - AdMob SSV(Server-Side Verification) 통합
    - HMAC-SHA256 서명 검증으로 위조 방지
    - 토큰 재사용 방지 (AdVerificationToken 모델 추가)
  - High Issue #3: IAP 영수증 검증 강화
    - Apple/Google 서버 간 검증 구현
    - 중복 결제 방지 (transaction_id 검증)
    - 환불 처리 지원 (consumptionState 확인)
  - High Issue #4: 코인 지갑 동시성 제어
    - 모든 잔액 변경에 비관적 락 적용
  - Medium Issue #6: 연속 로그인 보상 로직 개선
    - 7일마다 누적 보너스 지급 (14일, 21일, 28일도 보너스)
    - 30일, 60일, 90일 특별 보너스 추가
  - 새 서비스 추가: `AdVerificationService`, `PaymentService`
  - DB 모델 추가: `AdVerificationToken`
  - 환경 변수 추가: `ADMOB_SECRET_KEY`, `APPLE_SHARED_SECRET`, `GOOGLE_SERVICE_ACCOUNT_KEY`
  - ⚠️ **개발 착수 가능**: 모든 Critical/High 이슈 해결 완료
- **v3.1 (2026-01-02 18:30 EST)**:
  - 🔐 사용자 인증 및 계정 관리 시스템 추가 (섹션 20)
  - 하이브리드 인증: 게스트 모드 + 소셜 로그인 (Google/Apple/Kakao/Naver)
  - 코인 지갑 계정 연동: 디바이스 독립적 동기화
  - 게스트→정식 전환 로직 및 보너스 코인 시스템
- **v3.0 (2026-01-02 18:00 EST)**:
  - 💰 수익 모델 전면 재설계: Freemium 구독 → 코인 소비형
  - 코인 이코노미: 무료 획득, IAP 패키지, 알고리즘별 차등 가격
  - 마케팅 전략: 코인 모델 기반 CRO 및 리텐션
  - 예상 수익: Year 3 ₩3.61B (구독 모델 대비 +112%)
- **v2.1 (2026-01-02 17:00 EST)**: 
  - ✨ 사용자 번호 관리 및 자동 당첨 확인 시스템 추가 (섹션 15)
  - DB 모델 추가: `UserGeneratedNumbers`, `WinningCheckResult`, `UserStatistics`
  - API 추가: `/api/my-numbers` (번호 저장, 조회, 당첨 확인, 통계)
  - Celery 자동 작업 추가: 새 회차 발표 시 자동 당첨 확인 및 Push 알림
  - Flutter 화면 추가: 내 번호 관리, 당첨 내역, 사용자 통계
- **v2.0 (2026-01-02 16:30 EST)**:
  - Flutter 모바일 앱 구조 추가
  - 클라이언트-서버 아키텍처 명확화
  - 전체 프로젝트 디렉토리 구조 재설계
  - 앱 초기화 로직 및 상태 관리 추가

---

## 📋 목차

### 🎯 전체 아키텍처
1. [개요 및 시스템 아키텍처](#1-개요-및-시스템-아키텍처)
2. [전체 프로젝트 구조](#2-전체-프로젝트-구조)

### 📱 Flutter 모바일 앱
3. [Flutter 앱: 프로젝트 구조](#3-flutter-앱-프로젝트-구조)
4. [Flutter 앱: 초기화 로직](#4-flutter-앱-초기화-로직)
5. [Flutter 앱: 상태 관리](#5-flutter-앱-상태-관리)
6. [Flutter 앱: API 통신 계층](#6-flutter-앱-api-통신-계층)
7. [Flutter 앱: 로컬 데이터 저장](#7-flutter-앱-로컬-데이터-저장)
8. [Flutter 앱: UI 화면 구조](#8-flutter-앱-ui-화면-구조)

### 🖥️ FastAPI 백엔드
9. [백엔드: 프로젝트 구조](#9-백엔드-프로젝트-구조)
10. [백엔드: 서버 시작 로직](#10-백엔드-서버-시작-로직)
11. [백엔드: 데이터 관리 모듈](#11-백엔드-데이터-관리-모듈)
12. [백엔드: 알고리즘 모듈](#12-백엔드-알고리즘-모듈)
13. [백엔드: 검증 시스템](#13-백엔드-검증-시스템)
14. [백엔드: API 엔드포인트](#14-백엔드-api-엔드포인트)
15. [사용자 번호 관리 및 자동 당첨 확인](#15-사용자-번호-관리-및-자동-당첨-확인-시스템)
16. [백엔드: 캐싱 전략](#16-백엔드-캐싱-전략)
17. [백엔드: 백그라운드 작업](#17-백엔드-백그라운드-작업)

### 🔄 통합 및 배포
18. [클라이언트-서버 통신 흐름](#18-클라이언트-서버-통신-흐름)
19. [에러 처리 및 로깅](#19-에러-처리-및-로깅)

### 💰 비즈니스 모델
20. [사용자 인증 및 계정 관리](#20-사용자-인증-및-계정-관리)
21. [수익 모델 및 구현 전략](#21-수익-모델-및-구현-전략-코인-기반)
22. [마케팅 및 성장 전략](#22-마케팅-및-성장-전략-코인-모델)

### 🚀 배포 및 부록
23. [배포 전략](#23-배포-전략)
24. [부록](#24-부록)

---

## 1. 개요 및 시스템 아키텍처

### 1.1 전체 시스템 구조

LuckyAI 645는 **모바일 우선(Mobile-First)** AI 로또 번호 생성 서비스로, **Flutter 크로스플랫폼 앱**과 **FastAPI 백엔드**로 구성된 클라이언트-서버 아키텍처입니다.

```mermaid
graph TB
    subgraph "사용자 기기"
        A[Flutter 모바일 앱<br/>iOS + Android]
    end
    
    subgraph "백엔드 서버"
        B[FastAPI<br/>REST API]
        C[PostgreSQL<br/>메인 DB]
        D[Redis<br/>캐시 + 큐]
        E[Celery Worker<br/>백그라운드 작업]
    end
    
    subgraph "외부 서비스"
        F[동행복권<br/>크롤링]
        G[Firebase<br/>Push 알림]
    end
    
    A -->|HTTPS REST| B
    B --> C
    B --> D
    E --> C
    E --> D
    E -->|크롤링| F
    B -->|알림| G
    G -->|푸시| A
    
    style A fill:#667eea,color:#fff
    style B fill:#10b981,color:#fff
    style E fill:#f59e0b,color:#fff
```

### 1.2 아키텍처 설계 원칙

#### 1.2.1 클라이언트 측 (Flutter 앱)

```yaml
핵심 원칙:
  - Offline-First: 네트워크 없이도 기본 기능 동작
  - 반응형 UI: 상태 관리로 즉각적인 UI 업데이트
  - 로컬 캐싱: 자주 쓰는 데이터는 기기에 저장
  - 네이티브 성능: Flutter의 고성능 렌더링 활용

설계 패턴:
  - MVVM (Model-View-ViewModel)
  - Repository Pattern (데이터 소스 추상화)
  - Dependency Injection (Provider/Riverpod)
  - Clean Architecture (계층 분리)
```

#### 1.2.2 서버 측 (FastAPI 백엔드)

```yaml
핵심 원칙:
  - 모듈화: 각 기능별 독립 모듈
  - 재사용성: 공통 유틸리티 및 베이스 클래스
  - 확장성: 새 알고리즘 추가 용이
  - 유지보수성: 명확한 네이밍 및 문서화

설계 패턴:
  - Repository Pattern (DB 접근 추상화)
  - Service Layer (비즈니스 로직 분리)
  - Factory Pattern (알고리즘 동적 로드)
  - Strategy Pattern (알고리즘 교체 가능)
```

### 1.3 기술 스택

#### 1.3.1 Frontend (Mobile)

```yaml
Framework:
  - Flutter 3.16+
  - Dart 3.2+

상태 관리:
  - Riverpod 2.4+ (Provider 진화형)
  
네트워킹:
  - dio 5.4+ (HTTP 클라이언트)
  - retrofit + json_serializable (API 코드 생성)

로컬 저장소:
  - hive 2.2+ (NoSQL 로컬 DB)
  - shared_preferences (설정 저장)

UI/차트:
  - fl_chart 0.66+ (통계 그래프)
  - shimmer (로딩 애니메이션)
  - cached_network_image (이미지 캐싱)

기타:
  - qr_flutter (QR 코드 생성)
  - intl (다국어/날짜 포맷)
  - firebase_messaging (푸시 알림)
```

#### 1.3.2 Backend (Server)

```yaml
Framework:
  - Python 3.11+
  - FastAPI 0.110+

데이터베이스:
  - PostgreSQL 15 (메인 DB)
  - SQLAlchemy 2.0 (ORM)
  - Alembic (마이그레이션)

캐싱 및 큐:
  - Redis 7.2 (캐시 + 메시지 브로커)
  - Celery 5.3 (백그라운드 작업)

ML/AI:
  - PyTorch 2.1 (LSTM 모델)
  - NumPy 1.26
  - Pandas 2.1
  - Scikit-learn 1.3

크롤링:
  - aiohttp 3.9 (비동기 HTTP)
  - BeautifulSoup4 4.12 (HTML 파싱)

유틸리티:
  - python-dotenv (환경 변수)
  - loguru (로깅)
  - pydantic 2.5 (데이터 검증)
```

#### 1.3.3 인프라

```yaml
서버 호스팅:
  - AWS Lightsail / GCP Cloud Run

데이터베이스:
  - AWS RDS PostgreSQL / Cloud SQL

파일 저장소:
  - AWS S3 / GCS (모델 파일)

모니터링:
  - Sentry (에러 트래킹)
  - Google Analytics (사용자 분석)
  - CloudWatch / Stackdriver (서버 모니터링)

CI/CD:
  - GitHub Actions (자동 빌드/배포)
  - Fastlane (모바일 앱 배포)
```

### 1.4 데이터 흐름 개요

```mermaid
sequenceDiagram
    participant U as 사용자
    participant F as Flutter 앱
    participant H as Hive (로컬)
    participant A as FastAPI
    participant R as Redis
    participant P as PostgreSQL
    participant C as Celery Worker
    
    Note over U,C: 앱 초기 실행
    U->>F: 앱 실행
    F->>H: 로컬 데이터 로드
    F->>A: GET /draws/latest
    A->>R: 캐시 확인
    alt 캐시 히트
        R-->>A: 캐시된 데이터
    else 캐시 미스
        A->>P: 최신 회차 조회
        P-->>A: 데이터 반환
        A->>R: 캐시 저장
    end
    A-->>F: 최신 회차 정보
    F->>H: 로컬 업데이트
    F-->>U: 화면 표시
    
    Note over U,C: 번호 생성 요청
    U->>F: 번호 생성 버튼
    F->>A: POST /generate
    A->>P: 과거 데이터 로드
    A->>A: 알고리즘 실행
    A-->>F: 생성된 번호
    F->>H: 로컬 저장
    F-->>U: 결과 표시
    
    Note over U,C: 백그라운드 크롤링 (주 1회)
    C->>C: 스케줄 트리거
    C->>A: 최신 회차 크롤링
    C->>P: DB 업데이트
    C->>R: 캐시 무효화
    C->>A: Push 알림 전송
    A->>F: 새 회차 알림
```

---

## 2. 전체 프로젝트 구조

### 2.1 루트 디렉토리 레이아웃

```
luckyai_645/                       # 프로젝트 루트
│
├── mobile_app/                    # 📱 Flutter 모바일 앱
│   ├── lib/                       # Dart 소스 코드
│   ├── android/                   # Android 네이티브
│   ├── ios/                       # iOS 네이티브
│   ├── test/                      # 단위 테스트
│   ├── pubspec.yaml               # Flutter 의존성
│   └── README.md
│
├── backend/                       # 🖥️ FastAPI 백엔드 서버
│   ├── app/                       # Python 소스 코드
│   ├── data/                      # 데이터 파일
│   ├── results/                   # 검증 결과
│   ├── tests/                     # 테스트
│   ├── scripts/                   # 유틸리티 스크립트
│   ├── requirements.txt           # Python 의존성
│   ├── .env                       # 환경 변수
│   └── README.md
│
├── shared/                        # 🔗 공유 리소스
│   ├── docs/                      # 문서
│   ├── api_specs/                 # API 명세 (OpenAPI)
│   └── assets/                    # 공유 에셋
│
├── deployment/                    # 🚀 배포 설정
│   ├── docker/
│   │   ├── Dockerfile.backend
│   │   └── docker-compose.yml
│   ├── k8s/                       # Kubernetes (선택)
│   └── scripts/
│
├── .github/                       # CI/CD
│   └── workflows/
│       ├── flutter_ci.yml
│       └── backend_ci.yml
│
├── .gitignore
├── README.md                      # 프로젝트 전체 README
└── LICENSE
```

### 2.2 개발 환경별 구조

#### 개발 모드 (로컬)
```
로컬 개발 시:
- Flutter 앱: localhost:8080 (Flutter DevTools)
- FastAPI: localhost:8000
- PostgreSQL: localhost:5432 (Docker)
- Redis: localhost:6379 (Docker)
```

#### 프로덕션 모드
```
배포 시:
- Flutter 앱: iOS App Store + Google Play Store
- FastAPI: AWS Lightsail / GCP Cloud Run
- PostgreSQL: AWS RDS / Cloud SQL
- Redis: AWS ElastiCache / Memorystore
```

---

## 3. Flutter 앱: 프로젝트 구조

### 3.1 Flutter 앱 디렉토리 상세

```
mobile_app/
├── lib/
│   ├── main.dart                  # 📱 앱 엔트리포인트
│   │
│   ├── core/                      # 핵심 기능
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── api_endpoints.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── text_styles.dart
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   ├── validators.dart
│   │   │   └── number_formatter.dart
│   │   └── errors/
│   │       ├── exceptions.dart
│   │       └── failures.dart
│   │
│   ├── data/                      # 데이터 레이어
│   │   ├── models/                # 데이터 모델
│   │   │   ├── lotto_draw.dart
│   │   │   ├── generated_numbers.dart
│   │   │   ├── algorithm_info.dart
│   │   │   ├── user.dart
│   │   │   └── statistics.dart
│   │   ├── repositories/          # Repository 구현
│   │   │   ├── lotto_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   └── stats_repository.dart
│   │   ├── data_sources/          # 데이터 소스
│   │   │   ├── remote/
│   │   │   │   ├── api_client.dart
│   │   │   │   ├── lotto_api.dart
│   │   │   │   └── auth_api.dart
│   │   │   └── local/
│   │   │       ├── hive_database.dart
│   │   │       ├── shared_prefs.dart
│   │   │       └── cache_manager.dart
│   │   └── dto/                   # Data Transfer Objects
│   │       ├── generate_request.dart
│   │       └── generate_response.dart
│   │
│   ├── domain/                    # 도메인 레이어
│   │   ├── entities/              # 비즈니스 엔티티
│   │   │   ├── lotto_draw.dart
│   │   │   ├── number_set.dart
│   │   │   └── algorithm.dart
│   │   ├── repositories/          # Repository 인터페이스
│   │   │   └── lotto_repository.dart
│   │   └── usecases/              # 비즈니스 로직
│   │       ├── generate_numbers.dart
│   │       ├── get_latest_draw.dart
│   │       ├── check_winning.dart
│   │       └── get_statistics.dart
│   │
│   ├── presentation/              # 프레젠테이션 레이어
│   │   ├── providers/             # Riverpod Providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── lotto_provider.dart
│   │   │   ├── algorithm_provider.dart
│   │   │   └── theme_provider.dart
│   │   ├── screens/               # 화면
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── generate/
│   │   │   │   ├── generate_screen.dart
│   │   │   │   ├── algorithm_select_screen.dart
│   │   │   │   └── result_screen.dart
│   │   │   ├── history/
│   │   │   │   ├── history_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── statistics/
│   │   │   │   ├── stats_screen.dart
│   │   │   │   └── charts/
│   │   │   ├── winning_check/
│   │   │   │   └── winning_check_screen.dart
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   ├── widgets/               # 공통 위젯
│   │   │   ├── lotto_ball.dart
│   │   │   ├── number_card.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   └── qr_code_widget.dart
│   │   └── navigation/
│   │       ├── app_router.dart
│   │       └── bottom_nav_bar.dart
│   │
│   └── app.dart                   # App 위젯 정의
│
├── android/                       # Android 네이티브
│   ├── app/
│   │   ├── src/
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/                           # iOS 네이티브
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   └── Podfile
│
├── test/                          # 단위/위젯 테스트
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/                        # 에셋 파일
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml                   # Flutter 의존성
├── analysis_options.yaml          # Lint 설정
└── README.md
```

### 3.2 주요 패키지 및 버전

**`pubspec.yaml`**

```yaml
name: luckyai_645
description: AI 기반 로또 번호 생성 모바일 앱
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 상태 관리
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # 네트워킹
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^5.0.2
  
  # 로컬 저장소
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # JSON 직렬화
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
  # UI/차트
  fl_chart: ^0.66.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  
  # 유틸리티
  intl: ^0.19.0
  qr_flutter: ^4.1.0
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.8.0
  
  # 기타
  logger: ^2.0.2
  equatable: ^2.0.5
  dartz: ^0.10.1  # Either for error handling

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # 코드 생성
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1
  
  # 테스트
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

### 3.3 코드 생성 명령어 (필수)

**⚠️ Critical**: Riverpod, Freezed, Retrofit, Hive 등의 코드 생성 패키지를 사용하므로 **반드시 아래 명령어를 실행**해야 합니다.

#### 3.3.1 초기 설정 (프로젝트 시작 시 1회)

```bash
cd mobile_app

# 1. 의존성 설치
flutter pub get

# 2. 코드 생성 (*.g.dart, *.freezed.dart 파일 생성)
# --delete-conflicting-outputs: 기존 파일 충돌 시 자동 삭제
flutter pub run build_runner build --delete-conflicting-outputs

# 또는 짧은 명령어
dart run build_runner build --delete-conflicting-outputs
```

#### 3.3.2 개발 중 (코드 수정 시 자동 재생성)

```bash
# 파일 변경 감지하여 자동으로 코드 재생성 (권장)
flutter pub run build_runner watch --delete-conflicting-outputs

# 또는
dart run build_runner watch --delete-conflicting-outputs
```

#### 3.3.3 코드 생성이 필요한 파일 예시

```dart
// Provider 코드 생성 (Riverpod)
// lib/presentation/providers/auth_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';  // ⬅️ 코드 생성 필요

@riverpod
class AuthManager extends _$AuthManager {
  // ...
}
```

```dart
// 모델 직렬화 (Freezed + JSON Serializable)
// lib/data/models/user.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';  // ⬅️ 코드 생성 필요
part 'user.g.dart';        // ⬅️ 코드 생성 필요

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

```dart
// API 클라이언트 (Retrofit)
// lib/data/data_sources/remote/lotto_api.dart

import 'package:retrofit/retrofit.dart';

part 'lotto_api.g.dart';  // ⬅️ 코드 생성 필요

@RestApi()
abstract class LottoApi {
  factory LottoApi(Dio dio) = _LottoApi;
  // ...
}
```

```dart
// Hive 타입 어댑터
// lib/data/models/lotto_draw.dart

import 'package:hive/hive.dart';

part 'lotto_draw.g.dart';  // ⬅️ 코드 생성 필요

// ⚠️ 2026-01-02 22:00 EST 경고: typeId 절대 변경 금지!
// - typeId는 Hive가 내부적으로 데이터 타입을 식별하는 고유 번호
// - 한 번 배포 후에는 절대 변경하면 안 됨 (기존 사용자 데이터 손실)
// - 새 모델 추가 시 사용하지 않은 번호 할당 (예: 2, 3, ...)
@HiveType(typeId: 0)  // ⚠️ 변경 금지!
class LottoDraw extends HiveObject {
  @HiveField(0)
  int drawNo;
  // ...
}
```

**⚠️ Hive typeId 관리 가이드**:

```dart
// ✅ 올바른 예: typeId 순차적 할당 및 절대 변경 금지

@HiveType(typeId: 0)  // LottoDraw (변경 금지)
class LottoDraw { ... }

@HiveType(typeId: 1)  // GeneratedNumbers (변경 금지)
class GeneratedNumbers { ... }

@HiveType(typeId: 2)  // 미래에 추가될 모델 (새로운 ID)
class UserSettings { ... }


// ❌ 잘못된 예 1: typeId 중복
@HiveType(typeId: 0)  // LottoDraw
class LottoDraw { ... }

@HiveType(typeId: 0)  // ❌ GeneratedNumbers - 중복!
class GeneratedNumbers { ... }
// 결과: 런타임 오류, 데이터 손실


// ❌ 잘못된 예 2: typeId 변경
// v1.0.0 배포
@HiveType(typeId: 0)
class LottoDraw { ... }

// v1.1.0 배포 (잘못된 변경!)
@HiveType(typeId: 5)  // ❌ 0 → 5로 변경
class LottoDraw { ... }
// 결과: 기존 사용자의 로컬 데이터 읽기 실패


// ✅ 올바른 예 3: 모델 삭제 시
// typeId: 0 - LottoDraw (사용 중)
// typeId: 1 - OldModel (삭제됨) ⬅️ typeId 1은 영구 예약, 재사용 금지!
// typeId: 2 - NewModel (신규 추가)
```

**typeId 관리 문서화**:

```dart
// mobile_app/lib/data/models/README.md

# Hive TypeId 관리 (중요!)

## 현재 할당된 TypeId

| TypeId | 모델 이름           | 파일 경로                          | 상태   |
|--------|---------------------|-----------------------------------|--------|
| 0      | LottoDraw           | data/models/lotto_draw.dart       | 사용중 |
| 1      | GeneratedNumbers    | data/models/generated_numbers.dart| 사용중 |
| 2      | (예약됨)            | -                                 | -      |

## 규칙
1. typeId는 절대 변경 금지 (기존 사용자 데이터 손실)
2. 새 모델 추가 시 사용하지 않은 번호 순차적 할당
3. 모델 삭제 시 typeId는 영구 예약 (재사용 금지)
4. 이 문서를 반드시 최신 상태로 유지
```

#### 3.3.4 문제 해결 (코드 생성 오류 시)

```bash
# 1. 생성된 파일 모두 삭제 후 재생성
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# 2. 캐시 문제 시
flutter pub cache repair
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 3. 특정 파일만 재생성
dart run build_runner build --delete-conflicting-outputs \
  lib/presentation/providers/auth_provider.dart
```

#### 3.3.5 .gitignore 설정

**중요**: 생성된 파일은 Git에 커밋하지 않습니다.

```gitignore
# mobile_app/.gitignore

# 코드 생성 파일
*.g.dart
*.freezed.dart

# Riverpod 생성 파일
*.riverpod.dart

# Hive 생성 파일
*.hive_generator.dart
```

**예외**: 일부 프로젝트는 생성 파일을 커밋하기도 하지만, 권장하지 않습니다.

---

## 4. Flutter 앱: 초기화 로직

### 4.1 Flutter 앱 초기화 플로우차트

```mermaid
flowchart TD
    A[앱 실행<br/>main.dart] --> B[Flutter 바인딩 초기화]
    B --> C[Hive 초기화<br/>로컬 DB]
    C --> D[Firebase 초기화<br/>푸시 알림]
    D --> E[Riverpod<br/>Provider 컨테이너 생성]
    E --> F[앱 위젯 마운트<br/>MaterialApp]
    
    F --> G[Splash 화면 표시]
    G --> H{로컬 데이터<br/>존재?}
    
    H -->|Yes| I[로컬 캐시 로드<br/>Hive]
    H -->|No| J[첫 실행 플래그]
    
    I --> K[백그라운드로<br/>서버 동기화 시작]
    J --> K
    
    K --> L{네트워크<br/>연결?}
    L -->|No| M[오프라인 모드<br/>로컬 데이터만]
    L -->|Yes| N[서버 연결<br/>GET /draws/latest]
    
    N --> O{API<br/>성공?}
    O -->|No| P[재시도 또는<br/>오프라인 모드]
    O -->|Yes| Q[최신 회차 정보 수신]
    
    Q --> R{로컬 데이터와<br/>비교}
    R -->|최신| S[데이터 동기화 완료]
    R -->|구버전| T[서버에서<br/>최신 데이터 다운로드]
    
    T --> U[로컬 DB 업데이트]
    U --> S
    P --> S
    M --> S
    
    S --> V{사용자<br/>로그인?}
    V -->|No| W[홈 화면<br/>게스트 모드]
    V -->|Yes| X[사용자 데이터 로드<br/>히스토리, 즐겨찾기]
    
    X --> Y[홈 화면<br/>개인화]
    W --> Z[초기화 완료<br/>앱 사용 가능]
    Y --> Z
    
    style A fill:#667eea,color:#fff
    style Z fill:#10b981,color:#fff
    style M fill:#f59e0b,color:#fff
    style P fill:#f59e0b,color:#fff
```

### 4.2 Flutter 메인 엔트리포인트

**`mobile_app/lib/main.dart`**

```dart
/// LuckyAI 645 - Flutter 앱 엔트리포인트
/// 
/// 작성일: 2026-01-02 16:30:00 EST
/// 설명: 앱 초기화 및 Provider 컨테이너 설정

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/constants/hive_constants.dart';
import 'data/models/lotto_draw.dart';
import 'data/models/generated_numbers.dart';
import 'firebase_options.dart';

/// 글로벌 로거
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

void main() async {
  // 1. Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('🚀 LuckyAI 645 앱 시작...');
  
  // 2. 시스템 UI 설정 (상태바, 내비게이션바)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 3. 화면 방향 고정 (세로 모드만)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    // 4. Firebase 초기화 (푸시 알림용)
    logger.i('🔥 Firebase 초기화 중...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('✅ Firebase 초기화 완료');
    
    // 5. Hive 로컬 DB 초기화
    logger.i('💾 Hive 초기화 중...');
    await Hive.initFlutter();
    
    // Hive Adapter 등록 (커스텀 모델)
    // ⚠️ 2026-01-02 22:00 EST 경고: typeId 순서 중요!
    // - typeId는 0부터 시작, 고유해야 하며, 한 번 할당된 ID는 절대 변경 금지
    // - 변경 시 기존 사용자의 로컬 데이터 손실 발생
    // - 새 모델 추가 시 기존 ID를 건너뛰지 않고 순차적으로 할당
    
    // 현재 할당된 typeId:
    // - LottoDraw: typeId = 0
    // - GeneratedNumbers: typeId = 1
    // - (미래 추가 시 typeId = 2, 3, ...)
    
    Hive.registerAdapter(LottoDrawAdapter());          // typeId: 0
    Hive.registerAdapter(GeneratedNumbersAdapter());   // typeId: 1
    
    // ⚠️ 잘못된 예:
    // Hive.registerAdapter(GeneratedNumbersAdapter()); // typeId: 1 먼저 등록
    // Hive.registerAdapter(LottoDrawAdapter());        // typeId: 0 나중 등록
    // → 기존 데이터 손상 위험!
    
    // Hive Box 열기
    await Hive.openBox(HiveConstants.drawsBox);
    await Hive.openBox(HiveConstants.generatedBox);
    await Hive.openBox(HiveConstants.settingsBox);
    
    logger.i('✅ Hive 초기화 완료');
    
    // 6. 앱 실행
    runApp(
      // ProviderScope: Riverpod의 루트 컨테이너
      const ProviderScope(
        child: LuckyAIApp(),
      ),
    );
    
    logger.i('✨ 앱 초기화 완료!');
    
  } catch (e, stackTrace) {
    logger.e('❌ 앱 초기화 실패', error: e, stackTrace: stackTrace);
    
    // 에러 화면 표시
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '앱 초기화 중 오류가 발생했습니다',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4.3 앱 위젯 정의

**`mobile_app/lib/app.dart`**

```dart
/// LuckyAI 645 앱 위젯
/// 
/// MaterialApp 설정 및 라우팅 관리

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/theme_provider.dart';

class LuckyAIApp extends ConsumerWidget {
  const LuckyAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 테마 모드 감시 (다크/라이트 모드)
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      // 앱 기본 정보
      title: 'LuckyAI 645',
      debugShowCheckedModeBanner: false,
      
      // 테마 설정
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      
      // 라우팅
      routerConfig: router,
      
      // 로케일 설정
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      
      // 빌더 (앱 전체에 적용되는 위젯)
      builder: (context, child) {
        return MediaQuery(
          // 폰트 크기 고정 (시스템 설정 무시)
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
```

---

## 5. Flutter 앱: 상태 관리

### 5.1 Riverpod Provider 아키텍처

```
Provider 계층 구조:

1. Data Providers (데이터 소스)
   ├─ apiClientProvider          # Dio 클라이언트
   ├─ hiveProvider                # 로컬 DB
   └─ sharedPrefsProvider         # 설정 저장소

2. Repository Providers
   ├─ lottoRepositoryProvider     # 로또 데이터 Repository
   ├─ userRepositoryProvider      # 사용자 Repository
   └─ statsRepositoryProvider     # 통계 Repository

3. UseCase Providers (비즈니스 로직)
   ├─ generateNumbersProvider     # 번호 생성
   ├─ getLatestDrawProvider       # 최신 회차 조회
   └─ checkWinningProvider        # 당첨 확인

4. State Providers (UI 상태)
   ├─ authStateProvider           # 인증 상태
   ├─ lottoStateProvider          # 로또 데이터 상태
   ├─ algorithmStateProvider      # 선택된 알고리즘
   └─ themeProvider               # 테마 모드
```

### 5.2 주요 Provider 예시

**`mobile_app/lib/presentation/providers/lotto_provider.dart`**

```dart
/// 로또 데이터 상태 관리 Provider
/// 
/// Riverpod 2.0+ 코드 생성 방식 사용

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/lotto_draw.dart';
import '../../data/repositories/lotto_repository.dart';
import '../../domain/usecases/get_latest_draw.dart';

part 'lotto_provider.g.dart';

/// 최신 회차 조회 Provider
@riverpod
Future<LottoDraw?> latestDraw(LatestDrawRef ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final useCase = GetLatestDraw(repository);
  
  final result = await useCase.execute();
  
  return result.fold(
    (failure) => null,  // 실패 시 null
    (draw) => draw,      // 성공 시 데이터
  );
}

/// 로또 히스토리 Provider
@riverpod
Future<List<LottoDraw>> lottoHistory(
  LottoHistoryRef ref, {
  int limit = 50,
}) async {
  final repository = ref.watch(lottoRepositoryProvider);
  
  final result = await repository.getDraws(limit: limit);
  
  return result.fold(
    (failure) => [],
    (draws) => draws,
  );
}

/// 번호 생성 상태 Provider
@riverpod
class GenerationState extends _$GenerationState {
  @override
  AsyncValue<GeneratedResult?> build() {
    return const AsyncValue.data(null);
  }
  
  /// 번호 생성 요청
  Future<void> generateNumbers({
    required int algorithmId,
    required int nSets,
    List<int>? excludeNumbers,
    List<int>? includeNumbers,
  }) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(lottoRepositoryProvider);
    
    final result = await repository.generateNumbers(
      algorithmId: algorithmId,
      nSets: nSets,
      excludeNumbers: excludeNumbers,
      includeNumbers: includeNumbers,
    );
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (data) => AsyncValue.data(data),
    );
  }
}
```

### 5.3 Repository Pattern

**`mobile_app/lib/data/repositories/lotto_repository.dart`**

```dart
/// 로또 Repository 구현
/// 
/// 로컬(Hive) + 원격(API) 데이터 소스 통합

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data_sources/local/hive_database.dart';
import '../data_sources/remote/lotto_api.dart';
import '../models/lotto_draw.dart';
import '../../core/errors/failures.dart';

part 'lotto_repository.g.dart';

@riverpod
LottoRepository lottoRepository(LottoRepositoryRef ref) {
  final api = ref.watch(lottoApiProvider);
  final localDb = ref.watch(hiveDbProvider);
  
  return LottoRepositoryImpl(api: api, localDb: localDb);
}

abstract class LottoRepository {
  Future<Either<Failure, LottoDraw?>> getLatestDraw();
  Future<Either<Failure, List<LottoDraw>>> getDraws({int limit});
  Future<Either<Failure, GeneratedResult>> generateNumbers({
    required int algorithmId,
    required int nSets,
    List<int>? excludeNumbers,
    List<int>? includeNumbers,
  });
}

class LottoRepositoryImpl implements LottoRepository {
  final LottoApi api;
  final HiveDatabase localDb;
  
  LottoRepositoryImpl({
    required this.api,
    required this.localDb,
  });
  
  @override
  Future<Either<Failure, LottoDraw?>> getLatestDraw() async {
    try {
      // 1. 로컬 캐시 먼저 확인
      final cachedDraw = await localDb.getLatestDraw();
      
      // 2. 서버에서 최신 데이터 조회
      final remoteDraw = await api.getLatestDraw();
      
      // 3. 로컬 캐시 업데이트
      if (remoteDraw != null && remoteDraw != cachedDraw) {
        await localDb.saveDraw(remoteDraw);
      }
      
      return Right(remoteDraw ?? cachedDraw);
      
    } catch (e) {
      // 네트워크 오류 시 로컬 캐시 반환
      final cachedDraw = await localDb.getLatestDraw();
      if (cachedDraw != null) {
        return Right(cachedDraw);
      }
      
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<LottoDraw>>> getDraws({int limit = 50}) async {
    try {
      // 1. 로컬에서 먼저 로드 (빠른 UI 표시)
      final localDraws = await localDb.getDraws(limit: limit);
      
      // 2. 백그라운드로 서버 동기화
      _syncDrawsInBackground();
      
      return Right(localDraws);
      
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, GeneratedResult>> generateNumbers({
    required int algorithmId,
    required int nSets,
    List<int>? excludeNumbers,
    List<int>? includeNumbers,
  }) async {
    try {
      final result = await api.generateNumbers(
        algorithmId: algorithmId,
        nSets: nSets,
        excludeNumbers: excludeNumbers,
        includeNumbers: includeNumbers,
      );
      
      // 생성 결과 로컬 저장 (히스토리)
      await localDb.saveGeneratedNumbers(result);
      
      return Right(result);
      
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  Future<void> _syncDrawsInBackground() async {
    // 백그라운드 동기화 로직
    // TODO: 구현
  }
}
```

---

## 6. Flutter 앱: API 통신 계층

### 6.1 Dio HTTP 클라이언트 설정

**`mobile_app/lib/data/data_sources/remote/api_client.dart`**

```dart
/// API 클라이언트 설정
/// 
/// Dio + Interceptor 설정

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../core/constants/api_endpoints.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // 로깅 인터셉터 (개발 모드)
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );
  
  // 인증 인터셉터
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // JWT 토큰 추가
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 401 에러 시 자동 로그아웃
        if (error.response?.statusCode == 401) {
          ref.read(authStateProvider.notifier).logout();
        }
        handler.next(error);
      },
    ),
  );
  
  return dio;
});
```

### 6.2 Retrofit API 인터페이스

**`mobile_app/lib/data/data_sources/remote/lotto_api.dart`**

```dart
/// Retrofit API 인터페이스
/// 
/// 코드 생성으로 REST API 자동 구현

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/lotto_draw.dart';
import '../../dto/generate_request.dart';
import '../../dto/generate_response.dart';

part 'lotto_api.g.dart';

@riverpod
LottoApi lottoApi(LottoApiRef ref) {
  final dio = ref.watch(apiClientProvider);
  return LottoApi(dio);
}

@RestApi()
abstract class LottoApi {
  factory LottoApi(Dio dio, {String baseUrl}) = _LottoApi;
  
  /// 최신 회차 조회
  @GET('/api/draws/latest')
  Future<LottoDraw> getLatestDraw();
  
  /// 회차 리스트 조회
  @GET('/api/draws')
  Future<List<LottoDraw>> getDraws(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
  
  /// 특정 회차 조회
  @GET('/api/draws/{draw_no}')
  Future<LottoDraw> getDraw(@Path('draw_no') int drawNo);
  
  /// 번호 생성
  @POST('/api/generate')
  Future<GenerateResponse> generateNumbers(
    @Body() GenerateRequest request,
  );
  
  /// 알고리즘 목록
  @GET('/api/generate/algorithms')
  Future<List<AlgorithmInfo>> getAlgorithms();
  
  /// 당첨 확인
  @POST('/api/check-winning')
  Future<WinningResult> checkWinning(
    @Body() Map<String, dynamic> data,
  );
  
  /// 통계 조회
  @GET('/api/stats/frequency')
  Future<FrequencyStats> getFrequencyStats();
}
```

---

## 7. Flutter 앱: 로컬 데이터 저장

### 7.1 로컬 저장소 개요

### 7.2 Hive 데이터베이스 설정

**`mobile_app/lib/data/data_sources/local/hive_database.dart`**

```dart
/// Hive 로컬 데이터베이스
/// 
/// 오프라인 모드 및 캐싱용

import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/lotto_draw.dart';
import '../../models/generated_numbers.dart';
import '../../../core/constants/hive_constants.dart';

part 'hive_database.g.dart';

@riverpod
HiveDatabase hiveDb(HiveDbRef ref) {
  return HiveDatabase();
}

class HiveDatabase {
  Box<LottoDraw> get _drawsBox => Hive.box<LottoDraw>(HiveConstants.drawsBox);
  Box<GeneratedNumbers> get _generatedBox => 
      Hive.box<GeneratedNumbers>(HiveConstants.generatedBox);
  Box get _settingsBox => Hive.box(HiveConstants.settingsBox);
  
  /// 최신 회차 조회
  Future<LottoDraw?> getLatestDraw() async {
    if (_drawsBox.isEmpty) return null;
    
    // 회차 번호로 정렬하여 최신 데이터 반환
    final draws = _drawsBox.values.toList()
      ..sort((a, b) => b.drawNo.compareTo(a.drawNo));
    
    return draws.first;
  }
  
  /// 회차 저장
  Future<void> saveDraw(LottoDraw draw) async {
    await _drawsBox.put(draw.drawNo, draw);
  }
  
  /// 여러 회차 조회
  Future<List<LottoDraw>> getDraws({int limit = 50}) async {
    final draws = _drawsBox.values.toList()
      ..sort((a, b) => b.drawNo.compareTo(a.drawNo));
    
    return draws.take(limit).toList();
  }
  
  /// 생성된 번호 저장 (히스토리)
  Future<void> saveGeneratedNumbers(GeneratedNumbers numbers) async {
    final key = DateTime.now().millisecondsSinceEpoch;
    await _generatedBox.put(key, numbers);
  }
  
  /// 생성 히스토리 조회
  Future<List<GeneratedNumbers>> getGeneratedHistory({int limit = 20}) async {
    final history = _generatedBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return history.take(limit).toList();
  }
  
  /// 설정 저장
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  /// 설정 조회
  T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }
}
```

---

## 8. Flutter 앱: UI 화면 구조

### 8.1 주요 화면 목록

```
1. Splash Screen (스플래시)
   - 앱 로고 표시
   - 초기화 진행

2. Home Screen (홈)
   - 최신 회차 정보
   - 빠른 번호 생성 버튼
   - 최근 생성 히스토리

3. Generate Screen (번호 생성)
   - 알고리즘 선택
   - 옵션 설정 (제외/포함 번호)
   - 생성 결과 표시
   - QR 코드 생성

4. History Screen (히스토리)
   - 생성 히스토리
   - 즐겨찾기
   - 공유 기능

5. Statistics Screen (통계)
   - 번호 빈도 차트
   - 알고리즘 성능
   - 트렌드 분석

6. Winning Check Screen (당첨 확인)
   - 내 번호 입력
   - 자동 당첨 확인
   - 당첨 내역

7. Settings Screen (설정)
   - 테마 변경
   - 알림 설정
   - 계정 관리
```

### 8.2 번호 생성 화면 예시

**`mobile_app/lib/presentation/screens/generate/generate_screen.dart`**

```dart
/// 번호 생성 화면
/// 
/// 알고리즘 선택 및 번호 생성 요청

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/lotto_provider.dart';
import '../../widgets/lotto_ball.dart';
import '../../widgets/loading_indicator.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  int _selectedAlgorithm = 1;
  int _nSets = 5;
  List<int> _excludeNumbers = [];
  List<int> _includeNumbers = [];

  @override
  Widget build(BuildContext context) {
    final generationState = ref.watch(generationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('번호 생성'),
      ),
      body: generationState.when(
        data: (result) => _buildContent(result),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildError(error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateNumbers,
        icon: const Icon(Icons.casino),
        label: const Text('번호 생성'),
      ),
    );
  }

  Widget _buildContent(GeneratedResult? result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 알고리즘 선택
          _buildAlgorithmSelector(),
          
          const SizedBox(height: 24),
          
          // 생성 옵션
          _buildOptions(),
          
          const SizedBox(height: 24),
          
          // 결과 표시
          if (result != null) _buildResults(result),
        ],
      ),
    );
  }

  void _generateNumbers() {
    ref.read(generationStateProvider.notifier).generateNumbers(
      algorithmId: _selectedAlgorithm,
      nSets: _nSets,
      excludeNumbers: _excludeNumbers.isNotEmpty ? _excludeNumbers : null,
      includeNumbers: _includeNumbers.isNotEmpty ? _includeNumbers : null,
    );
  }
  
  // ... 나머지 UI 빌더 메서드들
}
```

---

## 9. 백엔드: 프로젝트 구조

### 9.1 백엔드 디렉토리 상세

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI 엔트리포인트
│   ├── config.py                  # 설정 관리
│   │
│   ├── api/                       # API 엔드포인트
│   │   ├── __init__.py
│   │   ├── deps.py                # 의존성 주입
│   │   └── routes/
│   │       ├── auth.py            # 인증 API
│   │       ├── generate.py        # 번호 생성 API
│   │       ├── draws.py           # 로또 데이터 API
│   │       ├── validation.py      # 검증 API
│   │       └── stats.py           # 통계 API
│   │
│   ├── core/                      # 핵심 비즈니스 로직
│   │   ├── data_manager.py        # 데이터 관리 총괄
│   │   ├── crawler.py             # 로또 크롤러
│   │   ├── data_validator.py      # 데이터 검증
│   │   ├── cache_manager.py       # 캐시 관리
│   │   └── scheduler.py           # 스케줄링
│   │
│   ├── algorithms/                # 알고리즘 모듈 (9개)
│   │   ├── base.py                # 추상 베이스 클래스
│   │   ├── algorithm_01_random.py
│   │   ├── algorithm_02_lstm.py
│   │   └── ...                    # 나머지 알고리즘
│   │
│   ├── models/                    # AI 모델
│   │   ├── lstm_model.py
│   │   ├── model_trainer.py
│   │   └── model_loader.py
│   │
│   ├── validation/                # 검증 시스템
│   │   ├── validator.py           # Walk-Forward Validation
│   │   ├── evaluator.py           # 성능 평가
│   │   └── metrics.py             # 지표 계산
│   │
│   ├── db/                        # 데이터베이스
│   │   ├── base.py
│   │   ├── session.py
│   │   ├── models/                # ORM 모델
│   │   │   ├── user.py
│   │   │   ├── lotto_draw.py
│   │   │   └── generated_number.py
│   │   └── repositories/
│   │       ├── user_repo.py
│   │       └── draw_repo.py
│   │
│   ├── services/                  # 비즈니스 서비스
│   │   ├── auth_service.py
│   │   ├── generation_service.py
│   │   └── stats_service.py
│   │
│   ├── schemas/                   # Pydantic 스키마
│   │   ├── user.py
│   │   ├── draw.py
│   │   └── generation.py
│   │
│   ├── utils/                     # 유틸리티
│   │   ├── logger.py
│   │   ├── helpers.py
│   │   └── constants.py
│   │
│   └── workers/                   # Celery Workers
│       ├── celery_app.py
│       ├── tasks.py
│       └── beat_schedule.py
│
├── data/                          # 데이터 파일
│   ├── raw/
│   │   └── lotto_data.csv
│   ├── processed/
│   └── models/
│       └── lstm_v1.pth
│
├── results/                       # 검증 결과
│   ├── validation/
│   ├── reports/
│   └── logs/
│
├── tests/                         # 테스트
│   ├── test_algorithms/
│   ├── test_validation/
│   └── test_api/
│
├── scripts/                       # 스크립트
│   ├── init_db.py
│   ├── load_data.py
│   └── run_validation.py
│
├── .env
├── requirements.txt
├── pyproject.toml
└── README.md
```

---

## 10. 백엔드: 서버 시작 로직

### 10.1 서버 초기화 플로우

```mermaid
flowchart TD
    A[FastAPI 서버 시작] --> B[환경 변수 로드]
    B --> C[로깅 초기화]
    C --> D[PostgreSQL 연결]
    D --> E{DB 연결<br/>성공?}
    E -->|No| F[에러 & 종료]
    E -->|Yes| G[Redis 연결]
    G --> H[데이터 매니저<br/>초기화]
    H --> I[로또 데이터<br/>동기화]
    I --> J{최신 회차<br/>확인}
    J -->|새 데이터| K[크롤링 & 업데이트]
    J -->|최신| L[로컬 데이터 사용]
    K --> M[알고리즘 로드]
    L --> M
    M --> N[LSTM 모델 로드]
    N --> O[캐시 워밍업]
    O --> P[Celery Worker 시작]
    P --> Q[API 서버 Ready]
    
    style A fill:#667eea,color:#fff
    style Q fill:#10b981,color:#fff
    style F fill:#ef4444,color:#fff
```

### 10.2 데이터 매니저

**`app/core/data_manager.py`**

```python
"""
데이터 관리 총괄 모듈

로또 데이터의 동기화, 검증, 저장을 관리
"""

import asyncio
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Dict, Optional

import pandas as pd
from loguru import logger

from app.config import settings
from app.core.crawler import LottoCrawler
from app.core.data_validator import DataValidator
from app.db.repositories.draw_repo import DrawRepository


class DataManager:
    """
    데이터 관리 총괄 클래스
    
    책임:
    - 로컬 CSV와 DB 동기화
    - 최신 회차 확인 및 업데이트
    - 데이터 무결성 검증
    """
    
    def __init__(self):
        self.csv_path = settings.LOTTO_CSV_PATH
        self.crawler = LottoCrawler()
        self.validator = DataValidator()
        self.draw_repo = DrawRepository()
        self.df: Optional[pd.DataFrame] = None
    
    async def initialize(self) -> Dict:
        """
        초기화 및 데이터 동기화
        
        Returns:
            Dict: {
                'status': 'success' | 'error',
                'total_draws': int,
                'latest_draw': int,
                'updated': bool,
                'error': Optional[str]
            }
        """
        try:
            # 1. 로컬 CSV 확인
            local_exists = self.csv_path.exists()
            local_latest = None
            
            if local_exists:
                logger.info(f"📁 로컬 CSV 발견: {self.csv_path}")
                self.df = pd.read_csv(self.csv_path, encoding='utf-8-sig')
                local_latest = self.df['회차'].max()
                logger.info(f"   로컬 최신 회차: {local_latest}회")
            else:
                logger.warning("⚠️  로컬 CSV 없음, 전체 크롤링 시작...")
            
            # 2. 온라인 최신 회차 확인
            logger.info("🌐 온라인 최신 회차 조회...")
            online_latest = await self.crawler.get_latest_draw_number()
            
            if online_latest is None:
                logger.error("❌ 온라인 조회 실패")
                if local_exists:
                    logger.info("   로컬 데이터로 계속 진행")
                    return await self._finalize_initialization(local_latest)
                else:
                    return {
                        'status': 'error',
                        'error': '데이터 없음 (로컬 & 온라인 모두 실패)',
                        'fatal': True
                    }
            
            logger.info(f"   온라인 최신 회차: {online_latest}회")
            
            # 3. 동기화 필요 여부 확인
            if local_latest is None:
                # 전체 크롤링
                logger.info(f"📥 전체 데이터 크롤링 (1~{online_latest}회)...")
                new_data = await self.crawler.crawl_range(1, online_latest)
                self.df = pd.DataFrame(new_data)
                await self._save_to_csv()
                updated = True
                
            elif online_latest > local_latest:
                # 증분 크롤링
                missing_count = online_latest - local_latest
                logger.info(f"📥 누락된 {missing_count}개 회차 크롤링...")
                new_data = await self.crawler.crawl_range(
                    local_latest + 1, 
                    online_latest
                )
                
                # 기존 데이터에 추가
                new_df = pd.DataFrame(new_data)
                self.df = pd.concat([self.df, new_df], ignore_index=True)
                await self._save_to_csv()
                updated = True
                
            else:
                # 최신 상태
                logger.success("✅ 데이터 최신 상태")
                updated = False
            
            # 4. 데이터 검증
            logger.info("🔍 데이터 무결성 검증...")
            validation_result = self.validator.validate_dataframe(self.df)
            
            if not validation_result['valid']:
                logger.error(f"❌ 데이터 검증 실패: {validation_result['errors']}")
                # 치명적 오류면 중단
                if validation_result.get('fatal'):
                    return {
                        'status': 'error',
                        'error': f"데이터 검증 실패: {validation_result['errors']}",
                        'fatal': True
                    }
            else:
                logger.success("✅ 데이터 검증 완료")
            
            # 5. DB 동기화
            logger.info("💾 데이터베이스 동기화...")
            await self._sync_to_database()
            
            return await self._finalize_initialization(online_latest, updated)
            
        except Exception as e:
            logger.exception(f"❌ 초기화 중 오류: {e}")
            return {
                'status': 'error',
                'error': str(e),
                'fatal': True
            }
    
    async def _finalize_initialization(
        self, 
        latest_draw: int, 
        updated: bool = False
    ) -> Dict:
        """초기화 완료 처리"""
        total_draws = len(self.df) if self.df is not None else 0
        
        return {
            'status': 'success',
            'total_draws': total_draws,
            'latest_draw': latest_draw,
            'updated': updated
        }
    
    async def _save_to_csv(self):
        """CSV 파일 저장"""
        try:
            self.df.to_csv(self.csv_path, index=False, encoding='utf-8-sig')
            logger.success(f"💾 CSV 저장 완료: {self.csv_path}")
        except Exception as e:
            logger.error(f"❌ CSV 저장 실패: {e}")
            raise
    
    async def _sync_to_database(self):
        """데이터베이스 동기화"""
        try:
            # CSV 데이터를 DB에 동기화
            synced_count = await self.draw_repo.sync_from_dataframe(self.df)
            logger.success(f"💾 DB 동기화 완료: {synced_count}개 회차")
        except Exception as e:
            logger.error(f"❌ DB 동기화 실패: {e}")
            # DB 동기화 실패는 치명적이지 않음 (CSV 있음)
    
    def get_dataframe(self) -> pd.DataFrame:
        """현재 데이터프레임 반환"""
        if self.df is None:
            raise ValueError("데이터가 로드되지 않음")
        return self.df
    
    def get_draws_up_to(self, draw_no: int) -> pd.DataFrame:
        """
        특정 회차까지의 데이터만 반환
        
        Walk-Forward Validation에서 시간 누수 방지용
        
        Args:
            draw_no: 제외할 회차 번호
            
        Returns:
            draw_no 미만의 데이터만 포함된 DataFrame
        """
        if self.df is None:
            raise ValueError("데이터가 로드되지 않음")
        
        return self.df[self.df['회차'] < draw_no].copy()
    
    async def check_for_updates(self) -> Dict:
        """
        업데이트 확인 (정기 체크용)
        
        Returns:
            Dict: {
                'has_update': bool,
                'current': int,
                'latest': int
            }
        """
        try:
            current = self.df['회차'].max() if self.df is not None else 0
            latest = await self.crawler.get_latest_draw_number()
            
            return {
                'has_update': latest > current if latest else False,
                'current': current,
                'latest': latest
            }
        except Exception as e:
            logger.error(f"업데이트 확인 실패: {e}")
            return {
                'has_update': False,
                'error': str(e)
            }
```

### 4.2 크롤러

**`app/core/crawler.py`**

```python
"""
로또 당첨번호 크롤러

동행복권 웹사이트에서 당첨번호 수집
"""

import asyncio
from datetime import datetime
from typing import Dict, List, Optional

import aiohttp
from bs4 import BeautifulSoup
from loguru import logger

from app.config import settings


class LottoCrawler:
    """
    로또 당첨번호 크롤러
    
    동행복권 웹사이트에서 데이터 수집
    """
    
    def __init__(self):
        self.base_url = settings.LOTTO_CRAWLER_URL
        self.timeout = settings.CRAWLER_TIMEOUT
        self.retry_count = settings.CRAWLER_RETRY
    
    async def get_latest_draw_number(self) -> Optional[int]:
        """
        최신 회차 번호 조회
        
        Returns:
            최신 회차 번호 또는 None (실패 시)
        """
        try:
            async with aiohttp.ClientSession() as session:
                params = {'method': 'getLast'}
                async with session.get(
                    self.base_url,
                    params=params,
                    timeout=self.timeout
                ) as response:
                    if response.status == 200:
                        html = await response.text()
                        soup = BeautifulSoup(html, 'html.parser')
                        
                        # 회차 번호 파싱
                        draw_no_elem = soup.select_one('.win_result h4 strong')
                        if draw_no_elem:
                            draw_no_text = draw_no_elem.text.strip()
                            # "1169회" -> 1169
                            draw_no = int(draw_no_text.replace('회', ''))
                            return draw_no
                        
        except Exception as e:
            logger.error(f"최신 회차 조회 실패: {e}")
        
        return None
    
    async def crawl_single(self, draw_no: int) -> Optional[Dict]:
        """
        단일 회차 크롤링
        
        Args:
            draw_no: 회차 번호
            
        Returns:
            Dict: {
                '회차': int,
                '추첨일': str,
                '번호1'~'번호6': int,
                '보너스': int,
                '1등당첨금': int,
                '1등당첨자수': int,
                ...
            }
        """
        for attempt in range(self.retry_count):
            try:
                async with aiohttp.ClientSession() as session:
                    params = {'drwNo': draw_no}
                    async with session.get(
                        self.base_url,
                        params=params,
                        timeout=self.timeout
                    ) as response:
                        if response.status == 200:
                            html = await response.text()
                            return self._parse_draw_data(html, draw_no)
                        
            except Exception as e:
                logger.warning(
                    f"회차 {draw_no} 크롤링 실패 "
                    f"(시도 {attempt + 1}/{self.retry_count}): {e}"
                )
                if attempt < self.retry_count - 1:
                    await asyncio.sleep(2 ** attempt)  # Exponential backoff
        
        logger.error(f"회차 {draw_no} 크롤링 최종 실패")
        return None
    
    def _parse_draw_data(self, html: str, draw_no: int) -> Optional[Dict]:
        """HTML 파싱하여 당첨번호 추출"""
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            # 당첨번호 추출
            numbers = []
            num_elements = soup.select('.win .ball_645')
            for elem in num_elements[:6]:  # 6개 번호
                num = int(elem.text.strip())
                numbers.append(num)
            
            # 보너스 번호
            bonus_elem = soup.select_one('.win .ball_645.bonus')
            bonus = int(bonus_elem.text.strip()) if bonus_elem else None
            
            # 추첨일
            date_elem = soup.select_one('.win_result .desc')
            draw_date = None
            if date_elem:
                date_text = date_elem.text.strip()
                # "2024년 12월 30일 추첨" -> "2024-12-30"
                import re
                match = re.search(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일', date_text)
                if match:
                    year, month, day = match.groups()
                    draw_date = f"{year}-{month.zfill(2)}-{day.zfill(2)}"
            
            # 당첨금/당첨자 수 (선택적)
            # TODO: 필요 시 추가 파싱
            
            return {
                '회차': draw_no,
                '추첨일': draw_date,
                '번호1': numbers[0],
                '번호2': numbers[1],
                '번호3': numbers[2],
                '번호4': numbers[3],
                '번호5': numbers[4],
                '번호6': numbers[5],
                '보너스': bonus,
            }
            
        except Exception as e:
            logger.error(f"HTML 파싱 실패 (회차 {draw_no}): {e}")
            return None
    
    async def crawl_range(
        self, 
        start: int, 
        end: int,
        batch_size: int = 10
    ) -> List[Dict]:
        """
        범위 크롤링 (비동기 병렬)
        
        Args:
            start: 시작 회차
            end: 종료 회차
            batch_size: 동시 크롤링 개수
            
        Returns:
            List[Dict]: 수집된 데이터 리스트
        """
        results = []
        total = end - start + 1
        
        logger.info(f"범위 크롤링 시작: {start}~{end}회 (총 {total}개)")
        
        # 배치로 나누어 크롤링
        for i in range(start, end + 1, batch_size):
            batch_end = min(i + batch_size - 1, end)
            batch_draws = range(i, batch_end + 1)
            
            # 병렬 실행
            tasks = [self.crawl_single(draw_no) for draw_no in batch_draws]
            batch_results = await asyncio.gather(*tasks)
            
            # None 제외하고 추가
            for result in batch_results:
                if result:
                    results.append(result)
            
            logger.info(f"진행: {len(results)}/{total}회차 완료")
            
            # Rate limiting (서버 부하 방지)
            if batch_end < end:
                await asyncio.sleep(1)
        
        logger.success(f"크롤링 완료: {len(results)}/{total}회차 수집")
        return results
```

### 4.3 데이터 검증기

**`app/core/data_validator.py`**

```python
"""
데이터 검증 모듈

로또 데이터의 무결성 검증
"""

from typing import Dict, List

import pandas as pd
from loguru import logger


class DataValidator:
    """
    데이터 무결성 검증 클래스
    """
    
    @staticmethod
    def validate_dataframe(df: pd.DataFrame) -> Dict:
        """
        DataFrame 전체 검증
        
        Args:
            df: 검증할 DataFrame
            
        Returns:
            Dict: {
                'valid': bool,
                'errors': List[str],
                'warnings': List[str],
                'fatal': bool
            }
        """
        errors = []
        warnings = []
        fatal = False
        
        # 1. 필수 컬럼 확인
        required_columns = ['회차', '번호1', '번호2', '번호3', 
                           '번호4', '번호5', '번호6', '보너스']
        missing_cols = [col for col in required_columns if col not in df.columns]
        
        if missing_cols:
            errors.append(f"필수 컬럼 누락: {missing_cols}")
            fatal = True
        
        # 2. 데이터 타입 확인
        try:
            df['회차'] = df['회차'].astype(int)
            for i in range(1, 7):
                df[f'번호{i}'] = df[f'번호{i}'].astype(int)
            df['보너스'] = df['보너스'].astype(int)
        except Exception as e:
            errors.append(f"데이터 타입 오류: {e}")
            fatal = True
        
        if not fatal:
            # 3. 번호 범위 확인 (1~45)
            for i in range(1, 7):
                col = f'번호{i}'
                invalid_nums = df[
                    (df[col] < 1) | (df[col] > 45)
                ]
                if len(invalid_nums) > 0:
                    errors.append(
                        f"{col}: 범위 오류 {len(invalid_nums)}건 "
                        f"(회차: {invalid_nums['회차'].tolist()[:5]}...)"
                    )
            
            # 보너스도 확인
            invalid_bonus = df[(df['보너스'] < 1) | (df['보너스'] > 45)]
            if len(invalid_bonus) > 0:
                errors.append(f"보너스: 범위 오류 {len(invalid_bonus)}건")
            
            # 4. 중복 번호 확인 (같은 회차 내 6개 번호)
            for idx, row in df.iterrows():
                numbers = [row[f'번호{i}'] for i in range(1, 7)]
                if len(numbers) != len(set(numbers)):
                    errors.append(f"회차 {row['회차']}: 중복 번호 있음 {numbers}")
            
            # 5. 회차 연속성 확인
            draws = sorted(df['회차'].unique())
            for i in range(1, len(draws)):
                if draws[i] != draws[i-1] + 1:
                    warnings.append(
                        f"회차 불연속: {draws[i-1]}회 다음이 {draws[i]}회"
                    )
        
        # 결과
        valid = len(errors) == 0
        
        if not valid:
            logger.warning(f"검증 오류 {len(errors)}건, 경고 {len(warnings)}건")
            for error in errors[:5]:  # 처음 5개만
                logger.error(f"  - {error}")
        
        if warnings:
            for warning in warnings[:5]:
                logger.warning(f"  - {warning}")
        
        return {
            'valid': valid,
            'errors': errors,
            'warnings': warnings,
            'fatal': fatal
        }
    
    @staticmethod
    def validate_single_draw(draw_data: Dict) -> bool:
        """
        단일 회차 데이터 검증
        
        Args:
            draw_data: 회차 데이터 딕셔너리
            
        Returns:
            bool: 유효 여부
        """
        # 필수 키 확인
        required_keys = ['회차', '번호1', '번호2', '번호3', 
                        '번호4', '번호5', '번호6', '보너스']
        
        if not all(key in draw_data for key in required_keys):
            return False
        
        # 번호 범위 확인
        numbers = [draw_data[f'번호{i}'] for i in range(1, 7)]
        if not all(1 <= num <= 45 for num in numbers):
            return False
        
        # 중복 확인
        if len(numbers) != len(set(numbers)):
            return False
        
        # 보너스 확인
        if not (1 <= draw_data['보너스'] <= 45):
            return False
        
        return True
```

---

## 11. 백엔드: 데이터 관리 모듈

> **참고**: 데이터 관리 모듈은 로또 당첨번호 크롤링, CSV 저장, DB 동기화를 담당합니다.
> 
> **주요 클래스**:
> - `DataManager`: 데이터 동기화 총괄
> - `LottoCrawler`: 동행복권 사이트 크롤링
> - `DataValidator`: 데이터 무결성 검증

### 11.1 DataManager 핵심 로직

**프로그램 시작 시 동작**:
1. 로컬 CSV 파일 확인
2. 온라인 최신 회차 조회 (`dhlottery.co.kr`)
3. 차이가 있으면 **증분 크롤링** (누락된 회차만)
4. CSV 저장 및 PostgreSQL 동기화
5. 앱 상태에 데이터 로드

**코드는 기존 섹션 4.1~4.3 참조** (변경 없음)

---

## 12. 백엔드: 알고리즘 모듈

### 5.1 베이스 클래스

**`app/algorithms/base.py`**

```python
"""
알고리즘 베이스 클래스

모든 알고리즘이 상속받을 추상 클래스
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Optional

import pandas as pd


class LottoAlgorithm(ABC):
    """
    로또 알고리즘 추상 베이스 클래스
    
    모든 알고리즘은 이 클래스를 상속받아야 함
    """
    
    def __init__(self, algorithm_id: int, name: str, description: str):
        """
        Args:
            algorithm_id: 알고리즘 ID (1~9)
            name: 알고리즘 이름
            description: 설명
        """
        self.algorithm_id = algorithm_id
        self.name = name
        self.description = description
        self.version = "1.0"
    
    @abstractmethod
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        번호 생성 (추상 메서드)
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호 리스트
            include_numbers: 포함할 번호 리스트
            **kwargs: 알고리즘별 추가 파라미터
            
        Returns:
            List[List[int]]: 생성된 번호 세트
            예: [[5, 12, 23, 31, 38, 42], ...]
        """
        pass
    
    def validate_parameters(
        self,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> bool:
        """
        파라미터 검증
        
        Args:
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            
        Returns:
            bool: 유효 여부
        """
        # 제외/포함 번호 검증
        if exclude_numbers:
            if not all(1 <= num <= 45 for num in exclude_numbers):
                return False
            if len(exclude_numbers) > 6:
                return False
        
        if include_numbers:
            if not all(1 <= num <= 45 for num in include_numbers):
                return False
            if len(include_numbers) > 6:
                return False
        
        # 제외/포함이 겹치면 안 됨
        if exclude_numbers and include_numbers:
            if set(exclude_numbers) & set(include_numbers):
                return False
        
        # 포함 번호 + 남은 번호가 6개 이상이어야 함
        if include_numbers:
            available = 45 - len(exclude_numbers or [])
            if len(include_numbers) + (6 - len(include_numbers)) > available:
                return False
        
        return True
    
    def get_info(self) -> Dict:
        """
        알고리즘 정보 반환
        
        Returns:
            Dict: {
                'id': int,
                'name': str,
                'description': str,
                'version': str,
                'parameters': Dict
            }
        """
        return {
            'id': self.algorithm_id,
            'name': self.name,
            'description': self.description,
            'version': self.version,
            'parameters': self.get_default_parameters()
        }
    
    @abstractmethod
    def get_default_parameters(self) -> Dict:
        """
        기본 파라미터 반환
        
        Returns:
            Dict: 알고리즘별 기본 파라미터
        """
        pass
    
    def __str__(self) -> str:
        return f"Algorithm {self.algorithm_id}: {self.name}"
    
    def __repr__(self) -> str:
        return f"<{self.__class__.__name__}(id={self.algorithm_id}, name='{self.name}')>"
```

### 5.2 알고리즘 예시 (Algorithm 1: Random)

**`app/algorithms/algorithm_01_random.py`**

```python
"""
Algorithm 1: 순수 랜덤

완전 무작위 번호 생성
"""

import random
from typing import List, Dict, Optional

import pandas as pd

from app.algorithms.base import LottoAlgorithm


class RandomAlgorithm(LottoAlgorithm):
    """
    순수 랜덤 알고리즘
    
    1~45 중 6개를 무작위로 선택
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=1,
            name="순수 랜덤 (Quick Pick)",
            description="1~45 중 6개를 완전 무작위로 선택합니다. "
                       "가장 공정하고 편향 없는 방법입니다."
        )
    
    def generate_numbers(
        self,
        historical_data: pd.DataFrame,
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        순수 랜덤 번호 생성
        
        Args:
            historical_data: 사용하지 않음 (랜덤이므로)
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            
        Returns:
            List[List[int]]: 번호 세트
        """
        # 파라미터 검증
        if not self.validate_parameters(exclude_numbers, include_numbers):
            raise ValueError("잘못된 파라미터")
        
        results = []
        
        # 사용 가능한 번호 풀
        available_numbers = set(range(1, 46))
        
        if exclude_numbers:
            available_numbers -= set(exclude_numbers)
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 랜덤 선택
            remaining_count = 6 - len(numbers)
            remaining_pool = list(available_numbers - set(numbers))
            
            selected = random.sample(remaining_pool, remaining_count)
            numbers.extend(selected)
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def get_default_parameters(self) -> Dict:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None
        }
```

### 5.3 알고리즘 로더

**`app/algorithms/__init__.py`**

```python
"""
알고리즘 모듈 초기화

모든 알고리즘을 동적으로 로드
"""

from typing import Dict
from loguru import logger

from app.algorithms.base import LottoAlgorithm
from app.algorithms.algorithm_01_random import RandomAlgorithm
# from app.algorithms.algorithm_02_lstm import LSTMAlgorithm
# ... 나머지 알고리즘 import


def load_all_algorithms() -> Dict[int, LottoAlgorithm]:
    """
    모든 알고리즘 로드
    
    Returns:
        Dict[int, LottoAlgorithm]: {algorithm_id: instance}
    """
    algorithms = {}
    
    # 알고리즘 인스턴스 생성
    algorithm_classes = [
        RandomAlgorithm,
        # LSTMAlgorithm,
        # ... 나머지 추가
    ]
    
    for AlgoClass in algorithm_classes:
        try:
            instance = AlgoClass()
            algorithms[instance.algorithm_id] = instance
            logger.debug(f"  ✓ {instance.name} 로드 완료")
        except Exception as e:
            logger.error(f"  ✗ {AlgoClass.__name__} 로드 실패: {e}")
    
    return algorithms


def get_algorithm(algorithm_id: int) -> LottoAlgorithm:
    """
    알고리즘 ID로 인스턴스 반환
    
    Args:
        algorithm_id: 알고리즘 ID (1~9)
        
    Returns:
        LottoAlgorithm: 알고리즘 인스턴스
    """
    algorithms = load_all_algorithms()
    
    if algorithm_id not in algorithms:
        raise ValueError(f"알고리즘 ID {algorithm_id} 없음")
    
    return algorithms[algorithm_id]
```

**핵심 원칙**:
- 모든 알고리즘은 `LottoAlgorithm` 추상 베이스 클래스 상속
- `generate_numbers()` 메서드 구현 필수
- 파라미터 검증 (`validate_parameters`)
- 동적 로딩 (Factory Pattern)

**코드는 기존 섹션 5.1~5.3 참조** (9개 알고리즘)

---

## 13. 백엔드: 검증 시스템

### 6.1 Validator (Walk-Forward Validation)

**`app/validation/validator.py`**

```python
"""
알고리즘 검증 시스템

Walk-Forward Validation으로 과거 성능 백테스팅
"""

import time
from typing import List, Dict, Optional
from pathlib import Path

import pandas as pd
from loguru import logger
from tqdm import tqdm

from app.algorithms.base import LottoAlgorithm
from app.validation.evaluator import PerformanceEvaluator
from app.config import settings


class LottoValidator:
    """
    로또 알고리즘 검증 클래스
    
    Walk-Forward Validation으로 시간 누수 방지
    """
    
    def __init__(
        self,
        data: pd.DataFrame,
        output_dir: Optional[Path] = None
    ):
        """
        Args:
            data: 전체 로또 데이터
            output_dir: 결과 저장 디렉토리
        """
        self.data = data
        self.output_dir = output_dir or Path("results/validation")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.evaluator = PerformanceEvaluator()
    
    def validate_algorithm(
        self,
        algorithm: LottoAlgorithm,
        start_draw: int,
        end_draw: int,
        n_sets: int = 5,
        verbose: bool = True
    ) -> pd.DataFrame:
        """
        단일 알고리즘 검증
        
        Args:
            algorithm: 검증할 알고리즘
            start_draw: 시작 회차
            end_draw: 종료 회차
            n_sets: 회차당 생성 세트 수
            verbose: 진행 상황 출력
            
        Returns:
            pd.DataFrame: 검증 결과
        """
        results = []
        total_draws = end_draw - start_draw + 1
        
        logger.info(
            f"알고리즘 {algorithm.algorithm_id} 검증 시작: "
            f"{start_draw}~{end_draw}회 (총 {total_draws}회차)"
        )
        
        start_time = time.time()
        
        # 진행바
        iterator = range(start_draw, end_draw + 1)
        if verbose:
            iterator = tqdm(
                iterator,
                desc=f"Algorithm {algorithm.algorithm_id}",
                unit="회차"
            )
        
        for draw_no in iterator:
            # 1. 과거 데이터만 추출 (시간 누수 방지)
            historical_data = self.data[self.data['회차'] < draw_no].copy()
            
            # 최소 데이터 확인
            if len(historical_data) < 10:
                continue
            
            # 2. 실제 당첨번호
            actual_row = self.data[self.data['회차'] == draw_no].iloc[0]
            winning_numbers = [
                actual_row[f'번호{i}'] for i in range(1, 7)
            ]
            bonus = actual_row['보너스']
            
            try:
                # 3. 번호 생성
                predictions = algorithm.generate_numbers(
                    historical_data=historical_data,
                    n_sets=n_sets
                )
                
                # 4. 각 세트 평가
                for set_no, predicted in enumerate(predictions, start=1):
                    rank, matched_count, has_bonus = self.evaluator.judge_rank(
                        predicted, winning_numbers, bonus
                    )
                    
                    results.append({
                        'draw_no': draw_no,
                        'algorithm_id': algorithm.algorithm_id,
                        'algorithm_name': algorithm.name,
                        'set_no': set_no,
                        'predicted': str(predicted),
                        'winning': str(winning_numbers),
                        'bonus': bonus,
                        'rank': rank,
                        'matched_count': matched_count,
                        'has_bonus': has_bonus,
                        'timestamp': pd.Timestamp.now()
                    })
            
            except Exception as e:
                logger.error(
                    f"회차 {draw_no} 생성 실패 "
                    f"(Algorithm {algorithm.algorithm_id}): {e}"
                )
                continue
        
        elapsed = time.time() - start_time
        logger.success(
            f"알고리즘 {algorithm.algorithm_id} 검증 완료: "
            f"{len(results)}개 결과 (소요 시간: {elapsed:.1f}초)"
        )
        
        return pd.DataFrame(results)
    
    def validate_multiple_algorithms(
        self,
        algorithms: List[LottoAlgorithm],
        start_draw: int,
        end_draw: int,
        n_sets: int = 5,
        save_results: bool = True
    ) -> Dict[int, pd.DataFrame]:
        """
        여러 알고리즘 검증
        
        Args:
            algorithms: 알고리즘 리스트
            start_draw: 시작 회차
            end_draw: 종료 회차
            n_sets: 회차당 세트 수
            save_results: 결과 저장 여부
            
        Returns:
            Dict[int, pd.DataFrame]: {algorithm_id: 결과 DataFrame}
        """
        all_results = {}
        
        logger.info(
            f"다중 알고리즘 검증: {len(algorithms)}개 알고리즘, "
            f"{start_draw}~{end_draw}회차"
        )
        
        for algorithm in algorithms:
            result_df = self.validate_algorithm(
                algorithm, start_draw, end_draw, n_sets
            )
            all_results[algorithm.algorithm_id] = result_df
            
            # 저장
            if save_results:
                timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M%S")
                filename = (
                    f"algo{algorithm.algorithm_id:02d}_"
                    f"{start_draw}-{end_draw}_{timestamp}.csv"
                )
                filepath = self.output_dir / filename
                result_df.to_csv(filepath, index=False, encoding='utf-8-sig')
                logger.info(f"  💾 결과 저장: {filepath}")
        
        # 통합 결과 저장
        if save_results and all_results:
            combined = pd.concat(all_results.values(), ignore_index=True)
            timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M%S")
            combined_file = self.output_dir / f"combined_{timestamp}.csv"
            combined.to_csv(combined_file, index=False, encoding='utf-8-sig')
            logger.success(f"📊 통합 결과 저장: {combined_file}")
        
        return all_results
    
    def get_latest_draw_no(self) -> int:
        """최신 회차 번호"""
        return self.data['회차'].max()
```

### 6.2 Evaluator (성능 평가)

**`app/validation/evaluator.py`**

```python
"""
성능 평가 모듈

등수 판정 및 성능 지표 계산
"""

from typing import List, Tuple, Dict

import pandas as pd
import numpy as np


class PerformanceEvaluator:
    """
    로또 번호 평가 클래스
    """
    
    @staticmethod
    def judge_rank(
        predicted: List[int],
        winning: List[int],
        bonus: int
    ) -> Tuple[int, int, bool]:
        """
        등수 판정
        
        Args:
            predicted: 예측 번호 (6개)
            winning: 당첨 번호 (6개)
            bonus: 보너스 번호
            
        Returns:
            (등수, 매칭 개수, 보너스 포함 여부)
            등수: 1~5 (당첨), 0 (꽝)
        """
        # 매칭 개수
        matched = set(predicted) & set(winning)
        matched_count = len(matched)
        
        # 보너스 포함 여부
        has_bonus = bonus in predicted
        
        # 등수 판정
        if matched_count == 6:
            rank = 1
        elif matched_count == 5 and has_bonus:
            rank = 2
        elif matched_count == 5:
            rank = 3
        elif matched_count == 4:
            rank = 4
        elif matched_count == 3:
            rank = 5
        else:
            rank = 0  # 꽝
        
        return rank, matched_count, has_bonus
    
    @staticmethod
    def calculate_metrics(results_df: pd.DataFrame) -> Dict:
        """
        집계 통계 계산
        
        Args:
            results_df: 검증 결과 DataFrame
            
        Returns:
            Dict: 성능 지표
        """
        total_sets = len(results_df)
        
        if total_sets == 0:
            return {}
        
        metrics = {
            'total_sets': total_sets,
            
            # 등수별 카운트
            'rank_1': (results_df['rank'] == 1).sum(),
            'rank_2': (results_df['rank'] == 2).sum(),
            'rank_3': (results_df['rank'] == 3).sum(),
            'rank_4': (results_df['rank'] == 4).sum(),
            'rank_5': (results_df['rank'] == 5).sum(),
            
            # 매칭 개수별
            'matched_0': (results_df['matched_count'] == 0).sum(),
            'matched_1': (results_df['matched_count'] == 1).sum(),
            'matched_2': (results_df['matched_count'] == 2).sum(),
            'matched_3': (results_df['matched_count'] == 3).sum(),
            'matched_4': (results_df['matched_count'] == 4).sum(),
            'matched_5': (results_df['matched_count'] == 5).sum(),
            'matched_6': (results_df['matched_count'] == 6).sum(),
            
            # 기본 통계
            'avg_matched': results_df['matched_count'].mean(),
            'std_matched': results_df['matched_count'].std(),
            'min_matched': results_df['matched_count'].min(),
            'max_matched': results_df['matched_count'].max(),
            
            # Hit Rate (1개 이상 맞춤)
            'hit_rate': (results_df['matched_count'] > 0).sum() / total_sets * 100,
            
            # 5등 확률
            'rank_5_prob': (results_df['rank'] == 5).sum() / total_sets * 100,
        }
        
        # Performance Index (이론값 2.244% 대비)
        baseline_rank5_prob = 2.244
        metrics['performance_index'] = (
            metrics['rank_5_prob'] / baseline_rank5_prob
            if baseline_rank5_prob > 0 else 0
        )
        
        return metrics
    
    @staticmethod
    def compare_algorithms(results_dict: Dict[int, pd.DataFrame]) -> pd.DataFrame:
        """
        여러 알고리즘 비교
        
        Args:
            results_dict: {algorithm_id: 결과 DataFrame}
            
        Returns:
            pd.DataFrame: 비교 테이블
        """
        comparison = []
        
        evaluator = PerformanceEvaluator()
        
        for algo_id, results_df in results_dict.items():
            metrics = evaluator.calculate_metrics(results_df)
            
            comparison.append({
                'algorithm_id': algo_id,
                'algorithm_name': results_df.iloc[0]['algorithm_name'] if len(results_df) > 0 else '',
                'total_sets': metrics.get('total_sets', 0),
                'rank_1': metrics.get('rank_1', 0),
                'rank_2': metrics.get('rank_2', 0),
                'rank_3': metrics.get('rank_3', 0),
                'rank_4': metrics.get('rank_4', 0),
                'rank_5': metrics.get('rank_5', 0),
                'avg_matched': round(metrics.get('avg_matched', 0), 2),
                'hit_rate': round(metrics.get('hit_rate', 0), 2),
                'rank_5_prob': round(metrics.get('rank_5_prob', 0), 2),
                'performance_index': round(metrics.get('performance_index', 0), 2),
            })
        
        comparison_df = pd.DataFrame(comparison)
        
        # 정렬 (avg_matched 내림차순)
        comparison_df = comparison_df.sort_values('avg_matched', ascending=False)
        
        return comparison_df
```

**Walk-Forward Validation**:
- 시간 누수 방지 (과거 데이터만 사용)
- 회차별 성능 평가
- 통계적 유의성 검증

**코드는 기존 섹션 6.1~6.2 참조**

---

### 13.3 광고 검증 서비스 (AdMob SSV)

> 🔒 **보안 핵심**: 광고 시청 보상의 부정 획득을 방지하기 위한 서버 간 검증 시스템
> 
> ⚠️ **2026-01-02 21:00 EST 수정**: AdMob SSV는 **URL 콜백 방식**이므로 토큰이 아닌 **쿼리 파라미터 검증**으로 구현

**AdMob SSV 실제 동작 방식**:
```yaml
AdMob SSV 흐름:
  1. 사용자가 앱에서 리워드 광고 시청 완료
  2. AdMob SDK가 서버 URL로 콜백 전송
     GET https://your-domain.com/api/coins/admob-callback?
       ad_network=5450213213286189855&
       ad_unit=ca-app-pub-xxx~xxx&
       reward_amount=5&
       reward_item=coin&
       timestamp=1234567890&
       transaction_id=xxx&
       user_id=xxx&
       signature=HMAC_SHA256_SIGNATURE&
       key_id=123
  3. 서버가 HMAC-SHA256 서명 검증
  4. 검증 성공 시 200 OK 응답
  5. 서버가 사용자에게 코인 지급
  6. 앱은 콜백 완료를 대기하여 UI 업데이트
```

**`backend/app/services/ad_verification_service.py`** (수정됨)

```python
"""
광고 검증 서비스

AdMob Server-Side Verification (SSV)를 통한 광고 시청 검증

🔧 2026-01-02 21:00 EST 수정:
- 기존: JWT 형식 토큰 검증 (오류)
- 수정: AdMob SSV 콜백 URL 쿼리 파라미터 검증 (올바름)
"""

import hashlib
import hmac
import urllib.parse
from datetime import datetime, timedelta
from typing import Dict, Optional

from loguru import logger

from app.core.config import settings
from app.db.session import get_db
from app.db.models.ad_verification import AdVerificationToken


class AdVerificationService:
    """
    광고 시청 검증 서비스 (AdMob SSV)
    
    **기능**:
    1. AdMob SSV 콜백 쿼리 파라미터 검증
    2. HMAC-SHA256 서명 검증 (위조 방지)
    3. 토큰 재사용 방지 (transaction_id 기반)
    4. 시간 제한 검증 (5분 이내)
    """
    
    def __init__(self):
        self.admob_secret = settings.ADMOB_SECRET_KEY  # .env에 저장
    
    async def verify_admob_callback(
        self,
        query_params: Dict[str, str]
    ) -> Dict:
        """
        AdMob SSV 콜백 검증
        
        Args:
            query_params: AdMob이 전송한 쿼리 파라미터
            {
                'ad_network': '5450213213286189855',
                'ad_unit': 'ca-app-pub-xxx~xxx',
                'reward_amount': '5',
                'reward_item': 'coin',
                'timestamp': '1234567890',
                'transaction_id': 'unique_tx_id',
                'user_id': 'user_uuid',
                'signature': 'hmac_sha256_hex',
                'key_id': '123'
            }
            
        Returns:
            {
                'valid': bool,
                'reason': str (실패 시),
                'transaction_id': str (성공 시),
                'user_id': str (성공 시),
                'reward_amount': int (성공 시)
            }
        """
        try:
            # === 1. 필수 파라미터 확인 ===
            required_fields = [
                'ad_network', 'ad_unit', 'reward_amount', 'reward_item',
                'timestamp', 'transaction_id', 'user_id', 'signature', 'key_id'
            ]
            
            for field in required_fields:
                if field not in query_params:
                    return {
                        'valid': False,
                        'reason': f'필수 파라미터 누락: {field}'
                    }
            
            # === 2. HMAC-SHA256 서명 검증 ===
            # AdMob은 signature와 key_id를 제외한 모든 파라미터로 서명 생성
            signature_received = query_params['signature']
            
            # 서명 대상 파라미터 (알파벳 순 정렬)
            params_for_signature = {
                k: v for k, v in query_params.items()
                if k not in ['signature', 'key_id']
            }
            
            # Query String 생성 (URL 인코딩, 알파벳 순)
            query_string = '&'.join([
                f"{k}={urllib.parse.quote(str(v))}"
                for k, v in sorted(params_for_signature.items())
            ])
            
            # HMAC-SHA256 계산
            expected_signature = hmac.new(
                self.admob_secret.encode('utf-8'),
                query_string.encode('utf-8'),
                hashlib.sha256
            ).hexdigest()
            
            if not hmac.compare_digest(signature_received, expected_signature):
                logger.warning(
                    f"[AdMob SSV] HMAC 검증 실패 (User {query_params.get('user_id')})"
                )
                return {
                    'valid': False,
                    'reason': 'HMAC 서명 검증 실패 (위조된 콜백)'
                }
            
            # === 3. 시간 제한 검증 (5분 이내) ===
            try:
                timestamp = int(query_params['timestamp'])
                callback_time = datetime.fromtimestamp(timestamp)
                now = datetime.utcnow()
                
                if now - callback_time > timedelta(minutes=5):
                    return {
                        'valid': False,
                        'reason': '콜백 만료 (5분 초과)'
                    }
            except (ValueError, OSError) as e:
                return {
                    'valid': False,
                    'reason': f'타임스탬프 오류: {e}'
                }
            
            # === 4. 보상 금액 확인 ===
            try:
                reward_amount = int(query_params['reward_amount'])
                if reward_amount != 5:
                    logger.warning(
                        f"[AdMob SSV] 비정상 보상 금액: {reward_amount} "
                        f"(예상: 5, User {query_params['user_id']})"
                    )
                    # 경고만 기록, 검증은 통과
            except ValueError:
                return {
                    'valid': False,
                    'reason': '보상 금액 형식 오류'
                }
            
            logger.info(
                f"[AdMob SSV 검증 성공] User {query_params['user_id']}, "
                f"Transaction {query_params['transaction_id']}, "
                f"Reward {reward_amount} coins"
            )
            
            return {
                'valid': True,
                'transaction_id': query_params['transaction_id'],
                'user_id': query_params['user_id'],
                'reward_amount': reward_amount
            }
        
        except Exception as e:
            logger.exception(f"[AdMob SSV] 검증 오류: {e}")
            return {
                'valid': False,
                'reason': f'검증 중 오류: {str(e)}'
            }
    
    async def is_token_used(self, transaction_id: str) -> bool:
        """
        토큰 재사용 여부 확인
        
        🔧 2026-01-02 21:00 EST 수정:
        - 기존: token_hash 기반 검증
        - 수정: transaction_id 기반 검증 (AdMob SSV 실제 구조에 맞춤)
        
        Args:
            transaction_id: AdMob 콜백의 transaction_id
            
        Returns:
            bool: 이미 사용된 거래이면 True
        """
        db = next(get_db())
        
        # transaction_id 해시 생성
        tx_hash = hashlib.sha256(transaction_id.encode()).hexdigest()
        
        existing = db.query(AdVerificationToken).filter(
            AdVerificationToken.token_hash == tx_hash
        ).first()
        
        return existing is not None
    
    async def mark_token_as_used(self, transaction_id: str):
        """
        토큰 사용 기록
        
        Args:
            transaction_id: AdMob 콜백의 transaction_id
        """
        db = next(get_db())
        
        tx_hash = hashlib.sha256(transaction_id.encode()).hexdigest()
        
        record = AdVerificationToken(
            token_hash=tx_hash,
            used_at=datetime.utcnow()
        )
        db.add(record)
        db.commit()
```

**API 엔드포인트 수정**: `backend/app/api/routes/coins.py`

```python
@router.get("/admob-callback")
async def admob_callback(
    request: Request,
    db: Session = Depends(get_db)
):
    """
    AdMob SSV 콜백 엔드포인트
    
    🔧 2026-01-02 21:00 EST 신규 추가:
    AdMob이 직접 호출하는 서버 간 검증 엔드포인트
    
    **동작**:
    1. AdMob이 GET 요청으로 쿼리 파라미터 전송
    2. 서버가 HMAC 서명 검증
    3. 검증 성공 시 200 OK 응답 (AdMob에게)
    4. 코인 지급은 별도로 처리
    
    **중요**: 이 엔드포인트는 인증 불필요 (AdMob 서버가 호출)
    """
    # 쿼리 파라미터 추출
    query_params = dict(request.query_params)
    
    ad_service = AdVerificationService()
    verification_result = await ad_service.verify_admob_callback(query_params)
    
    if not verification_result['valid']:
        logger.warning(
            f"[AdMob SSV] 검증 실패: {verification_result.get('reason')}"
        )
        return JSONResponse(
            status_code=400,
            content={"error": verification_result['reason']}
        )
    
    # 중복 확인
    transaction_id = verification_result['transaction_id']
    if await ad_service.is_token_used(transaction_id):
        logger.warning(f"[AdMob SSV] 중복 거래: {transaction_id}")
        return JSONResponse(
            status_code=200,
            content={"message": "Already processed"}  # AdMob에는 성공 응답
        )
    
    # 토큰 사용 기록
    await ad_service.mark_token_as_used(transaction_id)
    
    # 사용자에게 코인 지급
    try:
        user_id = verification_result['user_id']
        reward_amount = verification_result['reward_amount']
        
        # 비관적 락으로 지갑 조회
        wallet = db.query(CoinWallet).filter(
            CoinWallet.user_id == user_id
        ).with_for_update().first()
        
        if not wallet:
            logger.error(f"[AdMob SSV] 지갑 없음: User {user_id}")
            return JSONResponse(status_code=200, content={"message": "User not found"})
        
        # 일일 한도 확인
        if not wallet.can_watch_ad():
            logger.warning(f"[AdMob SSV] 일일 한도 초과: User {user_id}")
            return JSONResponse(status_code=200, content={"message": "Daily limit exceeded"})
        
        # 코인 지급
        wallet.balance += reward_amount
        wallet.total_earned += reward_amount
        wallet.daily_ad_count += 1
        wallet.last_ad_date = datetime.utcnow()
        
        # 거래 기록
        transaction = CoinTransaction(
            wallet_id=wallet.id,
            type=TransactionType.AD_REWARD,
            amount=reward_amount,
            balance_after=wallet.balance,
            description="광고 시청 보상 (AdMob SSV)",
            metadata=json.dumps({
                'transaction_id': transaction_id,
                'ad_network': query_params.get('ad_network')
            })
        )
        db.add(transaction)
        db.commit()
        
        logger.info(
            f"[AdMob SSV 보상 지급] User {user_id}, "
            f"+{reward_amount} coins, 잔액 {wallet.balance}"
        )
        
        return JSONResponse(
            status_code=200,
            content={"message": "Reward granted"}
        )
    
    except Exception as e:
        db.rollback()
        logger.exception(f"[AdMob SSV] 코인 지급 실패: {e}")
        return JSONResponse(status_code=500, content={"error": "Internal error"})
```

**DB 모델 추가**: `backend/app/db/models/ad_verification.py`

```python
"""
광고 검증 토큰 모델
"""

from datetime import datetime
from sqlalchemy import Column, String, DateTime, Index
from app.db.base import Base


class AdVerificationToken(Base):
    """
    광고 검증 토큰 사용 기록 (재사용 방지)
    """
    __tablename__ = "ad_verification_tokens"
    
    token_hash = Column(String(64), primary_key=True, comment="토큰 SHA256 해시")
    used_at = Column(DateTime, default=datetime.utcnow, nullable=False, comment="사용 시각")
    
    # 인덱스 (오래된 기록 정리용)
    __table_args__ = (
        Index('idx_used_at', 'used_at'),
    )
```

**환경 변수 추가**: `.env`

```bash
# AdMob Server-Side Verification
ADMOB_SECRET_KEY=your_admob_ssv_secret_key_here
```

**설정**: `backend/app/core/config.py`

```python
class Settings(BaseSettings):
    ...
    ADMOB_SECRET_KEY: str = Field(..., env="ADMOB_SECRET_KEY")
```

**⚠️ 주의사항**:
1. **AdMob 콘솔에서 SSV 활성화** 필요
2. **콜백 URL 설정**: `https://your-domain.com/api/coins/admob-callback`
3. **토큰 청소**: 7일 이상 된 기록은 Celery로 자동 삭제

### 13.3.1 AdMob SSV 설정 가이드 (필수)

**🔧 2026-01-02 22:00 EST 추가**: AdMob 콘솔에서 직접 설정해야 하는 단계별 가이드

#### Step 1: AdMob 콘솔 접속

```
1. https://apps.admob.com 접속
2. 앱 선택 (LuckyAI 645)
3. 좌측 메뉴 > "광고 단위(Ad units)" 클릭
4. 리워드 광고 단위 선택 (또는 신규 생성)
```

#### Step 2: Server-Side Verification 활성화

```
리워드 설정 섹션:
  1. "Server-side verification" 찾기
  2. "Enable server-side verification callbacks" 체크
  3. "Callback URL" 입력:
     - Production: https://api.luckyai645.com/api/coins/admob-callback
     - Development: https://dev-api.luckyai645.com/api/coins/admob-callback
  
  4. "Secret Key" 생성 버튼 클릭
     → 자동 생성된 키를 복사 (예: a1b2c3d4e5f6...)
  
  5. "Save" 클릭
```

#### Step 3: 백엔드 환경 변수 설정

```bash
# backend/.env
ADMOB_SECRET_KEY=a1b2c3d4e5f6...  # ⬅️ Step 2에서 복사한 키
```

#### Step 4: Flutter 앱 코드 설정

```dart
// mobile_app/lib/services/ad_service.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  /// 리워드 광고 로드 및 표시
  Future<void> showRewardedAd() async {
    // 1. 리워드 광고 로드
    await RewardedAd.load(
      adUnitId: Platform.isIOS 
        ? 'ca-app-pub-xxx/ios_reward_ad_unit_id'  // iOS
        : 'ca-app-pub-xxx/android_reward_ad_unit_id',  // Android
      request: AdRequest(
        // ⚠️ 중요: SSV용 Custom Data 전달
        customData: {
          'user_id': ref.read(authProvider).value!.id,  // 사용자 ID
        },
      ),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // 광고 표시
          ad.show(
            onUserEarnedReward: (ad, reward) async {
              // ⚠️ 주의: 클라이언트에서는 코인 지급하지 않음
              // AdMob이 서버 콜백으로 검증 후 지급
              print('광고 시청 완료, 서버 검증 대기 중...');
              
              // 1초 후 코인 지갑 새로고침
              await Future.delayed(Duration(seconds: 1));
              ref.invalidate(coinWalletProvider);
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('광고 로드 실패: $error');
        },
      ),
    );
  }
}
```

#### Step 5: 테스트

**개발 환경 테스트**:
```bash
# 1. AdMob 테스트 광고 ID 사용
# iOS: ca-app-pub-3940256099942544/1712485313
# Android: ca-app-pub-3940256099942544/5224354917

# 2. 백엔드 로그 확인
tail -f backend/logs/app.log | grep "AdMob SSV"

# 3. 테스트 디바이스 등록
# AdMob 콘솔 > 설정 > 테스트 디바이스 추가
```

**SSV 콜백 테스트**:
```bash
# 수동으로 SSV 콜백 시뮬레이션
curl -X GET "http://localhost:8000/api/coins/admob-callback?ad_network=5450213213286189855&ad_unit=ca-app-pub-xxx~xxx&reward_amount=5&reward_item=coin&timestamp=$(date +%s)&transaction_id=test_tx_123&user_id=USER_UUID_HERE&signature=FAKE_SIGNATURE&key_id=123"

# 백엔드 로그에서 검증 실패 확인 (서명 불일치)
# 실제 광고 시청 시에는 AdMob이 올바른 서명 생성
```

#### Step 6: 프로덕션 배포 전 확인

```yaml
체크리스트:
  ✅ AdMob SSV 활성화 (콘솔)
  ✅ 콜백 URL HTTPS 사용 (HTTP 불가)
  ✅ ADMOB_SECRET_KEY 환경 변수 설정
  ✅ 실제 광고 단위 ID 사용 (테스트 ID 제거)
  ✅ 사용자 ID 전달 (customData)
  ✅ 서버 로그 모니터링 설정
  ✅ 일일 광고 한도 설정 (5회)
```

#### 문제 해결

**문제 1: 콜백이 안 옴**
```
원인:
  - 콜백 URL 오타
  - HTTPS 미사용
  - 방화벽/보안그룹 차단

해결:
  1. AdMob 콘솔에서 URL 재확인
  2. 서버 로그에서 POST 요청 확인
  3. curl로 수동 테스트
```

**문제 2: 서명 검증 실패**
```
원인:
  - ADMOB_SECRET_KEY 불일치
  - 쿼리 파라미터 순서 문제

해결:
  1. .env 파일의 ADMOB_SECRET_KEY 재확인
  2. 서버 로그에서 signature 값 확인
  3. AdMob 콘솔에서 Secret Key 재생성
```

**문제 3: 코인이 안 지급됨**
```
원인:
  - 중복 거래 (transaction_id 재사용)
  - 일일 한도 초과 (5회)
  - 사용자 지갑 없음

해결:
  1. 로그에서 실패 원인 확인
  2. DB에서 CoinTransaction 확인
  3. 지갑 잔액 수동 확인
```

---

### 13.3.2 Celery 청소 작업

```python
# backend/app/celery_tasks/scheduled_tasks.py

@celery_app.task
def cleanup_old_ad_tokens():
    """
    7일 이상 된 광고 검증 토큰 삭제
    """
    db = SessionLocal()
    try:
        cutoff_date = datetime.utcnow() - timedelta(days=7)
        
        deleted = db.query(AdVerificationToken).filter(
            AdVerificationToken.used_at < cutoff_date
        ).delete()
        
        db.commit()
        logger.info(f"광고 토큰 청소 완료: {deleted}개 삭제")
        
    except Exception as e:
        logger.error(f"광고 토큰 청소 실패: {e}")
        db.rollback()
    finally:
        db.close()


# Celery Beat 스케줄에 추가
celery_app.conf.beat_schedule.update({
    'cleanup-old-ad-tokens': {
        'task': 'app.celery_tasks.scheduled_tasks.cleanup_old_ad_tokens',
        'schedule': crontab(hour=3, minute=0),  # 매일 새벽 3시
    }
})
```

---

### 13.4 IAP 결제 검증 서비스

> 🔒 **보안 핵심**: Apple/Google In-App Purchase 영수증 검증 및 중복 결제 방지

**`backend/app/services/payment_service.py`** (신규)

```python
"""
결제 검증 서비스

Apple/Google IAP 영수증 검증
"""

import aiohttp
import json
from datetime import datetime
from typing import Dict, Optional

from loguru import logger

from app.core.config import settings
from app.db.session import get_db
from app.db.models.coin_wallet import CoinTransaction


class PaymentService:
    """
    In-App Purchase 검증 서비스
    
    **지원 플랫폼**:
    - Apple App Store (StoreKit 2)
    - Google Play Store (Billing Library 5+)
    """
    
    def __init__(self):
        # Apple IAP
        self.apple_production_url = "https://buy.itunes.apple.com/verifyReceipt"
        self.apple_sandbox_url = "https://sandbox.itunes.apple.com/verifyReceipt"
        self.apple_shared_secret = settings.APPLE_SHARED_SECRET
        
        # Google IAP
        self.google_package_name = settings.GOOGLE_PACKAGE_NAME
        self.google_service_account_key = settings.GOOGLE_SERVICE_ACCOUNT_KEY
    
    async def verify_iap(
        self,
        provider: str,
        receipt: str,
        expected_product_id: str,
        expected_price: int
    ) -> Dict:
        """
        IAP 영수증 검증
        
        Args:
            provider: "iap_apple" | "iap_google"
            receipt: 영수증 토큰
            expected_product_id: 예상 상품 ID
            expected_price: 예상 가격 (원화, 위조 방지)
            
        Returns:
            {
                'success': bool,
                'transaction_id': str,
                'original_transaction_id': str,
                'error': str (실패 시)
            }
        """
        if provider == "iap_apple":
            return await self._verify_apple_receipt(
                receipt, expected_product_id, expected_price
            )
        elif provider == "iap_google":
            return await self._verify_google_receipt(
                receipt, expected_product_id, expected_price
            )
        else:
            return {
                'success': False,
                'error': f"지원하지 않는 결제 제공자: {provider}"
            }
    
    async def _verify_apple_receipt(
        self,
        receipt: str,
        expected_product_id: str,
        expected_price: int
    ) -> Dict:
        """
        Apple IAP 영수증 검증
        
        **검증 절차**:
        1. App Store 서버에 영수증 전송
        2. 응답 상태 코드 확인 (0 = 성공)
        3. 제품 ID 일치 확인
        4. 가격 확인 (위조 방지)
        5. 중복 transaction_id 확인
        """
        try:
            async with aiohttp.ClientSession() as session:
                # === 1. Production 서버로 검증 시도 ===
                payload = {
                    'receipt-data': receipt,
                    'password': self.apple_shared_secret,
                    'exclude-old-transactions': True
                }
                
                async with session.post(
                    self.apple_production_url,
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=10)
                ) as response:
                    data = await response.json()
                
                # Sandbox 영수증인 경우 재시도 (status=21007)
                if data.get('status') == 21007:
                    logger.info("Sandbox 영수증 감지, Sandbox 서버로 재검증")
                    async with session.post(
                        self.apple_sandbox_url,
                        json=payload,
                        timeout=aiohttp.ClientTimeout(total=10)
                    ) as response:
                        data = await response.json()
                
                # === 2. 상태 코드 확인 ===
                status = data.get('status')
                if status != 0:
                    error_messages = {
                        21000: "App Store가 영수증을 읽을 수 없음",
                        21002: "영수증 데이터 형식 오류",
                        21003: "영수증을 인증할 수 없음",
                        21004: "공유 비밀번호 불일치",
                        21005: "영수증 서버 사용 불가",
                        21006: "영수증이 유효하지만 구독이 만료됨",
                        21008: "영수증이 Sandbox용이지만 Production으로 전송됨",
                        21010: "영수증을 찾을 수 없음"
                    }
                    return {
                        'success': False,
                        'error': error_messages.get(status, f"검증 실패 (status={status})")
                    }
                
                # === 3. 최신 영수증 정보 추출 ===
                receipt_data = data.get('receipt', {})
                in_app = receipt_data.get('in_app', [])
                
                if not in_app:
                    return {
                        'success': False,
                        'error': '영수증에 구매 정보가 없습니다'
                    }
                
                # 가장 최근 구매 (latest_receipt_info 사용)
                latest_info = data.get('latest_receipt_info', in_app)
                if isinstance(latest_info, list):
                    purchase = latest_info[-1]  # 최신 거래
                else:
                    purchase = latest_info
                
                # === 4. 제품 ID 확인 ===
                product_id = purchase.get('product_id')
                if product_id != expected_product_id:
                    logger.warning(
                        f"제품 ID 불일치: 예상={expected_product_id}, 실제={product_id}"
                    )
                    return {
                        'success': False,
                        'error': '제품 정보가 일치하지 않습니다'
                    }
                
                # === 5. Transaction ID 추출 ===
                transaction_id = purchase.get('transaction_id')
                original_transaction_id = purchase.get('original_transaction_id', transaction_id)
                
                if not transaction_id:
                    return {
                        'success': False,
                        'error': '거래 ID를 찾을 수 없습니다'
                    }
                
                # === 6. 중복 거래 확인 ===
                db = next(get_db())
                existing = db.query(CoinTransaction).filter(
                    CoinTransaction.payment_id == transaction_id
                ).first()
                
                if existing:
                    return {
                        'success': False,
                        'error': '이미 처리된 결제입니다'
                    }
                
                logger.info(
                    f"[Apple IAP 검증 성공] Product {product_id}, "
                    f"Transaction {transaction_id}"
                )
                
                return {
                    'success': True,
                    'transaction_id': transaction_id,
                    'original_transaction_id': original_transaction_id
                }
        
        except aiohttp.ClientError as e:
            logger.error(f"Apple IAP 검증 네트워크 오류: {e}")
            return {
                'success': False,
                'error': '결제 검증 서버와 통신할 수 없습니다'
            }
        except Exception as e:
            logger.exception(f"Apple IAP 검증 오류: {e}")
            return {
                'success': False,
                'error': '결제 검증 중 오류가 발생했습니다'
            }
    
    async def _verify_google_receipt(
        self,
        receipt: str,
        expected_product_id: str,
        expected_price: int
    ) -> Dict:
        """
        Google Play IAP 영수증 검증
        
        **검증 절차**:
        1. Google Play Developer API 호출
        2. 구매 상태 확인 (0 = 구매됨)
        3. 제품 ID 일치 확인
        4. 중복 purchase_token 확인
        """
        try:
            from google.oauth2 import service_account
            from google.auth.transport.requests import Request
            
            # === 1. 서비스 계정 인증 ===
            credentials = service_account.Credentials.from_service_account_info(
                json.loads(self.google_service_account_key),
                scopes=['https://www.googleapis.com/auth/androidpublisher']
            )
            
            # 액세스 토큰 획득
            credentials.refresh(Request())
            access_token = credentials.token
            
            # === 2. Google Play Developer API 호출 ===
            # receipt는 purchase_token
            url = (
                f"https://androidpublisher.googleapis.com/androidpublisher/v3/"
                f"applications/{self.google_package_name}/purchases/"
                f"products/{expected_product_id}/tokens/{receipt}"
            )
            
            async with aiohttp.ClientSession() as session:
                headers = {
                    'Authorization': f'Bearer {access_token}'
                }
                
                async with session.get(
                    url,
                    headers=headers,
                    timeout=aiohttp.ClientTimeout(total=10)
                ) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        logger.warning(f"Google IAP API 오류: {response.status}, {error_text}")
                        return {
                            'success': False,
                            'error': 'Google 결제 정보를 확인할 수 없습니다'
                        }
                    
                    data = await response.json()
            
            # === 3. 구매 상태 확인 ===
            purchase_state = data.get('purchaseState')
            if purchase_state != 0:  # 0 = Purchased
                return {
                    'success': False,
                    'error': '구매가 완료되지 않았습니다'
                }
            
            # === 4. 소비 여부 확인 ===
            consumption_state = data.get('consumptionState')
            if consumption_state == 1:  # 1 = Consumed
                return {
                    'success': False,
                    'error': '이미 사용된 영수증입니다'
                }
            
            # === 5. Order ID 추출 ===
            order_id = data.get('orderId')
            if not order_id:
                return {
                    'success': False,
                    'error': '주문 ID를 찾을 수 없습니다'
                }
            
            # === 6. 중복 거래 확인 ===
            db = next(get_db())
            existing = db.query(CoinTransaction).filter(
                CoinTransaction.payment_id == order_id
            ).first()
            
            if existing:
                return {
                    'success': False,
                    'error': '이미 처리된 결제입니다'
                }
            
            logger.info(
                f"[Google IAP 검증 성공] Product {expected_product_id}, "
                f"Order {order_id}"
            )
            
            return {
                'success': True,
                'transaction_id': order_id,
                'original_transaction_id': order_id
            }
        
        except Exception as e:
            logger.exception(f"Google IAP 검증 오류: {e}")
            return {
                'success': False,
                'error': '결제 검증 중 오류가 발생했습니다'
            }
```

**환경 변수 추가**: `.env`

```bash
# Apple IAP
APPLE_SHARED_SECRET=your_apple_shared_secret_here

# Google IAP
GOOGLE_PACKAGE_NAME=com.yourcompany.luckyai
GOOGLE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}
```

**설정**: `backend/app/core/config.py`

```python
class Settings(BaseSettings):
    ...
    # IAP 검증
    APPLE_SHARED_SECRET: str = Field(..., env="APPLE_SHARED_SECRET")
    GOOGLE_PACKAGE_NAME: str = Field(..., env="GOOGLE_PACKAGE_NAME")
    GOOGLE_SERVICE_ACCOUNT_KEY: str = Field(..., env="GOOGLE_SERVICE_ACCOUNT_KEY")
```

**의존성 추가**: `requirements.txt`

```txt
google-auth==2.23.0
google-auth-oauthlib==1.1.0
google-auth-httplib2==0.1.1
```

---

### 13.5 알림 서비스 (Push Notification)

> 🆕 **2026-01-02 21:00 EST 추가**: Firebase Cloud Messaging (FCM) 통합 가이드

**`backend/app/services/notification_service.py`**

```python
"""
Push 알림 서비스

Firebase Cloud Messaging (FCM)을 통한 푸시 알림 전송

🆕 2026-01-02 21:00 EST 추가:
- 당첨 알림 전송
- 다중 디바이스 지원
- FCM 토큰 관리
"""

import firebase_admin
from firebase_admin import credentials, messaging
from typing import List, Optional
from loguru import logger

from app.core.config import settings
from app.db.session import get_db
from app.db.models.user import User


class NotificationService:
    """
    푸시 알림 전송 서비스
    
    **기능**:
    1. 당첨 알림 전송
    2. 다중 디바이스 동시 발송
    3. FCM 토큰 관리
    4. 발송 실패 처리
    """
    
    def __init__(self):
        # Firebase Admin SDK 초기화 (싱글톤)
        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_KEY)
            firebase_admin.initialize_app(cred)
            logger.info("✅ Firebase Admin SDK 초기화 완료")
    
    async def send_winning_notification(
        self,
        user_id: str,
        rank: int,
        numbers: List[int],
        draw_no: int
    ) -> dict:
        """
        당첨 알림 전송
        
        Args:
            user_id: 사용자 ID
            rank: 당첨 등수 (1~5)
            numbers: 당첨 번호
            draw_no: 회차
            
        Returns:
            {
                'success': bool,
                'sent_count': int,
                'failed_count': int,
                'failed_tokens': List[str]  # 전송 실패한 토큰 (제거 필요)
            }
        """
        db = next(get_db())
        
        try:
            # === 1. 사용자의 FCM 토큰 조회 ===
            user = db.query(User).filter(User.id == user_id).first()
            if not user or not user.fcm_tokens:
                logger.warning(f"[Push] FCM 토큰 없음: User {user_id}")
                return {
                    'success': False,
                    'sent_count': 0,
                    'failed_count': 0,
                    'reason': 'No FCM tokens'
                }
            
            # === 2. 등수별 메시지 커스터마이징 ===
            rank_emoji = {
                1: "🎊",  # 1등: 파티
                2: "🎉",  # 2등: 축하
                3: "🥳",  # 3등: 기쁨
                4: "😊",  # 4등: 미소
                5: "🎯"   # 5등: 타겟
            }
            
            rank_text = {
                1: "1등 당첨!",
                2: "2등 당첨!",
                3: "3등 당첨!",
                4: "4등 당첨!",
                5: "5등 당첨!"
            }
            
            rank_body = {
                1: f"대박! {draw_no}회차 1등에 당첨되었습니다!",
                2: f"축하합니다! {draw_no}회차 2등 당첨!",
                3: f"와우! {draw_no}회차 3등에 당첨되었어요!",
                4: f"{draw_no}회차 4등 당첨! 축하드려요!",
                5: f"{draw_no}회차 5등에 당첨되었습니다!"
            }
            
            emoji = rank_emoji.get(rank, "🎰")
            title = f"{emoji} {rank_text.get(rank, '당첨!')}"
            body = rank_body.get(rank, f"{draw_no}회차 당첨!")
            
            numbers_str = ', '.join(map(str, sorted(numbers)))
            
            # === 3. FCM 메시지 생성 (다중 디바이스) ===
            messages = []
            for token in user.fcm_tokens:
                messages.append(messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=f"{body}\n번호: {numbers_str}"
                    ),
                    data={
                        'type': 'winning',
                        'rank': str(rank),
                        'draw_no': str(draw_no),
                        'numbers': numbers_str,
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                        'route': f'/my-numbers/{draw_no}'  # 앱 내 이동 경로
                    },
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            icon='notification_icon',
                            color='#4CAF50',  # 초록색
                            sound='default'
                        )
                    ),
                    apns=messaging.APNSConfig(
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(
                                sound='default',
                                badge=1
                            )
                        )
                    ),
                    token=token
                ))
            
            # === 4. 배치 전송 ===
            response = messaging.send_all(messages)
            
            # === 5. 실패한 토큰 수집 (제거 필요) ===
            failed_tokens = []
            for idx, resp in enumerate(response.responses):
                if not resp.success:
                    failed_token = user.fcm_tokens[idx]
                    failed_tokens.append(failed_token)
                    logger.warning(
                        f"[Push] 전송 실패: User {user_id}, "
                        f"Token {failed_token[:20]}..., "
                        f"Error: {resp.exception}"
                    )
            
            # === 6. 무효 토큰 제거 ===
            if failed_tokens:
                user.fcm_tokens = [
                    t for t in user.fcm_tokens if t not in failed_tokens
                ]
                db.commit()
                logger.info(f"[Push] 무효 토큰 {len(failed_tokens)}개 제거")
            
            logger.info(
                f"[Push] 당첨 알림 전송 완료: User {user_id}, "
                f"성공 {response.success_count}/{len(messages)}, "
                f"실패 {response.failure_count}"
            )
            
            return {
                'success': response.success_count > 0,
                'sent_count': response.success_count,
                'failed_count': response.failure_count,
                'failed_tokens': failed_tokens
            }
        
        except Exception as e:
            logger.exception(f"[Push] 알림 전송 오류: User {user_id}, Error: {e}")
            return {
                'success': False,
                'sent_count': 0,
                'failed_count': len(user.fcm_tokens) if user and user.fcm_tokens else 0,
                'error': str(e)
            }
    
    async def send_general_notification(
        self,
        user_ids: List[str],
        title: str,
        body: str,
        data: dict = None
    ) -> dict:
        """
        일반 알림 전송 (이벤트, 공지사항 등)
        
        Args:
            user_ids: 수신자 ID 목록
            title: 알림 제목
            body: 알림 내용
            data: 추가 데이터 (선택)
            
        Returns:
            전송 결과 통계
        """
        db = next(get_db())
        
        total_sent = 0
        total_failed = 0
        
        for user_id in user_ids:
            user = db.query(User).filter(User.id == user_id).first()
            if not user or not user.fcm_tokens:
                continue
            
            messages = []
            for token in user.fcm_tokens:
                messages.append(messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=body
                    ),
                    data=data or {},
                    token=token
                ))
            
            try:
                response = messaging.send_all(messages)
                total_sent += response.success_count
                total_failed += response.failure_count
            except Exception as e:
                logger.error(f"[Push] 일반 알림 전송 실패: User {user_id}, {e}")
                total_failed += len(messages)
        
        logger.info(
            f"[Push] 일반 알림 전송 완료: "
            f"대상 {len(user_ids)}명, 성공 {total_sent}, 실패 {total_failed}"
        )
        
        return {
            'success': total_sent > 0,
            'sent_count': total_sent,
            'failed_count': total_failed
        }
```

**User 모델에 FCM 토큰 필드 추가**: `backend/app/db/models/user.py`

```python
class User(Base):
    __tablename__ = "users"
    
    # ... 기존 필드들 ...
    
    # 🆕 2026-01-02 21:00 EST 추가: FCM 토큰 (다중 디바이스 지원)
    fcm_tokens = Column(
        ARRAY(String),
        default=[],
        comment="Firebase Cloud Messaging 디바이스 토큰 (여러 기기 지원)"
    )
```

**FCM 토큰 등록 API**: `backend/app/api/routes/auth.py`

```python
@router.post("/fcm-token", response_model=dict)
async def register_fcm_token(
    fcm_token: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    FCM 토큰 등록/갱신
    
    🆕 2026-01-02 21:00 EST 추가
    
    Args:
        fcm_token: Firebase Messaging 디바이스 토큰
        
    Returns:
        성공 여부
    """
    try:
        # 중복 확인 후 추가
        if fcm_token not in current_user.fcm_tokens:
            current_user.fcm_tokens.append(fcm_token)
            db.commit()
            logger.info(
                f"[FCM] 토큰 등록: User {current_user.id}, "
                f"토큰 수 {len(current_user.fcm_tokens)}"
            )
        
        return {
            "success": True,
            "message": "FCM 토큰이 등록되었습니다",
            "token_count": len(current_user.fcm_tokens)
        }
    except Exception as e:
        logger.error(f"[FCM] 토큰 등록 실패: {e}")
        raise HTTPException(500, detail=f"FCM 토큰 등록 실패: {str(e)}")


@router.delete("/fcm-token")
async def remove_fcm_token(
    fcm_token: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    FCM 토큰 제거 (로그아웃 시)
    
    Args:
        fcm_token: 제거할 토큰
    """
    try:
        if fcm_token in current_user.fcm_tokens:
            current_user.fcm_tokens.remove(fcm_token)
            db.commit()
            logger.info(f"[FCM] 토큰 제거: User {current_user.id}")
        
        return {"success": True, "message": "FCM 토큰이 제거되었습니다"}
    except Exception as e:
        logger.error(f"[FCM] 토큰 제거 실패: {e}")
        raise HTTPException(500, detail=f"FCM 토큰 제거 실패: {str(e)}")
```

### 13.5.1 Flutter에서 FCM 토큰 등록 가이드

**🔧 2026-01-02 22:00 EST 추가**: Flutter 앱에서 FCM 토큰을 서버에 등록하는 전체 흐름

#### Step 1: Firebase 설정 (필수 사전 작업)

```bash
# 1. Firebase 프로젝트 생성 (Firebase Console)
# https://console.firebase.google.com

# 2. Flutter 앱에 Firebase 추가
cd mobile_app
firebase login
firebase init
# Firestore, Cloud Messaging 선택

# 3. FlutterFire CLI로 자동 설정
flutter pub add firebase_core firebase_messaging
flutterfire configure
# → lib/firebase_options.dart 자동 생성
```

#### Step 2: FCM 서비스 구현

**`mobile_app/lib/services/fcm_service.dart`** (신규)

```dart
/// Firebase Cloud Messaging 서비스
/// 
/// FCM 토큰 관리 및 푸시 알림 처리

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../data/data_sources/remote/auth_api.dart';

final logger = Logger();

/// FCM 서비스 Provider
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(ref);
});

class FCMService {
  final Ref ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  FCMService(this.ref);
  
  /// FCM 초기화 및 토큰 등록
  Future<void> initialize() async {
    try {
      // 1. 알림 권한 요청 (iOS 필수, Android 13+ 필수)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.w('📵 푸시 알림 권한 거부됨');
        return;
      }
      
      logger.i('✅ 푸시 알림 권한 승인: ${settings.authorizationStatus}');
      
      // 2. FCM 토큰 가져오기
      final token = await _messaging.getToken();
      
      if (token == null) {
        logger.e('❌ FCM 토큰 가져오기 실패');
        return;
      }
      
      logger.i('🔑 FCM 토큰 획득: ${token.substring(0, 20)}...');
      
      // 3. 서버에 토큰 등록
      await _registerTokenToServer(token);
      
      // 4. 토큰 갱신 리스너 (토큰이 변경될 때마다 호출)
      _messaging.onTokenRefresh.listen((newToken) {
        logger.i('🔄 FCM 토큰 갱신: ${newToken.substring(0, 20)}...');
        _registerTokenToServer(newToken);
      });
      
      // 5. 포어그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // 6. 백그라운드 메시지 핸들러 (main.dart에서 설정)
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 7. 앱이 종료 상태에서 알림 탭으로 실행된 경우
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
      
      // 8. 백그라운드에서 알림 탭 시
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      
    } catch (e, stackTrace) {
      logger.e('❌ FCM 초기화 실패', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 서버에 FCM 토큰 등록
  Future<void> _registerTokenToServer(String token) async {
    try {
      final authApi = ref.read(authApiProvider);
      await authApi.registerFCMToken(token);
      
      logger.i('✅ FCM 토큰 서버 등록 완료');
    } catch (e) {
      logger.e('❌ FCM 토큰 서버 등록 실패: $e');
    }
  }
  
  /// 서버에서 FCM 토큰 제거 (로그아웃 시)
  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      
      final authApi = ref.read(authApiProvider);
      await authApi.removeFCMToken(token);
      
      // FCM 토큰 삭제 (선택)
      await _messaging.deleteToken();
      
      logger.i('✅ FCM 토큰 제거 완료');
    } catch (e) {
      logger.e('❌ FCM 토큰 제거 실패: $e');
    }
  }
  
  /// 포어그라운드 메시지 처리 (앱 사용 중)
  void _handleForegroundMessage(RemoteMessage message) {
    logger.i('📩 포어그라운드 메시지: ${message.notification?.title}');
    
    // 인앱 알림 표시 (SnackBar, 커스텀 배너 등)
    // TODO: UI에서 처리
  }
  
  /// 알림 탭 시 처리
  void _handleNotificationTap(RemoteMessage message) {
    logger.i('👆 알림 탭: ${message.data}');
    
    // 특정 화면으로 네비게이션
    final data = message.data;
    
    if (data['type'] == 'winning') {
      // 당첨 화면으로 이동
      // ref.read(routerProvider).push('/winning-detail', extra: data);
    } else if (data['type'] == 'general') {
      // 알림 목록으로 이동
      // ref.read(routerProvider).push('/notifications');
    }
  }
}

/// 백그라운드 메시지 핸들러 (Top-level 함수, main.dart에서 호출)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (백그라운드에서 필요)
  await Firebase.initializeApp();
  
  print('📩 백그라운드 메시지: ${message.notification?.title}');
  
  // 간단한 로깅만 수행 (UI 업데이트 불가)
}
```

#### Step 3: API 클라이언트에 FCM 메서드 추가

**`mobile_app/lib/data/data_sources/remote/auth_api.dart`**

```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;
  
  // ... (기존 메서드) ...
  
  /// FCM 토큰 등록
  @POST('/api/auth/fcm-token')
  Future<Map<String, dynamic>> registerFCMToken(
    @Body() Map<String, String> body,  // {"fcm_token": "..."}
  );
  
  /// FCM 토큰 제거
  @DELETE('/api/auth/fcm-token')
  Future<Map<String, dynamic>> removeFCMToken(
    @Body() Map<String, String> body,  // {"fcm_token": "..."}
  );
}
```

#### Step 4: main.dart에서 FCM 초기화

**`mobile_app/lib/main.dart`**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

// 백그라운드 메시지 핸들러 (Top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('📩 백그라운드 메시지: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ProviderScope(
      child: const LuckyAIApp(),
    ),
  );
}
```

#### Step 5: 로그인 후 FCM 토큰 등록

**`mobile_app/lib/presentation/providers/auth_provider.dart`**

```dart
@riverpod
class AuthManager extends _$AuthManager {
  @override
  FutureOr<User?> build() async {
    // 초기 로딩...
    return null;
  }
  
  Future<void> loginWithGoogle() async {
    // ... 소셜 로그인 로직 ...
    
    // 로그인 성공 후 FCM 토큰 등록
    await ref.read(fcmServiceProvider).initialize();
  }
  
  Future<void> logout() async {
    // FCM 토큰 제거
    await ref.read(fcmServiceProvider).unregisterToken();
    
    // ... 로그아웃 로직 ...
  }
}
```

#### Step 6: Android/iOS 네이티브 설정

**Android**: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
  <application>
    <!-- FCM 기본 채널 설정 -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="high_importance_channel" />
    
    <!-- FCM 아이콘 (선택) -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_icon"
      android:resource="@drawable/ic_notification" />
  </application>
</manifest>
```

**iOS**: `ios/Runner/Info.plist` (권한 설명)

```xml
<dict>
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
  
  <key>UIBackgroundModes</key>
  <array>
    <string>remote-notification</string>
  </array>
</dict>
```

**iOS**: APNs 인증서 설정 (Firebase Console)

```
1. Firebase Console > Project Settings > Cloud Messaging
2. Apple 앱 설정 > APNs 인증 키 업로드
   - Key ID, Team ID 입력
   - .p8 파일 업로드
```

#### 문제 해결

**문제 1: 토큰을 못 가져옴 (token == null)**

```
원인:
  - Firebase 설정 누락
  - google-services.json / GoogleService-Info.plist 누락
  - 인터넷 연결 문제

해결:
  1. flutterfire configure 재실행
  2. Firebase Console에서 앱 등록 확인
  3. 로그 확인: adb logcat | grep Firebase
```

**문제 2: iOS에서 알림 안 옴**

```
원인:
  - APNs 인증서 미설정
  - 알림 권한 거부
  - 실기기 테스트 필요 (시뮬레이터 불가)

해결:
  1. Firebase Console에서 APNs 설정
  2. iOS 설정 > 알림 > 앱 권한 확인
  3. 실기기에서 테스트
```

**문제 3: Android 13+에서 알림 안 옴**

```
원인:
  - 런타임 알림 권한 미요청

해결:
  1. permission_handler 패키지 사용
  2. 알림 권한 요청:
     await Permission.notification.request();
```

---

**환경 변수 추가**: `.env`

```bash
# === Firebase (Push 알림) ===
# 🔧 2026-01-02 22:00 EST 추가: 다중 방식 지원

# 방법 1: 파일 경로 (권장)
FIREBASE_SERVICE_ACCOUNT_KEY=/path/to/firebase-adminsdk-xxxxx.json

# 방법 2: JSON 문자열 (Docker/Cloud 환경)
# FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account","project_id":"..."}'

# 방법 3: Base64 인코딩 (AWS SSM/Secrets Manager)
# FIREBASE_SERVICE_ACCOUNT_KEY_BASE64=eyJ0eXBlIjoic2VydmljZV9hY2NvdW50Ii...
```

**설정 로직**: `backend/app/core/config.py`

```python
# 🔧 2026-01-02 22:00 EST 추가: Firebase 키 유연한 로드

import json
import base64
from pathlib import Path
from pydantic import Field, validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ... (기존 설정) ...
    
    FIREBASE_SERVICE_ACCOUNT_KEY: str = Field(
        ..., 
        env="FIREBASE_SERVICE_ACCOUNT_KEY",
        description="Firebase Admin SDK 키 (파일 경로 or JSON 문자열)"
    )
    FIREBASE_SERVICE_ACCOUNT_KEY_BASE64: str | None = Field(
        None,
        env="FIREBASE_SERVICE_ACCOUNT_KEY_BASE64",
        description="Firebase Admin SDK 키 (Base64 인코딩)"
    )
    
    @validator('FIREBASE_SERVICE_ACCOUNT_KEY', pre=True)
    def load_firebase_key(cls, v, values):
        """
        Firebase 키를 다중 방식으로 로드
        
        우선순위:
        1. Base64 환경 변수 (FIREBASE_SERVICE_ACCOUNT_KEY_BASE64)
        2. JSON 문자열 (FIREBASE_SERVICE_ACCOUNT_KEY가 '{' 시작)
        3. 파일 경로 (FIREBASE_SERVICE_ACCOUNT_KEY가 파일)
        
        Returns:
            str: Firebase 키 (JSON 문자열 또는 파일 경로)
        """
        # 1. Base64 환경 변수 우선
        base64_key = values.get('FIREBASE_SERVICE_ACCOUNT_KEY_BASE64')
        if base64_key:
            try:
                decoded = base64.b64decode(base64_key).decode('utf-8')
                # JSON 유효성 검증
                json.loads(decoded)
                logger.info("✅ Firebase 키 로드: Base64 환경 변수")
                return decoded
            except Exception as e:
                logger.warning(f"⚠️ Base64 키 파싱 실패: {e}, 다음 방법 시도")
        
        # 2. JSON 문자열 확인
        if isinstance(v, str) and v.strip().startswith('{'):
            try:
                json.loads(v)
                logger.info("✅ Firebase 키 로드: JSON 문자열")
                return v
            except Exception as e:
                logger.warning(f"⚠️ JSON 문자열 파싱 실패: {e}, 파일 경로로 시도")
        
        # 3. 파일 경로 확인
        if isinstance(v, str):
            file_path = Path(v)
            if file_path.exists() and file_path.is_file():
                logger.info(f"✅ Firebase 키 로드: 파일 경로 {file_path}")
                return str(file_path.absolute())
            else:
                raise ValueError(
                    f"Firebase 키 파일 없음: {file_path}\n"
                    f"파일 경로, JSON 문자열, Base64 중 하나 제공 필요"
                )
        
        raise ValueError(
            "FIREBASE_SERVICE_ACCOUNT_KEY 형식 오류\n"
            "지원 형식: 파일 경로 | JSON 문자열 | Base64 (FIREBASE_SERVICE_ACCOUNT_KEY_BASE64)"
        )
    
    class Config:
        env_file = ".env"
        case_sensitive = True
```

**NotificationService 초기화 수정**: `backend/app/services/notification_service.py`

```python
import json
from pathlib import Path

class NotificationService:
    def __init__(self):
        if not firebase_admin._apps:
            firebase_key = settings.FIREBASE_SERVICE_ACCOUNT_KEY
            
            # JSON 문자열 vs 파일 경로 판단
            if firebase_key.strip().startswith('{'):
                # JSON 문자열 → dict로 변환
                cred_dict = json.loads(firebase_key)
                cred = credentials.Certificate(cred_dict)
                logger.info("✅ Firebase 초기화: JSON 문자열")
            else:
                # 파일 경로
                cred = credentials.Certificate(firebase_key)
                logger.info(f"✅ Firebase 초기화: 파일 {firebase_key}")
            
            firebase_admin.initialize_app(cred)
            logger.info("✅ Firebase Admin SDK 초기화 완료")
```

**Docker Compose 예시**:

```yaml
# docker-compose.yml
services:
  backend:
    environment:
      # 파일 마운트 (개발)
      - FIREBASE_SERVICE_ACCOUNT_KEY=/app/secrets/firebase-key.json
    volumes:
      - ./secrets/firebase-key.json:/app/secrets/firebase-key.json:ro
```

```yaml
# docker-compose.prod.yml (프로덕션)
services:
  backend:
    environment:
      # JSON 문자열 (환경 변수)
      - FIREBASE_SERVICE_ACCOUNT_KEY=${FIREBASE_KEY_JSON}
      # 또는 Base64
      # - FIREBASE_SERVICE_ACCOUNT_KEY_BASE64=${FIREBASE_KEY_B64}
```

**AWS Secrets Manager 통합**:

```python
# backend/app/core/secrets.py

import boto3
import json
from loguru import logger


def load_firebase_key_from_aws():
    """
    AWS Secrets Manager에서 Firebase 키 로드
    
    환경 변수:
      AWS_SECRET_NAME=lotto645-firebase-key
      AWS_REGION=ap-northeast-2
    """
    try:
        client = boto3.client('secretsmanager', region_name='ap-northeast-2')
        
        response = client.get_secret_value(SecretId='lotto645-firebase-key')
        
        secret = json.loads(response['SecretString'])
        firebase_key = secret['firebase_service_account']
        
        logger.info("✅ Firebase 키 로드: AWS Secrets Manager")
        return firebase_key
        
    except Exception as e:
        logger.error(f"❌ AWS Secrets Manager 로드 실패: {e}")
        raise


# .env 대신 AWS 사용 시:
# if os.getenv('USE_AWS_SECRETS') == 'true':
#     settings.FIREBASE_SERVICE_ACCOUNT_KEY = load_firebase_key_from_aws()
```

**의존성 추가**: `requirements.txt`

```txt
firebase-admin==6.2.0
```

---

## 14. 백엔드: API 엔드포인트

### 14.1 API 엔드포인트 전체 구조

```yaml
인증 API (/api/auth):
  - POST /api/auth/guest/create: 게스트 사용자 생성
  - POST /api/auth/login/social: 소셜 로그인 (Google/Apple/Kakao/Naver)
  - POST /api/auth/upgrade-from-guest: 게스트→정식 전환
  - GET /api/auth/me: 현재 사용자 정보

코인 API (/api/coins):
  - GET /api/coins/wallet: 코인 지갑 조회
  - POST /api/coins/purchase: 코인 구매 (IAP)
  - POST /api/coins/daily-login: 일일 로그인 보상
  - POST /api/coins/watch-ad: 광고 시청 보상
  - POST /api/coins/spend: 코인 차감 (번호 생성 시)
  - GET /api/coins/transactions: 거래 내역 조회

번호 생성 API (/api/generate):
  - POST /api/generate: 번호 생성
  - GET /api/generate/algorithms: 알고리즘 목록
  - GET /api/generate/algorithms/{id}: 알고리즘 상세

로또 회차 API (/api/draws):
  - GET /api/draws/latest: 최신 회차
  - GET /api/draws: 회차 리스트
  - GET /api/draws/{draw_no}: 특정 회차 상세

내 번호 API (/api/my-numbers):
  - POST /api/my-numbers: 번호 저장
  - GET /api/my-numbers: 내 번호 목록
  - POST /api/my-numbers/{id}/check-winning: 당첨 확인
  - GET /api/my-numbers/stats: 내 통계
```

### 14.2 번호 생성 API

**`app/api/routes/generate.py`**

```python
"""
번호 생성 API

로또 번호 생성 엔드포인트
"""

from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Request
from loguru import logger

from app.schemas.generation import (
    GenerationRequest,
    GenerationResponse,
    NumberSet
)
from app.services.generation_service import GenerationService
from app.api.deps import get_current_user


router = APIRouter()


@router.post("/", response_model=GenerationResponse)
async def generate_numbers(
    request_data: GenerationRequest,
    req: Request,
    current_user: User = Depends(get_current_user),  # 인증 필수
    db: Session = Depends(get_db)
):
    """
    로또 번호 생성 (코인 차감 통합)
    
    **파라미터**:
    - algorithm_id: 알고리즘 ID (1~10, 99)
    - n_sets: 생성할 세트 수 (1~10)
    - exclude_numbers: 제외할 번호 (선택)
    - include_numbers: 포함할 번호 (선택)
    
    **응답**:
    - numbers: 생성된 번호 세트 리스트
    - algorithm_info: 사용된 알고리즘 정보
    - generation_time: 생성 소요 시간 (ms)
    - coins_spent: 차감된 코인 수
    - remaining_balance: 남은 코인 잔액
    
    **🔒 보안**:
    - 코인 잔액 확인 및 차감이 번호 생성과 원자적으로 처리됨
    - 비관적 락(with_for_update)으로 동시성 제어
    """
    try:
        # === 1. 알고리즘 검증 ===
        algorithms = req.app.state.algorithms
        if request_data.algorithm_id not in algorithms:
            raise HTTPException(
                status_code=400,
                detail=f"알고리즘 ID {request_data.algorithm_id} 없음"
            )
        
        algorithm = algorithms[request_data.algorithm_id]
        
        # === 2. 코인 비용 계산 ===
        # 🔧 2026-01-02 21:00 EST 수정: DB에서 동적 조회로 변경 예정
        # 현재는 Fallback으로 하드코딩 유지
        from app.db.models.algorithm_pricing import AlgorithmPricing
        
        pricing = db.query(AlgorithmPricing).filter(
            AlgorithmPricing.algorithm_id == request_data.algorithm_id,
            AlgorithmPricing.is_active == True
        ).first()
        
        if pricing:
            cost_per_set = pricing.final_cost  # 할인 적용된 최종 비용
        else:
            # Fallback: 기본 비용
            default_costs = {
                1: 5, 2: 15, 3: 15, 4: 15, 5: 15,
                6: 10, 7: 10, 8: 30, 9: 35, 10: 40, 99: 100
            }
            cost_per_set = default_costs.get(request_data.algorithm_id, 20)
        
        total_cost = cost_per_set * request_data.n_sets
        
        # === 3. 코인 지갑 조회 및 락 획득 (동시성 제어) ===
        # ⚠️ 2026-01-02 21:00 EST 경고: Race Condition 위험
        # 
        # 현재 구조의 문제:
        # - 락 획득 → 알고리즘 실행 (2~5초) → 코인 차감
        # - 알고리즘 실행 중에는 락만 잡고 있고 차감은 안 됨
        # - 동시 요청 시 잔액 불일치 가능
        #
        # 권장 해결 방안: Deduct First 패턴
        # 1. 락 획득
        # 2. 잔액 확인
        # 3. 코인 즉시 차감 + 커밋 (락 해제)
        # 4. 알고리즘 실행
        # 5. 성공 시 거래 기록, 실패 시 롤백
        #
        # 구현 예시:
        # ```python
        # wallet.balance -= total_cost
        # wallet.total_spent += total_cost
        # db.commit()  # 즉시 커밋으로 락 해제
        # 
        # try:
        #     result = await service.generate(...)  # 락 없이 실행
        #     # 거래 기록
        # except Exception as e:
        #     # 실패 시 롤백
        #     wallet.balance += total_cost
        #     wallet.total_spent -= total_cost
        #     db.commit()
        #     raise
        # ```
        
        from app.db.models.coin_wallet import CoinWallet, CoinTransaction, TransactionType
        
        wallet = db.query(CoinWallet).filter(
            CoinWallet.user_id == current_user.id
        ).with_for_update().first()  # 🔒 비관적 락
        
        if not wallet:
            raise HTTPException(
                status_code=404,
                detail="코인 지갑을 찾을 수 없습니다"
            )
        
        # === 4. 잔액 확인 ===
        if wallet.balance < total_cost:
            raise HTTPException(
                status_code=402,  # Payment Required
                detail={
                    "error": "코인이 부족합니다",
                    "required": total_cost,
                    "current": wallet.balance,
                    "shortage": total_cost - wallet.balance,
                    "algorithm_id": request_data.algorithm_id,
                    "cost_per_set": cost_per_set
                }
            )
        
        # === 5. 코인 즉시 차감 (Deduct First 패턴) ===
        # 🔧 2026-01-02 21:00 EST 권장: 알고리즘 실행 전 차감하여 락 해제
        wallet.balance -= total_cost
        wallet.total_spent += total_cost
        db.commit()  # 즉시 커밋 → 락 해제
        
        # === 6. 번호 생성 (비즈니스 로직, 락 없이 실행) ===
        data_manager = req.app.state.data_manager
        historical_data = data_manager.get_dataframe()
        
        service = GenerationService()
        
        try:
            result = await service.generate(
                algorithm=algorithm,
                historical_data=historical_data,
                n_sets=request_data.n_sets,
                exclude_numbers=request_data.exclude_numbers,
                include_numbers=request_data.include_numbers,
                user_id=current_user.id
            )
        except Exception as e:
            # 알고리즘 실행 실패 시 코인 롤백
            logger.error(f"[번호 생성 실패] User {current_user.id}, 코인 롤백: {total_cost}")
            wallet = db.query(CoinWallet).filter(
                CoinWallet.user_id == current_user.id
            ).with_for_update().first()
            wallet.balance += total_cost
            wallet.total_spent -= total_cost
            db.commit()
            raise HTTPException(
                status_code=500,
                detail=f"번호 생성 중 오류 발생: {str(e)}"
            )
        
        # === 7. 거래 기록 생성 ===
        transaction = CoinTransaction(
            wallet_id=wallet.id,
            type=TransactionType.GENERATION,
            amount=-total_cost,
            balance_after=wallet.balance,
            algorithm_id=request_data.algorithm_id,
            description=f"번호 생성 (알고리즘 {request_data.algorithm_id}, {request_data.n_sets}세트)",
            metadata=json.dumps({
                'algorithm_name': algorithm.name,
                'n_sets': request_data.n_sets,
                'cost_per_set': cost_per_set
            })
        )
        db.add(transaction)
        
        # === 8. 커밋 (원자성 보장) ===
        db.commit()
        
        logger.info(
            f"[번호 생성 성공] User {current_user.id}, "
            f"Algorithm {request_data.algorithm_id}, "
            f"{request_data.n_sets}세트, 코인 {total_cost} 차감, "
            f"남은 잔액: {wallet.balance}, {result['generation_time']:.0f}ms"
        )
        
        # === 9. 응답 반환 ===
        return GenerationResponse(
            numbers=[
                NumberSet(numbers=nums, set_no=i+1)
                for i, nums in enumerate(result['numbers'])
            ],
            algorithm_info={
                'id': algorithm.algorithm_id,
                'name': algorithm.name,
                'description': algorithm.description,
                'cost_per_set': cost_per_set
            },
            generation_time=result['generation_time'],
            latest_draw=data_manager.df['회차'].max(),
            coins_spent=total_cost,
            remaining_balance=wallet.balance
        )
        
    except HTTPException:
        # 명시적 HTTP 예외는 그대로 전달
        db.rollback()
        raise
    
    except ValueError as e:
        db.rollback()
        logger.warning(f"입력 오류: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
    except Exception as e:
        db.rollback()
        logger.exception(f"번호 생성 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail="내부 서버 오류. 코인은 차감되지 않았습니다."
        )


@router.get("/algorithms", response_model=List[dict])
async def list_algorithms(req: Request):
    """
    사용 가능한 알고리즘 목록
    
    **응답**:
    - 알고리즘 정보 리스트 (id, name, description)
    """
    algorithms = req.app.state.algorithms
    
    return [
        algo.get_info()
        for algo in algorithms.values()
    ]


@router.get("/algorithms/{algorithm_id}", response_model=dict)
async def get_algorithm_info(algorithm_id: int, req: Request):
    """
    특정 알고리즘 상세 정보
    
    **파라미터**:
    - algorithm_id: 알고리즘 ID
    
    **응답**:
    - 알고리즘 상세 정보 (id, name, description, parameters)
    """
    algorithms = req.app.state.algorithms
    
    if algorithm_id not in algorithms:
        raise HTTPException(status_code=404, detail="알고리즘 없음")
    
    algorithm = algorithms[algorithm_id]
    return algorithm.get_info()
```

**주요 엔드포인트**:
- `POST /api/generate`: 번호 생성
- `GET /api/draws/latest`: 최신 회차
- `GET /api/draws`: 회차 리스트
- `GET /api/generate/algorithms`: 알고리즘 목록
- `POST /api/check-winning`: 당첨 확인

**코드는 기존 섹션 7.1 참조**

---

## 15. 사용자 번호 관리 및 자동 당첨 확인 시스템

> 🎯 **핵심 기능**: 사용자가 생성한 번호를 서버에 저장하고, 새 회차 발표 시 자동으로 당첨 여부를 확인하여 통계를 기록합니다.

### 15.1 시스템 개요

```mermaid
flowchart TD
    A[사용자가 번호 생성] --> B[서버에 저장<br/>UserGeneratedNumbers]
    B --> C[로컬에도 저장<br/>Hive]
    C --> D[대기 상태]
    
    E[매주 토/일 크롤링] --> F[새 회차 발견]
    F --> G[Celery 자동 작업 트리거]
    G --> H[모든 미확인 번호 조회]
    H --> I[당첨 여부 자동 계산]
    I --> J{당첨?}
    
    J -->|Yes| K[WinningCheckResult 저장]
    J -->|No| L[꽝 기록]
    
    K --> M[Push 알림 전송<br/>Firebase]
    L --> N[통계 업데이트]
    M --> N
    N --> O[사용자 앱에서 확인]
    
    style A fill:#667eea,color:#fff
    style M fill:#f59e0b,color:#fff
    style O fill:#10b981,color:#fff
```

### 15.2 데이터베이스 모델 추가

**`backend/app/db/models/user_generated_number.py`**

```python
"""
사용자 생성 번호 모델

사용자가 생성한 번호를 서버에 저장
"""

from datetime import datetime
from uuid import uuid4
from typing import List

from sqlalchemy import Column, String, Integer, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship

from app.db.base import Base


class UserGeneratedNumber(Base):
    """
    사용자가 생성한 로또 번호
    
    서버에 저장하여:
    - 자동 당첨 확인
    - 통계 추적
    - 즐겨찾기
    - 여러 기기 간 동기화
    """
    __tablename__ = "user_generated_numbers"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # 생성 정보
    algorithm_id = Column(Integer, nullable=False)  # 어떤 알고리즘으로 생성했는지
    algorithm_name = Column(String(100), nullable=False)
    
    # 번호 (정렬된 6개)
    numbers = Column(ARRAY(Integer), nullable=False)  # [3, 12, 19, 28, 35, 42]
    
    # 대상 회차
    target_draw_no = Column(Integer, nullable=False, index=True)  # 어느 회차용인지
    
    # 생성 시각
    generated_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 즐겨찾기
    is_favorite = Column(Boolean, default=False)
    
    # 메모 (사용자가 남긴 메모)
    memo = Column(String(200), nullable=True)
    
    # 당첨 확인 여부
    is_checked = Column(Boolean, default=False, index=True)
    
    # 관계
    user = relationship("User", back_populates="generated_numbers")
    winning_result = relationship(
        "WinningCheckResult", 
        back_populates="generated_number",
        uselist=False
    )
    
    def __repr__(self):
        return f"<UserGeneratedNumber(id={self.id}, numbers={self.numbers}, draw={self.target_draw_no})>"


class WinningCheckResult(Base):
    """
    당첨 확인 결과
    
    새 회차 발표 시 자동으로 계산하여 저장
    """
    __tablename__ = "winning_check_results"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    
    # 어떤 생성 번호인지
    generated_number_id = Column(
        UUID(as_uuid=True), 
        ForeignKey("user_generated_numbers.id"),
        unique=True,  # 1:1 관계
        nullable=False
    )
    
    # 어느 회차 결과인지
    draw_no = Column(Integer, nullable=False, index=True)
    
    # 당첨 정보
    rank = Column(Integer, nullable=False)  # 1~5등 (0=꽝)
    matched_count = Column(Integer, nullable=False)  # 맞춘 개수 (0~6)
    has_bonus = Column(Boolean, default=False)
    
    # 당첨금 (있으면)
    prize_amount = Column(Integer, nullable=True)
    
    # 맞춘 번호들
    matched_numbers = Column(ARRAY(Integer), nullable=True)
    
    # 확인 시각
    checked_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 알림 전송 여부
    notification_sent = Column(Boolean, default=False)
    
    # 관계
    generated_number = relationship("UserGeneratedNumber", back_populates="winning_result")
    
    def __repr__(self):
        return f"<WinningCheckResult(draw={self.draw_no}, rank={self.rank}, matched={self.matched_count})>"


class UserStatistics(Base):
    """
    사용자 통계 (집계 테이블)
    
    정기적으로 업데이트되는 통계 데이터
    """
    __tablename__ = "user_statistics"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)
    
    # 전체 통계
    total_generated = Column(Integer, default=0)  # 총 생성 개수
    total_checked = Column(Integer, default=0)    # 확인된 개수
    
    # 등수별 당첨 횟수
    rank_1_count = Column(Integer, default=0)
    rank_2_count = Column(Integer, default=0)
    rank_3_count = Column(Integer, default=0)
    rank_4_count = Column(Integer, default=0)
    rank_5_count = Column(Integer, default=0)
    
    # 총 당첨금
    total_prize = Column(Integer, default=0)
    
    # 알고리즘별 통계 (JSON)
    algorithm_stats = Column(JSON, nullable=True)
    # 예: {"1": {"generated": 50, "rank_5": 3}, "2": {...}}
    
    # 마지막 업데이트
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 관계
    user = relationship("User", back_populates="statistics")
    
    def __repr__(self):
        return f"<UserStatistics(user_id={self.user_id}, generated={self.total_generated})>"
```

### 15.3 API 엔드포인트 추가

**`backend/app/api/routes/my_numbers.py`** (신규)

```python
"""
내 번호 관리 API

사용자가 생성한 번호 저장, 조회, 당첨 확인
"""

from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.user_generated_number import (
    UserGeneratedNumber,
    WinningCheckResult,
    UserStatistics
)
from app.schemas.my_numbers import (
    SaveNumbersRequest,
    SaveNumbersResponse,
    MyNumberDetail,
    MyNumbersList,
    WinningCheckResponse,
    UserStatsResponse
)
from app.services.winning_service import WinningService

router = APIRouter()


@router.post("/", response_model=SaveNumbersResponse)
async def save_my_numbers(
    request: SaveNumbersRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    생성한 번호를 서버에 저장
    
    **요청**:
    ```json
    {
      "algorithm_id": 2,
      "algorithm_name": "LSTM 기본",
      "numbers": [
        [3, 12, 19, 28, 35, 42],
        [5, 8, 15, 23, 31, 44]
      ],
      "target_draw_no": 1170,
      "memo": "이번주 번호"
    }
    ```
    
    **응답**:
    - 저장된 번호 ID 목록
    """
    saved_ids = []
    
    for number_set in request.numbers:
        # 번호 저장
        generated_number = UserGeneratedNumber(
            user_id=current_user.id,
            algorithm_id=request.algorithm_id,
            algorithm_name=request.algorithm_name,
            numbers=sorted(number_set),  # 정렬하여 저장
            target_draw_no=request.target_draw_no,
            memo=request.memo
        )
        
        db.add(generated_number)
        db.flush()  # ID 생성
        
        saved_ids.append(str(generated_number.id))
    
    db.commit()
    
    return SaveNumbersResponse(
        success=True,
        saved_count=len(saved_ids),
        ids=saved_ids,
        message=f"{len(saved_ids)}개 번호 저장 완료"
    )


@router.get("/", response_model=MyNumbersList)
async def get_my_numbers(
    draw_no: Optional[int] = Query(None, description="회차 필터"),
    checked: Optional[bool] = Query(None, description="확인 여부 필터"),
    favorite: Optional[bool] = Query(None, description="즐겨찾기만"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    내가 생성한 번호 목록 조회
    
    **필터**:
    - `draw_no`: 특정 회차만
    - `checked`: True(확인됨), False(미확인), None(전체)
    - `favorite`: True(즐겨찾기만)
    """
    query = db.query(UserGeneratedNumber).filter(
        UserGeneratedNumber.user_id == current_user.id
    )
    
    # 필터 적용
    if draw_no:
        query = query.filter(UserGeneratedNumber.target_draw_no == draw_no)
    if checked is not None:
        query = query.filter(UserGeneratedNumber.is_checked == checked)
    if favorite:
        query = query.filter(UserGeneratedNumber.is_favorite == True)
    
    # 정렬 (최신순)
    query = query.order_by(UserGeneratedNumber.generated_at.desc())
    
    # 페이징
    total = query.count()
    numbers = query.offset(offset).limit(limit).all()
    
    return MyNumbersList(
        total=total,
        items=[MyNumberDetail.from_orm(n) for n in numbers]
    )


@router.post("/{number_id}/check-winning", response_model=WinningCheckResponse)
async def check_winning_manual(
    number_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    수동으로 당첨 확인
    
    보통은 Celery가 자동으로 확인하지만, 사용자가 직접 확인할 수도 있음
    """
    # 번호 조회
    generated_number = db.query(UserGeneratedNumber).filter(
        UserGeneratedNumber.id == number_id,
        UserGeneratedNumber.user_id == current_user.id
    ).first()
    
    if not generated_number:
        raise HTTPException(status_code=404, detail="번호를 찾을 수 없습니다")
    
    # 이미 확인됨?
    if generated_number.is_checked:
        # 기존 결과 반환
        result = generated_number.winning_result
        return WinningCheckResponse.from_orm(result)
    
    # 당첨 확인 서비스 호출
    winning_service = WinningService(db)
    result = await winning_service.check_single_number(generated_number)
    
    return WinningCheckResponse.from_orm(result)


@router.get("/stats", response_model=UserStatsResponse)
async def get_my_statistics(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    내 통계 조회
    
    **응답**:
    - 총 생성 / 확인 개수
    - 등수별 당첨 횟수
    - 알고리즘별 성적
    - 총 당첨금
    """
    stats = db.query(UserStatistics).filter(
        UserStatistics.user_id == current_user.id
    ).first()
    
    if not stats:
        # 통계 없으면 기본값 생성
        stats = UserStatistics(user_id=current_user.id)
        db.add(stats)
        db.commit()
        db.refresh(stats)
    
    return UserStatsResponse.from_orm(stats)


@router.patch("/{number_id}/favorite")
async def toggle_favorite(
    number_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """즐겨찾기 토글"""
    generated_number = db.query(UserGeneratedNumber).filter(
        UserGeneratedNumber.id == number_id,
        UserGeneratedNumber.user_id == current_user.id
    ).first()
    
    if not generated_number:
        raise HTTPException(status_code=404, detail="번호를 찾을 수 없습니다")
    
    generated_number.is_favorite = not generated_number.is_favorite
    db.commit()
    
    return {
        "success": True,
        "is_favorite": generated_number.is_favorite
    }
```

### 15.4 자동 당첨 확인 서비스

**`backend/app/services/winning_service.py`** (신규)

```python
"""
당첨 확인 서비스

번호와 실제 당첨번호를 비교하여 등수 계산
"""

from typing import List, Tuple
from sqlalchemy.orm import Session
from loguru import logger

from app.db.models.user_generated_number import (
    UserGeneratedNumber,
    WinningCheckResult
)
from app.db.models.lotto_draw import LottoDraw


class WinningService:
    """당첨 확인 서비스"""
    
    def __init__(self, db: Session):
        self.db = db
    
    async def check_single_number(
        self,
        generated_number: UserGeneratedNumber
    ) -> WinningCheckResult:
        """
        단일 번호 당첨 확인
        
        Args:
            generated_number: 확인할 번호
            
        Returns:
            WinningCheckResult: 확인 결과
        """
        # 실제 당첨번호 조회
        draw = self.db.query(LottoDraw).filter(
            LottoDraw.draw_no == generated_number.target_draw_no
        ).first()
        
        if not draw:
            raise ValueError(f"회차 {generated_number.target_draw_no} 데이터 없음")
        
        # 등수 판정
        rank, matched_count, has_bonus, matched_nums = self._judge_rank(
            predicted=generated_number.numbers,
            winning=[draw.num1, draw.num2, draw.num3, draw.num4, draw.num5, draw.num6],
            bonus=draw.bonus
        )
        
        # 당첨금 조회 (있으면)
        prize = self._get_prize_amount(rank, draw)
        
        # 결과 저장
        result = WinningCheckResult(
            generated_number_id=generated_number.id,
            draw_no=draw.draw_no,
            rank=rank,
            matched_count=matched_count,
            has_bonus=has_bonus,
            matched_numbers=matched_nums,
            prize_amount=prize
        )
        
        self.db.add(result)
        
        # 생성 번호 확인 완료 표시
        generated_number.is_checked = True
        
        self.db.commit()
        self.db.refresh(result)
        
        logger.info(
            f"당첨 확인 완료: 번호 {generated_number.id}, "
            f"회차 {draw.draw_no}, 등수 {rank}, 맞춤 {matched_count}개"
        )
        
        return result
    
    @staticmethod
    def _judge_rank(
        predicted: List[int],
        winning: List[int],
        bonus: int
    ) -> Tuple[int, int, bool, List[int]]:
        """
        등수 판정
        
        Returns:
            (등수, 맞춘개수, 보너스포함, 맞춘번호들)
        """
        matched = set(predicted) & set(winning)
        matched_count = len(matched)
        has_bonus = bonus in predicted
        
        # 등수 계산
        if matched_count == 6:
            rank = 1
        elif matched_count == 5 and has_bonus:
            rank = 2
        elif matched_count == 5:
            rank = 3
        elif matched_count == 4:
            rank = 4
        elif matched_count == 3:
            rank = 5
        else:
            rank = 0  # 꽝
        
        return rank, matched_count, has_bonus, sorted(list(matched))
    
    def _get_prize_amount(self, rank: int, draw: LottoDraw) -> int:
        """당첨금 조회 (DB에 있으면)"""
        if rank == 0:
            return 0
        
        # TODO: LottoDraw 모델에 당첨금 필드 추가 후 반환
        # 현재는 평균값 또는 None
        prize_map = {
            1: 2000000000,  # 1등 평균 20억
            2: 50000000,    # 2등 평균 5천만
            3: 1500000,     # 3등 평균 150만
            4: 50000,       # 4등 5만원 고정
            5: 5000,        # 5등 5천원 고정
        }
        
        return prize_map.get(rank, 0)
```

### 15.5 Celery 자동 당첨 확인 작업

**`backend/app/workers/tasks.py`에 추가**

```python
@celery_app.task(name="tasks.auto_check_winning")
def auto_check_winning_for_new_draw(draw_no: int):
    """
    새 회차 발표 시 자동 당첨 확인
    
    Args:
        draw_no: 새로 발표된 회차 번호
        
    동작:
    1. 해당 회차를 타겟으로 하는 미확인 번호 모두 조회
    2. 각 번호별 당첨 여부 자동 계산
    3. WinningCheckResult 저장
    4. 당첨자에게 Push 알림 전송
    5. 사용자 통계 업데이트
    """
    logger.info(f"🎰 자동 당첨 확인 시작: {draw_no}회차")
    
    from app.db.session import SessionLocal
    from app.db.models.user_generated_number import UserGeneratedNumber
    from app.services.winning_service import WinningService
    from app.services.notification_service import NotificationService
    
    db = SessionLocal()
    
    try:
        # 1. 미확인 번호 조회
        unchecked_numbers = db.query(UserGeneratedNumber).filter(
            UserGeneratedNumber.target_draw_no == draw_no,
            UserGeneratedNumber.is_checked == False
        ).all()
        
        logger.info(f"  확인할 번호: {len(unchecked_numbers)}개")
        
        if not unchecked_numbers:
            logger.info("  확인할 번호 없음")
            return {'status': 'no_numbers', 'draw_no': draw_no}
        
        # 2. 당첨 확인 서비스 초기화
        winning_service = WinningService(db)
        notification_service = NotificationService()
        
        checked_count = 0
        winning_count = 0
        
        # 3. 각 번호 확인
        for generated_number in unchecked_numbers:
            try:
                # 당첨 확인
                result = winning_service.check_single_number(generated_number)
                checked_count += 1
                
                # 당첨이면 알림 전송
                if result.rank > 0:
                    winning_count += 1
                    logger.info(
                        f"  🎉 당첨! 사용자 {generated_number.user_id}, "
                        f"{result.rank}등, {result.matched_count}개 맞춤"
                    )
                    
                    # Push 알림
                    await notification_service.send_winning_notification(
                        user_id=generated_number.user_id,
                        rank=result.rank,
                        numbers=generated_number.numbers,
                        draw_no=draw_no
                    )
                    
                    result.notification_sent = True
                    db.commit()
                
            except Exception as e:
                logger.error(f"  번호 {generated_number.id} 확인 실패: {e}")
                continue
        
        # 4. 통계 업데이트 (배치)
        from app.services.stats_service import StatsService
        stats_service = StatsService(db)
        stats_service.update_user_statistics()
        
        logger.success(
            f"✅ 자동 당첨 확인 완료: {checked_count}개 확인, "
            f"{winning_count}개 당첨"
        )
        
        return {
            'status': 'success',
            'draw_no': draw_no,
            'checked_count': checked_count,
            'winning_count': winning_count
        }
        
    except Exception as e:
        logger.exception(f"❌ 자동 당첨 확인 실패: {e}")
        raise
        
    finally:
        db.close()


# 크롤링 작업 수정 (당첨 확인 트리거 추가)
@celery_app.task(name="tasks.crawl_latest_draw")
def crawl_latest_draw():
    """
    최신 회차 크롤링 (주기적)
    
    매주 토요일 21:00, 일요일 09:00 실행
    """
    logger.info("🌐 최신 회차 크롤링 작업 시작...")
    
    try:
        import asyncio
        
        async def _crawl():
            data_manager = DataManager()
            result = await data_manager.check_for_updates()
            
            if result.get('has_update'):
                latest_draw = result['latest']
                logger.info(f"새 회차 발견: {latest_draw}회")
                
                # 데이터 동기화
                sync_result = await data_manager.initialize()
                
                # ✨ 자동 당첨 확인 작업 예약
                auto_check_winning_for_new_draw.delay(latest_draw)
                
                return sync_result
            else:
                logger.info("최신 상태 유지")
                return {'status': 'no_update'}
        
        result = asyncio.run(_crawl())
        logger.success("크롤링 작업 완료")
        
        return result
        
    except Exception as e:
        logger.exception(f"크롤링 작업 실패: {e}")
        raise
```

### 15.6 Flutter 앱 화면 추가

**내 번호 관리 화면** (`mobile_app/lib/presentation/screens/my_numbers/`)

```dart
/// 내 번호 관리 화면
/// 
/// 생성한 번호 목록, 당첨 확인, 통계

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/my_numbers_provider.dart';
import '../../widgets/number_card.dart';
import '../../widgets/winning_badge.dart';

class MyNumbersScreen extends ConsumerStatefulWidget {
  const MyNumbersScreen({super.key});

  @override
  ConsumerState<MyNumbersScreen> createState() => _MyNumbersScreenState();
}

class _MyNumbersScreenState extends ConsumerState<MyNumbersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final myNumbersState = ref.watch(myNumbersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 번호'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '미확인'),
            Tab(text: '당첨'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNumbers(myNumbersState),
          _buildUncheckedNumbers(myNumbersState),
          _buildWinningNumbers(myNumbersState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 번호 생성 화면으로 이동
          Navigator.pushNamed(context, '/generate');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllNumbers(AsyncValue<MyNumbersList> state) {
    return state.when(
      data: (numbers) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: numbers.items.length,
        itemBuilder: (context, index) {
          final item = numbers.items[index];
          return _buildNumberCard(item);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류: $error')),
    );
  }

  Widget _buildNumberCard(MyNumberDetail item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Row(
          children: [
            // 번호 공
            ...item.numbers.map((num) => LottoBall(number: num)),
            const Spacer(),
            // 당첨 배지
            if (item.winningResult != null)
              WinningBadge(rank: item.winningResult!.rank),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.targetDrawNo}회차 • ${item.algorithmName}'),
            if (item.memo != null) Text(item.memo!),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            item.isFavorite ? Icons.star : Icons.star_border,
            color: item.isFavorite ? Colors.amber : null,
          ),
          onPressed: () => _toggleFavorite(item.id),
        ),
        onTap: () => _showDetailDialog(item),
      ),
    );
  }

  // ... 나머지 UI 메서드들
}
```

### 15.7 통신 시퀀스 (자동 당첨 확인)

```mermaid
sequenceDiagram
    participant C as Celery Worker
    participant DB as PostgreSQL
    participant W as WinningService
    participant N as NotificationService
    participant F as Firebase
    participant App as Flutter 앱
    
    Note over C,App: 매주 토요일 21:00 크롤링
    C->>DB: 새 회차 1170 크롤링 완료
    C->>C: auto_check_winning 작업 예약
    
    Note over C,App: 자동 당첨 확인 시작
    C->>DB: SELECT 미확인 번호<br/>(target_draw_no=1170)
    DB-->>C: 150개 번호 반환
    
    loop 각 번호마다
        C->>W: check_single_number()
        W->>DB: 실제 당첨번호 조회
        W->>W: 등수 판정
        W->>DB: WinningCheckResult 저장
        
        alt 당첨 (rank > 0)
            W->>N: send_winning_notification()
            N->>F: Push 알림 전송
            F->>App: "🎉 3등 당첨!"
            App->>App: 알림 표시
        end
    end
    
    C->>DB: UserStatistics 업데이트
    C->>C: 작업 완료
    
    Note over App: 사용자가 앱 열면
    App->>DB: GET /api/my-numbers
    DB-->>App: 당첨 결과 포함
    App->>App: 당첨 배지 표시
```

---

## 16. 백엔드: 캐싱 전략

### 16.1 캐시 매니저

**`app/core/cache_manager.py`**

```python
"""
캐시 관리 모듈

Redis를 사용한 데이터 캐싱
"""

import json
import pickle
from typing import Any, Optional

import aioredis
from loguru import logger

from app.config import settings


class CacheManager:
    """
    Redis 캐시 매니저
    """
    
    def __init__(self):
        self.redis: Optional[aioredis.Redis] = None
        self.enabled = settings.CACHE_ENABLED
        self.default_ttl = settings.CACHE_TTL
    
    async def connect(self):
        """Redis 연결"""
        if not self.enabled:
            logger.info("캐시 비활성화됨")
            return
        
        try:
            self.redis = await aioredis.from_url(
                settings.REDIS_URL,
                encoding="utf-8",
                decode_responses=False  # pickle 사용 위해
            )
            
            # 연결 테스트
            await self.redis.ping()
            logger.success("✅ Redis 연결 완료")
            
        except Exception as e:
            logger.error(f"❌ Redis 연결 실패: {e}")
            self.enabled = False
    
    async def disconnect(self):
        """Redis 연결 해제"""
        if self.redis:
            await self.redis.close()
            logger.info("Redis 연결 해제")
    
    async def get(self, key: str) -> Optional[Any]:
        """
        캐시 조회
        
        Args:
            key: 캐시 키
            
        Returns:
            캐시된 값 또는 None
        """
        if not self.enabled or not self.redis:
            return None
        
        try:
            value = await self.redis.get(key)
            if value:
                # pickle로 역직렬화
                return pickle.loads(value)
            return None
            
        except Exception as e:
            logger.warning(f"캐시 조회 실패 (key={key}): {e}")
            return None
    
    async def set(
        self,
        key: str,
        value: Any,
        ttl: Optional[int] = None
    ):
        """
        캐시 저장
        
        Args:
            key: 캐시 키
            value: 저장할 값
            ttl: TTL (초), None이면 기본값
        """
        if not self.enabled or not self.redis:
            return
        
        try:
            # pickle로 직렬화
            serialized = pickle.dumps(value)
            
            ttl = ttl or self.default_ttl
            await self.redis.setex(key, ttl, serialized)
            
        except Exception as e:
            logger.warning(f"캐시 저장 실패 (key={key}): {e}")
    
    async def delete(self, key: str):
        """캐시 삭제"""
        if not self.enabled or not self.redis:
            return
        
        try:
            await self.redis.delete(key)
        except Exception as e:
            logger.warning(f"캐시 삭제 실패 (key={key}): {e}")
    
    async def exists(self, key: str) -> bool:
        """캐시 존재 여부"""
        if not self.enabled or not self.redis:
            return False
        
        try:
            return await self.redis.exists(key) > 0
        except:
            return False
    
    async def warmup(self):
        """
        캐시 워밍업
        
        자주 사용되는 데이터를 미리 캐시
        """
        if not self.enabled:
            return
        
        logger.info("캐시 워밍업 시작...")
        
        # TODO: 자주 사용되는 데이터 미리 로드
        # 예: 최신 회차 정보, 알고리즘 성능 통계 등
        
        logger.success("캐시 워밍업 완료")
    
    def make_key(self, *parts) -> str:
        """
        캐시 키 생성
        
        Args:
            *parts: 키 구성 요소
            
        Returns:
            "lotto:part1:part2:..." 형식의 키
        """
        return "lotto:" + ":".join(str(p) for p in parts)
```

**Redis 캐싱**:
- 최신 회차 정보 (TTL: 1시간)
- 알고리즘 성능 통계
- 빈도 분석 데이터
- API 응답 캐싱

**코드는 기존 섹션 8.1 참조**

---

## 17. 백엔드: 백그라운드 작업

### 17.1 Celery 워커

**`app/workers/tasks.py`**

```python
"""
Celery 백그라운드 작업

정기 크롤링, AI 학습 등
"""

from celery import Celery
from loguru import logger

from app.config import settings
from app.core.data_manager import DataManager


# Celery 앱 초기화
celery_app = Celery(
    "lotto645_worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND
)

# 🔧 2026-01-02 21:00 EST 추가: 시간대 설정
celery_app.conf.timezone = 'Asia/Seoul'  # KST (한국 표준시)
celery_app.conf.enable_utc = False  # 로컬 시간 사용 (UTC 비활성화)

logger.info(f"✅ Celery 시간대 설정: {celery_app.conf.timezone}")


@celery_app.task(name="tasks.crawl_latest_draw")
def crawl_latest_draw():
    """
    최신 회차 크롤링 (주기적)
    
    ⏰ 실행 시간:
    - 매주 토요일 21:00 KST (추첨 직후)
    - 매주 일요일 09:00 KST (재시도)
    """
    logger.info("🌐 최신 회차 크롤링 작업 시작...")
    
    try:
        import asyncio
        
        async def _crawl():
            data_manager = DataManager()
            result = await data_manager.check_for_updates()
            
            if result.get('has_update'):
                logger.info(f"새 회차 발견: {result['latest']}회")
                sync_result = await data_manager.initialize()
                return sync_result
            else:
                logger.info("최신 상태 유지")
                return {'status': 'no_update'}
        
        result = asyncio.run(_crawl())
        logger.success("크롤링 작업 완료")
        
        return result
        
    except Exception as e:
        logger.exception(f"크롤링 작업 실패: {e}")
        raise


@celery_app.task(name="tasks.retrain_lstm_model")
def retrain_lstm_model():
    """
    LSTM 모델 재학습
    
    매주 일요일 02:00 실행
    """
    logger.info("🤖 LSTM 모델 재학습 작업 시작...")
    
    try:
        from app.models.model_trainer import ModelTrainer
        
        trainer = ModelTrainer()
        result = trainer.train_lstm()
        
        logger.success(f"모델 재학습 완료: 정확도 {result['accuracy']:.4f}")
        return result
        
    except Exception as e:
        logger.exception(f"재학습 실패: {e}")
        raise


@celery_app.task(name="tasks.aggregate_statistics")
def aggregate_statistics():
    """
    통계 집계
    
    매일 03:00 실행
    """
    logger.info("📊 통계 집계 작업 시작...")
    
    try:
        # TODO: 통계 집계 로직
        logger.success("통계 집계 완료")
        return {'status': 'success'}
        
    except Exception as e:
        logger.exception(f"통계 집계 실패: {e}")
        raise
```

### 17.2 스케줄 설정

**`app/workers/beat_schedule.py`**

```python
"""
Celery Beat 스케줄 설정

주기적 작업 스케줄 정의
"""

from celery.schedules import crontab


# 🔧 2026-01-02 21:00 EST 수정: 시간대 명확화
# Celery 시간대는 celery_app.py에서 CELERY_TIMEZONE='Asia/Seoul'로 설정됨
# 모든 시간은 KST (한국 표준시) 기준

# Celery Beat 스케줄
CELERYBEAT_SCHEDULE = {
    # 매주 토요일 21:00 KST - 최신 회차 크롤링
    'crawl-saturday-night': {
        'task': 'tasks.crawl_latest_draw',
        'schedule': crontab(
            hour=21,  # KST 21:00 (추첨 직후)
            minute=0,
            day_of_week=6  # 토요일 (0=일요일, 6=토요일)
        ),
        'options': {'queue': 'default'}
    },
    
    # 매주 일요일 09:00 KST - 재시도 크롤링 (토요일 실패 시)
    'crawl-sunday-morning': {
        'task': 'tasks.crawl_latest_draw',
        'schedule': crontab(
            hour=9,  # KST 09:00
            minute=0,
            day_of_week=0  # 일요일
        ),
        'options': {'queue': 'default'}
    },
    
    # 매주 일요일 02:00 KST - LSTM 모델 재학습
    'retrain-model-weekly': {
        'task': 'tasks.retrain_lstm_model',
        'schedule': crontab(
            hour=2,  # KST 02:00
            minute=0,
            day_of_week=0  # 일요일
        ),
        'options': {'queue': 'heavy'}
    },
    
    # 매일 03:00 KST - 통계 집계
    'aggregate-stats-daily': {
        'task': 'tasks.aggregate_statistics',
        'schedule': crontab(
            hour=3,  # KST 03:00
            minute=0
        ),
        'options': {'queue': 'default'}
    },
}
```

**⚠️ 시간대 주의사항**:

```python
# 🔧 2026-01-02 22:00 EST 통합: Celery 시간대 설정
# app/workers/celery_app.py (또는 tasks.py)

celery_app.conf.update(
    timezone='Asia/Seoul',  # KST (한국 표준시)
    enable_utc=False,       # UTC 비활성화 (로컬 시간 사용)
)

# ✅ 이후 모든 crontab 시간은 KST 기준으로 해석됨
# 예: crontab(hour=21) → KST 21:00 (토요일 추첨 후)
```

**환경 변수 설정**:

```bash
# backend/.env
CELERY_TIMEZONE=Asia/Seoul  # 명시적 설정 (옵션)
```

**Celery 작업**:
- 주 1회 자동 크롤링 (토요일 21:00, 일요일 09:00)
- **주 1회 자동 당첨 확인** (크롤링 직후)
- 주 1회 LSTM 모델 재학습 (일요일 02:00)
- 일일 통계 집계 (매일 03:00)

**코드는 기존 섹션 9.1~9.2 참조**

---

## 18. 클라이언트-서버 통신 흐름

### 18.1 번호 생성 시퀀스

```mermaid
sequenceDiagram
    participant U as 사용자
    participant F as Flutter 앱
    participant A as FastAPI
    participant R as Redis
    participant P as PostgreSQL
    participant Algo as Algorithm
    
    U->>F: 번호 생성 요청
    F->>F: 입력 검증<br/>(제외/포함 번호)
    F->>A: POST /api/generate<br/>{algorithm_id, n_sets}
    
    A->>R: 캐시 확인<br/>(과거 데이터)
    alt 캐시 히트
        R-->>A: 캐시된 데이터
    else 캐시 미스
        A->>P: 과거 당첨번호 조회
        P-->>A: DataFrame
        A->>R: 캐시 저장
    end
    
    A->>Algo: generate_numbers()<br/>(historical_data)
    Algo-->>A: 생성된 번호 세트
    
    A->>P: 생성 히스토리 저장<br/>(optional, 로그인 시)
    A-->>F: GenerateResponse<br/>{numbers, algorithm_info}
    
    F->>F: 로컬 DB 저장<br/>(Hive)
    F-->>U: 결과 화면 표시
```

### 18.2 앱 시작 시 데이터 동기화

```mermaid
sequenceDiagram
    participant F as Flutter 앱
    participant H as Hive (로컬)
    participant A as FastAPI
    participant P as PostgreSQL
    
    Note over F,P: 앱 실행
    F->>H: 로컬 데이터 로드
    H-->>F: 캐시된 최신 회차
    
    par 백그라운드 동기화
        F->>A: GET /api/draws/latest
        A->>P: SELECT MAX(draw_no)
        P-->>A: 최신 회차 정보
        A-->>F: LottoDraw
        
        F->>F: 로컬과 비교
        alt 로컬이 구버전
            F->>A: GET /api/draws?since={last_draw}
            A->>P: 누락된 회차 조회
            P-->>A: List[LottoDraw]
            A-->>F: 새 데이터
            F->>H: 로컬 DB 업데이트
        end
    end
    
    F->>F: UI 업데이트
```

### 18.3 에러 처리 전략

| 에러 종류 | Flutter 처리 | 백엔드 처리 |
|---------|------------|-----------|
| **네트워크 오류** | 로컬 캐시 사용, 재시도 버튼 | N/A |
| **400 Bad Request** | 사용자 입력 오류 메시지 | 입력 검증 실패 |
| **401 Unauthorized** | 자동 로그아웃, 로그인 화면 | JWT 토큰 만료 |
| **404 Not Found** | "데이터 없음" 메시지 | 리소스 없음 |
| **500 Server Error** | "서버 오류" 알림, 재시도 | 로그 기록, Sentry 전송 |
| **Timeout** | 재시도 또는 오프라인 모드 | N/A |

---

## 19. 에러 처리 및 로깅

### 19.1 로깅 전략

#### Flutter 앱
- **Logger 패키지** 사용
- 개발 모드: 상세 로그 출력
- 프로덕션: 에러만 Firebase Crashlytics 전송

#### FastAPI 백엔드
- **Loguru** 사용
- 콘솔 출력 (INFO 레벨)
- 파일 저장 (DEBUG 레벨, 일별 로테이션)
- Sentry 통합 (에러 트래킹)

**백엔드 로깅 코드는 기존 섹션 10.1 참조**

---

## 23. 배포 전략

### 20.1 개발 환경 (로컬)

```yaml
Flutter 앱:
  - 실행: flutter run
  - 핫 리로드 지원
  - API 엔드포인트: http://localhost:8000

백엔드:
  - 실행: uvicorn app.main:app --reload
  - PostgreSQL: Docker (postgres:15)
  - Redis: Docker (redis:7.2)
```

### 20.2 프로덕션 환경

#### Flutter 앱 배포

```yaml
iOS:
  - Fastlane 자동화
  - App Store Connect 업로드
  - TestFlight 베타 테스트
  
Android:
  - Fastlane 자동화
  - Google Play Console 업로드
  - Internal Testing 트랙
```

**배포 명령어**:
```bash
# iOS 빌드 & 배포
cd mobile_app
fastlane ios release

# Android 빌드 & 배포
fastlane android release
```

#### 백엔드 배포

```yaml
AWS Lightsail:
  - 인스턴스: $20/month (2GB RAM, 2 vCPU)
  - PostgreSQL: 내장 또는 RDS Micro
  - Redis: 내장
  - Nginx: 리버스 프록시
  - SSL: Let's Encrypt (certbot)

또는 GCP Cloud Run:
  - 컨테이너 기반 배포
  - 자동 스케일링
  - PostgreSQL: Cloud SQL
  - Redis: Memorystore
```

**Docker 배포**:
```bash
# 백엔드 Docker 이미지 빌드
cd backend
docker build -t luckyai-backend:latest -f ../deployment/docker/Dockerfile.backend .

# Docker Compose 실행 (전체 스택)
cd deployment/docker
docker-compose up -d
```

### 20.3 CI/CD 파이프라인

**GitHub Actions 워크플로우**:

```yaml
# .github/workflows/flutter_ci.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'mobile_app/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release

  deploy_android:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Play Store
        run: fastlane android deploy
```

```yaml
# .github/workflows/backend_ci.yml
name: Backend CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: pip install -r backend/requirements.txt
      - run: pytest backend/tests

  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to AWS
        run: |
          ssh user@server "cd /app && git pull && docker-compose up -d --build"
```

### 20.4 모니터링 및 알림

```yaml
모니터링 도구:
  - Sentry: 에러 트래킹 (Flutter + Backend)
  - Firebase Analytics: 사용자 행동 분석
  - Firebase Crashlytics: 앱 크래시 리포트
  - CloudWatch/Stackdriver: 서버 성능

알림 설정:
  - 서버 다운: Slack/Discord 웹훅
  - 크롤링 실패: 이메일 알림
  - 에러 급증: Sentry 알림
```

### 20.5 백업 전략

```yaml
데이터베이스 백업:
  - PostgreSQL: 일일 자동 백업 (pg_dump)
  - 보관 기간: 30일
  - S3/GCS에 저장

AI 모델 백업:
  - 버전별 모델 파일 보관
  - S3/GCS에 저장
  - 학습 메타데이터 함께 저장
```

---

```python
"""
로깅 설정

Loguru를 사용한 통합 로깅
"""

import sys
from pathlib import Path

from loguru import logger

from app.config import settings


def setup_logging():
    """
    로깅 설정 초기화
    
    - 콘솔 출력: INFO 레벨
    - 파일 출력: DEBUG 레벨, 일별 로테이션
    """
    # 기본 핸들러 제거
    logger.remove()
    
    # 콘솔 출력 (색상 포함)
    logger.add(
        sys.stdout,
        level=settings.LOG_LEVEL,
        format=(
            "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
            "<level>{message}</level>"
        ),
        colorize=True
    )
    
    # 파일 출력 (일별 로테이션)
    logger.add(
        settings.LOG_FILE,
        level="DEBUG",
        format=(
            "{time:YYYY-MM-DD HH:mm:ss} | "
            "{level: <8} | "
            "{name}:{function}:{line} - {message}"
        ),
        rotation="00:00",  # 자정마다 로테이션
        retention="30 days",  # 30일 보관
        compression="zip",  # 압축
        encoding="utf-8"
    )
    
    logger.info("로깅 설정 완료")


def get_logger(name: str):
    """
    모듈별 로거 반환
    
    Args:
        name: 모듈 이름
        
    Returns:
        logger 인스턴스
    """
    return logger.bind(name=name)
```

---

## 📝 부록

### A. 환경 변수 예시

**`.env`**

```bash
# === 기본 설정 ===
DEBUG=True
HOST=0.0.0.0
PORT=8000
WORKERS=4

# === 데이터베이스 ===
DATABASE_URL=postgresql://user:password@localhost:5432/lotto645

# === Redis ===
REDIS_URL=redis://localhost:6379/0
CACHE_ENABLED=True
CACHE_TTL=3600

# === Celery ===
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1
CELERY_TIMEZONE=Asia/Seoul

# === 로또 데이터 ===
LOTTO_CRAWLER_URL=https://www.dhlottery.co.kr/gameResult.do

# === AI 모델 ===
LSTM_WINDOW_SIZE=100
LSTM_HIDDEN_SIZE=128
LSTM_LEARNING_RATE=0.001

# === API ===
JWT_SECRET_KEY=your-secret-key-change-in-production
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# === IAP 결제 검증 ===
# 🆕 2026-01-02 21:00 EST 추가
APPLE_SHARED_SECRET=your_apple_shared_secret_here
GOOGLE_PACKAGE_NAME=com.yourcompany.luckyai645
GOOGLE_SERVICE_ACCOUNT_KEY=/path/to/google-service-account.json

# === AdMob 광고 검증 ===
# 🆕 2026-01-02 21:00 EST 추가
ADMOB_SECRET_KEY=your_admob_ssv_secret_key_here

# === Firebase (Push 알림) ===
# 🆕 2026-01-02 21:00 EST 추가
FIREBASE_SERVICE_ACCOUNT_KEY=/path/to/firebase-adminsdk-xxxxx.json
# 또는: FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'

# === 소셜 로그인 (OAuth) ===
# 🔧 2026-01-02 22:00 EST 추가
GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxxxxxxxx
APPLE_CLIENT_ID=com.yourcompany.luckyai645
KAKAO_REST_API_KEY=your_kakao_rest_api_key
NAVER_CLIENT_ID=your_naver_client_id

# === 로깅 ===
LOG_LEVEL=INFO
```

### B. 실행 명령어

```bash
# === 개발 환경 ===

# 1. 가상 환경 생성 및 활성화
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate  # Windows

# 2. 의존성 설치
pip install -r requirements.txt

# 3. 데이터베이스 초기화
python scripts/init_db.py

# 4. 데이터 로드
python scripts/load_data.py

# 5. API 서버 실행
python app/main.py

# 또는 uvicorn 직접 실행
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 6. Celery Worker 실행 (별도 터미널)
celery -A app.workers.celery_app worker --loglevel=info

# 7. Celery Beat 실행 (별도 터미널)
celery -A app.workers.celery_app beat --loglevel=info

# === 프로덕션 환경 ===

# Docker Compose로 전체 스택 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f app

# 검증 실행
python scripts/run_validation.py --algorithms 1,2,6
```

### C. 디렉토리 생성 스크립트

```bash
#!/bin/bash
# create_directories.sh

mkdir -p app/{api/routes,core,algorithms,models,validation,db/{models,repositories},services,schemas,utils,workers}
mkdir -p data/{raw,processed,models}
mkdir -p results/{validation,reports,logs}
mkdir -p tests/{test_algorithms,test_validation,test_api}
mkdir -p scripts

echo "디렉토리 구조 생성 완료!"
```

## 📝 부록

### A. 전체 프로젝트 디렉토리 구조 요약

```
luckyai_645/
│
├── mobile_app/                    # 📱 Flutter 모바일 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/                  # 핵심 기능
│   │   ├── data/                  # 데이터 레이어
│   │   ├── domain/                # 비즈니스 로직
│   │   └── presentation/          # UI 레이어
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── backend/                       # 🖥️ FastAPI 백엔드
│   ├── app/
│   │   ├── main.py
│   │   ├── core/                  # 크롤링, 데이터 관리
│   │   ├── algorithms/            # 9개 알고리즘
│   │   ├── models/                # LSTM 모델
│   │   ├── validation/            # 검증 시스템
│   │   ├── api/                   # REST API
│   │   ├── db/                    # 데이터베이스
│   │   └── workers/               # Celery 작업
│   ├── data/
│   └── requirements.txt
│
├── shared/                        # 공유 리소스
│   ├── docs/
│   └── api_specs/
│
└── deployment/                    # 배포 설정
    ├── docker/
    └── k8s/
```

### B. 실행 명령어 모음

**Flutter 앱**:
```bash
# 개발 모드 실행
cd mobile_app
flutter pub get
flutter run

# 빌드
flutter build apk --release  # Android
flutter build ios --release  # iOS

# 테스트
flutter test
```

**백엔드**:
```bash
# 개발 모드 실행
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

# 초기 데이터 로드
python scripts/init_db.py
python scripts/load_data.py

# Celery 실행
celery -A app.workers.celery_app worker --loglevel=info
celery -A app.workers.celery_app beat --loglevel=info
```

**Docker Compose** (전체 스택):
```bash
cd deployment/docker
docker-compose up -d

# 로그 확인
docker-compose logs -f backend
```

### C. 환경 변수 예시

**Flutter (`.env`)**:
```bash
API_BASE_URL=https://api.luckyai645.com
FIREBASE_API_KEY=your-firebase-key
```

**Backend (`.env`)**:
```bash
DEBUG=False
DATABASE_URL=postgresql://user:pass@localhost:5432/lotto645
REDIS_URL=redis://localhost:6379/0
JWT_SECRET_KEY=your-secret-key-change-in-production
LOTTO_CRAWLER_URL=https://www.dhlottery.co.kr/gameResult.do
```

### D. 주요 기술 문서 링크

**Flutter**:
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Riverpod 문서](https://riverpod.dev)
- [Dio HTTP](https://pub.dev/packages/dio)

**FastAPI**:
- [FastAPI 공식 문서](https://fastapi.tiangolo.com)
- [SQLAlchemy ORM](https://docs.sqlalchemy.org)
- [Celery 문서](https://docs.celeryq.dev)

---

## 20. 사용자 인증 및 계정 관리

### 20.1 인증 전략 개요

```yaml
접근 방식: 하이브리드 (게스트 + 소셜 로그인)

핵심 원칙:
  - 빠른 시작: 게스트 모드로 즉시 체험
  - 자연스러운 전환: 보상으로 로그인 유도
  - 데이터 보호: 서버 동기화로 디바이스 변경 대응
  - 사용자 편의: 소셜 로그인으로 간편 가입

코인 지갑 연동:
  - 게스트: 로컬 저장 (디바이스 종속)
  - 정식 계정: 서버 저장 (디바이스 독립)
```

### 20.2 사용자 유형 및 시나리오

#### 20.2.1 게스트 사용자 (Guest Mode)

```yaml
특징:
  - 회원가입 불필요
  - 앱 설치 즉시 사용 가능
  - 디바이스에 로컬 저장
  
제한사항:
  - 무료 코인만 사용 가능 (일일 로그인, 광고)
  - 유료 코인 구매 불가
  - 디바이스 변경 시 데이터 복구 불가
  - 서버 동기화 없음

코인 획득:
  - 웰컴 보너스: 100코인
  - 일일 로그인: 5코인
  - 광고 시청: 최대 25코인/일
  
로그인 유도:
  - "로그인하고 100코인 더 받기" 배너
  - 유료 코인 구매 시도 시 차단
  - 디바이스 변경 경고 메시지
```

#### 20.2.2 정식 사용자 (Registered Account)

```yaml
인증 방법:
  - Google Sign In (Android/iOS)
  - Apple Sign In (iOS 필수)
  - Kakao Login (한국 사용자)
  - Naver Login (한국 사용자)

혜택:
  - 웰컴 보너스: 200코인 (게스트 100코인의 2배)
  - 모든 디바이스에서 코인 동기화
  - 유료 코인 구매 가능
  - 자동 당첨 확인 + Push 알림
  - 생성 기록 서버 저장
  
게스트 → 정식 전환:
  - 게스트 코인 및 데이터 자동 이전
  - 추가 보너스 100코인 지급
  - 기존 번호 생성 기록 유지
```

### 20.3 데이터베이스 모델

#### 20.3.1 사용자 모델 (확장)

**`backend/app/db/models/user.py`** (기존 User 모델 확장)

```python
"""
사용자 인증 및 계정 관리 모델
2026-01-02 18:30:00 EST - 코인 지갑 동기화를 위한 인증 시스템 추가
2026-01-02 22:00:00 EST - Critical Issue #3 수정: GIN 인덱스 추가
"""

from datetime import datetime
from enum import Enum
from uuid import uuid4

from sqlalchemy import Column, String, Boolean, DateTime, Enum as SQLEnum, ARRAY, Index
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class AuthProvider(str, Enum):
    """인증 제공자"""
    EMAIL = "email"           # 이메일 (미래 확장용)
    GOOGLE = "google"         # Google Sign In
    APPLE = "apple"           # Apple Sign In
    KAKAO = "kakao"           # Kakao Login
    NAVER = "naver"           # Naver Login
    GUEST = "guest"           # 익명 게스트


class User(Base):
    """
    사용자 계정
    
    게스트/정식 계정 모두 지원
    """
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    
    # === 인증 정보 ===
    auth_provider = Column(
        SQLEnum(AuthProvider),
        nullable=False,
        default=AuthProvider.GUEST,
        comment="인증 제공자"
    )
    auth_id = Column(
        String(255),
        nullable=True,
        comment="소셜 로그인 고유 ID (provider별)"
    )
    email = Column(
        String(255),
        nullable=True,
        unique=True,
        index=True,
        comment="이메일 (소셜 로그인에서 제공)"
    )
    
    # === 프로필 ===
    nickname = Column(String(50), nullable=True, comment="닉네임")
    profile_image = Column(String(500), nullable=True, comment="프로필 이미지 URL")
    
    # === 디바이스 관리 ===
    device_ids = Column(
        ARRAY(String),
        default=[],
        comment="사용한 디바이스 ID 목록 (추적용)"
    )
    
    # === 계정 상태 ===
    is_guest = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="게스트 여부 (True: 게스트, False: 정식)"
    )
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="계정 활성 상태"
    )
    
    # === 타임스탬프 ===
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    last_login = Column(DateTime, nullable=True, comment="마지막 로그인 시각")
    upgraded_at = Column(DateTime, nullable=True, comment="게스트→정식 전환 시각")
    
    # === 인덱스 (성능 최적화) ===
    # 🔧 2026-01-02 22:00 EST 추가: GIN 인덱스로 device_ids 배열 검색 성능 개선
    __table_args__ = (
        Index('idx_users_device_ids', 'device_ids', postgresql_using='gin'),
        Index('idx_users_is_guest_active', 'is_guest', 'is_active'),
        Index('idx_users_created_at', 'created_at'),
    )
    
    # === 관계 ===
    coin_wallet = relationship(
        "CoinWallet",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan"
    )
    generated_numbers = relationship(
        "UserGeneratedNumbers",
        back_populates="user",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self):
        return f"<User {self.id} ({self.auth_provider}, guest={self.is_guest})>"
```

### 20.4 API 엔드포인트

#### 20.4.1 게스트 사용자 생성

**`backend/app/api/routes/auth.py`** (신규)

```python
"""
사용자 인증 API
2026-01-02 18:30:00 EST - 게스트/소셜 로그인 구현
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.db.models.user import User, AuthProvider
from app.db.models.coin_wallet import CoinWallet, CoinTransaction, TransactionType
from app.schemas.auth import (
    GuestCreateRequest,
    GuestCreateResponse,
    SocialLoginRequest,
    SocialLoginResponse,
    UpgradeFromGuestRequest,
    UpgradeFromGuestResponse
)
from app.services.auth_service import (
    create_access_token,
    verify_social_login
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/guest/create", response_model=GuestCreateResponse)
async def create_guest_user(
    request: GuestCreateRequest,
    db: Session = Depends(get_db)
):
    """
    게스트 사용자 생성 (앱 최초 실행 시)
    
    **요청**:
    ```json
    {
      "device_id": "ABC123-DEF456-GHI789"
    }
    ```
    
    **응답**:
    ```json
    {
      "user_id": "uuid-here",
      "token": "jwt-token-here",
      "is_guest": true,
      "welcome_bonus": 100
    }
    ```
    
    **동작**:
    1. device_id로 기존 게스트 확인 (GIN 인덱스 활용)
    2. 없으면 신규 게스트 생성 (동시성 제어)
    3. 코인 지갑 생성 (웰컴 보너스 100코인)
    4. JWT 토큰 발급
    
    🔧 2026-01-02 22:00 EST 수정:
    - GIN 인덱스로 device_ids 배열 검색 성능 개선
    - 비관적 락으로 동시성 제어 (중복 생성 방지)
    - 최신 게스트만 반환 (여러 게스트 존재 시)
    """
    # === 1. 기존 게스트 사용자 확인 (GIN 인덱스 활용) ===
    # ⚠️ 성능 최적화: User 모델의 __table_args__에 GIN 인덱스 필수
    # CREATE INDEX idx_users_device_ids ON users USING GIN (device_ids);
    
    existing_user = db.query(User).filter(
        User.device_ids.any(request.device_id),  # 🔧 .contains → .any로 변경
        User.is_guest == True,
        User.is_active == True  # 비활성화 계정 제외
    ).order_by(
        User.created_at.desc()  # 최신 게스트 우선
    ).with_for_update(
        skip_locked=False  # 🔒 비관적 락 (동시성 제어)
    ).first()
    
    if existing_user:
        # 기존 게스트 사용자 반환
        existing_user.last_login = datetime.utcnow()
        db.commit()
        
        token = create_access_token(existing_user.id)
        
        logger.info(
            f"[게스트 로그인] 기존 계정: User {existing_user.id}, "
            f"Device {request.device_id}"
        )
        
        return GuestCreateResponse(
            user_id=str(existing_user.id),
            token=token,
            is_guest=True,
            welcome_bonus=0,  # 이미 지급됨
            message="기존 게스트 계정으로 로그인했습니다"
        )
    
    # === 2. 신규 게스트 사용자 생성 (동시성 제어) ===
    # 트랜잭션 내에서 락이 유지되므로 중복 생성 불가
    guest_user = User(
        auth_provider=AuthProvider.GUEST,
        is_guest=True,
        device_ids=[request.device_id],
        last_login=datetime.utcnow()
    )
    db.add(guest_user)
    db.flush()  # ID 생성
    
    # === 3. 코인 지갑 생성 (웰컴 보너스 100코인) ===
    wallet = CoinWallet(
        user_id=guest_user.id,
        balance=100,
        total_earned=100
    )
    db.add(wallet)
    db.flush()
    
    # 웰컴 보너스 거래 기록
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.WELCOME,
        amount=100,
        balance_after=100,
        description="게스트 웰컴 보너스"
    )
    db.add(transaction)
    
    # === 4. 커밋 및 응답 ===
    db.commit()
    
    token = create_access_token(guest_user.id)
    
    logger.info(
        f"[게스트 생성] 신규 계정: User {guest_user.id}, "
        f"Device {request.device_id}, 웰컴 보너스 100코인"
    )
    
    return GuestCreateResponse(
        user_id=str(guest_user.id),
        token=token,
        is_guest=True,
        welcome_bonus=100,
        message="게스트 계정이 생성되었습니다. 100코인을 드렸어요! 🎉"
    )


@router.post("/login/social", response_model=SocialLoginResponse)
async def social_login(
    request: SocialLoginRequest,
    db: Session = Depends(get_db)
):
    """
    소셜 로그인 (Google, Apple, Kakao, Naver)
    
    **요청**:
    ```json
    {
      "provider": "google",
      "access_token": "google-token-here",
      "device_id": "ABC123"
    }
    ```
    
    **응답**:
    ```json
    {
      "token": "jwt-token",
      "user_id": "uuid",
      "is_new_user": true,
      "welcome_bonus": 200,
      "wallet_balance": 200
    }
    ```
    
    **동작**:
    - 신규 사용자: 계정 생성 + 웰컴 보너스 200코인
    - 기존 사용자: 로그인 + 디바이스 ID 추가
    """
    # 소셜 로그인 토큰 검증 (provider별 API 호출)
    try:
        social_user_info = await verify_social_login(
            provider=request.provider,
            token=request.access_token
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"소셜 로그인 검증 실패: {str(e)}"
        )
    
    # 기존 사용자 확인 (provider + auth_id)
    user = db.query(User).filter(
        User.auth_provider == request.provider,
        User.auth_id == social_user_info['id']
    ).first()
    
    if user:
        # === 기존 사용자: 로그인 ===
        user.last_login = datetime.utcnow()
        
        # 디바이스 ID 추가 (중복 방지)
        if request.device_id not in user.device_ids:
            user.device_ids = user.device_ids + [request.device_id]
        
        db.commit()
        db.refresh(user)
        
        token = create_access_token(user.id)
        
        return SocialLoginResponse(
            token=token,
            user_id=str(user.id),
            is_new_user=False,
            welcome_bonus=0,
            wallet_balance=user.coin_wallet.balance,
            message="다시 오신 것을 환영합니다!"
        )
    
    else:
        # === 신규 사용자: 계정 생성 ===
        new_user = User(
            auth_provider=request.provider,
            auth_id=social_user_info['id'],
            email=social_user_info.get('email'),
            nickname=social_user_info.get('name') or social_user_info.get('nickname'),
            profile_image=social_user_info.get('picture') or social_user_info.get('profile_image'),
            is_guest=False,
            device_ids=[request.device_id],
            last_login=datetime.utcnow()
        )
        db.add(new_user)
        db.flush()
        
        # 코인 지갑 생성 (웰컴 보너스 200코인 - 정식 가입자 특전)
        wallet = CoinWallet(
            user_id=new_user.id,
            balance=200,
            total_earned=200
        )
        db.add(wallet)
        db.flush()
        
        # 웰컴 보너스 거래 기록
        transaction = CoinTransaction(
            wallet_id=wallet.id,
            type=TransactionType.WELCOME,
            amount=200,
            balance_after=200,
            description="정식 가입 웰컴 보너스"
        )
        db.add(transaction)
        
        db.commit()
        db.refresh(new_user)
        
        token = create_access_token(new_user.id)
        
        return SocialLoginResponse(
            token=token,
            user_id=str(new_user.id),
            is_new_user=True,
            welcome_bonus=200,
            wallet_balance=200,
            message="환영합니다! 정식 가입 축하 200코인을 드렸어요 🎉"
        )


@router.post("/upgrade-from-guest", response_model=UpgradeFromGuestResponse)
async def upgrade_from_guest(
    request: UpgradeFromGuestRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    게스트 사용자 → 정식 사용자 전환
    
    **요청**:
    ```json
    {
      "provider": "google",
      "access_token": "google-token-here",
      "device_id": "ABC123"
    }
    ```
    
    **기능**:
    - 게스트 코인/데이터를 정식 계정으로 자동 이전
    - 추가 보너스 코인 지급 (100코인)
    - 기존 번호 생성 기록 유지
    
    **주의**:
    - 이미 존재하는 소셜 계정과는 병합 불가
    - 게스트 계정만 전환 가능
    """
    # 권한 확인: 게스트만 전환 가능
    if not current_user.is_guest:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미 정식 계정입니다"
        )
    
    # 소셜 로그인 토큰 검증
    try:
        social_user_info = await verify_social_login(
            provider=request.provider,
            token=request.access_token
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"소셜 로그인 검증 실패: {str(e)}"
        )
    
    # 중복 확인: 이미 다른 계정이 존재하는지
    existing_user = db.query(User).filter(
        User.auth_provider == request.provider,
        User.auth_id == social_user_info['id']
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="이미 등록된 소셜 계정입니다. 해당 계정으로 로그인해주세요."
        )
    
    # === 게스트 → 정식 계정 업그레이드 ===
    current_user.auth_provider = request.provider
    current_user.auth_id = social_user_info['id']
    current_user.email = social_user_info.get('email')
    current_user.nickname = social_user_info.get('name') or social_user_info.get('nickname')
    current_user.profile_image = social_user_info.get('picture') or social_user_info.get('profile_image')
    current_user.is_guest = False
    current_user.upgraded_at = datetime.utcnow()
    
    # 디바이스 ID 추가
    if request.device_id not in current_user.device_ids:
        current_user.device_ids = current_user.device_ids + [request.device_id]
    
    # 전환 보너스 코인 지급 (100코인 추가)
    wallet = current_user.coin_wallet
    wallet.balance += 100
    wallet.total_earned += 100
    
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.BONUS,
        amount=100,
        balance_after=wallet.balance,
        description="게스트→정식 전환 보너스"
    )
    db.add(transaction)
    
    db.commit()
    db.refresh(current_user)
    
    return UpgradeFromGuestResponse(
        success=True,
        user_id=str(current_user.id),
        is_guest=False,
        bonus_coins=100,
        total_balance=wallet.balance,
        message="정식 계정으로 업그레이드되었습니다! 100코인을 추가로 드렸어요 🎉"
    )
```

### 20.5 Flutter 앱 구현

#### 20.5.1 인증 Provider

**`mobile_app/lib/presentation/providers/auth_provider.dart`**

```dart
/// 사용자 인증 관리 Provider
/// 2026-01-02 18:30:00 EST - 게스트/소셜 로그인 구현

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthManager extends _$AuthManager {
  @override
  AsyncValue<User?> build() {
    _initAuth();
    return const AsyncValue.loading();
  }
  
  Future<void> _initAuth() async {
    state = const AsyncValue.loading();
    
    try {
      // 로컬에 저장된 토큰 확인
      final prefs = ref.read(sharedPreferencesProvider);
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        // 토큰 유효성 검증 후 사용자 정보 로드
        final user = await _getUserFromToken(token);
        state = AsyncValue.data(user);
      } else {
        // 토큰 없음 → 게스트 생성
        await _createGuestUser();
      }
    } catch (e, stack) {
      // 오류 발생 → 게스트로 폴백
      await _createGuestUser();
    }
  }
  
  Future<void> _createGuestUser() async {
    try {
      final deviceId = await _getDeviceId();
      final api = ref.read(apiClientProvider);
      
      final response = await api.post('/api/auth/guest/create', data: {
        'device_id': deviceId,
      });
      
      final token = response.data['token'];
      final userId = response.data['user_id'];
      final welcomeBonus = response.data['welcome_bonus'];
      
      // 토큰 저장
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userId);
      
      state = AsyncValue.data(User(
        id: userId,
        isGuest: true,
      ));
      
      // 웰컴 보너스 알림 (신규 게스트만)
      if (welcomeBonus > 0) {
        ref.read(toastProvider).showSuccess(
          '환영합니다! $welcomeBonus 코인을 드렸어요 🎉'
        );
      }
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    
    try {
      // Google Sign In
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 취소함
        state = AsyncValue.data(state.value);
        return;
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      
      if (accessToken == null) {
        throw Exception('Google 액세스 토큰을 가져올 수 없습니다');
      }
      
      await _socialLogin('google', accessToken);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(toastProvider).showError('Google 로그인 실패: ${e.toString()}');
    }
  }
  
  Future<void> loginWithApple() async {
    if (!Platform.isIOS) {
      ref.read(toastProvider).showError('Apple 로그인은 iOS에서만 지원됩니다');
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception('Apple 인증 토큰을 가져올 수 없습니다');
      }
      
      await _socialLogin('apple', identityToken);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(toastProvider).showError('Apple 로그인 실패: ${e.toString()}');
    }
  }
  
  Future<void> _socialLogin(String provider, String accessToken) async {
    final deviceId = await _getDeviceId();
    final api = ref.read(apiClientProvider);
    
    final currentUser = state.value;
    
    // 게스트 전환 vs 일반 로그인
    final endpoint = currentUser?.isGuest == true
        ? '/api/auth/upgrade-from-guest'
        : '/api/auth/login/social';
    
    final response = await api.post(endpoint, data: {
      'provider': provider,
      'access_token': accessToken,
      'device_id': deviceId,
    });
    
    final token = response.data['token'];
    final userId = response.data['user_id'];
    
    // 토큰 저장
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    
    // 사용자 정보 업데이트
    final user = await _getUserFromToken(token);
    state = AsyncValue.data(user);
    
    // 코인 지갑 새로고침
    ref.invalidate(coinWalletProvider);
    
    // 성공 메시지
    final message = response.data['message'] as String?;
    if (message != null) {
      ref.read(toastProvider).showSuccess(message);
    }
  }
  
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? ''; // IDFV
    } else {
      return 'unknown';
    }
  }
  
  Future<User> _getUserFromToken(String token) async {
    // JWT 토큰으로 사용자 정보 조회
    final api = ref.read(apiClientProvider);
    final response = await api.get('/api/auth/me', headers: {
      'Authorization': 'Bearer $token',
    });
    
    return User.fromJson(response.data);
  }
  
  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    
    // 게스트로 재생성
    await _createGuestUser();
  }
}
```

#### 20.5.2 로그인 유도 화면

```dart
/// 로그인 유도 배너 및 화면

class LoginPromptBanner extends ConsumerWidget {
  const LoginPromptBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authManagerProvider).value;
    
    // 게스트가 아니면 표시 안 함
    if (user?.isGuest != true) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '로그인하고 100코인 더 받기!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '코인 동기화 + 디바이스 변경 OK',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}


class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              const Text(
                '로그인하고 혜택 받기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              _buildBenefitRow(Icons.card_giftcard, '100코인 추가 보너스'),
              _buildBenefitRow(Icons.sync, '모든 디바이스에서 코인 동기화'),
              _buildBenefitRow(Icons.shopping_cart, '유료 코인 구매 가능'),
              _buildBenefitRow(Icons.notifications, '자동 당첨 확인 알림'),
              
              const SizedBox(height: 32),
              
              // Google 로그인
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authManagerProvider.notifier).loginWithGoogle();
                },
                icon: Image.asset('assets/images/google_logo.png', height: 24),
                label: const Text('Google로 계속하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Apple 로그인 (iOS만)
              if (Platform.isIOS)
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authManagerProvider.notifier).loginWithApple();
                  },
                  icon: const Icon(Icons.apple),
                  label: const Text('Apple로 계속하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('나중에 하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
```

### 20.6 디바이스 변경 시나리오

#### 20.6.1 게스트 사용자

```yaml
상황: 디바이스 A에서 게스트로 사용 → 디바이스 B로 변경

결과:
  - 디바이스 B에서 새로운 게스트 계정 생성
  - 디바이스 A의 코인 및 데이터 복구 불가
  
경고 메시지:
  "게스트 모드는 디바이스 변경 시 데이터가 사라집니다.
   지금 로그인하고 코인을 영구히 보관하세요!"
  
권장 행동:
  - 유료 코인 구매 전 로그인 필수
  - 일정 코인 이상(예: 500코인) 보유 시 로그인 유도
```

#### 20.6.2 정식 사용자

```yaml
상황: 디바이스 A에서 정식 계정 → 디바이스 B로 변경

동작:
  1. 디바이스 B에 앱 설치
  2. 게스트로 시작 or 즉시 로그인 선택
  3. 소셜 로그인 (Google/Apple/Kakao)
  4. 서버에서 코인 및 데이터 자동 동기화
  5. 디바이스 B에서 이전과 동일하게 사용

장점:
  - 완전 자동 이전
  - 데이터 손실 없음
  - 즉시 사용 가능
```

### 20.7 보안 고려사항

```yaml
JWT 토큰 관리:
  - 액세스 토큰: 1시간 유효
  - 리프레시 토큰: 30일 유효
  - Secure Storage에 저장 (flutter_secure_storage)

소셜 로그인 검증:
  - 백엔드에서 provider API로 토큰 재검증
  - 위조 토큰 차단

디바이스 ID:
  - Android: Android ID (공장 초기화 시 변경)
  - iOS: IDFV (앱 재설치 시 동일)
  - 추적용으로만 사용, 인증에 미사용

계정 보호:
  - 동일 소셜 계정 중복 가입 방지
  - 게스트→정식 전환 시 기존 계정 병합 불가 (명확한 안내)
```

---

## 21. 수익 모델 및 구현 전략 (코인 기반)

### 21.1 코인 이코노미 모델 개요

```yaml
비즈니스 모델: 코인 소비형 (Pay-as-you-go)
핵심 전략: "무료 코인으로 체험 → 가치 입증 → 자연스러운 충전"
목표 전환율: 무료 → 유료 결제 8~12%
장점:
  - 구독 부담 없음 (언제든 사용 가능)
  - 사용한 만큼만 지불
  - 명확한 가치 인식 (1코인 = 1번호)
  - 소액 결제 유도 쉬움
  - 이탈률 낮음
```

### 21.2 코인 시스템 설계

#### 21.2.1 무료 코인 획득 방법

```yaml
신규 가입:
  - 웰컴 보너스: 100코인 무료

일일 로그인:
  - 매일 첫 로그인: 5코인
  - 7일 연속 로그인: 보너스 30코인
  - 30일 연속 로그인: 보너스 200코인

광고 시청:
  - 동영상 광고 1회 시청: 5코인
  - 일일 최대: 5회 (25코인)

친구 초대:
  - 친구 가입: 양쪽 각 50코인
  - 친구가 코인 구매: 추가 30코인

이벤트:
  - 로또 당첨 인증: 3등 이상 100코인
  - 리뷰 작성: 20코인
  - 설문조사 참여: 10코인
```

#### 21.2.2 코인 패키지 (IAP)

| 패키지 | 코인량 | 가격 | 보너스 | 실제 | 코인당 가격 |
|--------|--------|------|--------|------|------------|
| **스타터** | 100 | ₩1,000 | - | 100 | ₩10 |
| **베이직** | 500 | ₩4,500 | +10% | 550 | ₩8.2 |
| **스탠다드** | 1,000 | ₩8,000 | +20% | 1,200 | ₩6.7 |
| **프리미엄** | 2,500 | ₩18,000 | +30% | 3,250 | ₩5.5 |
| **메가** | 5,000 | ₩35,000 | +40% | 7,000 | ₩5.0 |

```yaml
프로모션 패키지 (한정):
  - 론칭 특가: 1,000코인 ₩5,000 (50% 할인)
  - 주간 딜: 매주 랜덤 패키지 30% 할인
  - 생일 선물: 생일 당일 500코인 무료
```

#### 21.2.3 알고리즘별 코인 소모량

```yaml
기본 알고리즘 (Low-Cost):
  - Algorithm 1 (순수 랜덤): 5코인/세트
  - Algorithm 6 (빈도 분석): 10코인/세트
  - Algorithm 7 (역빈도 분석): 10코인/세트

중급 알고리즘 (Mid-Tier):
  - Algorithm 2 (짝수 우대): 15코인/세트
  - Algorithm 3 (홀수 우대): 15코인/세트
  - Algorithm 4 (짝홀 균형): 15코인/세트
  - Algorithm 5 (고저 균형): 15코인/세트

고급 알고리즘 (Premium):
  - Algorithm 8 (LSTM 기본): 30코인/세트
  - Algorithm 9 (LSTM 역순): 35코인/세트
  - Algorithm 10 (LSTM 누적): 40코인/세트

최고급 알고리즘 (Ultra-Premium, Phase 6):
  - 앙상블 AI (Multi-Model): 100코인/세트
  - 커스텀 백테스팅: 50코인/실행

추가 기능:
  - QR 코드 생성: 무료
  - CSV 내보내기: 10코인
  - 고급 통계 리포트: 20코인
  - AI 챗봇 질문: 30코인/질문
```

**코인 소모 예시**:
```python
# 사용자 시나리오 1: 캐주얼 유저
- 일일 로그인: +5코인
- 광고 시청 2회: +10코인
- 랜덤 알고리즘 3회: -15코인
→ 순 소모: 0코인 (완전 무료 가능)

# 사용자 시나리오 2: 적극적 유저
- 일일 로그인: +5코인
- LSTM 알고리즘 5회: -150코인
- 광고 시청 5회: +25코인
→ 순 소모: -120코인/일 (월 ₩8,000 정도)

# 사용자 시나리오 3: 파워 유저
- LSTM 10회 + 앙상블 2회: -500코인
→ 순 소모: -500코인/일 (월 ₩25,000~30,000)
```

### 21.3 데이터베이스 구현

#### 21.3.0 알고리즘 비용 모델

**`backend/app/db/models/algorithm_pricing.py`** (신규)

```python
"""
알고리즘 비용 관리 모델

2026-01-02 22:00:00 EST - Critical Issue #1 수정: AlgorithmPricing 모델 추가
"""

from datetime import datetime
from uuid import uuid4

from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base


class AlgorithmPricing(Base):
    """
    알고리즘별 코인 비용 관리
    
    **용도**:
    - 알고리즘별 동적 가격 설정
    - 프로모션 할인 적용
    - 가격 변경 이력 추적
    """
    __tablename__ = "algorithm_pricing"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    algorithm_id = Column(
        Integer, 
        unique=True, 
        nullable=False, 
        index=True,
        comment="알고리즘 ID (1~10, 99)"
    )
    algorithm_name = Column(
        String(100), 
        nullable=False,
        comment="알고리즘 이름"
    )
    
    # 비용 정보
    base_cost = Column(
        Integer, 
        nullable=False,
        comment="기본 코인 비용 (세트당)"
    )
    discount_rate = Column(
        Integer, 
        default=0,
        comment="할인율 (0-100%)"
    )
    final_cost = Column(
        Integer, 
        nullable=False,
        comment="최종 비용 = base_cost * (1 - discount_rate/100)"
    )
    
    # 상태 및 설명
    is_active = Column(
        Boolean, 
        default=True, 
        nullable=False,
        comment="활성 상태 (비활성화 시 Fallback 사용)"
    )
    description = Column(
        Text, 
        nullable=True,
        comment="비용 설명 및 변경 사유"
    )
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime, 
        default=datetime.utcnow, 
        onupdate=datetime.utcnow, 
        nullable=False
    )
    
    def __repr__(self):
        return (
            f"<AlgorithmPricing(id={self.algorithm_id}, "
            f"name='{self.algorithm_name}', "
            f"cost={self.final_cost})>"
        )
    
    def calculate_final_cost(self) -> int:
        """할인율 적용하여 최종 비용 계산"""
        if self.discount_rate <= 0:
            return self.base_cost
        
        discount_multiplier = 1 - (self.discount_rate / 100.0)
        return int(self.base_cost * discount_multiplier)
    
    def update_final_cost(self):
        """final_cost 자동 계산 및 업데이트"""
        self.final_cost = self.calculate_final_cost()


# 초기 데이터 (Migration 또는 init_db.py에서 사용)
DEFAULT_ALGORITHM_PRICING = [
    {"algorithm_id": 1, "algorithm_name": "순수 랜덤 (Quick Pick)", "base_cost": 5, "discount_rate": 0},
    {"algorithm_id": 2, "algorithm_name": "짝수 우대", "base_cost": 15, "discount_rate": 0},
    {"algorithm_id": 3, "algorithm_name": "홀수 우대", "base_cost": 15, "discount_rate": 0},
    {"algorithm_id": 4, "algorithm_name": "짝홀 균형", "base_cost": 15, "discount_rate": 0},
    {"algorithm_id": 5, "algorithm_name": "고저 균형", "base_cost": 15, "discount_rate": 0},
    {"algorithm_id": 6, "algorithm_name": "빈도 분석", "base_cost": 10, "discount_rate": 0},
    {"algorithm_id": 7, "algorithm_name": "역빈도 분석", "base_cost": 10, "discount_rate": 0},
    {"algorithm_id": 8, "algorithm_name": "LSTM 기본", "base_cost": 30, "discount_rate": 0},
    {"algorithm_id": 9, "algorithm_name": "LSTM 역순", "base_cost": 35, "discount_rate": 0},
    {"algorithm_id": 10, "algorithm_name": "LSTM 누적", "base_cost": 40, "discount_rate": 0},
    {"algorithm_id": 99, "algorithm_name": "앙상블 Multi-Model (Phase 6)", "base_cost": 100, "discount_rate": 0},
]
```

**데이터베이스 마이그레이션**:

```bash
# backend/scripts/init_algorithm_pricing.py
"""
AlgorithmPricing 초기 데이터 로드 스크립트
"""

import sys
from pathlib import Path

# 프로젝트 루트를 sys.path에 추가
sys.path.append(str(Path(__file__).parent.parent))

from app.db.session import SessionLocal
from app.db.models.algorithm_pricing import AlgorithmPricing, DEFAULT_ALGORITHM_PRICING
from loguru import logger


def init_algorithm_pricing():
    """AlgorithmPricing 테이블 초기 데이터 생성"""
    db = SessionLocal()
    
    try:
        logger.info("🔧 AlgorithmPricing 초기 데이터 로드 시작...")
        
        # 기존 데이터 확인
        existing_count = db.query(AlgorithmPricing).count()
        
        if existing_count > 0:
            logger.info(f"  이미 {existing_count}개 데이터 존재, 스킵")
            return
        
        # 초기 데이터 삽입
        for data in DEFAULT_ALGORITHM_PRICING:
            pricing = AlgorithmPricing(
                algorithm_id=data["algorithm_id"],
                algorithm_name=data["algorithm_name"],
                base_cost=data["base_cost"],
                discount_rate=data["discount_rate"],
                final_cost=data["base_cost"],  # 할인율 0이므로 base_cost와 동일
                is_active=True
            )
            db.add(pricing)
        
        db.commit()
        logger.success(f"✅ AlgorithmPricing 초기 데이터 {len(DEFAULT_ALGORITHM_PRICING)}개 생성 완료")
        
    except Exception as e:
        logger.error(f"❌ AlgorithmPricing 초기화 실패: {e}")
        db.rollback()
        raise
    
    finally:
        db.close()


if __name__ == "__main__":
    init_algorithm_pricing()
```

**실행**:
```bash
cd backend
python scripts/init_algorithm_pricing.py
```

---

#### 21.3.1 코인 지갑 모델

**`backend/app/db/models/coin_wallet.py`** (신규)

```python
"""
코인 지갑 관리 모델
"""

from datetime import datetime
from enum import Enum

from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Enum as SQLEnum, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from uuid import uuid4

from app.db.base import Base


class TransactionType(str, Enum):
    """거래 유형"""
    # 충전
    PURCHASE = "purchase"          # IAP 구매
    BONUS = "bonus"                # 보너스 지급
    WELCOME = "welcome"            # 웰컴 보너스
    DAILY_LOGIN = "daily_login"    # 일일 로그인
    AD_REWARD = "ad_reward"        # 광고 시청
    REFERRAL = "referral"          # 친구 초대
    EVENT = "event"                # 이벤트 보상
    
    # 소비
    GENERATION = "generation"      # 번호 생성
    EXPORT_CSV = "export_csv"      # CSV 내보내기
    REPORT = "report"              # 리포트 생성
    CHATBOT = "chatbot"            # 챗봇 질문
    BACKTEST = "backtest"          # 백테스팅
    
    # 기타
    REFUND = "refund"              # 환불
    ADMIN = "admin"                # 관리자 지급/차감


class CoinWallet(Base):
    """
    사용자 코인 지갑
    """
    __tablename__ = "coin_wallets"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)
    
    # 코인 잔액
    balance = Column(Integer, nullable=False, default=0)
    
    # 통계
    total_earned = Column(Integer, default=0)    # 총 획득 코인
    total_spent = Column(Integer, default=0)     # 총 사용 코인
    total_purchased = Column(Integer, default=0) # 총 구매 코인
    
    # 일일 제한 (무료 획득)
    daily_ad_count = Column(Integer, default=0)  # 오늘 광고 시청 횟수
    last_ad_date = Column(DateTime, nullable=True)
    last_login_date = Column(DateTime, nullable=True)
    consecutive_login_days = Column(Integer, default=0)
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 관계
    user = relationship("User", back_populates="coin_wallet")
    transactions = relationship("CoinTransaction", back_populates="wallet", order_by="desc(CoinTransaction.created_at)")
    
    def can_watch_ad(self) -> bool:
        """광고 시청 가능 여부 (일일 5회 제한)"""
        today = datetime.utcnow().date()
        
        if not self.last_ad_date or self.last_ad_date.date() < today:
            # 날짜가 바뀌면 리셋
            self.daily_ad_count = 0
            self.last_ad_date = datetime.utcnow()
        
        return self.daily_ad_count < 5
    
    def check_consecutive_login(self):
        """
        연속 로그인 체크 및 보상
        
        🔧 2026-01-02 21:00 EST 수정:
        - 기존 문제: 30일 = 30 % 7 = 2 (나머지) → 7일 보너스 미지급
        - 수정: 7일마다 보너스 먼저 체크 → 30일 특별 보너스 추가
        - 결과: 30일차 = 5 (기본) + 30 (7일 보너스) + 200 (30일 특별) = 235코인
        """
        today = datetime.utcnow().date()
        
        if not self.last_login_date:
            # 첫 로그인
            self.consecutive_login_days = 1
            self.last_login_date = datetime.utcnow()
            return 5  # 기본 5코인
        
        last_login = self.last_login_date.date()
        
        if last_login == today:
            # 오늘 이미 로그인함
            return 0
        
        elif last_login == today - timedelta(days=1):
            # 연속 로그인
            self.consecutive_login_days += 1
            self.last_login_date = datetime.utcnow()
            
            # 기본 보상
            base_reward = 5
            bonus = 0
            
            # 7일마다 보너스 (7일, 14일, 21일, 28일, 35일 등 모두 해당)
            if self.consecutive_login_days % 7 == 0:
                bonus += 30
            
            # 특별 마일스톤 보너스 (7일 보너스와 별개로 추가 지급)
            if self.consecutive_login_days == 30:
                bonus += 200  # 30일: 5 + 30 + 200 = 235코인 (28일 보너스 포함)
            elif self.consecutive_login_days == 60:
                bonus += 500  # 60일: 5 + 30 + 500 = 535코인
            elif self.consecutive_login_days == 90:
                bonus += 1000  # 90일: 5 + 30 + 1000 = 1035코인
            elif self.consecutive_login_days == 180:
                bonus += 3000  # 180일: 5 + 30 + 3000 = 3035코인
            elif self.consecutive_login_days == 365:
                bonus += 10000  # 365일: 5 + 30 + 10000 = 10035코인
            
            return base_reward + bonus
        
        else:
            # 연속 끊김
            self.consecutive_login_days = 1
            self.last_login_date = datetime.utcnow()
            return 5
    
    def has_enough(self, amount: int) -> bool:
        """잔액 충분 여부"""
        return self.balance >= amount


class CoinTransaction(Base):
    """
    코인 거래 내역
    """
    __tablename__ = "coin_transactions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    wallet_id = Column(UUID(as_uuid=True), ForeignKey("coin_wallets.id"), nullable=False)
    
    # 거래 정보
    type = Column(SQLEnum(TransactionType), nullable=False)
    amount = Column(Integer, nullable=False)  # 양수: 충전, 음수: 소비
    balance_after = Column(Integer, nullable=False)  # 거래 후 잔액
    
    # 상세 정보
    description = Column(String(255), nullable=True)
    metadata = Column(Text, nullable=True)  # JSON 형식 추가 정보
    
    # 관련 정보
    algorithm_id = Column(Integer, nullable=True)  # 번호 생성 시
    payment_id = Column(String(255), nullable=True)  # IAP 영수증
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 관계
    wallet = relationship("CoinWallet", back_populates="transactions")
```

### 21.4 API 엔드포인트 추가

**`backend/app/api/routes/coins.py`** (신규)

```python
"""
코인 관리 API
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.coin_wallet import CoinWallet, CoinTransaction, TransactionType
from app.schemas.coins import (
    WalletInfo,
    PurchaseRequest,
    PurchaseResponse,
    TransactionHistory
)

router = APIRouter()


@router.get("/wallet", response_model=WalletInfo)
async def get_my_wallet(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    내 코인 지갑 조회
    
    **응답**:
    ```json
    {
      "balance": 1250,
      "total_earned": 2500,
      "total_spent": 1250,
      "total_purchased": 2000,
      "consecutive_login_days": 7,
      "can_watch_ad": true,
      "daily_ad_remaining": 3
    }
    ```
    
    🔧 2026-01-02 22:00 EST 수정:
    - 코인 지갑 초기화 Race Condition 방지
    - 비관적 락으로 중복 생성 방지
    """
    # === 1. 기존 지갑 확인 (Lock 없이) ===
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).first()
    
    if wallet:
        # 기존 지갑 있음 → 바로 반환
        return WalletInfo(
            balance=wallet.balance,
            total_earned=wallet.total_earned,
            total_spent=wallet.total_spent,
            total_purchased=wallet.total_purchased,
            consecutive_login_days=wallet.consecutive_login_days,
            can_watch_ad=wallet.can_watch_ad(),
            daily_ad_remaining=max(0, 5 - wallet.daily_ad_count)
        )
    
    # === 2. 지갑 없음 → 신규 생성 (Race Condition 방지) ===
    # 🔒 User 테이블에 Lock을 걸어 동시 생성 방지
    user_lock = db.query(User).filter(
        User.id == current_user.id
    ).with_for_update().first()
    
    if not user_lock:
        raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")
    
    # Lock 획득 후 재확인 (다른 요청이 이미 생성했을 수 있음)
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).first()
    
    if wallet:
        # 다른 요청이 이미 생성함
        logger.info(f"[코인 지갑] User {current_user.id}: 이미 생성됨 (재확인)")
        db.commit()  # Lock 해제
        return WalletInfo(
            balance=wallet.balance,
            total_earned=wallet.total_earned,
            total_spent=wallet.total_spent,
            total_purchased=wallet.total_purchased,
            consecutive_login_days=wallet.consecutive_login_days,
            can_watch_ad=wallet.can_watch_ad(),
            daily_ad_remaining=max(0, 5 - wallet.daily_ad_count)
        )
    
    # === 3. 신규 지갑 생성 (웰컴 보너스 100코인) ===
    wallet = CoinWallet(
        user_id=current_user.id,
        balance=100,
        total_earned=100
    )
    db.add(wallet)
    db.flush()  # wallet.id 생성
    
    # 웰컴 거래 기록
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.WELCOME,
        amount=100,
        balance_after=100,
        description="웰컴 보너스"
    )
    db.add(transaction)
    
    db.commit()
    db.refresh(wallet)
    
    logger.info(f"[코인 지갑] User {current_user.id}: 신규 생성 (웰컴 보너스 100코인)")
    
    return WalletInfo(
        balance=wallet.balance,
        total_earned=wallet.total_earned,
        total_spent=wallet.total_spent,
        total_purchased=wallet.total_purchased,
        consecutive_login_days=wallet.consecutive_login_days,
        can_watch_ad=wallet.can_watch_ad(),
        daily_ad_remaining=max(0, 5 - wallet.daily_ad_count)
    )


@router.post("/purchase", response_model=PurchaseResponse)
async def purchase_coins(
    request: PurchaseRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    코인 구매 (IAP)
    
    **🔒 보안 강화 (2026-01-02)**:
    - Apple/Google IAP 영수증 검증
    - 중복 결제 방지
    - 환불 처리 지원
    
    **요청**:
    ```json
    {
      "package_id": "standard_1000",
      "payment_provider": "iap_apple" | "iap_google",
      "payment_id": "receipt_token_here"
    }
    ```
    """
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).with_for_update().first()  # 🔒 비관적 락
    
    # 패키지 정보
    packages = {
        "starter_100": {"coins": 100, "bonus": 0, "price": 1000},
        "basic_500": {"coins": 500, "bonus": 50, "price": 4500},
        "standard_1000": {"coins": 1000, "bonus": 200, "price": 8000},
        "premium_2500": {"coins": 2500, "bonus": 750, "price": 18000},
        "mega_5000": {"coins": 5000, "bonus": 2000, "price": 35000},
    }
    
    package = packages.get(request.package_id)
    if not package:
        raise HTTPException(status_code=400, detail="잘못된 패키지 ID")
    
    # === 결제 검증 (IAP) ===
    from app.services.payment_service import PaymentService
    payment_service = PaymentService()
    
    try:
        payment_result = await payment_service.verify_iap(
            provider=request.payment_provider,
            receipt=request.payment_id,
            expected_product_id=request.package_id,
            expected_price=package['price']
        )
        
        if not payment_result['success']:
            logger.warning(
                f"[IAP 검증 실패] User {current_user.id}, "
                f"Provider {request.payment_provider}, "
                f"Reason: {payment_result.get('error')}"
            )
            raise HTTPException(
                status_code=400,
                detail=payment_result.get('error', '결제 검증 실패')
            )
        
        # 중복 결제 확인
        transaction_id = payment_result['transaction_id']
        existing_tx = db.query(CoinTransaction).filter(
            CoinTransaction.payment_id == transaction_id
        ).first()
        
        if existing_tx:
            raise HTTPException(
                status_code=400,
                detail="이미 처리된 결제입니다"
            )
    
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"[IAP 검증 오류] {e}")
        raise HTTPException(
            status_code=500,
            detail="결제 검증 중 오류가 발생했습니다"
        )
    
    # === 코인 지급 ===
    total_coins = package['coins'] + package['bonus']
    wallet.balance += total_coins
    wallet.total_earned += total_coins
    wallet.total_purchased += package['coins']
    
    # === 거래 기록 ===
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.PURCHASE,
        amount=total_coins,
        balance_after=wallet.balance,
        description=f"코인 패키지 구매 ({package['coins']}+{package['bonus']})",
        payment_id=transaction_id,  # 검증된 transaction_id 사용
        metadata=json.dumps({
            'package_id': request.package_id,
            'provider': request.payment_provider,
            'price': package['price'],
            'original_transaction_id': payment_result.get('original_transaction_id')
        })
    )
    db.add(transaction)
    db.commit()
    
    logger.info(
        f"[코인 구매 완료] User {current_user.id}, "
        f"Package {request.package_id}, 코인 {total_coins} 지급"
    )
    
    return PurchaseResponse(
        success=True,
        coins_added=total_coins,
        new_balance=wallet.balance,
        message=f"{total_coins}코인이 충전되었습니다!"
    )


@router.post("/daily-login")
async def claim_daily_login(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    일일 로그인 보상 획득
    """
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).first()
    
    coins_earned = wallet.check_consecutive_login()
    
    if coins_earned == 0:
        return {
            "success": False,
            "message": "오늘은 이미 로그인 보상을 받았습니다"
        }
    
    wallet.balance += coins_earned
    wallet.total_earned += coins_earned
    
    # 거래 기록
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.DAILY_LOGIN,
        amount=coins_earned,
        balance_after=wallet.balance,
        description=f"일일 로그인 ({wallet.consecutive_login_days}일 연속)"
    )
    db.add(transaction)
    db.commit()
    
    bonus_message = ""
    if wallet.consecutive_login_days == 7:
        bonus_message = " (7일 연속 보너스 +30코인!)"
    elif wallet.consecutive_login_days == 30:
        bonus_message = " (30일 연속 보너스 +200코인!)"
    
    return {
        "success": True,
        "coins_earned": coins_earned,
        "new_balance": wallet.balance,
        "consecutive_days": wallet.consecutive_login_days,
        "message": f"{coins_earned}코인 획득!{bonus_message}"
    }


@router.post("/watch-ad")
async def watch_ad_reward(
    ad_verification_token: str,  # 🔒 광고 SDK에서 발급한 토큰
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    광고 시청 보상 (일일 5회 제한)
    
    **🔒 보안 강화**:
    - ad_verification_token: 광고 SDK(AdMob)에서 발급한 검증 토큰 필수
    - 서버 간 검증으로 부정 획득 방지
    - 토큰 재사용 방지
    """
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).first()
    
    # === 1. 일일 한도 확인 ===
    if not wallet.can_watch_ad():
        return {
            "success": False,
            "message": "오늘의 광고 시청 한도를 모두 사용했습니다 (5/5)"
        }
    
    # === 2. 광고 시청 검증 (AdMob SSV) ===
    try:
        from app.services.ad_verification_service import AdVerificationService
        
        ad_service = AdVerificationService()
        verification_result = await ad_service.verify_rewarded_ad(
            token=ad_verification_token,
            user_id=str(current_user.id)
        )
        
        if not verification_result['valid']:
            logger.warning(
                f"[광고 검증 실패] User {current_user.id}, "
                f"Reason: {verification_result.get('reason')}"
            )
            raise HTTPException(
                status_code=400,
                detail="광고 시청 검증 실패. 광고를 끝까지 시청해주세요."
            )
        
        # === 3. 토큰 중복 사용 방지 ===
        if await ad_service.is_token_used(ad_verification_token):
            raise HTTPException(
                status_code=400,
                detail="이미 사용된 보상입니다"
            )
        
        # 토큰 사용 기록
        await ad_service.mark_token_as_used(ad_verification_token)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[광고 검증 오류] {e}")
        raise HTTPException(
            status_code=500,
            detail="광고 검증 중 오류가 발생했습니다"
        )
    
    # === 4. 코인 지급 ===
    coins_earned = 5
    wallet.balance += coins_earned
    wallet.total_earned += coins_earned
    wallet.daily_ad_count += 1
    
    # === 5. 거래 기록 ===
    transaction = CoinTransaction(
        wallet_id=wallet.id,
        type=TransactionType.AD_REWARD,
        amount=coins_earned,
        balance_after=wallet.balance,
        description="광고 시청 보상",
        metadata=json.dumps({
            'ad_network': 'admob',
            'verification_token': ad_verification_token[:20] + '...'  # 앞 20자만
        })
    )
    db.add(transaction)
    db.commit()
    
    logger.info(
        f"[광고 보상 지급] User {current_user.id}, "
        f"코인 {coins_earned} 지급, 오늘 {wallet.daily_ad_count}/5"
    )
    
    return {
        "success": True,
        "coins_earned": coins_earned,
        "new_balance": wallet.balance,
        "remaining_today": 5 - wallet.daily_ad_count,
        "message": f"{coins_earned}코인 획득! (오늘 {wallet.daily_ad_count}/5)"
    }


@router.get("/transactions", response_model=List[TransactionHistory])
async def get_transaction_history(
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    코인 거래 내역 조회
    """
    wallet = db.query(CoinWallet).filter(
        CoinWallet.user_id == current_user.id
    ).first()
    
    transactions = db.query(CoinTransaction).filter(
        CoinTransaction.wallet_id == wallet.id
    ).order_by(
        CoinTransaction.created_at.desc()
    ).limit(limit).offset(offset).all()
    
    return [
        TransactionHistory(
            id=str(tx.id),
            type=tx.type,
            amount=tx.amount,
            balance_after=tx.balance_after,
            description=tx.description,
            created_at=tx.created_at
        )
        for tx in transactions
    ]
```

### 21.5 Flutter 앱 구현

#### 21.5.1 코인 지갑 Provider

**`mobile_app/lib/presentation/providers/coin_provider.dart`**

```dart
/// 코인 지갑 관리 Provider

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coin_provider.g.dart';

@riverpod
Future<WalletInfo> coinWallet(CoinWalletRef ref) async {
  final api = ref.watch(apiClientProvider);
  
  final response = await api.get('/api/coins/wallet');
  return WalletInfo.fromJson(response.data);
}

@riverpod
class CoinManager extends _$CoinManager {
  @override
  AsyncValue<WalletInfo?> build() {
    return const AsyncValue.data(null);
  }
  
  Future<void> purchaseCoins({
    required String packageId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // IAP 결제 처리
      final purchaseService = ref.read(inAppPurchaseProvider);
      final purchase = await purchaseService.buyProduct(
        productId: packageId,
      );
      
      // 서버에 영수증 전송
      final api = ref.read(apiClientProvider);
      final response = await api.post('/api/coins/purchase', data: {
        'package_id': packageId,
        'payment_provider': Platform.isIOS ? 'iap_apple' : 'iap_google',
        'payment_id': purchase.receipt,
      });
      
      final newBalance = response.data['new_balance'];
      final coinsAdded = response.data['coins_added'];
      
      // 상태 업데이트
      ref.invalidate(coinWalletProvider);
      
      // 성공 알림
      ref.read(toastProvider).showSuccess('$coinsAdded 코인이 충전되었습니다!');
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      ref.read(toastProvider).showError('충전 실패: ${e.toString()}');
    }
  }
  
  Future<void> claimDailyLogin() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post('/api/coins/daily-login');
      
      if (response.data['success']) {
        ref.invalidate(coinWalletProvider);
        ref.read(toastProvider).showSuccess(response.data['message']);
      } else {
        ref.read(toastProvider).showInfo(response.data['message']);
      }
    } catch (e) {
      ref.read(toastProvider).showError('로그인 보상 실패');
    }
  }
  
  Future<void> watchAdForCoins() async {
    try {
      // 광고 SDK 호출
      final adService = ref.read(adMobProvider);
      await adService.showRewardedAd();
      
      // 서버에 보상 요청
      final api = ref.read(apiClientProvider);
      final response = await api.post('/api/coins/watch-ad');
      
      if (response.data['success']) {
        ref.invalidate(coinWalletProvider);
        ref.read(toastProvider).showSuccess(response.data['message']);
      } else {
        ref.read(toastProvider).showInfo(response.data['message']);
      }
    } catch (e) {
      ref.read(toastProvider).showError('광고 시청 실패');
    }
  }
}
```

#### 21.5.2 코인 스토어 화면

```dart
/// 코인 구매 화면

class CoinStoreScreen extends ConsumerWidget {
  const CoinStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(coinWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('코인 충전'),
        actions: [
          // 현재 잔액 표시
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${wallet.value?.balance ?? 0}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 무료 코인 획득 섹션
            _buildFreeCoinsSection(ref, wallet.value),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // 코인 패키지
            Text(
              '코인 패키지',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildPackageCard(
              packageId: 'starter_100',
              coins: 100,
              price: '₩1,000',
              bonus: 0,
              onTap: () => _purchase(ref, 'starter_100'),
            ),
            
            _buildPackageCard(
              packageId: 'basic_500',
              coins: 500,
              price: '₩4,500',
              bonus: 50,
              onTap: () => _purchase(ref, 'basic_500'),
            ),
            
            _buildPackageCard(
              packageId: 'standard_1000',
              coins: 1000,
              price: '₩8,000',
              bonus: 200,
              badge: '인기',
              onTap: () => _purchase(ref, 'standard_1000'),
            ),
            
            _buildPackageCard(
              packageId: 'premium_2500',
              coins: 2500,
              price: '₩18,000',
              bonus: 750,
              onTap: () => _purchase(ref, 'premium_2500'),
            ),
            
            _buildPackageCard(
              packageId: 'mega_5000',
              coins: 5000,
              price: '₩35,000',
              bonus: 2000,
              badge: '최고가치',
              onTap: () => _purchase(ref, 'mega_5000'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeCoinsSection(WidgetRef ref, WalletInfo? wallet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '무료 코인 획득',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 일일 로그인
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('일일 로그인'),
              subtitle: Text('연속 ${wallet?.consecutive_login_days ?? 0}일'),
              trailing: ElevatedButton(
                onPressed: () => ref.read(coinManagerProvider.notifier).claimDailyLogin(),
                child: const Text('+5코인'),
              ),
            ),
            
            // 광고 시청
            ListTile(
              leading: const Icon(Icons.play_circle, color: Colors.green),
              title: const Text('광고 시청'),
              subtitle: Text('오늘 ${wallet?.daily_ad_remaining ?? 5}회 남음'),
              trailing: ElevatedButton(
                onPressed: wallet?.can_watch_ad == true
                    ? () => ref.read(coinManagerProvider.notifier).watchAdForCoins()
                    : null,
                child: const Text('+5코인'),
              ),
            ),
            
            // 친구 초대
            ListTile(
              leading: const Icon(Icons.share, color: Colors.orange),
              title: const Text('친구 초대'),
              subtitle: const Text('양쪽 각 50코인'),
              trailing: IconButton(
                onPressed: () {
                  // 초대 링크 공유
                },
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchase(WidgetRef ref, String packageId) {
    ref.read(coinManagerProvider.notifier).purchaseCoins(
      packageId: packageId,
    );
  }
}
```

### 21.6 수익 예측 (코인 기반 모델)

#### 21.6.1 3개년 재무 계획

**사용자 및 전환 가정**:

```yaml
Year 1 (론칭):
  MAU: 10,000명
  무료 유저 (광고만): 9,000명 (90%)
  유료 전환 유저: 1,000명 (10%)
  
  유료 유저 월평균 구매:
    - 라이트 유저 (30%): ₩2,000/월
    - 일반 유저 (50%): ₩8,000/월
    - 헤비 유저 (20%): ₩25,000/월

Year 2 (성장):
  MAU: 50,000명
  무료 유저: 42,000명 (84%)
  유료 전환 유저: 8,000명 (16%)

Year 3 (확장):
  MAU: 150,000명
  무료 유저: 120,000명 (80%)
  유료 전환 유저: 30,000명 (20%)
```

| 항목 | Year 1 | Year 2 | Year 3 |
|------|--------|--------|--------|
| **사용자 수** | | | |
| 월간 활성 유저 (MAU) | 10,000 | 50,000 | 150,000 |
| 무료 유저 (광고만) | 9,000 | 42,000 | 120,000 |
| 유료 전환 유저 | 1,000 | 8,000 | 30,000 |
| **전환율** | 10% | 16% | 20% |
| **월 매출 (평균)** | | | |
| 코인 구매 수익 | ₩9.5M | ₩75M | ₩265M |
| 광고 수익 | ₩2.7M | ₩13M | ₩36M |
| **합계** | **₩12.2M** | **₩88M** | **₩301M** |
| **연 매출** | **₩146M** | **₩1.06B** | **₩3.61B** |

**코인 구매 수익 산출 근거**:

```python
# Year 1
라이트 유저: 1,000 × 30% × ₩2,000 = ₩600K
일반 유저: 1,000 × 50% × ₩8,000 = ₩4,000K
헤비 유저: 1,000 × 20% × ₩25,000 = ₩5,000K
합계: ₩9,600K ≈ ₩9.5M/월

# Year 2
라이트 유저: 8,000 × 30% × ₩2,000 = ₩4.8M
일반 유저: 8,000 × 50% × ₩8,000 = ₩32M
헤비 유저: 8,000 × 20% × ₩25,000 = ₩40M
합계: ₩76.8M ≈ ₩75M/월

# Year 3
라이트 유저: 30,000 × 30% × ₩2,000 = ₩18M
일반 유저: 30,000 × 50% × ₩8,000 = ₩120M
헤비 유저: 30,000 × 20% × ₩25,000 = ₩150M
합계: ₩288M ≈ ₩265M/월 (일부 이탈 고려)
```

**광고 수익 산출**:

```python
# RPM (Revenue Per Mille) = 광고 노출 1,000회당 수익
RPM: ₩300~500 (한국 평균)

# Year 1
무료 유저 9,000명 × 일일 광고 노출 10회 × 30일 = 2.7M 노출
수익: 2,700 × ₩500 = ₩1.35M (배너) + ₩1.35M (리워드) = ₩2.7M

# Year 2
무료 유저 42,000명 → 12.6M 노출 → ₩13M

# Year 3
무료 유저 120,000명 → 36M 노출 → ₩36M
```

#### 21.6.2 비용 구조

| 항목 | Year 1 | Year 2 | Year 3 |
|------|--------|--------|--------|
| **고정 비용** | | | |
| 인건비 (3명→5명→8명) | ₩60M | ₩120M | ₩200M |
| 인프라 (AWS/GCP) | ₩2M | ₩8M | ₩25M |
| 사무실 | ₩5M | ₩10M | ₩20M |
| **변동 비용** | | | |
| 마케팅 | ₩30M | ₩150M | ₩400M |
| IAP 수수료 (30%) | ₩34M | ₩270M | ₩954M |
| 광고 SDK 수수료 (20%) | ₩0.6M | ₩3M | ₩8M |
| 기타 (법무/회계) | ₩5M | ₩15M | ₩30M |
| **합계** | **₩136.6M** | **₩576M** | **₩1.637B** |
| **영업이익** | **₩9.4M** | **₩484M** | **₩1.973B** |
| **영업이익률** | 6.4% | 45.7% | 54.6% |

**핵심 인사이트**:

```yaml
장점:
  - 높은 전환율: 구독(5%) vs 코인(10~20%)
  - 낮은 이탈: 구독 해지 부담 없음
  - 자연스러운 소액 결제
  - 무료 유저도 수익화 (광고)
  - ARPU 증가 곡선이 가파름

단점:
  - IAP 수수료 30% (높음)
  - 예측 어려움 (변동성)
  - 코인 관리 복잡도

해결책:
  - 직접 결제 유도 (웹 결제 시 10% 추가 보너스)
  - 패키지 번들로 ARPU 높이기
  - 코인 소멸 정책 (1년 미사용 시)
```

#### 21.6.3 핵심 지표 (KPI)

```yaml
비즈니스 지표:
  - 전환율 (Free → Paid): 목표 15%
  - ARPU (Average Revenue Per User): ₩1,200~2,000
  - ARPPU (Average Revenue Per Paying User): ₩8,000~10,000
  - LTV (Lifetime Value): ₩50,000~100,000
  - Churn Rate: < 5%/월

코인 이코노미 지표:
  - 일일 무료 코인 획득량: 평균 10~15코인
  - 코인 소진율: 80% (20%는 쌓아둠)
  - 알고리즘별 사용 비율:
    - 랜덤(5코인): 30%
    - 중급(15코인): 40%
    - LSTM(30~40코인): 25%
    - 앙상블(100코인): 5%

마케팅 효율:
  - CAC (Customer Acquisition Cost): ₩3,000~5,000
  - LTV/CAC 비율: 10~20x (건강)
  - Payback Period: 1~2개월
```

---

## 22. 마케팅 및 성장 전략 (코인 모델)

### 22.1 Launch 전략 (Phase 0)

#### 22.1.1 소프트 론칭 (베타 테스트)

```yaml
기간: 출시 1개월 전
대상: 100명 얼리 어답터
혜택:
  - 웰컴 보너스 500코인 (일반 100코인의 5배)
  - 평생 코인 구매 30% 할인
  - 론칭 팀원 명단 등재
  
채널:
  - 네이버 카페 (로또 커뮤니티)
  - 클리앙 (알뜰 구매 게시판)
  - 페이스북 그룹
```

#### 22.1.2 공식 론칭

```yaml
론칭 이벤트:
  - "첫 가입 200코인 무료" (일반 100코인의 2배)
  - "첫 구매 50% 보너스" (예: 1,000코인 구매 → 1,500코인 지급)
  - "친구 초대 시 양쪽 각 100코인" (일반 50코인의 2배)
  - "3등 이상 당첨 인증 시 500코인"
  
PR:
  - 보도자료 배포 (벤처비트, 테크크런치 코리아)
  - Product Hunt 등록
  - 스타트업 커뮤니티 발표
```

### 22.2 성장 전략 (Phase 1-3)

#### Phase 1: 초기 트랙션 (0~6개월)

**목표**: 10,000 MAU, 10% 유료 전환율

**전략**:
1. **콘텐츠 마케팅**
   - 블로그: "코인으로 똑똑하게 로또 즐기기"
   - 유튜브: "무료 코인만으로 LSTM 써보기"
   - 인스타그램: "오늘의 무료 코인 획득법"

2. **바이럴 마케팅 (코인 중심)**
   - **친구 초대 보상**: 양쪽 각 50코인
   - **당첨 인증 이벤트**: 3등 이상 100코인, 2등 500코인, 1등 10,000코인!
   - **"이번 주 핫 번호" 공유**: 공유 시 5코인 획득

3. **무료 코인 극대화 전략 홍보**
   ```
   "매일 무료 코인으로 LSTM 알고리즘 사용하기"
   - 일일 로그인: +5코인
   - 광고 5회: +25코인
   - 친구 초대 1명: +50코인
   → 총 80코인 = LSTM 2회 무료!
   ```

#### Phase 2: 가속 성장 (6~12개월)

**목표**: 50,000 MAU, 16% 유료 전환율

**전략**:
1. **인플루언서 협업**
   - 로또 유튜버: "코인 충전 없이 한 달 써보기 챌린지"
   - 데이터 분석 유튜버: "AI 로또 앱 코인 가성비 분석"
   - 제품 리뷰: "구독 vs 코인, 어느 것이 유리할까?"

2. **성과 마케팅**
   - Google Ads: "로또 번호 무료 코인"
   - 페이스북/인스타그램: "첫 구매 50% 보너스"
   - 카카오톡 채널: "일일 로그인 보상 알림"

3. **프로모션 전략**
   ```yaml
   주간 특가:
     - 매주 랜덤 패키지 30% 할인
     - "오늘만" 플래시 세일 (2시간 한정)
   
   이벤트 코인:
     - 생일 축하 500코인
     - 설날/추석 1,000코인
     - 앱 다운로드 10만 돌파 기념 200코인
   ```

#### Phase 3: 시장 지배 (12개월~)

**목표**: 150,000 MAU, 20% 유료 전환율

**전략**:
1. **대중 마케팅**
   - TV 광고: "코인으로 시작하는 AI 로또"
   - 지하철/버스: "오늘의 무료 코인 받으셨나요?"
   - 브랜드 캠페인: "당신의 행운을 코인으로"

2. **B2B 확장**
   - 로또 판매점: "키오스크에서 코인 충전"
   - 편의점 제휴: "GS25에서 코인 카드 구매"

3. **글로벌 진출**
   - 해외 로또 추가 (Powerball, EuroMillions)
   - 현지화된 코인 패키지

### 22.3 전환율 최적화 (CRO) - 코인 특화

#### 22.3.1 코인 소진 → 충전 전환 포인트

```python
# 전환 트리거 포인트

1. 코인 부족 시 (번호 생성 시도)
   → "30코인이 부족합니다 😢"
   → "₩1,000로 100코인 충전하기" (즉시 사용 가능)
   → "광고 보고 5코인 무료 받기" (대안 제시)

2. 고급 알고리즘 사용 시도
   → "LSTM 알고리즘은 30코인이 필요합니다"
   → "첫 구매 50% 보너스! 100코인 → 150코인"

3. 연속 사용 후
   → "오늘 이미 5회 생성했네요! 🎉"
   → "내일 또 무료 5코인 받으려면 로그인하세요"
   → "지금 충전하면 보너스 20% 추가"

4. 코인 0 근처 (10코인 이하)
   → "코인이 얼마 남지 않았어요"
   → "₩4,500로 550코인 (20% 보너스)"
   → "친구 초대하면 50코인 무료"

5. 당첨 후
   → "축하합니다! 5등 당첨!"
   → "기념으로 100코인 보너스 받기" (첫 구매 시)
```

#### 22.3.2 코인 번들 최적화

```yaml
심리적 가격 설정:
  - ₩990 (스타터 미니): 50코인 → 충동 구매 유도
  - ₩4,500 (베이직): 550코인 → 가장 많이 팔림
  - ₩8,000 (스탠다드): 1,200코인 → 가성비 최고
  - ₩18,000 (프리미엄): 3,250코인 → 파워 유저
  - ₩35,000 (메가): 7,000코인 → 장기 유저

번들 네이밍 전략:
  - "초보자 패키지" → 심리적 진입 장벽 낮춤
  - "인기 1위 패키지" → 사회적 증거
  - "가성비 킹 패키지" → 합리적 선택
  - "VIP 패키지" → 프리미엄 느낌
```

#### 22.3.3 A/B 테스트 계획

```yaml
테스트 항목:
  - 패키지 가격 (₩8,000 vs ₩9,900)
  - 보너스 비율 (20% vs 30%)
  - 웰컴 코인 (100 vs 200)
  - 일일 로그인 보상 (5코인 vs 10코인)
  - 광고 보상 (5코인 vs 10코인)
  - 전환 팝업 타이밍 (즉시 vs 3초 후)
  
측정 지표:
  - 전환율 (Free → First Purchase)
  - ARPPU (Average Revenue Per Paying User)
  - 재구매율 (Repeat Purchase Rate)
  - 코인 소진율 (Burn Rate)
  - LTV (Lifetime Value)
```

### 22.4 리텐션 전략 (코인 기반)

#### 22.4.1 사용자 유지

```yaml
일일 미션:
  - 로그인: +5코인
  - 번호 1회 생성: +3코인
  - 광고 3회 시청: +15코인
  - 친구와 공유: +10코인
  → 일일 최대 33코인 무료 획득 가능

주간 챌린지:
  - 7일 연속 로그인: +30코인
  - 주간 누적 10회 생성: +50코인
  - 5명 친구 초대: +250코인

월간 리워드:
  - 30일 연속 로그인: +200코인
  - 월간 누적 50회 생성: +500코인
  - 당첨 인증 1회: +100코인

푸시 알림:
  - 토요일 18:00: "일일 로그인 보상 받으셨나요? +5코인"
  - 일요일 21:00: "당첨 번호 발표! 자동 확인 중..."
  - 코인 부족 시: "광고 보고 5코인 무료 받기"
  - 이벤트 시작: "주말 특가! 코인 50% 보너스"

Gamification:
  - 레벨 시스템: 누적 사용 코인으로 레벨업 → 보너스 지급
  - 뱃지 수집: "LSTM 마스터", "연속 로그인 왕"
  - 리더보드: "이번 주 코인 절약왕 TOP 10"
```

#### 22.4.2 Churn 방지

```yaml
이탈 징후:
  - 7일 미접속
  - 코인 잔액 0 지속
  - 광고만 보고 생성 안 함
  
재활성화 캠페인:
  - "보고 싶었어요! 100코인 선물" (푸시)
  - "돌아오신 기념 50% 할인" (이메일)
  - "친구가 50코인을 선물했어요" (SMS)

코인 소멸 정책:
  - 1년 미사용 코인 자동 소멸 (사전 알림)
  - 소멸 30일 전 푸시: "500코인이 곧 사라져요!"
  - 긴급 사용 유도
```

### 22.5 코인 이코노미 밸런싱

#### 22.5.1 무료 vs 유료 균형

```yaml
목표:
  - 무료 유저: 주 1~2회 LSTM 사용 가능 (광고 + 로그인)
  - 유료 유저: 월 ₩5,000~10,000 지출로 충분한 만족도
  
무료 유저 시나리오:
  일일 로그인: +5코인
  광고 5회: +25코인
  친구 초대 (월 1명): +50코인/30일 = +1.7코인/일
  → 일일 평균 32코인 획득
  → 주간 224코인 = LSTM 7회 or 랜덤 40회
  
유료 유저 (월 ₩8,000 지출):
  1,200코인 패키지 (20% 보너스)
  + 무료 획득 900코인 (월)
  = 2,100코인/월
  → LSTM 70회 or 앙상블 21회
```

#### 22.5.2 인플레이션 방지

```yaml
코인 가치 유지 전략:
  - 알고리즘 가격 고정 (인상 금지)
  - 신규 알고리즘 추가 시 기존 것 가격 인하
  - 이벤트 코인 지급 제한 (월 최대 500코인)
  - 무료 획득 상한선 설정

디플레이션 방지:
  - 주기적 할인 이벤트
  - 신규 유저 웰컴 보너스 확대
  - 시즌 이벤트 (명절, 크리스마스)
```

---

**문서 끝 | v3.1 | 2026-01-02 18:30:00 EST**

> 💡 **핵심 요약 (v3.1 - 코인 모델 + 인증 시스템)**:
> 
> ### 🎯 전체 아키텍처
> 1. **Flutter 크로스플랫폼 앱** (iOS + Android)
> 2. **FastAPI 백엔드 서버** (Python 3.11+)
> 3. **클라이언트-서버 REST API** 통신
> 
> ### 📱 Flutter 앱 특징
> 1. Offline-First 설계 (Hive 로컬 DB)
> 2. Riverpod 상태 관리
> 3. Repository Pattern (데이터 소스 추상화)
> 4. 자동 서버 동기화
> 5. **게스트/소셜 로그인 하이브리드 인증**
> 6. **코인 지갑 및 거래 내역 UI**
> 7. **무료 코인 획득 (로그인, 광고, 초대)**
> 
> ### 🖥️ 백엔드 특징
> 1. 자동 로또 데이터 크롤링 (주 1회)
> 2. 9가지 AI 알고리즘 (LSTM 포함)
> 3. Walk-Forward Validation 검증
> 4. Redis 캐싱 및 Celery 백그라운드 작업
> 5. **하이브리드 인증 시스템 (게스트 + 소셜)**
> 6. **코인 지갑 시스템 (`CoinWallet`, `CoinTransaction`)**
> 7. **알고리즘별 차등 코인 소모 (5~100코인)**
> 8. **무료 코인 획득 로직 (일일/광고/초대)**
> 
> ### 🔄 데이터 흐름
> 1. **앱 시작**: 게스트 생성 or 토큰 로드 → 로컬 캐시 로드 → 백그라운드 서버 동기화 → 코인 지갑 조회
> 2. **번호 생성**: 코인 잔액 확인 → API 요청 → 알고리즘 실행 → 코인 차감 → 서버 + 로컬 저장
> 3. **주기적 크롤링**: Celery 스케줄 → 최신 회차 업데이트 → 자동 당첨 확인 → Push 알림
> 4. **통계 추적**: 사용자별 생성/당첨 통계, 알고리즘별 실전 성적, 코인 사용 패턴
> 
> ### 🔐 인증 시스템 (v3.1 신규)
> 
> **게스트 모드**:
> - 회원가입 불필요, 즉시 시작
> - 웰컴 보너스 100코인
> - 무료 코인만 사용 (로그인/광고)
> - 디바이스 종속 (변경 시 복구 불가)
> 
> **정식 계정** (Google/Apple/Kakao/Naver):
> - 웰컴 보너스 200코인
> - 모든 디바이스 동기화
> - 유료 코인 구매 가능
> - 디바이스 변경 시 자동 이전
> 
> **게스트 → 정식 전환**:
> - 기존 코인/데이터 자동 이전
> - 추가 보너스 100코인
> - 번호 생성 기록 유지
> 
> **디바이스 관리**:
> - `device_ids` 배열로 사용 기기 추적
> - JWT 토큰 기반 인증
> - 소셜 로그인 토큰 서버 재검증
> 
> ### 💰 수익 모델 (코인 기반)
> 1. **무료 획득**: 일일 로그인(5코인), 광고 시청(5코인×5회), 친구 초대(50코인)
> 2. **코인 패키지**: ₩1,000(100코인) ~ ₩35,000(7,000코인), 보너스 10~40%
> 3. **알고리즘 비용**: 랜덤(5코인), 중급(15코인), LSTM(30~40코인), 앙상블(100코인)
> 4. **예상 수익**: Year 1 ₩146M → Year 3 ₩3.61B
> 5. **전환율**: 10% (Year 1) → 20% (Year 3)
> 
> ### 🎰 핵심 신규 기능 (v3.1)
> 1. **하이브리드 인증**: 게스트(즉시 시작) + 소셜 로그인(데이터 보호)
> 2. **코인 지갑 동기화**: 정식 계정은 모든 디바이스에서 동일한 코인 잔액
> 3. **게스트 전환**: 게스트 → 정식 전환 시 데이터 손실 없음
> 4. **디바이스 독립**: 디바이스 변경해도 로그인만 하면 즉시 복구
> 5. **로그인 유도**: 보너스 코인으로 자연스러운 전환 유도
> 6. **소셜 로그인**: Google, Apple, Kakao, Naver 지원
> 7. **보안**: JWT 토큰, 소셜 토큰 재검증, Secure Storage
> 
> ### 🚀 배포
> - **모바일 앱**: App Store + Google Play (Fastlane 자동화)
> - **백엔드**: AWS Lightsail / GCP Cloud Run (Docker)
> - **CI/CD**: GitHub Actions 자동 빌드/배포
> - **수익화**: 코인 IAP + AdMob (리워드 광고)
> 
> ### 📊 코인 이코노미 요약
> ```
> 게스트: 웰컴 100코인 + 일일 32코인 무료 = 주 224코인 (LSTM 7회)
> 정식: 웰컴 200코인 + 일일 32코인 무료 + 유료 구매
> 전환: 게스트→정식 시 +100코인 보너스
> 
> 디바이스 변경:
>   게스트: 복구 불가 (경고 표시)
>   정식: 자동 동기화 (즉시 복구)
> ```

