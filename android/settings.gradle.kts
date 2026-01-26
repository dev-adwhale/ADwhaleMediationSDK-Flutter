pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // AdWhale SDK Repository Public Access Info
        maven {
            url = uri("https://dev-adwhale.github.io/adwhale-sdk-android-maven/maven-repo")
        }
        // Cauly SDK Repository Public Access Info
        maven {
            url = uri("https://cauly.github.io/cauly-sdk-android-maven/maven-repo")
        }

        // Admize SDK Repository Public Access Info
        maven {
            url = uri("https://cauly.github.io/admize-sdk-android-maven/maven-repo")
        }

        // AdFit SDK Repository Public Access Info
        maven {
            url = uri("https://devrepo.kakao.com/nexus/content/groups/public/")
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
