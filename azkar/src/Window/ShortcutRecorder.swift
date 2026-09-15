import AppKit
import Carbon.HIToolbox
import SwiftUI

/// Click, then press the new shortcut; Esc cancels.
struct ShortcutRecorder: View {
  @ObservedObject var model: SettingsModel
  @State private var monitor: Any?

  var body: some View {
    Button(action: { monitor == nil ? start() : stop() }) {
      Text(monitor == nil ? model.config.hotkey.display : "Press keys…")
        .font(.system(.body, design: .rounded).weight(.semibold))
        .frame(minWidth: 96)
    }
    .buttonStyle(.bordered)
    .tint(monitor == nil ? nil : .accentColor)
    .help("Click, then press the new shortcut. Esc cancels.")
    .onDisappear(perform: stop)
  }

  private func start() {
    monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
      MainActor.assumeIsolated {
        if model.record(keyCode: event.keyCode, flags: event.modifierFlags) || event.keyCode == UInt16(kVK_Escape) {
          stop()
        } else {
          NSSound.beep()
        }
      }
      return nil
    }
  }

  private func stop() {
    if let monitor { NSEvent.removeMonitor(monitor) }
    monitor = nil
  }
}
