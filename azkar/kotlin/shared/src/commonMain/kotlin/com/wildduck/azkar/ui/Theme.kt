// How Azkar looks on every platform: the colours, the Arabic font, and each list's accent.
package com.wildduck.azkar.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.resources.Res
import com.wildduck.azkar.resources.noto_naskh_arabic_bold
import com.wildduck.azkar.resources.noto_naskh_arabic_regular
import org.jetbrains.compose.resources.Font

/** The colour each list is drawn in, on cards and in the window. */
val Session.accent: Color
    get() = when (this) {
        Session.Sabah -> Color(0xFFF5A33C)
        Session.Masaa -> Color(0xFFA98BF0)
        Session.General -> Color(0xFF45C8C0)
    }

/** Cards are always dark, whatever the rest of the desktop is doing. */
object CardColors {
    val surface = Color(0xFF212223)
    val text = Color(0xFFF2F3F5)
    val secondary = Color(0xFFA8AFB4)
    val tertiary = Color(0xFF7C8388)
}

private val darkScheme = darkColorScheme(
    primary = Color(0xFF45C8C0),
    onPrimary = Color(0xFF00201C),
    secondary = Color(0xFFF5A33C),
    background = Color(0xFF101315),
    onBackground = Color(0xFFE6E9EB),
    surface = Color(0xFF15181B),
    onSurface = Color(0xFFE6E9EB),
    surfaceVariant = Color(0xFF1E2327),
    onSurfaceVariant = Color(0xFFB4BCC1),
    outlineVariant = Color(0xFF2C3237),
    error = Color(0xFFF08A7A),
)

private val lightScheme = lightColorScheme(
    primary = Color(0xFF0E7C74),
    onPrimary = Color.White,
    secondary = Color(0xFFB4651A),
    background = Color(0xFFF1F3F5),
    onBackground = Color(0xFF1A1D1F),
    surface = Color(0xFFFBFCFD),
    onSurface = Color(0xFF1A1D1F),
    surfaceVariant = Color(0xFFE7EAED),
    onSurfaceVariant = Color(0xFF474F54),
    outlineVariant = Color(0xFFD3D8DC),
    error = Color(0xFFB3261E),
)

/** Noto Naskh Arabic, which ships with the app so harakat look the same everywhere. */
val LocalArabic = staticCompositionLocalOf<FontFamily> { FontFamily.Default }

@Composable
fun AzkarTheme(dark: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    val arabic = FontFamily(
        Font(Res.font.noto_naskh_arabic_regular, FontWeight.Normal),
        Font(Res.font.noto_naskh_arabic_bold, FontWeight.Bold),
    )
    MaterialTheme(colorScheme = if (dark) darkScheme else lightScheme) {
        CompositionLocalProvider(LocalArabic provides arabic, content = content)
    }
}

/** The row colours, the same ones the macOS app uses. */
object Accents {
    val teal = Color(0xFF45C8C0)
    val orange = Color(0xFFF5A33C)
    val purple = Color(0xFFA98BF0)
    val indigo = Color(0xFF7C86F0)
    val blue = Color(0xFF4FA3F7)
    val green = Color(0xFF5CC36A)
    val pink = Color(0xFFF07FA8)
    val grey = Color(0xFF9AA1A6)
}
