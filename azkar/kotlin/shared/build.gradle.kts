import org.gradle.api.tasks.testing.logging.TestExceptionFormat

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.kotlinSerialization)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    jvmToolchain(21)

    jvm()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            api(libs.kotlinx.datetime)
            api(libs.kotlinx.coroutines.core)
            implementation(libs.kotlinx.serialization.json)
            api(compose.runtime)
            api(compose.foundation)
            api(compose.ui)
            api(libs.compose.material3)
            api(compose.components.resources)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
            implementation(libs.compose.ui.test)
        }
        jvmTest.dependencies {
            // The UI tests draw for real, so they need this machine's Compose backend (Skia, AWT).
            implementation(compose.desktop.currentOs)
        }
    }
}

compose.resources {
    publicResClass = true
    packageOfResClass = "com.wildduck.azkar.resources"
    generateResClass = always
}

val azkarPackage: File = rootDir.parentFile

tasks.named<Test>("jvmTest") {
    // ShippedFilesTest reads the real azkar.json and config.json; rerun it when they change.
    systemProperty("azkar.package", azkarPackage.absolutePath)
    inputs.dir(azkarPackage.resolve(".config/azkar")).withPropertyName("shippedFiles")
    testLogging {
        events("passed", "failed")
        exceptionFormat = TestExceptionFormat.FULL
    }
}
