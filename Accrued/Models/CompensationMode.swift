import Foundation

enum CompensationMode: String, CaseIterable, Identifiable {
    case annual
    case monthly

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}
