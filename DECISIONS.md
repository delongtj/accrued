# Implementation decisions

- Settings use `@AppStorage`/UserDefaults primitives so changes are immediate and persist without a database.
- Times are stored as minutes from midnight. The calculator reconstructs local dates with the injected `Calendar` and time zone, preserving correct local-day behavior across DST changes.
- The calculator uses `Decimal` for compensation values and is independent of SwiftUI.
- A lightweight timer refreshes the menu-bar label and panel at the next minute boundary and then once per minute; menu-bar currency is rounded to whole units while the panel retains cents.
- The menu-bar Settings button presents the same SwiftUI SettingsView in a retained native settings window; the SwiftUI Settings scene remains declared for standard macOS settings integration, while this explicit presenter works reliably for a menu-bar-only app.
- SwiftUI `MenuBarExtra` does not expose its underlying `NSStatusItem` for reliable right-click or Option-click handling. Settings and Quit remain available in the main flyout; adding a true alternate-click menu would require replacing the `MenuBarExtra` implementation with AppKit.
- `LSUIElement` makes the app menu-bar-only and prevents a Dock icon. The Settings scene is opened through the native `openSettings` environment action.
- The project is configured for native arm64 Debug builds on the current Apple-silicon development machine. Xcode can be selected per command with `DEVELOPER_DIR` if multiple Xcode installations are kept.
