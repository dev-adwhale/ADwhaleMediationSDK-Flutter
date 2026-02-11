# AdWhale SDK Flutter Sample

AdWhale Mediation SDK Flutter 샘플 프로젝트입니다.

## 시작하기

### 1. 프로젝트 클론 및 의존성 설치

```bash
# 프로젝트 클론
git clone https://github.com/dev-adwhale/ADwhaleMediationSDK-Flutter.git
cd ADwhaleMediationSDK-Flutter

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

#### iOS 설정

1. **서명(Development Team) 설정**  
   iOS 빌드 전에 Xcode에서 개발 팀을 지정해야 합니다.
   - `ios/Runner.xcworkspace`를 Xcode로 엽니다.
   - **TARGETS** → **Runner** → **Signing & Capabilities** 탭으로 이동합니다.
   - **Team** 드롭다운에서 본인의 Apple Developer 팀을 선택합니다.  
   (팀이 없다면 [Apple Developer Program](https://developer.apple.com/programs/) 가입이 필요합니다.)

2. **AdMob 앱 ID 설정**  
   `ios/Runner/Info.plist`에서 AdMob Application ID를 설정하세요.
   - `GADApplicationIdentifier` 키의 값을 Google AdMob에서 발급받은 iOS 앱 ID로 변경합니다.  
   (예: `ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx`)

#### Placement UID 설정

**`lib/guide_sample_android.dart`**  
각 광고 타입별 Placement UID를 설정하세요:

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

**`lib/guide_sample_integration.dart`** (Android 배너 + iOS AdMob 배너 통합 샘플)  
이 파일도 사용할 경우 다음 두 값을 반드시 설정하세요:

- **`androidPlacementUid`**: AdWhale 대시보드에서 발급한 배너 Placement UID
- **`iosBannerAdUnitId`**: iOS용 Google AdMob 배너 광고 단위 ID (예: `ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx`)

```dart
adInfo: AdInfo(
  androidPlacementUid: 'YOUR_BANNER_PLACEMENT_UID',
  iosBannerAdUnitId: 'YOUR_IOS_ADMOB_BANNER_AD_UNIT_ID',
  bannerHeight: size,
),
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
- `lib/guide_sample_android.dart`: Android용 모든 광고 타입 샘플 구현
  - 배너 광고
  - 전면 광고
  - 보상형 광고
  - 네이티브 템플릿 광고
  - 네이티브 커스텀 광고
  - 앱 오프닝 광고
- `lib/guide_sample_integration.dart`: Android(iOS) 통합 배너 샘플
  - Android: AdWhale placement UID 사용
  - iOS: Google AdMob 배너 광고 단위 ID 사용

## 주요 기능

- ✅ AdWhale SDK 2.7.2+7 연동
- ✅ 모든 광고 타입 샘플 코드(iOS는 배너만)
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

- **Signing for "Runner" requires a development team**: Xcode에서 `ios/Runner.xcworkspace`를 연 뒤 **TARGETS** → **Runner** → **Signing & Capabilities**에서 **Team**을 선택하세요.
- **Pod / 빌드 캐시 문제**:
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
