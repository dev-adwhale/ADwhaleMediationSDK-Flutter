# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

#================== AdWhale Cauly Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.cauly.adapter.CaulyAdBannerLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyAdBannerPreLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyAdInterstitialLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyAdRewardLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyCustomEventInterstitialLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyCustomEventBannerLoader {*;}

-keep class net.adwhale.sdk.cauly.adapter.CaulyCustomEventRewardLoader {*;}

#================== AdWhale Cauly Adapter SDK Proguard for Release 적용 코드 끝 ==================

#================== AdWhale Admize Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.admize.adapter.AdmizeAdBannerLoader {*;}

-keep class net.adwhale.sdk.admize.adapter.AdmizeAdBannerPreLoader {*;}

-keep class net.adwhale.sdk.admize.adapter.AdmizeAdInterstitialLoader {*;}

-keep class net.adwhale.sdk.admize.adapter.AdmizeAdRewardLoader {*;}

#================== AdWhale Admize Adapter SDK Proguard for Release 적용 코드 끝 ==================

#================== AdWhale AdFit Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.adfit.adapter.AdFitAdBannerLoader {*;}

-keep class net.adwhale.sdk.adfit.adapter.AdFitAdBannerPreLoader {*;}

#================== AdWhale AdFit Adapter SDK Proguard for Release 적용 코드 끝 ==================

#================== AdWhale AdManager Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdBannerLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdBannerPreLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdInterstitialLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdNativeTemplateLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdNativeCustomBindingLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdRewardLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdManagerAdRewardedInterstitialLoader {*;}

#================== AdWhale AdManager Adapter SDK Proguard for Release 적용 코드 끝 ==================

#================== AdWhale Admob Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.admob.adapter.AdmobAdBannerLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdBannerPreLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdInterstitialLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdNativeTemplateLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdNativeCustomBindingLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdRewardLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.AdmobAdRewardedInterstitialLoader {*;}

-keep class net.adwhale.sdk.admob.adapter.custom.cauly.AdMobCaulyEvent {*;}

-keep class net.adwhale.sdk.admob.adapter.custom.cauly.CaulyMediationBannerAd {*;}

-keep class net.adwhale.sdk.admob.adapter.custom.cauly.CaulyMediationInterstitialAd {*;}

-keep class net.adwhale.sdk.admob.adapter.custom.cauly.CaulyMediationRewardAd {*;}

# AdWhale AdMob Adapter - Keep the public entry points for reflection
-keep public class net.adwhale.sdk.admob.adapter.AdMobPrivacyAdapter {
    public static net.adwhale.sdk.admob.adapter.AdMobPrivacyAdapter getInstance();
}

#================== AdWhale Admob Adapter SDK Proguard for Release 적용 코드 끝 ==================

#================== AdWhale LevelPlay Adapter SDK Proguard for Release 적용 코드 시작 ==================

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdBannerLoader {*;}

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdBannerPreLoader {*;}

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdInterstitialLoader {*;}

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdRewardLoader {*;}

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdNativeCustomBindingLoader {*;}

-keep class net.adwhale.sdk.levelplay.adapter.LevelPlayAdNativeTemplateLoader {*;}

# AdWhale LevelPlay Adapter - Keep the public entry points for reflection
-keep public class net.adwhale.sdk.levelplay.adapter.LevelPlayPrivacyAdapter {
    public static net.adwhale.sdk.levelplay.adapter.LevelPlayPrivacyAdapter getInstance();
}

#================== AdWhale LevelPlay Adapter SDK Proguard for Release 적용 코드 끝 ==================