import org.gradle.api.tasks.testing.logging.TestExceptionFormat

plugins {
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.kotlinAndroid)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    jvmToolchain(21)
}

android {
    namespace = "com.wildduck.azkar.android"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.wildduck.azkar"
        minSdk = 26
        targetSdk = 37
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    buildFeatures {
        compose = true
    }

    // Filled in by copyAzkar below; a plain path, because the source-set API takes no task providers.
    sourceSets["main"].assets.srcDir("build/generated/azkarAssets")

    testOptions {
        unitTests.all {
            it.testLogging {
                events("passed", "failed")
                exceptionFormat = TestExceptionFormat.FULL
            }
        }
    }
}

dependencies {
    implementation(project(":shared"))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.core.ktx)

    testImplementation(libs.kotlin.test)
}

// The azkar that ship with the app: the very same file the macOS app installs.
val copyAzkar by tasks.registering(Copy::class) {
    from(rootDir.parentFile.resolve(".config/azkar/azkar.json"))
    into(layout.buildDirectory.dir("generated/azkarAssets"))
}

tasks.named("preBuild") {
    dependsOn(copyAzkar)
}
