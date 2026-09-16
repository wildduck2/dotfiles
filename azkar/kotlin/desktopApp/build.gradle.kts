import org.gradle.api.tasks.testing.logging.TestExceptionFormat
import org.jetbrains.compose.desktop.application.dsl.TargetFormat

plugins {
    alias(libs.plugins.kotlinJvm)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
}

kotlin {
    jvmToolchain(21)
}

dependencies {
    implementation(project(":shared"))
    implementation(compose.desktop.currentOs)
    implementation(libs.kotlinx.coroutines.swing)
    implementation(libs.composenativetray)
    // The global shortcut: RegisterHotKey on Windows, XGrabKey on an X11 session.
    implementation(libs.jna)
    implementation(libs.jna.platform)
    // The GlobalShortcuts portal on a Wayland session.
    implementation(libs.dbus.java.core)
    runtimeOnly(libs.dbus.java.unixsocket)
    runtimeOnly(libs.slf4j.nop)

    testImplementation(libs.kotlin.test)
    testImplementation(libs.dbus.java.unixsocket)
}

tasks.withType<Test>().configureEach {
    useJUnitPlatform()
    testLogging {
        events("passed", "failed")
        exceptionFormat = TestExceptionFormat.FULL
    }
}

compose.desktop.application {
    mainClass = "com.wildduck.azkar.desktop.MainKt"

    nativeDistributions {
        // jpackage only builds for the OS it runs on: .deb on Linux, .msi on Windows.
        targetFormats(TargetFormat.Deb, TargetFormat.Msi, TargetFormat.Dmg)
        packageName = "azkar"
        packageVersion = "1.0.0"
        vendor = "wildduck"
        description = "A zikr card every few minutes"
        // jdk.unsupported: JNA. java.management: the single-instance lock reports the running pid.
        modules("jdk.unsupported", "java.management")

        linux {
            packageName = "azkar"
            debMaintainer = "azkar@localhost"
            appCategory = "Utility"
            menuGroup = "Utility"
        }
        windows {
            packageName = "Azkar"
            menu = true
            menuGroup = "Azkar"
            shortcut = true
            dirChooser = true
            // Fixed, so an .msi upgrades the installed app instead of installing beside it.
            upgradeUuid = "6f1c2e84-3a27-4d0b-9c16-5b8f0a7d41e2"
        }
    }
}
