import SwiftUI

struct MenuBarLabel: View {
    let amount: Decimal

    var body: some View {
        Text("\(CurrencyFormatting.string(amount, fractionDigits: 0)) today")
            .monospacedDigit()
            .lineLimit(1)
    }
}
