import org.gradle.api.tasks.testing.logging.TestExceptionFormat

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.kotlinSerialization)
}

kotlin {
    jvmToolchain(21)

    jvm()
    iosArm64()
    iosSimulatorArm64()

    sourceSets {
        commonMain.dependencies {
            api(libs.kotlinx.datetime)
            implementation(libs.kotlinx.serialization.json)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
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
