import SwiftUI

/// Starting at login, the menu-bar count, sound, and where the settings live.
struct GeneralPage: View {
  @ObservedObject var model: SettingsModel

  var body: some View {
    Form {
      Section {
        Toggle(isOn: $model.config.openAtLogin) {
          Row(
            title: "Open at login", symbol: "power", color: .green,
            detail: "Start Azkar in the menu bar when you log in."
          ) { EmptyView() }
        }
        Toggle(isOn: $model.config.showWindowAtLogin) {
          Row(
            title: "Show this window at login", symbol: "macwindow", color: .blue,
            detail: "Off: it starts quietly, with just 📿 in the menu bar."
          ) { EmptyView() }
        }
        .disabled(!model.config.openAtLogin)
      } header: {
        Text("Startup")
      } footer: {
        Footnote("Opening Azkar yourself — from Finder, Spotlight or the Dock — always shows this window.")
      }

      Section("Menu bar and sound") {
        Toggle(isOn: $model.config.showCount) {
          Row(
            title: "Show card count", symbol: "number", color: .orange,
            detail: "📿 3 while three cards are waiting."
          ) { EmptyView() }
        }
        Toggle(isOn: $model.config.sound) {
          Row(
            title: "Sounds", symbol: "speaker.wave.2.fill", color: .pink,
            detail: "A chime when a card pops in, and when you finish a zikr's count."
          ) { EmptyView() }
        }
      }

      Section {
        HStack {
          Button {
            model.perform?(.revealConfig)
          } label: {
            Label("Show config in Finder", systemImage: "folder")
          }
          Spacer()
          Button("Quit Azkar", role: .destructive) { model.perform?(.quit) }
        }
      } footer: {
        Footnote(
          "Changes are saved to ~/.config/azkar/config.json straight away. Quitting stops reminders until you open Azkar again or next log in."
        )
      }
    }
    .formStyle(.grouped)
    .toggleStyle(.switch)
    .navigationTitle("General")
  }
}
