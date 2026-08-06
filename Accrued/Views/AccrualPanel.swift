import SwiftUI

struct AccrualPanel: View {
    @ObservedObject var settings: AccruedSettings
    let snapshot: AccrualSnapshot
    let openSettings: () -> Void
    let quit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accrued").font(.title3.weight(.semibold))
            Picker("Menu bar period", selection: $settings.menuBarPeriodRaw) {
                ForEach(MenuBarPeriod.allCases) { period in
                    Text(period.shortTitle).tag(period.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            PeriodProgressView(title: "Today", period: snapshot.today)
            PeriodProgressView(title: "This week", period: snapshot.week)
            PeriodProgressView(title: "This month", period: snapshot.month)
            PeriodProgressView(title: "This year", period: snapshot.year)
            Divider()
            Text("\(CurrencyFormatting.string(snapshot.hourlyRate, fractionDigits: 2)) per scheduled hour")
                .font(.system(.body, design: .monospaced))
            if snapshot.isOutsideSchedule {
                Label("Outside scheduled hours", systemImage: "clock")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Button("Settings", action: openSettings)
                Spacer()
                Button("Quit", action: quit)
            }
        }
        .padding(18)
        .frame(width: 330)
    }
}
