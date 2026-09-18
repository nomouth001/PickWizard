# Flutter SDK 설치 가이드 (Windows)

## 📍 설치 방법

### 1. Flutter SDK 다운로드

**공식 사이트**: https://docs.flutter.dev/get-started/install/windows

또는 직접 다운로드:
```
https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
```

### 2. 압축 해제

1. 다운로드한 ZIP 파일을 압축 해제
2. 권장 경로: `C:\src\flutter` (또는 원하는 경로)
3. **중요**: 경로에 공백이나 특수문자가 없어야 합니다

### 3. 환경 변수 설정

#### PowerShell에서 설정:

```powershell
# 시스템 환경 변수 편집 창 열기
rundll32 sysdm.cpl,EditEnvironmentVariables

# 또는 PowerShell로 직접 추가 (관리자 권한 필요)
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\src\flutter\bin",
    "User"
)
```

#### 수동 설정:
1. "내 PC" 우클릭 → "속성"
2. "고급 시스템 설정"
3. "환경 변수"
4. "사용자 변수"에서 "Path" 선택 → "편집"
5. "새로 만들기" → `C:\src\flutter\bin` 입력
6. "확인"

### 4. 설치 확인

**새 PowerShell 창을 열고**:

```powershell
flutter --version
```

정상 출력:
```
Flutter 3.24.5 • channel stable
Framework • revision xxx
Engine • revision xxx
Tools • Dart 3.5.4
```

### 5. Flutter Doctor 실행

```powershell
flutter doctor
```

출력 예시:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.5, on Microsoft Windows)
[✗] Android toolchain - develop for Android devices
    ✗ Android SDK not found
[✗] Chrome - develop for the web
[✗] Visual Studio - develop Windows apps
[✓] VS Code (version 1.85.1)
[!] Connected device
```

**걱정하지 마세요!** Android Studio 등은 나중에 설치해도 됩니다.

### 6. Flutter 프로젝트 생성 테스트

```powershell
cd H:\_Lotto_picker_app\pick_wizard

# Flutter 프로젝트 생성
flutter create mobile_app
```

---

## 🚨 문제 해결

### 1. "flutter를 찾을 수 없습니다"

- PowerShell을 **완전히 종료**하고 다시 열기
- 시스템 재시작
- Path 환경 변수 확인

### 2. "Dart SDK를 찾을 수 없습니다"

```powershell
# Flutter에 포함된 Dart 사용
flutter doctor
```

### 3. 느린 다운로드

```powershell
# 중국 미러 사용 (선택사항)
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

---

## ✅ 설치 완료 확인

다음 명령어가 정상 작동하면 설치 완료:

```powershell
flutter --version
flutter doctor
```

---

**설치가 완료되면 알려주세요!**
그러면 바로 Phase 3 개발을 시작하겠습니다.

---

## 🎯 빠른 설치 (PowerShell - 관리자 권한)

```powershell
# 1. Flutter SDK 다운로드 디렉토리 생성
New-Item -ItemType Directory -Force -Path C:\src

# 2. Flutter SDK 다운로드
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile "C:\src\flutter.zip"

# 3. 압축 해제
Expand-Archive -Path "C:\src\flutter.zip" -DestinationPath "C:\src" -Force

# 4. 환경 변수 추가
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\src\flutter\bin",
    "User"
)

Write-Host "Flutter SDK 설치 완료!" -ForegroundColor Green
Write-Host "새 PowerShell 창을 열고 'flutter --version'을 실행하세요." -ForegroundColor Yellow
```

---

**작성일**: 2026-01-04 EST

