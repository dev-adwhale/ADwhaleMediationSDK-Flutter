# AdWhale SDK Flutter Sample

AdWhale Mediation SDK Flutter 샘플 프로젝트입니다.

## 시작하기

### 1. 프로젝트 클론 및 의존성 설치

```bash
# 프로젝트 클론
git clone https://github.com/dev-adwhale/ADwhaleMediationSDK-Flutter.git
cd clone 위치폴더

# Flutter 의존성 설치
flutter pub get

# iOS 의존성 설치 (iOS 빌드 시에만 필요)
cd ios
pod install
cd ..
```

### 2. 필수 설정

#### Android 설정

`android/app/src/main/AndroidManifest.xml` 파일을 열어 다음 값을 설정하세요:

```xml
<!-- AdWhale SDK 설정 -->
<meta-data
    android:name="net.adwhale.sdk.mediation.PUBLISHER_UID"
    android:value="YOUR_PUBLISHER_UID" />

<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID" />
```

- `YOUR_PUBLISHER_UID`: AdWhale 대시보드에서 발급받은 Publisher UID
- `YOUR_ADMOB_APP_ID`: Google AdMob에서 발급받은 Application ID (예: `ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx`)

#### Placement UID 설정

`lib/guide_sample.dart` 파일을 열어 각 광고 타입별 Placement UID를 설정하세요:

```dart
_placementUidByType.addAll(<int, String>{
  0: "YOUR_BANNER_PLACEMENT_UID",      // 배너
  1: "YOUR_INTERSTITIAL_PLACEMENT_UID", // 전면
  2: "YOUR_REWARD_PLACEMENT_UID",       // 보상형전면
  3: "YOUR_NATIVE_TEMPLATE_PLACEMENT_UID", // 네이티브(템플릿)
  4: "YOUR_NATIVE_CUSTOM_PLACEMENT_UID",   // 네이티브(커스텀)
  5: "YOUR_APP_OPEN_PLACEMENT_UID",     // 앱 오프닝
});
```

### 3. 실행

```bash
# Android 실행
flutter run

# iOS 실행
flutter run

# 특정 디바이스에서 실행
flutter devices
flutter run -d <device-id>
```

## 프로젝트 구조

- `lib/main.dart`: 앱 진입점 및 SDK 초기화
- `lib/guide_sample.dart`: 모든 광고 타입 샘플 구현
  - 배너 광고
  - 전면 광고
  - 보상형 광고
  - 네이티브 템플릿 광고
  - 네이티브 커스텀 광고
  - 앱 오프닝 광고

## 주요 기능

- ✅ AdWhale SDK 2.7.2+6 연동
- ✅ 모든 광고 타입 샘플 코드
- ✅ COPPA, GDPR 설정 기능
- ✅ 로거 설정 기능
- ✅ ProGuard 설정 완료

## 요구사항

- Flutter SDK 3.9.2 이상
- Dart SDK 3.9.2 이상
- Android Studio / Xcode (네이티브 빌드용)

## 참고 문서

- [AdWhale SDK 가이드](https://adwhale.gitbook.io/adwhale-mediation-sdk/flutter/sdk)

## 문제 해결

### iOS 빌드 오류
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Android 빌드 오류
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
```

## 라이선스

이 프로젝트는 샘플 프로젝트입니다.
