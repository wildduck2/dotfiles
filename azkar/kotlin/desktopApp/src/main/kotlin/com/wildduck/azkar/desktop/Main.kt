// The Windows and Linux app. (On macOS this is only for development; the Mac app is apple/.)
package com.wildduck.azkar.desktop

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() = application {
    Window(onCloseRequest = ::exitApplication, title = "Azkar") {
        MaterialTheme {
            Text("Azkar")
        }
    }
}
