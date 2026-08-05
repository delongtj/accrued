import Foundation

enum CurrencyFormatting {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }()

    static func string(_ value: Decimal, fractionDigits: Int? = nil) -> String {
        let formatter = currency.copy() as! NumberFormatter
        if let fractionDigits { formatter.minimumFractionDigits = fractionDigits; formatter.maximumFractionDigits = fractionDigits }
        return formatter.string(from: value as NSDecimalNumber) ?? "—"
    }
}
