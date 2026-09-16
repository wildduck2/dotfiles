// The window: the five pages, with a sidebar when there's room and tabs when there isn't.
package com.wildduck.azkar.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.VerticalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.wildduck.azkar.app.Features
import com.wildduck.azkar.app.UiState

/** The window's pages, in the order they are listed. */
enum class AzkarTab(val title: String, val color: Color) {
    Today("Today", Accents.teal),
    Schedule("Schedule", Accents.orange),
    Cards("Cards", Accents.pink),
    Azkar("Azkar", Accents.purple),
    General("General", Accents.grey),
}

@Composable
fun AzkarWindow(
    ui: UiState,
    features: Features,
    actions: AzkarActions,
    modifier: Modifier = Modifier,
) {
    var tab by remember { mutableStateOf(AzkarTab.Today) }
    Surface(modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
        BoxWithConstraints {
            val wide = maxWidth >= 620.dp
            if (wide) {
                Row(Modifier.fillMaxSize()) {
                    Column(Modifier.width(180.dp).fillMaxHeight().padding(vertical = 14.dp)) {
                        for (page in AzkarTab.entries) {
                            SidebarItem(page, page == tab) { tab = page }
                        }
                    }
                    VerticalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    Box(Modifier.weight(1f).fillMaxHeight()) { Content(tab, ui, features, actions) }
                }
            } else {
                Column(Modifier.fillMaxSize()) {
                    Box(Modifier.fillMaxWidth().weight(1f)) { Content(tab, ui, features, actions) }
                    NavigationBar {
                        for (page in AzkarTab.entries) {
                            NavigationBarItem(
                                selected = page == tab,
                                onClick = { tab = page },
                                icon = { Tile(page.color) },
                                label = { Text(page.title) },
                            )
                        }
                    }
                }
            }
            if (ui.notice != null) {
                Box(Modifier.fillMaxSize().padding(16.dp), contentAlignment = Alignment.BottomCenter) {
                    Text(
                        ui.notice,
                        Modifier
                            .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(10.dp))
                            .padding(horizontal = 14.dp, vertical = 8.dp),
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

@Composable
private fun Content(tab: AzkarTab, ui: UiState, features: Features, actions: AzkarActions) {
    when (tab) {
        AzkarTab.Today -> TodayPage(ui, features, actions)
        AzkarTab.Schedule -> SchedulePage(ui, features, actions)
        AzkarTab.Cards -> CardsPage(ui, features, actions)
        AzkarTab.Azkar -> AzkarListPage(ui, features, actions)
        AzkarTab.General -> GeneralPage(ui, features, actions)
    }
}

@Composable
private fun SidebarItem(page: AzkarTab, selected: Boolean, onClick: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 2.dp)
            .background(
                if (selected) MaterialTheme.colorScheme.surfaceVariant else Color.Transparent,
                RoundedCornerShape(8.dp),
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 10.dp, vertical = 9.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Tile(page.color)
        Text(page.title, style = MaterialTheme.typography.bodyLarge)
    }
}
