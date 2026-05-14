/**
 * AdWhale SDK Configuration
 * This file contains build-type specific configuration values.
 * kDebugMode is automatically set to true in debug builds and false in release builds.
 */

/// AdWhale SDK 설정값을 관리하는 클래스
class AdConfig {

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

  // Export individual values for convenience
  static String get iosBannerAdUnitId => _config['iosBannerAdUnitId']!;
  static String get iosInterstitialAdUnitId => _config['iosInterstitialAdUnitId']!;
  static String get iosRewardAdUnitId => _config['iosRewardAdUnitId']!;
  static String get iosAppOpenAdUnitId => _config['iosAppOpenAdUnitId']!;
  static String get iosNativeAdUnitId => _config['iosNativeAdUnitId']!;
  static String get banner320x50PlacementUid => _config['banner320x50PlacementUid']!;
  static String get banner320x100PlacementUid => _config['banner320x100PlacementUid']!;
  static String get banner300x250PlacementUid => _config['banner300x250PlacementUid']!;
  static String get banner250x250PlacementUid => _config['banner250x250PlacementUid']!;
  static String get interstitialPlacementUid1 => _config['interstitialPlacementUid1']!;
  static String get interstitialPlacementUid2 => _config['interstitialPlacementUid2']!;
  static String get interstitialPlacementUid3 => _config['interstitialPlacementUid3']!;
  static String get rewardPlacementUid1 => _config['rewardPlacementUid1']!;
  static String get rewardPlacementUid2 => _config['rewardPlacementUid2']!;
  static String get rewardPlacementUid3 => _config['rewardPlacementUid3']!;
  static String get nativePlacementUid => _config['nativePlacementUid']!;
  static String get appOpenPlacementUid => _config['appOpenPlacementUid']!;
  static String get exitPopupPlacementUid => _config['exitPopupPlacementUid']!;
  static String get transitionPopupPlacementUid =>
      _config['transitionPopupPlacementUid']!;

  // Legacy support - 기본 placementUid (banner320x50 사용)
  static String get placementUid => banner320x50PlacementUid;
}
