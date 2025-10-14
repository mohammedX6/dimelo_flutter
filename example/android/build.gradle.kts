allprojects {
    repositories {
        google()
        mavenCentral()
        // Required for Dimelo / RingCentral Engage Digital Messaging SDKs used by :dimelo_flutter
        maven { url = uri("https://raw.github.com/ringcentral/engage-digital-messaging-android/master") }
        maven { url = uri("https://raw.github.com/ringcentral/engage-digital-messaging-android-location/master") }
        maven { url = uri("https://raw.github.com/dimelo/Dimelo-Android/master") }
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
