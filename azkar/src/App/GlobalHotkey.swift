// The global shortcut via Carbon RegisterEventHotKey: works in every app and needs no
// Accessibility permission.
import Carbon.HIToolbox
import Foundation

final class GlobalHotkey {
  private var ref: EventHotKeyRef?
  private var handlerInstalled = false

  /// Returns nil on success, otherwise why it failed.
  func register(_ hotkey: Hotkey) -> String? {
    unregister()
    if !handlerInstalled {
      var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
      InstallEventHandler(
        GetApplicationEventTarget(),
        { _, _, _ in
          NotificationCenter.default.post(name: .azkarHotkey, object: nil)
          return noErr
        }, 1, &spec, nil, nil)
      handlerInstalled = true
    }
    let id = EventHotKeyID(signature: OSType(0x415A_4B52), id: 1)  // 'AZKR'
    let status = RegisterEventHotKey(hotkey.keyCode, hotkey.modifiers, id, GetApplicationEventTarget(), 0, &ref)
    return status == noErr ? nil : "\(hotkey.display) is taken by another app (error \(status))"
  }

  func unregister() {
    if let ref { UnregisterEventHotKey(ref) }
    ref = nil
  }
}
