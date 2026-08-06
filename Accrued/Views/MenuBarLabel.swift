import SwiftUI

struct MenuBarLabel: View {
    let amount: Decimal
    let period: MenuBarPeriod
    @State private var lastHundredBucket: Int?
    @State private var isPulsing = false

    private var hundredBucket: Int {
        max(0, NSDecimalNumber(decimal: amount / 100).doubleValue.rounded(.down).toInt())
    }

    var body: some View {
        Text("\(CurrencyFormatting.string(amount, fractionDigits: 0)) \(period.rawValue)")
            .monospacedDigit()
            .lineLimit(1)
            .scaleEffect(isPulsing ? 1.08 : 1)
            .opacity(isPulsing ? 0.82 : 1)
            .animation(.easeOut(duration: 0.2), value: isPulsing)
            .onAppear {
                lastHundredBucket = hundredBucket
            }
            .onChange(of: amount) { _ in
                updatePulseIfNeeded()
            }
            .onChange(of: period) { _ in
                lastHundredBucket = hundredBucket
            }
    }

    private func updatePulseIfNeeded() {
        let newBucket = hundredBucket
        guard let previousBucket = lastHundredBucket else {
            lastHundredBucket = newBucket
            return
        }
        lastHundredBucket = newBucket
        guard newBucket > previousBucket else { return }

        isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            isPulsing = false
        }
    }
}

private extension Double {
    func toInt() -> Int {
        guard isFinite else { return 0 }
        return Int(self)
    }
}
