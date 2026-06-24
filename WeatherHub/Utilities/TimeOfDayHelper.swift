
import SwiftUI


enum TimeOfDay {
    case morning
    case evening
}


enum TimeOfDayHelper {

    static func current() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        return (5 <= hour && hour < 18) ? .morning : .evening
    }

    static func backgroundGradient(for timeOfDay: TimeOfDay) -> [Color] {
        switch timeOfDay {
        case .morning:
            return [
                Color(red: 0.53, green: 0.81, blue: 0.92),
                Color(red: 1.0, green: 0.84, blue: 0.0)
            ]
        case .evening:
            return [
                Color(red: 0.06, green: 0.13, blue: 0.15),
                Color(red: 0.17, green: 0.33, blue: 0.39)
            ]
        }
    }

    static func textColor(for timeOfDay: TimeOfDay) -> Color {
        switch timeOfDay {
        case .morning:
            return .black
        case .evening:
            return .white
        }
    }

    static func secondaryTextColor(for timeOfDay: TimeOfDay) -> Color {
        switch timeOfDay {
        case .morning:
            return .black.opacity(0.7)
        case .evening:
            return .white.opacity(0.7)
        }
    }
}
