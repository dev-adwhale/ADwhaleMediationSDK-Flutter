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
    implementation("net.adwhale.sdk.cauly.adapter:cauly-sdk:3.5.43.0")

    // 옵션 디펜던시(제외가능): Admize Adapter SDK Repository
    implementation("net.adwhale.sdk.admize.adapter:admize-sdk:1.0.8.1")

    // 옵션 디펜던시(제외가능): AdFit Adapter SDK Repository
    implementation("net.adwhale.sdk.adfit.adapter:adfit-sdk:3.21.17.0")

    // 옵션 디펜던시(제외가능): Admob Adapter SDK Repository
    implementation("net.adwhale.sdk.admob.adapter:admob-sdk:24.3.0.3")

    // 옵션 디펜던시(제외가능): Levelplay Adapter SDK Repository
    implementation("net.adwhale.sdk.levelplay.adapter:levelplay-sdk:8.11.0.0")
}
flutter {
    source = "../.."
}
