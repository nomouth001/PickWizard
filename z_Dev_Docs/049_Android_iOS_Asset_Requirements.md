# 049. Android / iOS 앱 에셋 종류 및 폴더 구조

Flutter 앱(럭키 찬스 645)을 Android·iOS 각 플랫폼에 배포할 때 필요한 **에셋의 종류**와 **폴더/파일 위치**를 정리한 문서이다.  
실제 이미지 제작은 디자인 도구에서 하며, 여기서는 **필요한 항목과 경로**만 기술한다.

---

## 1. Android 에셋

기준 경로: `[프로젝트]/android/app/src/main/res/`

### 1.1 앱 아이콘 (라운처 아이콘)

| 용도 | 폴더 | 파일명 | 비고 |
|------|------|--------|------|
| MDPI (~160dpi) | `res/mipmap-mdpi/` | `ic_launcher.png` | 48×48 px |
| HDPI (~240dpi) | `res/mipmap-hdpi/` | `ic_launcher.png` | 72×72 px |
| XHDPI (~320dpi) | `res/mipmap-xhdpi/` | `ic_launcher.png` | 96×96 px |
| XXHDPI (~480dpi) | `res/mipmap-xxhdpi/` | `ic_launcher.png` | 144×144 px |
| XXXHDPI (~640dpi) | `res/mipmap-xxxhdpi/` | `ic_launcher.png` | 192×192 px |

- **AndroidManifest.xml**에서 `android:icon="@mipmap/ic_launcher"` 로 참조한다.
- PNG, 투명 영역 가능. 정사각형 권장(시스템이 형태 적용).

### 1.2 적응형 아이콘 (Adaptive Icon, API 26+)

다양한 기기에서 마스크(원형·둥근 사각형 등)가 잘리지 않도록 **전경·배경**을 분리해 둔다.

| 용도 | 폴더 | 파일명 | 비고 |
|------|------|--------|------|
| 전경(포그라운드) | `res/drawable/` 또는 `res/mipmap-*/` | `ic_launcher_foreground.png` | 로고·심볼. 108×108 dp 기준, 중앙 66×66 dp 세이프존 권장 |
| 배경(백그라운드) | `res/drawable/` | `ic_launcher_background.png` 또는 XML로 단색 | 108×108 dp. 또는 `ic_launcher_background.xml`에서 color 사용 |

- **drawable**에 `ic_launcher.xml`(또는 `mipmap-anydpi-v26/ic_launcher.xml`)로 `adaptive-icon` 정의 시, 위 전경·배경을 참조한다.
- Flutter 기본 템플릿에는 적응형 아이콘 설정이 없을 수 있으므로, 필요 시 `mipmap-anydpi-v26` 폴더와 XML을 추가한다.

### 1.3 스플래시 / 런치 화면

| 용도 | 폴더 | 파일명 | 비고 |
|------|------|--------|------|
| 런치 배경 | `res/drawable/` | `launch_background.xml` | 레이어리스트. 현재는 흰색 배경만 사용. |
| (선택) 런치 이미지 | `res/drawable/` 또는 `res/mipmap-*/` | 예: `launch_image.png` | 로고 등. `launch_background.xml`에서 bitmap으로 참조 |

- **다크 모드**: `res/drawable-v21/launch_background.xml`, `res/values-night/` 등으로 테마별 리소스 가능.
- Flutter 2+ 에서는 `flutter_native_splash` 패키지로 스플래시를 생성·관리하는 방식도 많이 쓴다.

### 1.4 Android 리소스 폴더 요약

```
android/app/src/main/res/
├── drawable/              # 런치 배경 XML, (선택) 아이콘/이미지
├── drawable-v21/          # API 21+ 전용 drawable (예: 런치)
├── mipmap-mdpi/           # ic_launcher.png (48px)
├── mipmap-hdpi/           # ic_launcher.png (72px)
├── mipmap-xhdpi/          # ic_launcher.png (96px)
├── mipmap-xxhdpi/         # ic_launcher.png (144px)
├── mipmap-xxxhdpi/        # ic_launcher.png (192px)
├── mipmap-anydpi-v26/     # (선택) adaptive icon XML
├── values/                # styles.xml, colors 등
└── values-night/          # (선택) 다크 테마
```

---

## 2. iOS 에셋

기준 경로: `[프로젝트]/ios/Runner/Assets.xcassets/`

### 2.1 앱 아이콘 (AppIcon)

**폴더**: `Runner/Assets.xcassets/AppIcon.appiconset/`

**필수 이미지** (파일명은 예시, `Contents.json`과 일치해야 함):

| 용도 | idiom | size | scale | 파일명 예 | 픽셀 |
|------|-------|------|-------|------------|------|
| iPhone | iphone | 20×20 | 2x | Icon-App-20x20@2x.png | 40×40 |
| iPhone | iphone | 20×20 | 3x | Icon-App-20x20@3x.png | 60×60 |
| iPhone | iphone | 29×29 | 1x | Icon-App-29x29@1x.png | 29×29 |
| iPhone | iphone | 29×29 | 2x | Icon-App-29x29@2x.png | 58×58 |
| iPhone | iphone | 29×29 | 3x | Icon-App-29x29@3x.png | 87×87 |
| iPhone | iphone | 40×40 | 2x | Icon-App-40x40@2x.png | 80×80 |
| iPhone | iphone | 40×40 | 3x | Icon-App-40x40@3x.png | 120×120 |
| iPhone | iphone | 60×60 | 2x | Icon-App-60x60@2x.png | 120×120 |
| iPhone | iphone | 60×60 | 3x | Icon-App-60x60@3x.png | 180×180 |
| iPad | ipad | 20×20 | 1x | Icon-App-20x20@1x.png | 20×20 |
| iPad | ipad | 20×20 | 2x | Icon-App-20x20@2x.png | 40×40 |
| iPad | ipad | 29×29 | 1x | Icon-App-29x29@1x.png | 29×29 |
| iPad | ipad | 29×29 | 2x | Icon-App-29x29@2x.png | 58×58 |
| iPad | ipad | 40×40 | 1x | Icon-App-40x40@1x.png | 40×40 |
| iPad | ipad | 40×40 | 2x | Icon-App-40x40@2x.png | 80×80 |
| iPad | ipad | 76×76 | 1x | Icon-App-76x76@1x.png | 76×76 |
| iPad | ipad | 76×76 | 2x | Icon-App-76x76@2x.png | 152×152 |
| iPad Pro | ipad | 83.5×83.5 | 2x | Icon-App-83.5x83.5@2x.png | 167×167 |
| App Store | ios-marketing | 1024×1024 | 1x | Icon-App-1024x1024@1x.png | 1024×1024 |

- **App Store 제출용**: 1024×1024는 **알파 채널 없이** 제출해야 한다(투명 불가).
- **Contents.json**: 위 파일명·size·idiom·scale과 일치하도록 유지한다. Xcode에서 AppIcon 이미지셋을 편집하면 자동 갱신된다.


**알파 채널(Alpha channel)**
이미지에서 투명도를 담당하는 정보예요.
알파가 있으면: 픽셀마다 “얼마나 투명한지”가 있어서, 반투명·완전 투명을 표현할 수 있어요.
알파가 없으면: 픽셀은 전부 불투명이라서, 투명한 부분을 만들 수 없어요.
“알파 채널 없이” = “투명 불가”
RGB만 쓰고 Alpha 채널은 제거한 이미지라는 뜻이에요.
즉, 투명한 부분이 하나도 없어야 하고, 1024×1024 전체가 실제 색(픽셀)으로 채워져 있어야 해요.
PNG로 저장할 때 “투명 배경”을 쓰지 말고, 배경까지 포함해 전부 불투명한 색으로 저장해야 한다는 의미예요.
왜 이렇게 하냐면
App Store/Apple이 그 아이콘을 여러 배경(다크 모드, 스토어 페이지 등) 위에 올리기 때문에, 투명한 아이콘이 있으면 예상치 못한 모양이 나올 수 있어요.
그래서 Apple이 1024×1024 아이콘만 “알파 없음(투명 불가)”을 요구하는 거예요.
실무에서 할 일
1024×1024 아이콘을 만들 때:
투명 배경 쓰지 말고,
아이콘 뒤를 단색(예: 흰색·브랜드 색) 등으로 채운 불투명 PNG로 내보내거나,
포토샵/일러스트 등에서 “알파 채널 제거” 후 저장하면 돼요.


### 2.2 런치 스크린 / 스플래시

**런치 이미지 (선택)**  
**폴더**: `Runner/Assets.xcassets/LaunchImage.imageset/`

| scale | 파일명 예 | 비고 |
|-------|------------|------|
| 1x | LaunchImage.png | 범용 |
| 2x | LaunchImage@2x.png | |
| 3x | LaunchImage@3x.png | |

- **Contents.json**에 위 파일명이 등록되어 있어야 한다.
- **LaunchScreen.storyboard**: `Runner/Base.lproj/LaunchScreen.storyboard` 에서 배경색·이미지 뷰를 설정한다. 스토리보드만으로도 런치 화면 구성 가능(이미지셋 없이).

### 2.3 iOS 에셋 폴더 요약

```
ios/Runner/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/     # 앱 아이콘 (위 표 참고)
│   │   ├── Contents.json
│   │   └── Icon-App-*.png
│   └── LaunchImage.imageset/   # (선택) 런치 이미지
│       ├── Contents.json
│       ├── LaunchImage.png
│       ├── LaunchImage@2x.png
│       └── LaunchImage@3x.png
└── Base.lproj/
    └── LaunchScreen.storyboard # 런치 화면 레이아웃
```

---

## 3. Flutter 공통 에셋 (앱 내 사용)

**경로**: `pubspec.yaml`의 `flutter: assets:` 에 등록한 경로(예: 프로젝트 루트의 `assets/`).

| 용도 | 예시 경로 | 비고 |
|------|-----------|------|
| 이미지 | `assets/images/` | PNG, JPG 등 |
| 아이콘(앱 내) | `assets/icons/` | 버튼·탭 등 UI용 |
| 폰트 | `assets/fonts/` | pubspec에 `fonts:` 로 등록 |

- Android/iOS **네이티브** 아이콘·런치 이미지는 위 1·2절 경로에 두고, **앱 내에서 로드하는 이미지**는 이 공통 assets에 두는 것이 일반적이다.

---

## 4. 자동 생성 도구 (참고)

### 4.1 flutter_launcher_icons

**역할**: 하나의 소스 이미지(예: 1024×1024 PNG)로 Android mipmap·iOS AppIcon·적응형 아이콘(foreground/background)까지 한 번에 생성.

**사용 방법**

1. **의존성 추가**  
   `pubspec.yaml`의 `dev_dependencies`에 `flutter_launcher_icons` 추가 후 `flutter pub get`.
2. **설정**  
   `pubspec.yaml`에 `flutter_launcher_icons:` 블록을 넣거나, 프로젝트 루트에 `flutter_launcher_icons.yaml` 생성.  
   - `image_path`: 소스 아이콘 경로. **프로젝트 루트**(`pubspec.yaml`이 있는 폴더) 기준 상대 경로.  
     - 예: `assets/icon/app_icon.png`  
     - 이 프로젝트에서의 **전체 경로**: `pick_wizard/mobile_app/assets/icon/app_icon.png`  
     - `assets/icon/` 폴더가 없으면 직접 생성한 뒤, 원본 PNG를 `app_icon.png` 이름으로 넣으면 됨.  
   - `android: true/false`, `ios: true/false` 등으로 플랫폼별 생성 여부 지정.  
   - Android 적응형 아이콘은 `adaptive_icon_foreground`, `adaptive_icon_background` 등으로 지정.
   - **macOS**: `macos: { generate: true, image_path: "..." }` 로 `macos/Runner/Assets.xcassets/AppIcon.appiconset/` 생성.
   - **Web**: `web: { generate: true, image_path: "..." }` 로 `web/favicon.png`, `web/icons/Icon-*.png` 생성.
3. **실행**  
   터미널에서 `dart run flutter_launcher_icons` 실행.  
   설정에 따라 `android/app/src/main/res/`의 mipmap·drawable, `ios/Runner/Assets.xcassets/AppIcon.appiconset/`, **macOS·Web** 아이콘이 자동 생성·덮어쓰기됨.
4. **Android `build/` 폴더**  
   `build/` 안의 mipmap은 **빌드 결과물**이라 도구가 직접 수정하지 않음. 소스(`res/mipmap-*/ic_launcher.png`)가 갱신된 뒤 **`flutter clean`** 실행 후 다시 **`flutter run`** 또는 **`flutter build apk`** 하면 새 아이콘이 패키징됨.

**설정 파일 자동 생성**: `dart run flutter_launcher_icons:generate` 로 `flutter_launcher_icons.yaml` 템플릿을 만들 수 있음.

**공식 문서**: [pub.dev – flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

**경로: pick_wizard/mobile_app/pubspec.yaml** 
(저장소 루트 기준: _Lotto_picker_app 아래 pick_wizard/mobile_app/ 폴더 안)
flutter_launcher_icons나 flutter_native_splash를 쓸 때는 Flutter 프로젝트 루트, 즉 pubspec.yaml이 있는 디렉터리에서 flutter pub get, dart run flutter_launcher_icons 같은 명령을 실행하면 됩니다.

---

### 4.2 flutter_native_splash

**역할**: 스플래시(네이티브 런치 화면)의 배경색·중앙 이미지를 설정하면, Android `drawable`·iOS `LaunchImage`/스토리보드에 맞는 리소스를 자동 생성. Flutter가 로드되기 전 흰 화면 대신 지정한 스플래시가 보이게 함.

**사용 방법**

1. **의존성 추가**  
   `pubspec.yaml`의 `dev_dependencies`에 `flutter_native_splash` 추가 후 `flutter pub get`.
2. **설정**  
   `pubspec.yaml`에 `flutter_native_splash:` 블록을 넣거나, 프로젝트 루트에 `flutter_native_splash.yaml` 생성.  
   - `color`: 배경색(필수, 단색 사용 시).  
   - `color_dark`: 다크 모드 배경색(선택).  
   - `image`: 중앙에 표시할 로고 이미지 경로(선택).  
   - `background_image`: 전체 배경 이미지(선택, `color` 대신 사용 가능).  
   - Android/iOS별로 `color`, `image` 등 오버라이드 가능.
3. **생성**  
   터미널에서 `dart run flutter_native_splash:create` 실행.  
   Android `res/drawable/launch_background.xml` 등, iOS `LaunchImage.imageset`·스토리보드 등이 생성·갱신됨.
4. **제거(원복)**  
   기본 Flutter 스플래시로 되돌리려면 `dart run flutter_native_splash:remove` 실행.

**공식 문서**: [pub.dev – flutter_native_splash](https://pub.dev/packages/flutter_native_splash)

---

이 문서는 **에셋 종류와 폴더 구조**만 정의하며, 디자인 가이드(색상·사이즈 상세)는 별도 디자인 스펙을 참고하면 된다.

---

## 5. 다국어(로케일)와 에셋

### 5.1 언어별로 에셋이 모두 필요한가?

**아니요.**  
앱 아이콘·런치 스크린(스플래시)은 **보통 언어와 관계없이 한 세트만** 사용한다.  
설정 언어가 바뀌어도 홈 화면 아이콘과 런치 이미지는 동일한 것이 일반적이므로, **다국어 앱이라도 아이콘/런치 에셋은 1세트만 두면 된다.**

언어별로 **다른 에셋이 필요한 경우**는 예를 들어 다음과 같다.

- 스플래시에 언어별 문구가 들어가는 이미지(예: "럭키 찬스" / "Lucky Chance" 등)
- 지역별로 다른 앱 아이콘(브랜딩 정책 등)
- 앱 **내부**에서 쓰는 로고·일러스트를 언어/지역별로 다르게 보여주는 경우(이때는 Flutter 공통 에셋을 언어별로 나누어 로드)

### 5.2 언어별 에셋을 쓸 때, 파일명·폴더는 어떻게 구분하나?

**파일명은 같게 두고, 폴더(리소스 한정자)로만 구분한다.**  
즉, **각 언어마다 다른 폴더**를 쓰고, **같은 파일명**을 사용한다.  
코드에서는 `@mipmap/ic_launcher`처럼 **리소스 이름만** 참조하면 되고, 시스템이 현재 로케일에 맞는 폴더를 자동으로 선택한다.

#### Android: 리소스 한정자(qualifier)로 폴더 구분

- **폴더 이름**에 로케일 접미사를 붙인다.  
  예: `mipmap-ko`, `mipmap-ja`, `mipmap-th`, `mipmap-vi`, `mipmap-zh`, `drawable-ko` 등.  
  밀도와 같이 쓰면: `mipmap-ko-hdpi`, `mipmap-ja-xhdpi` (순서는 [공식 문서](https://developer.android.com/guide/topics/resources/providing-resources) 참고).
- **파일명**은 언어와 무관하게 동일하게 둔다.  
  예: 모든 폴더에 `ic_launcher.png`, `launch_image.png`.

| 로케일 | 폴더 예 (아이콘) | 파일명 |
|--------|-------------------|--------|
| 기본(fallback) | `mipmap-hdpi/` | `ic_launcher.png` |
| 한국어 | `mipmap-ko-hdpi/` | `ic_launcher.png` |
| 일본어 | `mipmap-ja-hdpi/` | `ic_launcher.png` |
| 태국어 | `mipmap-th-hdpi/` | `ic_launcher.png` |
| 베트남어 | `mipmap-vi-hdpi/` | `ic_launcher.png` |
| 중국어 | `mipmap-zh-hdpi/` | `ic_launcher.png` |
| 영어 | `mipmap-en-hdpi/` (필요 시) | `ic_launcher.png` |

- 참조는 그대로 `@mipmap/ic_launcher`.  
  기기 언어가 한국어면 `mipmap-ko-*` 계열이 선택되고, 해당 폴더가 없으면 기본 `mipmap-*`로 폴백된다.

#### iOS: Asset Catalog 언어 변형 또는 .lproj

- **Asset Catalog (Assets.xcassets)**  
  이미지셋(예: AppIcon, LaunchImage)에 **Language**를 추가하면, 같은 이미지셋 이름으로 언어별 이미지를 넣을 수 있다.  
  파일명은 이미지셋 내에서 1x/2x/3x 등으로만 구분하고, “어떤 언어용인지”는 카탈로그 설정으로 구분한다.
- **.lproj 폴더**  
  `ko.lproj`, `ja.lproj` 등에 이미지 파일을 두는 방식도 있다.  
  이때도 **파일명은 동일**하게 두고, 폴더로 로케일을 구분한다.

정리하면, **“각 언어마다 다른 폴더(또는 카탈로그 내 언어 변형), 같은 파일명”**이면 되고, **파일명 자체를 언어별로 바꿀 필요는 없다.**
