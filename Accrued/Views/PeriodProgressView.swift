import SwiftUI

struct PeriodProgressView: View {
    let title: String
    let period: AccrualPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline)
            HStack {
                Text("\(CurrencyFormatting.string(period.accrued)) of \(CurrencyFormatting.string(period.full))")
                    .font(.system(.body, design: .monospaced))
                Spacer()
                Text("\(Int(period.progress * 100))%")
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: period.progress)
        }
    }
}
