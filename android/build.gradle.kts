allprojects {
    repositories {
        google()
        mavenCentral()
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

        // Mintegral SDK Repository
        maven {
            url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea")
        }

        // Pangle SDK Repository
        maven {
            url = uri("https://artifact.bytedance.com/repository/pangle/") }

        // Ironsource SDK Repository
        maven {
            url = uri("https://android-sdk.is.com/") }

    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
