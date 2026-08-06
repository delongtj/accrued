import Foundation

enum CompensationMode: String, CaseIterable, Identifiable {
    case annual
    case monthly

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum MenuBarPeriod: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case year

    var id: String { rawValue }
    var title: String {
        switch self {
        case .today: return "Today"
        case .week: return "This week"
        case .month: return "This month"
        case .year: return "This year"
        }
    }

    var shortTitle: String {
        switch self {
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}
