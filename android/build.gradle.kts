// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    //id("com.google.gms.google-services") apply false  // ✅ IMPORTANT
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.1.4")
        // Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
        // Google Services Plugin (pour Firebase)
        classpath("com.google.gms:google-services:4.4.0")  // ✅ AJOUTER ICI
        // Flutter Gradle Plugin
        // Note: Le plugin Flutter est ajouté automatiquement
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration du répertoire de build (votre code actuel)
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