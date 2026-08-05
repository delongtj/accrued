import SwiftUI
import AppKit

@main
struct AccruedApp: App {
    @StateObject private var settings = AccruedSettings()
    @StateObject private var clock = AccruedClock()

    private var configuration: AccrualConfiguration {
        AccrualConfiguration(mode: settings.compensationMode, amount: settings.amountDecimal,
                             enabledWeekdays: Set((1...7).filter { settings.isEnabled(weekday: $0) }),
                             startMinutes: settings.workdayStartMinutes, endMinutes: settings.workdayEndMinutes,
                             weeklyHours: Decimal(settings.weeklyHours))
    }

    private var snapshot: AccrualSnapshot {
        let calendar = Calendar.autoupdatingCurrent
        return AccrualCalculator(calendar: calendar, timeZone: calendar.timeZone, now: clock.now).snapshot(configuration: configuration)
    }

    private var menuBarAmount: Decimal {
        switch settings.menuBarPeriod {
        case .today: return snapshot.today.accrued
        case .week: return snapshot.week.accrued
        case .month: return snapshot.month.accrued
        case .year: return snapshot.year.accrued
        }
    }

    var body: some Scene {
        MenuBarExtra {
            AccrualPanel(settings: settings, snapshot: snapshot, openSettings: {
                SettingsWindowController.shared.show(settings: settings)
            }, quit: { NSApplication.shared.terminate(nil) })
        } label: {
            MenuBarLabel(amount: menuBarAmount, period: settings.menuBarPeriod)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(settings: settings)
        }
    }
}

@MainActor
private final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show(settings: AccruedSettings) {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let hostingController = NSHostingController(rootView: SettingsView(settings: settings))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Accrued Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 460, height: 680))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}

@MainActor
private final class AccruedClock: ObservableObject {
    @Published var now = Date()
    private var timer: Timer?

    init() {
        let secondsUntilNextMinute = max(0.1, 60 - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60))
        timer = Timer.scheduledTimer(withTimeInterval: secondsUntilNextMinute, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.now = Date()
                self?.startRepeatingTimer()
            }
        }
    }

    private func startRepeatingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.now = Date()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
