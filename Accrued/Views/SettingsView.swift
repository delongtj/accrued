import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AccruedSettings
    @State private var showingResetConfirmation = false

    private let weekdays = [(1, "Sunday"), (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"), (5, "Thursday"), (6, "Friday"), (7, "Saturday")]

    private var configuration: AccrualConfiguration {
        AccrualConfiguration(mode: settings.compensationMode, amount: settings.amountDecimal,
                             enabledWeekdays: Set(weekdays.compactMap { settings.isEnabled(weekday: $0.0) ? $0.0 : nil }),
                             startMinutes: settings.workdayStartMinutes, endMinutes: settings.workdayEndMinutes,
                             weeklyHours: Decimal(settings.weeklyHours))
    }

    private var validationMessage: String? {
        if settings.amountDecimal <= 0 { return "Enter a compensation amount greater than zero." }
        if settings.weeklyHours <= 0 { return "Weekly hours must be greater than zero." }
        if settings.enabledWeekdays == 0 { return "Select at least one workday." }
        if settings.workdayEndMinutes <= settings.workdayStartMinutes { return "End time must be after start time." }
        return nil
    }

    var body: some View {
        Form {
            Section {
                Text("Accrued").font(.title2.weight(.semibold))
                Text("A schedule-based view of compensation accumulating during your workday. It does not track activity.")
                    .foregroundStyle(.secondary)
            }
            Section("Compensation") {
                Picker("Compensation mode", selection: $settings.compensationModeRaw) {
                    ForEach(CompensationMode.allCases) { Text($0.title).tag($0.rawValue) }
                }
                TextField(settings.compensationMode == .annual ? "Annual amount" : "Monthly amount", text: $settings.compensationAmount)
                TextField("Weekly hours", value: $settings.weeklyHours, format: .number)
            }
            Section("Schedule") {
                ForEach(weekdays, id: \.0) { day in
                    Toggle(day.1, isOn: Binding(get: { settings.isEnabled(weekday: day.0) }, set: { settings.setEnabled($0, weekday: day.0) }))
                }
                TimePickerRow(title: "Workday starts", minutes: $settings.workdayStartMinutes)
                TimePickerRow(title: "Workday ends", minutes: $settings.workdayEndMinutes)
                if let validationMessage { Text(validationMessage).foregroundStyle(.red) }
            }
            Section("Live preview") {
                LabeledContent("Hourly equivalent", value: CurrencyFormatting.string(configuration.hourlyRate, fractionDigits: 2))
                LabeledContent("Daily scheduled", value: CurrencyFormatting.string(configuration.hourlyRate * Decimal(settings.workdayEndMinutes - settings.workdayStartMinutes) / 60))
                LabeledContent("Weekly scheduled", value: CurrencyFormatting.string(configuration.hourlyRate * Decimal(settings.workdayEndMinutes - settings.workdayStartMinutes) / 60 * Decimal(settings.enabledWeekdays.nonzeroBitCount)))
            }
            Section {
                Button("Reset to Defaults", role: .destructive) { showingResetConfirmation = true }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .confirmationDialog("Reset all settings to defaults?", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) { settings.reset() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

private struct TimePickerRow: View {
    let title: String
    @Binding var minutes: Int

    private var date: Date {
        Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: Date()) ?? Date()
    }

    var body: some View {
        DatePicker(title, selection: Binding(get: { date }, set: { value in
            let components = Calendar.current.dateComponents([.hour, .minute], from: value)
            minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        }), displayedComponents: .hourAndMinute)
    }
}
