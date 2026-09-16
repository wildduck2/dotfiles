// The three lists from azkar.json, as they will be shown.
package com.wildduck.azkar.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.UiState
import com.wildduck.azkar.core.Session
import com.wildduck.azkar.core.Zikr

@Composable
fun AzkarListPage(ui: UiState, features: Features, actions: AzkarActions) {
    var list by remember { mutableStateOf(Session.Sabah) }
    val items = when (list) {
        Session.Sabah -> ui.library.sabah
        Session.Masaa -> ui.library.masaa
        Session.General -> ui.library.general
    }

    Column(Modifier.fillMaxSize().padding(horizontal = 20.dp, vertical = 18.dp)) {
        Text("Azkar", style = MaterialTheme.typography.headlineSmall)
        Row(
            Modifier.fillMaxWidth().padding(top = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            for (session in Session.entries) {
                val count = when (session) {
                    Session.Sabah -> ui.library.sabah.size
                    Session.Masaa -> ui.library.masaa.size
                    Session.General -> ui.library.general.size
                }
                FilterChip(
                    selected = list == session,
                    onClick = { list = session },
                    label = { Text("${label(session)}  $count") },
                )
            }
            Spacer(Modifier.weight(1f))
            OutlinedButton(onClick = { actions.editAzkar() }) { Text("Edit azkar.json") }
        }

        LazyColumn(
            Modifier.fillMaxWidth().weight(1f).padding(top = 12.dp),
            verticalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            itemsIndexed(items) { i, zikr ->
                ZikrRow(i + 1, zikr, list, count(zikr, list, ui))
            }
        }
    }
}

@Composable
private fun ZikrRow(number: Int, zikr: Zikr, session: Session, count: Int) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(10.dp))
            .padding(horizontal = 12.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Text(
            number.toString(),
            Modifier.width(24.dp),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            style = MaterialTheme.typography.bodyMedium,
        )
        if (count > 1) {
            Text(
                "×$count",
                Modifier
                    .background(session.accent.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 6.dp, vertical = 2.dp),
                color = session.accent,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
            )
        }
        Text(
            zikr.text,
            Modifier.weight(1f),
            fontFamily = LocalArabic.current,
            fontSize = 15.sp,
            lineHeight = 24.sp,
            maxLines = 4,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.End,
        )
    }
}

private fun label(session: Session): String = when (session) {
    Session.Sabah -> "Morning"
    Session.Masaa -> "Evening"
    Session.General -> "General"
}

/** General azkar are one tap each unless "Repeat counts" is on. */
private fun count(zikr: Zikr, session: Session, ui: UiState): Int =
    if (session == Session.General && !ui.config.repeatGeneral) 1 else zikr.count
