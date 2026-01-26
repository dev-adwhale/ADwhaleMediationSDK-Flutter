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
