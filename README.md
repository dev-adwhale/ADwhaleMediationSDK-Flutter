# AdWhale SDK Flutter Sample

AdWhale Mediation SDK Flutter 샘플 프로젝트입니다.

## Support platforms
| Platform | Support |
|----------|---------|
| Android  | O       |
| iOS      | O       |

## Support Features
| Features         | Support           |
|------------------|-------------------|
| SDK initialize   | O                 |
| Banner           | O                 |
| Interstitial     | O                 |
| Rewarded         | O                 |
| Native Template  | ⚠️(Android only)  |
| Native Custom    | O                 |
| App Open         | O                 |
| App Exit Popup   | ⚠️(Android only)  |
| Transition Popup | ⚠️(Android only)  |
| Event Callback   | O                 |

## Version
샘플 프로젝트에 적용된 Flutter SDK 버전은 ```2.7.4+0``` 입니다.

| Native SDK    | Flutter SDK |
|---------------|-------------|
| Android 2.7.4 | 2.7.4+0     |
| iOS 1.0.7     | 2.7.4+0     |

## 시작하기

### 1. 프로젝트 클론 및 의존성 설치

```bash
# 1. 프로젝트 클론
git clone https://github.com/dev-adwhale/ADwhaleMediationSDK-Flutter.git
cd ADwhaleMediationSDK-Flutter

# 2. Flutter 의존성 설치
flutter pub get

# 3. iOS 의존성 설치 (iOS 빌드 시에만 필요)
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

**`lib/config.dart`**  
각 광고 타입별 Placement UID를 설정하세요:

```dart
  static const Map<String, String> _config = {

  /// iOS 지면ID(AdUnitId) 정보
  'iosBannerAdUnitId': 'YOUR_IOS_BANNER_PLACEMENT_UID',
  'iosInterstitialAdUnitId': 'YOUR_IOS_INTERSTITIAL_PLACEMENT_UID',
  'iosRewardAdUnitId': 'YOUR_IOS_REWARD_PLACEMENT_UID',
  'iosAppOpenAdUnitId': 'YOUR_IOS_APP_OPEN_PLACEMENT_UID',
  'iosNativeAdUnitId': 'YOUR_IOS_NATIVE_PLACEMENT_UID',
  
  /// 안드로이드 지면ID(PlacementUid) 정보
  'banner320x50PlacementUid': 'YOUR_AOS_BANNER_PLACEMENT_UID',
  'banner320x100PlacementUid': 'YOUR_AOS_BANNER_PLACEMENT_UID',
  'banner300x250PlacementUid': 'YOUR_AOS_BANNER_PLACEMENT_UID',
  'banner250x250PlacementUid': 'YOUR_AOS_BANNER_PLACEMENT_UID',
  'interstitialPlacementUid1': 'YOUR_AOS_INTERSTITIAL_PLACEMENT_UID',
  'interstitialPlacementUid2': 'YOUR_AOS_INTERSTITIAL_PLACEMENT_UID',
  'interstitialPlacementUid3': 'YOUR_AOS_INTERSTITIAL_PLACEMENT_UID',
  'rewardPlacementUid1': 'YOUR_AOS_REWARD_PLACEMENT_UID',
  'rewardPlacementUid2': 'YOUR_AOS_REWARD_PLACEMENT_UID',
  'rewardPlacementUid3': 'YOUR_AOS_REWARD_PLACEMENT_UID',
  'nativePlacementUid': 'YOUR_AOS_NATIVE_PLACEMENT_UID',
  'appOpenPlacementUid': 'YOUR_AOS_APP_OPEN_PLACEMENT_UID',
  'exitPopupPlacementUid': 'YOUR_AOS_EXIT_POPUP_PLACEMENT_UID',
  'transitionPopupPlacementUid': 'YOUR_AOS_TRANSITION_POPUP_PLACEMENT_UID',
};
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
```

### 4. 환경 점검
```sh
flutter doctor
```

## 프로젝트 구조

- `lib/main.dart`: 앱 진입점 및 SDK 초기화, Android 전용 앱 종료 팝업 광고 구현
- `lib/guide_sample.dart`: Android iOS 모든 광고 타입 샘플 구현
  - 배너 광고
  - 전면 광고
  - 보상형 광고
  - 네이티브 템플릿 광고
  - 네이티브 커스텀 광고
  - 앱 오프닝 광고
- `lib/transition_popup_ad_test_page.dart`: Android 전용 전환 팝업 광고 구현


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
