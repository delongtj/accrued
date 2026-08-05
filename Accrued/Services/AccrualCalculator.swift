import Foundation

struct AccrualConfiguration: Equatable {
    var mode: CompensationMode = .annual
    var amount: Decimal = 160000
    var enabledWeekdays: Set<Int> = [2, 3, 4, 5, 6]
    var startMinutes = 480
    var endMinutes = 960
    var weeklyHours: Decimal = 40

    var isValid: Bool {
        amount > 0 && weeklyHours > 0 && !enabledWeekdays.isEmpty && endMinutes > startMinutes
    }

    var annualCompensation: Decimal {
        mode == .annual ? amount : amount * 12
    }

    var hourlyRate: Decimal {
        guard isValid else { return 0 }
        return annualCompensation / (weeklyHours * 52)
    }
}

struct AccrualPeriod {
    var accrued: Decimal
    var full: Decimal
    var progress: Double { guard full > 0 else { return 0 }; return min(1, max(0, NSDecimalNumber(decimal: accrued / full).doubleValue)) }
}

struct AccrualSnapshot {
    var today: AccrualPeriod
    var week: AccrualPeriod
    var month: AccrualPeriod
    var year: AccrualPeriod
    var hourlyRate: Decimal
    var isOutsideSchedule: Bool
}

struct AccrualCalculator {
    var calendar: Calendar
    var timeZone: TimeZone
    var now: Date

    init(calendar: Calendar = .current, timeZone: TimeZone? = nil, now: Date = .now) {
        self.timeZone = timeZone ?? calendar.timeZone
        self.calendar = calendar
        self.calendar.timeZone = self.timeZone
        self.now = now
    }

    func snapshot(configuration: AccrualConfiguration) -> AccrualSnapshot {
        guard configuration.isValid else {
            let zero = AccrualPeriod(accrued: 0, full: 0)
            return AccrualSnapshot(today: zero, week: zero, month: zero, year: zero, hourlyRate: 0, isOutsideSchedule: true)
        }
        let day = calendar.startOfDay(for: now)
        let daily = configuration.hourlyRate * Decimal(configuration.endMinutes - configuration.startMinutes) / 60
        let today = period(for: day, through: now, configuration: configuration, daily: daily)
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now)!
        let monthInterval = calendar.dateInterval(of: .month, for: now)!
        let yearInterval = calendar.dateInterval(of: .year, for: now)!
        return AccrualSnapshot(
            today: today,
            week: aggregate(interval: weekInterval, through: now, configuration: configuration, daily: daily),
            month: aggregate(interval: monthInterval, through: now, configuration: configuration, daily: daily),
            year: aggregate(interval: yearInterval, through: now, configuration: configuration, daily: daily),
            hourlyRate: configuration.hourlyRate,
            isOutsideSchedule: !isWithinSchedule(day: day, date: now, configuration: configuration)
        )
    }

    private func aggregate(interval: DateInterval, through date: Date, configuration: AccrualConfiguration, daily: Decimal) -> AccrualPeriod {
        var cursor = interval.start
        var accrued: Decimal = 0
        var full: Decimal = 0
        while cursor < interval.end {
            let day = calendar.startOfDay(for: cursor)
            if configuration.enabledWeekdays.contains(calendar.component(.weekday, from: day)) {
                full += daily
                if day <= date { accrued += period(for: day, through: min(date, interval.end), configuration: configuration, daily: daily).accrued }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            cursor = next
        }
        return AccrualPeriod(accrued: accrued, full: full)
    }

    private func period(for day: Date, through date: Date, configuration: AccrualConfiguration, daily: Decimal) -> AccrualPeriod {
        guard configuration.enabledWeekdays.contains(calendar.component(.weekday, from: day)),
              let bounds = bounds(for: day, configuration: configuration) else { return AccrualPeriod(accrued: 0, full: 0) }
        let elapsed = max(0, min(date.timeIntervalSince(bounds.start), bounds.end.timeIntervalSince(bounds.start)))
        let fraction = elapsed / bounds.end.timeIntervalSince(bounds.start)
        return AccrualPeriod(accrued: daily * Decimal(fraction), full: daily)
    }

    private func bounds(for day: Date, configuration: AccrualConfiguration) -> (start: Date, end: Date)? {
        guard let start = calendar.date(bySettingHour: configuration.startMinutes / 60, minute: configuration.startMinutes % 60, second: 0, of: day),
              let end = calendar.date(bySettingHour: configuration.endMinutes / 60, minute: configuration.endMinutes % 60, second: 0, of: day) else { return nil }
        return end > start ? (start, end) : nil
    }

    private func isWithinSchedule(day: Date, date: Date, configuration: AccrualConfiguration) -> Bool {
        guard let bounds = bounds(for: day, configuration: configuration), configuration.enabledWeekdays.contains(calendar.component(.weekday, from: day)) else { return false }
        return date >= bounds.start && date < bounds.end
    }
}
