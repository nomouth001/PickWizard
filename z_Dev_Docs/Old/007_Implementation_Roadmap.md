# LuckyAI 645 구현 로드맵
## Implementation Roadmap

---

**문서 버전**: v1.0  
**작성일**: 2026-01-04 EST  
**작성자**: AI Coding Assistant  
**목적**: 005_Implementation_Logic_and_Module_Design.md에 기반한 단계별 코딩 계획

---

## 📋 로드맵 개요

### 전체 전략
- **Bottom-Up 접근**: 기반 모듈부터 구축 → 상위 서비스 → UI
- **병렬 개발**: 백엔드와 프론트엔드를 Phase별로 병렬 진행
- **단계별 테스트**: 각 Phase 완료 시 통합 테스트 후 다음 단계 진행
- **점진적 확장**: 최소 기능부터 시작 → 고급 기능 추가

### 예상 일정
- **Phase 0 (환경 설정)**: 1일
- **Phase 1 (백엔드 Core)**: 3-4일
- **Phase 2 (백엔드 알고리즘 & API)**: 4-5일
- **Phase 3 (Flutter 앱 기본)**: 4-5일
- **Phase 4 (비즈니스 로직)**: 3-4일
- **Phase 5 (통합 & 테스트)**: 2-3일
- **Phase 6 (배포 준비)**: 2일
- **총 예상 기간**: 19-24일 (약 3-4주)

---

## Phase 0: 프로젝트 환경 설정 (1일)

### 목표
프로젝트 뼈대 구축 및 개발 환경 준비

### 작업 목록

#### 0.1 디렉토리 구조 생성
```powershell
# 백엔드 디렉토리
mkdir -p backend/app/{api/routes,core,algorithms,models,validation,db/{models,repositories},services,schemas,utils,workers}
mkdir -p backend/data/{raw,processed,models}
mkdir -p backend/results/{validation,reports,logs}
mkdir -p backend/tests
mkdir -p backend/scripts

# 프론트엔드는 Flutter CLI로 생성
flutter create mobile_app
```

**파일**:
- 디렉토리 구조 스크립트 작성

**완료 기준**: 모든 폴더 생성 완료

---

#### 0.2 백엔드 기본 설정 파일 작성

**파일**:
1. `backend/requirements.txt` - Python 의존성
2. `backend/.env.example` - 환경 변수 템플릿
3. `backend/pyproject.toml` - 프로젝트 메타데이터
4. `backend/.gitignore` - Git 제외 파일
5. `backend/app/__init__.py` - 패키지 초기화 (각 폴더)

**완료 기준**: 
- `pip install -r requirements.txt` 성공
- PostgreSQL/Redis Docker Compose 작성 및 실행

---

#### 0.3 Flutter 프로젝트 초기 설정

**파일**:
1. `mobile_app/pubspec.yaml` - 의존성 추가 (Riverpod, Dio, Hive 등)
2. `mobile_app/analysis_options.yaml` - Lint 규칙
3. `mobile_app/lib/core/constants/` - 상수 파일들
4. `mobile_app/.gitignore` - Git 제외 파일

**완료 기준**: 
- `flutter pub get` 성공
- `flutter run` 실행 가능 (빈 화면)

---

#### 0.4 Git 저장소 초기화

**작업**:
- Git 초기화 및 initial commit
- 브랜치 전략 수립 (main, develop, feature/*)
- README.md 작성

**완료 기준**: Git 저장소 준비 완료

---

## Phase 1: 백엔드 Core 모듈 (3-4일)

### 목표
데이터 수집 및 관리 시스템 구축

### 1.1 데이터베이스 모델 정의 (0.5일)

**파일**:
1. `backend/app/db/base.py` - SQLAlchemy Base 클래스
2. `backend/app/db/session.py` - DB 세션 관리
3. `backend/app/db/models/lotto_draw.py` - 로또 회차 모델
4. `backend/app/db/models/user.py` - 사용자 모델 (기본)
5. `backend/app/db/models/__init__.py` - 모델 export

**핵심 작업**:
```python
# lotto_draw.py 예시
class LottoDraw(Base):
    __tablename__ = "lotto_draws"
    
    draw_no = Column(Integer, primary_key=True)
    draw_date = Column(Date, nullable=False)
    num1 = Column(Integer, nullable=False)
    num2 = Column(Integer, nullable=False)
    # ... num3~num6
    bonus = Column(Integer, nullable=False)
    # ... 당첨금, 당첨자 수 등
```

**완료 기준**: 
- 모델 정의 완료
- Alembic 마이그레이션 파일 생성
- `python scripts/init_db.py` 실행 성공

---

### 1.2 설정 관리 (0.5일)

**파일**:
1. `backend/app/config.py` - Pydantic Settings 클래스

**핵심 작업**:
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    REDIS_URL: str
    JWT_SECRET_KEY: str
    LOTTO_CRAWLER_URL: str
    # ... 기타 설정
    
    class Config:
        env_file = ".env"

settings = Settings()
```

**완료 기준**: 환경 변수 로드 확인

---

### 1.3 로또 크롤러 구현 (1일)

**파일**:
1. `backend/app/core/crawler.py` - LottoCrawler 클래스

**핵심 메서드**:
```python
class LottoCrawler:
    async def get_latest_draw_number() -> int
    async def crawl_single(draw_no: int) -> Dict
    async def crawl_range(start: int, end: int) -> List[Dict]
    def _parse_draw_data(html: str) -> Dict
```

**완료 기준**: 
- 최신 회차 조회 성공
- 단일 회차 크롤링 성공 (예: 1169회)
- 범위 크롤링 성공 (예: 1160~1169회)
- 단위 테스트 작성 및 통과

---

### 1.4 데이터 검증기 (0.5일)

**파일**:
1. `backend/app/core/data_validator.py` - DataValidator 클래스

**핵심 메서드**:
```python
class DataValidator:
    def validate_dataframe(df: pd.DataFrame) -> Dict[str, Any]
    def _check_missing_draws(df: pd.DataFrame) -> List[int]
    def _check_number_ranges(df: pd.DataFrame) -> bool
    def _check_duplicates(df: pd.DataFrame) -> List[int]
```

**완료 기준**: 
- 데이터 무결성 검증 로직 완성
- 오류 보고 기능 작동

---

### 1.5 데이터 매니저 (1일)

**파일**:
1. `backend/app/core/data_manager.py` - DataManager 클래스
2. `backend/app/db/repositories/draw_repo.py` - DrawRepository

**핵심 메서드**:
```python
class DataManager:
    async def initialize() -> Dict
    async def _save_to_csv()
    async def _sync_to_database()
    def get_dataframe() -> pd.DataFrame
    def get_draws_up_to(draw_no: int) -> pd.DataFrame
    async def check_for_updates() -> Dict
```

**통합 로직**:
1. 로컬 CSV 확인
2. 온라인 최신 회차 조회
3. 증분 크롤링 (누락 회차만)
4. CSV 저장
5. DB 동기화
6. 검증

**완료 기준**: 
- 초기 데이터 로드 성공 (1~최신회차)
- `data/raw/lotto_data.csv` 생성
- PostgreSQL에 데이터 저장 확인
- 증분 업데이트 테스트 성공

---

### 1.6 캐시 매니저 (0.5일)

**파일**:
1. `backend/app/core/cache_manager.py` - CacheManager 클래스

**핵심 메서드**:
```python
class CacheManager:
    async def get(key: str) -> Optional[Any]
    async def set(key: str, value: Any, ttl: int = 3600)
    async def delete(key: str)
    async def invalidate_pattern(pattern: str)
```

**완료 기준**: Redis 연동 및 캐싱 동작 확인

---

## Phase 2: 백엔드 알고리즘 & API (4-5일)

### 목표
번호 생성 알고리즘 및 REST API 구현

### 2.1 알고리즘 베이스 클래스 (0.5일)

**파일**:
1. `backend/app/algorithms/base.py` - LottoAlgorithm 추상 클래스

**핵심 구조**:
```python
class LottoAlgorithm(ABC):
    @abstractmethod
    def generate_numbers(
        historical_data: pd.DataFrame,
        n_sets: int,
        exclude_numbers: List[int],
        include_numbers: List[int]
    ) -> List[List[int]]:
        pass
    
    def validate_parameters(...) -> bool
    def get_info() -> Dict
```

**완료 기준**: 추상 클래스 정의 완료

---

### 2.2 알고리즘 구현 (2일)

**우선순위별 구현**:

#### Phase 2.2.1: 기본 알고리즘 (1일)
**파일**:
1. `backend/app/algorithms/algorithm_01_random.py` - 순수 랜덤
2. `backend/app/algorithms/algorithm_06_frequency.py` - 빈도 기반
3. `backend/app/algorithms/algorithm_07_hot_cold.py` - 핫넘버/콜드넘버

**완료 기준**: 3개 알고리즘 번호 생성 성공

#### Phase 2.2.2: 고급 알고리즘 (1일)
**파일**:
4. `backend/app/algorithms/algorithm_03_ensemble.py` - 앙상블
5. `backend/app/algorithms/algorithm_04_pattern.py` - 패턴 분석
6. `backend/app/algorithms/algorithm_05_weighted.py` - 가중치

**완료 기준**: 6개 알고리즘 완성

#### Phase 2.2.3: AI/ML 알고리즘 (추후 확장)
**파일**:
7. `backend/app/algorithms/algorithm_02_lstm.py` - LSTM (선택)
8. `backend/app/algorithms/algorithm_08_gan.py` - GAN (선택)
9. `backend/app/algorithms/algorithm_09_rl.py` - RL (선택)

**참고**: ML 알고리즘은 Phase 4 이후 추가 가능

---

### 2.3 알고리즘 로더 (0.5일)

**파일**:
1. `backend/app/algorithms/__init__.py` - 알고리즘 동적 로딩

**핵심 로직**:
```python
def load_all_algorithms() -> Dict[int, LottoAlgorithm]:
    """모든 알고리즘 인스턴스 생성"""
    algorithms = {}
    for AlgoClass in [RandomAlgorithm, FrequencyAlgorithm, ...]:
        instance = AlgoClass()
        algorithms[instance.algorithm_id] = instance
    return algorithms

def get_algorithm(algorithm_id: int) -> LottoAlgorithm:
    """ID로 알고리즘 반환"""
```

**완료 기준**: Factory 패턴으로 알고리즘 로드 성공

---

### 2.4 Pydantic 스키마 정의 (0.5일)

**파일**:
1. `backend/app/schemas/generation.py` - 번호 생성 요청/응답
2. `backend/app/schemas/draw.py` - 회차 정보
3. `backend/app/schemas/user.py` - 사용자 정보

**핵심 스키마**:
```python
class GenerateRequest(BaseModel):
    algorithm_id: int
    n_sets: int = 5
    exclude_numbers: Optional[List[int]] = None
    include_numbers: Optional[List[int]] = None

class GeneratedNumberSet(BaseModel):
    numbers: List[int]
    set_no: int

class GenerateResponse(BaseModel):
    algorithm_name: str
    results: List[GeneratedNumberSet]
    timestamp: datetime
```

**완료 기준**: 모든 API 스키마 정의 완료

---

### 2.5 FastAPI 서버 초기화 (0.5일)

**파일**:
1. `backend/app/main.py` - FastAPI 앱 엔트리포인트

**핵심 구조**:
```python
from fastapi import FastAPI
from app.core.data_manager import DataManager
from app.api.routes import generate, draws, auth

app = FastAPI(title="LuckyAI 645 API", version="1.0.0")

@app.on_event("startup")
async def startup_event():
    # DB 연결
    # 데이터 매니저 초기화
    # Redis 연결
    # 알고리즘 로드
    pass

@app.on_event("shutdown")
async def shutdown_event():
    # 리소스 정리
    pass

app.include_router(generate.router, prefix="/api/generate")
app.include_router(draws.router, prefix="/api/draws")
```

**완료 기준**: 
- 서버 시작 성공
- Swagger UI 접근 가능 (http://localhost:8000/docs)

---

### 2.6 API 엔드포인트 구현 (1일)

#### 2.6.1 번호 생성 API
**파일**: `backend/app/api/routes/generate.py`

**엔드포인트**:
```python
@router.post("/", response_model=GenerateResponse)
async def generate_numbers(
    request: GenerateRequest,
    db: Session = Depends(get_db)
):
    # 1. 알고리즘 로드
    # 2. 과거 데이터 조회
    # 3. 번호 생성
    # 4. DB 저장 (선택)
    # 5. 응답 반환
```

**완료 기준**: POST /api/generate 성공

---

#### 2.6.2 회차 조회 API
**파일**: `backend/app/api/routes/draws.py`

**엔드포인트**:
- `GET /api/draws/latest` - 최신 회차
- `GET /api/draws/{draw_no}` - 특정 회차
- `GET /api/draws/range` - 범위 조회

**완료 기준**: 모든 엔드포인트 테스트 성공

---

#### 2.6.3 알고리즘 정보 API
**파일**: `backend/app/api/routes/algorithms.py`

**엔드포인트**:
- `GET /api/algorithms` - 전체 목록
- `GET /api/algorithms/{id}` - 상세 정보

**완료 기준**: 알고리즘 메타데이터 반환

---

## Phase 3: Flutter 앱 기본 구조 (4-5일)

### 목표
모바일 앱 UI/UX 및 상태 관리 구현

### 3.1 코드 생성 및 기본 설정 (0.5일)

**작업**:
```bash
cd mobile_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**파일**:
1. `lib/core/constants/api_endpoints.dart` - API URL 상수
2. `lib/core/constants/app_colors.dart` - 색상 테마
3. `lib/core/theme/app_theme.dart` - 테마 정의

**완료 기준**: 기본 상수 및 테마 정의

---

### 3.2 데이터 모델 정의 (0.5일)

**파일**:
1. `lib/data/models/lotto_draw.dart` - 회차 모델
2. `lib/data/models/generated_numbers.dart` - 생성 결과 모델
3. `lib/data/models/algorithm_info.dart` - 알고리즘 정보

**핵심 구조** (Freezed 사용):
```dart
@freezed
class LottoDraw with _$LottoDraw {
  factory LottoDraw({
    required int drawNo,
    required DateTime drawDate,
    required List<int> numbers,
    required int bonus,
  }) = _LottoDraw;
  
  factory LottoDraw.fromJson(Map<String, dynamic> json) 
    => _$LottoDrawFromJson(json);
}
```

**완료 기준**: 
- 코드 생성 성공 (*.g.dart, *.freezed.dart)
- JSON 직렬화/역직렬화 테스트

---

### 3.3 API 클라이언트 (1일)

#### 3.3.1 Dio 클라이언트 설정
**파일**: `lib/data/data_sources/remote/api_client.dart`

**핵심 설정**:
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  
  dio.interceptors.add(PrettyDioLogger());
  dio.interceptors.add(AuthInterceptor());
  
  return dio;
});
```

#### 3.3.2 Retrofit API 인터페이스
**파일**: `lib/data/data_sources/remote/lotto_api.dart`

**핵심 메서드**:
```dart
@RestApi(baseUrl: ApiEndpoints.baseUrl)
abstract class LottoApi {
  factory LottoApi(Dio dio) = _LottoApi;
  
  @GET('/api/draws/latest')
  Future<LottoDraw> getLatestDraw();
  
  @POST('/api/generate')
  Future<GenerateResponse> generateNumbers(
    @Body() GenerateRequest request
  );
}
```

**완료 기준**: 
- API 코드 생성 성공
- 실제 백엔드 호출 테스트

---

### 3.4 로컬 저장소 (Hive) (0.5일)

**파일**:
1. `lib/data/data_sources/local/hive_database.dart`

**핵심 작업**:
```dart
class HiveDatabase {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Adapter 등록
    Hive.registerAdapter(LottoDrawAdapter());
    Hive.registerAdapter(GeneratedNumbersAdapter());
    
    // Box 열기
    await Hive.openBox<LottoDraw>('draws');
    await Hive.openBox<GeneratedNumbers>('generated');
  }
}
```

**완료 기준**: 
- Hive 초기화 성공
- 데이터 저장/로드 테스트

---

### 3.5 Repository 구현 (1일)

**파일**:
1. `lib/data/repositories/lotto_repository.dart`

**핵심 메서드**:
```dart
class LottoRepository {
  Future<Either<Failure, LottoDraw>> getLatestDraw();
  Future<Either<Failure, GenerateResponse>> generateNumbers(
    GenerateRequest request
  );
  Future<List<GeneratedNumbers>> getLocalHistory();
  Future<void> saveToLocal(GeneratedNumbers data);
}
```

**완료 기준**: 
- Repository Pattern 구현
- Either (성공/실패) 처리

---

### 3.6 Riverpod Provider (1일)

**파일**:
1. `lib/presentation/providers/lotto_provider.dart`
2. `lib/presentation/providers/algorithm_provider.dart`

**핵심 Provider**:
```dart
@riverpod
class LottoNotifier extends _$LottoNotifier {
  @override
  FutureOr<LottoDraw?> build() async {
    // 최신 회차 로드
    return _loadLatestDraw();
  }
  
  Future<void> generateNumbers(GenerateRequest request) async {
    state = const AsyncValue.loading();
    final result = await ref.read(lottoRepositoryProvider)
                             .generateNumbers(request);
    result.fold(
      (failure) => state = AsyncValue.error(failure),
      (data) => state = AsyncValue.data(data),
    );
  }
}

final latestDrawProvider = lottoNotifierProvider;
```

**완료 기준**: 
- 상태 관리 동작 확인
- UI 반응성 테스트

---

### 3.7 UI 화면 구현 (1일)

#### 3.7.1 스플래시 화면
**파일**: `lib/presentation/screens/splash/splash_screen.dart`

**기능**: 
- 앱 초기화 (Hive, Firebase)
- 데이터 동기화
- 홈 화면 이동

---

#### 3.7.2 홈 화면
**파일**: `lib/presentation/screens/home/home_screen.dart`

**UI 요소**:
- 최신 회차 표시
- 번호 생성 버튼
- 하단 네비게이션

---

#### 3.7.3 번호 생성 화면
**파일**: `lib/presentation/screens/generate/generate_screen.dart`

**UI 요소**:
- 알고리즘 선택 드롭다운
- 생성 개수 슬라이더
- 제외/포함 번호 선택
- 생성 버튼
- 결과 화면

---

#### 3.7.4 공통 위젯
**파일**:
- `lib/presentation/widgets/lotto_ball.dart` - 로또 공 위젯
- `lib/presentation/widgets/number_card.dart` - 번호 세트 카드
- `lib/presentation/widgets/loading_indicator.dart` - 로딩

**완료 기준**: 
- 모든 화면 네비게이션 동작
- 번호 생성 플로우 완성

---

## Phase 4: 비즈니스 로직 (3-4일)

### 목표
사용자 인증, 코인 시스템, 결제 연동

### 4.1 사용자 인증 (1일)

#### 4.1.1 게스트 모드
**파일**:
- `backend/app/api/routes/auth.py`
- `backend/app/services/auth_service.py`
- `lib/presentation/providers/auth_provider.dart`

**핵심 기능**:
- 게스트 사용자 자동 생성 (device_id 기반)
- 로컬 저장소에 user_id 저장

**완료 기준**: 앱 실행 시 게스트 계정 자동 생성

---

#### 4.1.2 소셜 로그인 (선택적 구현)
**서비스**: Google, Apple, Kakao (Phase 5 이후)

---

### 4.2 코인 시스템 (1.5일)

#### 4.2.1 코인 지갑 모델
**파일**: `backend/app/db/models/coin_wallet.py`

**핵심 필드**:
```python
class CoinWallet(Base):
    user_id: UUID (FK)
    free_coins: int (무료 코인)
    paid_coins: int (유료 코인)
    total_earned: int (누적 획득)
    total_spent: int (누적 소비)
```

**완료 기준**: DB 모델 및 마이그레이션

---

#### 4.2.2 코인 획득 API
**파일**: `backend/app/api/routes/coins.py`

**엔드포인트**:
- `POST /api/coins/daily-login` - 일일 로그인 보상
- `POST /api/coins/watch-ad` - 광고 시청 보상
- `GET /api/coins/balance` - 잔액 조회

**핵심 로직**:
```python
@router.post("/daily-login")
async def claim_daily_login(
    user_id: UUID,
    db: Session = Depends(get_db)
):
    # 1. 중복 확인 (당일 이미 받았는지)
    # 2. 연속 로그인 일수 계산
    # 3. 보상 지급 (5코인 + 보너스)
    # 4. 지갑 업데이트
```

**완료 기준**: 코인 획득 기능 동작

---

#### 4.2.3 코인 소비 (번호 생성 통합)
**파일**: `backend/app/api/routes/generate.py` (수정)

**핵심 로직**:
```python
@router.post("/", response_model=GenerateResponse)
async def generate_numbers(
    request: GenerateRequest,
    user_id: UUID,
    db: Session = Depends(get_db)
):
    # 1. 알고리즘 비용 조회
    algo_cost = get_algorithm_cost(request.algorithm_id)
    
    # 2. 잔액 확인
    wallet = await wallet_repo.get_by_user(user_id)
    if wallet.total_coins < algo_cost:
        raise HTTPException(402, "코인 부족")
    
    # 3. 코인 차감 (트랜잭션)
    await wallet_repo.deduct_coins(user_id, algo_cost, db)
    
    # 4. 번호 생성
    # ...
```

**완료 기준**: 
- 코인 차감 후 번호 생성
- 잔액 부족 시 오류 응답

---

### 4.3 결제 연동 (1일, 선택)

#### 4.3.1 IAP 검증 (Phase 5 이후)
**파일**: `backend/app/services/payment_service.py`

#### 4.3.2 AdMob 광고 (Phase 5 이후)
**파일**: `backend/app/services/ad_verification_service.py`

---

### 4.4 Flutter 코인 UI (0.5일)

**파일**:
- `lib/presentation/screens/coin_store/coin_store_screen.dart`
- `lib/presentation/widgets/coin_balance_widget.dart`

**UI 요소**:
- 코인 잔액 표시 (헤더)
- 코인 스토어 화면
- 일일 로그인 버튼
- 광고 시청 버튼

**완료 기준**: 코인 획득/소비 플로우 완성

---

## Phase 5: 고급 기능 & 통합 (2-3일)

### 목표
사용자 번호 관리, 당첨 확인, 검증 시스템

### 5.1 사용자 번호 관리 (1일)

#### 5.1.1 DB 모델
**파일**: 
- `backend/app/db/models/user_generated_numbers.py`
- `backend/app/db/models/winning_check_result.py`

#### 5.1.2 API
**파일**: `backend/app/api/routes/my_numbers.py`

**엔드포인트**:
- `POST /api/my-numbers/save` - 번호 저장
- `GET /api/my-numbers` - 내 번호 목록
- `POST /api/my-numbers/check` - 당첨 확인

**완료 기준**: 내 번호 저장 및 조회

---

### 5.2 자동 당첨 확인 (1일)

#### 5.2.1 Celery Worker 설정
**파일**:
- `backend/app/workers/celery_app.py` - Celery 초기화
- `backend/app/workers/tasks.py` - 백그라운드 작업
- `backend/app/workers/beat_schedule.py` - 스케줄 설정

**핵심 작업**:
```python
@celery_app.task
def update_latest_draw():
    """새 회차 확인 및 업데이트"""
    # 1. 온라인 최신 회차 조회
    # 2. DB와 비교
    # 3. 새 회차면 크롤링
    # 4. 자동 당첨 확인 트리거

@celery_app.task
def auto_check_winning():
    """저장된 번호 자동 당첨 확인"""
    # 1. 미확인 번호 조회
    # 2. 최신 회차 당첨번호와 비교
    # 3. 당첨 결과 저장
    # 4. Push 알림 전송
```

**스케줄**:
```python
celery_app.conf.beat_schedule = {
    'update-draw-weekly': {
        'task': 'update_latest_draw',
        'schedule': crontab(day_of_week=6, hour=21, minute=0),  # 매주 토 21:00
    },
}
```

**완료 기준**: 
- Celery Worker 실행 성공
- 스케줄 작업 동작 확인

---

#### 5.2.2 Push 알림
**파일**: `backend/app/services/notification_service.py`

**기능**: 
- Firebase Cloud Messaging 연동
- 당첨 시 알림 전송

**완료 기준**: 당첨 시 Push 알림 수신

---

### 5.3 알고리즘 검증 시스템 (선택, 1일)

**파일**:
- `backend/app/validation/validator.py` - Walk-Forward Validation
- `backend/app/validation/evaluator.py` - 성능 평가
- `backend/scripts/run_validation.py` - 검증 실행 스크립트

**기능**: 
- 과거 데이터로 알고리즘 백테스팅
- 성능 지표 계산 (평균 매칭 개수, 등수 분포)
- 검증 결과 리포트 생성

**완료 기준**: 
- 검증 스크립트 실행 성공
- 결과 CSV/JSON 저장

---

## Phase 6: 배포 준비 (2일)

### 목표
프로덕션 환경 준비 및 최종 테스트

### 6.1 Docker 컨테이너화 (0.5일)

**파일**:
- `deployment/docker/Dockerfile.backend` - 백엔드 Docker 이미지
- `deployment/docker/docker-compose.yml` - 전체 스택

**완료 기준**: 
- `docker-compose up` 성공
- 컨테이너 내부에서 API 동작

---

### 6.2 CI/CD 파이프라인 (0.5일)

**파일**:
- `.github/workflows/backend_ci.yml` - 백엔드 자동 테스트
- `.github/workflows/flutter_ci.yml` - Flutter 빌드/테스트

**완료 기준**: 
- Git push 시 자동 테스트 실행
- 빌드 성공

---

### 6.3 AWS Lightsail 배포 (0.5일)

**작업**:
1. Lightsail 인스턴스 생성
2. PostgreSQL RDS 설정
3. Redis ElastiCache 설정
4. 백엔드 배포
5. 도메인 연결

**완료 기준**: 
- API 엔드포인트 외부 접근 가능
- `https://api.luckyai645.com` 동작

---

### 6.4 Flutter 앱 빌드 (0.5일)

**작업**:
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

**완료 기준**: 
- APK/AAB 생성 성공
- 테스트 디바이스 설치 및 동작 확인

---

### 6.5 통합 테스트 (0.5일)

**테스트 항목**:
1. 회원가입 (게스트)
2. 일일 로그인 보상
3. 광고 시청 (테스트)
4. 번호 생성 (각 알고리즘)
5. 내 번호 저장
6. 당첨 확인
7. 코인 구매 (IAP 테스트)

**완료 기준**: 전체 플로우 성공

---

## 📊 우선순위 매트릭스

### 최우선 (P0) - Phase 1, 2, 3 필수
| 모듈 | 이유 |
|------|------|
| 데이터 크롤링 | 데이터 없으면 아무것도 불가 |
| 알고리즘 (랜덤, 빈도, 핫콜드) | 핵심 기능 |
| API 서버 | 백엔드 기반 |
| Flutter UI | 사용자 인터페이스 |

### 높은 우선순위 (P1) - Phase 4
| 모듈 | 이유 |
|------|------|
| 코인 시스템 | 비즈니스 모델 |
| 게스트 인증 | 사용자 관리 |
| 내 번호 저장 | 핵심 기능 |

### 중간 우선순위 (P2) - Phase 5
| 모듈 | 이유 |
|------|------|
| 자동 당첨 확인 | 편의 기능 |
| Push 알림 | 리텐션 |
| Celery 백그라운드 작업 | 자동화 |

### 낮은 우선순위 (P3) - Phase 6+
| 모듈 | 이유 |
|------|------|
| 소셜 로그인 | 추후 확장 |
| IAP 결제 | 수익화 고도화 |
| ML 알고리즘 (LSTM, GAN) | 선택적 기능 |
| 검증 시스템 | 분석용 |

---

## 🛠️ 개발 도구 및 환경

### 백엔드 개발
- **IDE**: VS Code / PyCharm
- **디버깅**: Uvicorn --reload, Postman/Insomnia
- **DB 관리**: DBeaver / pgAdmin
- **테스트**: pytest, pytest-asyncio

### 프론트엔드 개발
- **IDE**: VS Code / Android Studio
- **디버깅**: Flutter DevTools, Dart DevTools
- **에뮬레이터**: Android Emulator / iOS Simulator
- **테스트**: flutter test, integration_test

### 협업 도구
- **버전 관리**: Git + GitHub
- **문서**: 현재 `.cursor/` 폴더의 설계 문서들
- **로그**: `.cursor/code_change_log.md`

---

## 🚨 주요 체크포인트

### Phase 1 완료 기준
- [ ] PostgreSQL에 로또 데이터 1~최신회차 저장
- [ ] `GET /api/draws/latest` API 응답 성공
- [ ] Redis 캐싱 동작 확인

### Phase 2 완료 기준
- [ ] 6개 알고리즘 번호 생성 성공
- [ ] `POST /api/generate` API 응답 성공
- [ ] Swagger UI에서 모든 API 테스트 통과

### Phase 3 완료 기준
- [ ] Flutter 앱 실행 및 홈 화면 표시
- [ ] 번호 생성 버튼 → 결과 화면 플로우 동작
- [ ] 로컬 저장소(Hive)에 데이터 저장 확인

### Phase 4 완료 기준
- [ ] 게스트 계정 자동 생성
- [ ] 코인 획득/소비 기능 동작
- [ ] 코인 부족 시 오류 처리

### Phase 5 완료 기준
- [ ] 내 번호 저장 및 조회
- [ ] Celery Worker 실행 및 스케줄 작업 확인
- [ ] 당첨 확인 결과 Push 알림

### Phase 6 완료 기준
- [ ] Docker Compose로 전체 스택 실행
- [ ] AWS Lightsail 배포 완료
- [ ] APK/AAB 빌드 성공

---

## 📝 개발 원칙 (재강조)

1. **코드 변경 시 반드시**:
   - 날짜/시간, 수정 이유를 주석으로 기록
   - 기존 코드는 주석 처리 후 보존
   - `.cursor/code_change_log.md`에 변경 이력 기록

2. **승인 전 설명**:
   - 코드 작성 전 변경 계획 요약 및 승인 요청
   - 승인 후에만 코드 수정 진행

3. **단위별 완성**:
   - 각 모듈/함수 완성 후 즉시 테스트
   - 문제 발견 시 즉시 수정

4. **문서 우선**:
   - 설계서와 불일치 시 설계서 우선
   - 불명확한 부분은 질문 후 진행

---

## 🎯 다음 단계

**로드맵 승인 후 즉시 착수 가능**:
1. Phase 0 디렉토리 생성 스크립트 실행
2. Backend requirements.txt 작성
3. Flutter pubspec.yaml 작성
4. PostgreSQL/Redis Docker Compose 작성

**마스터 승인 대기 중...**

---

**문서 종료**

