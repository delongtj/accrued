import SwiftUI

struct MenuBarLabel: View {
    let amount: Decimal
    let period: MenuBarPeriod

    var body: some View {
        Text("\(CurrencyFormatting.string(amount, fractionDigits: 0)) \(period.rawValue)")
            .monospacedDigit()
            .lineLimit(1)
    }
}
