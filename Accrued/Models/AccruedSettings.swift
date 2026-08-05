import Foundation
import SwiftUI

@MainActor
final class AccruedSettings: ObservableObject {
    @AppStorage("compensationMode") var compensationModeRaw = CompensationMode.annual.rawValue
    @AppStorage("compensationAmount") var compensationAmount = "160000"
    @AppStorage("enabledWeekdays") var enabledWeekdays = 62 // Monday-Friday; Calendar weekday values are 2...6.
    @AppStorage("workdayStartMinutes") var workdayStartMinutes = 8 * 60
    @AppStorage("workdayEndMinutes") var workdayEndMinutes = 16 * 60
    @AppStorage("weeklyHours") var weeklyHours = 40.0
    @AppStorage("menuBarPeriod") var menuBarPeriodRaw = MenuBarPeriod.today.rawValue

    var compensationMode: CompensationMode {
        get { CompensationMode(rawValue: compensationModeRaw) ?? .annual }
        set { compensationModeRaw = newValue.rawValue }
    }

    var menuBarPeriod: MenuBarPeriod {
        get { MenuBarPeriod(rawValue: menuBarPeriodRaw) ?? .today }
        set { menuBarPeriodRaw = newValue.rawValue }
    }

    func isEnabled(weekday: Int) -> Bool {
        enabledWeekdays & (1 << (weekday - 1)) != 0
    }

    func setEnabled(_ enabled: Bool, weekday: Int) {
        if enabled { enabledWeekdays |= (1 << (weekday - 1)) }
        else { enabledWeekdays &= ~(1 << (weekday - 1)) }
    }

    var amountDecimal: Decimal { Decimal(string: compensationAmount) ?? 0 }

    func reset() {
        compensationModeRaw = CompensationMode.annual.rawValue
        compensationAmount = "160000"
        enabledWeekdays = 62
        workdayStartMinutes = 8 * 60
        workdayEndMinutes = 16 * 60
        weeklyHours = 40
        menuBarPeriodRaw = MenuBarPeriod.today.rawValue
    }
}
