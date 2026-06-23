plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.adwhale_sdk_flutter_sample"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.adwhale_sdk_flutter_sample"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // ProGuard 활성화
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // 옵션 디펜던시(제외가능): Cauly Adapter SDK Repository
    implementation("net.adwhale.sdk.cauly.adapter:cauly-sdk:3.5.44.0")

    // 옵션 디펜던시(제외가능): Admize Adapter SDK Repository
    implementation("net.adwhale.sdk.admize.adapter:admize-sdk:1.0.8.2")

    // 옵션 디펜던시(제외가능): AdFit Adapter SDK Repository
    implementation("net.adwhale.sdk.adfit.adapter:adfit-sdk:3.21.17.1")

    // 옵션 디펜던시(제외가능): Admob Adapter SDK Repository
    implementation("net.adwhale.sdk.admob.adapter:admob-sdk:24.3.0.4")

    // 옵션 디펜던시(제외가능): Levelplay Adapter SDK Repository
    implementation("net.adwhale.sdk.levelplay.adapter:levelplay-sdk:8.12.0.1")

    implementation("com.google.ads.mediation:applovin:13.3.1.1") // Admob-AppLovin SDK dependency
    implementation("com.google.ads.mediation:fyber:8.3.7.0") // Admob-DT Exchange SDK dependency
    implementation("com.google.ads.mediation:inmobi:10.8.3.1") // Admob-InMobi SDK dependency
    implementation("com.google.ads.mediation:vungle:7.5.0.0") // Admob-Liftoff Monetize SDK dependency
    implementation("com.google.ads.mediation:mintegral:16.9.71.0") // Admob-Mintegral SDK dependency
    implementation("com.google.ads.mediation:pangle:7.2.0.4.0") // Admob-Pangle SDK dependency
    implementation("com.unity3d.ads:unity-ads:4.15.0") // Admob-Unity Ads SDK dependency
    implementation("com.google.ads.mediation:unity:4.15.0.0") // Admob-Unity Ads SDK dependency
    implementation("com.google.ads.mediation:moloco:3.10.0.0") // Admob-Moloco SDK dependency
    implementation("com.google.ads.mediation:ironsource:8.9.0.0") // Admob-Ironsource SDK dependency

}
flutter {
    source = "../.."
}
