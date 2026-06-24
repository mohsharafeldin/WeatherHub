
import Foundation
import SwiftUI

final class HourlyForecastViewModel: ObservableObject {


    @Published var hours: [HourWeather]


    let dateString: String

    let dayLabel: String


    var timeOfDay: TimeOfDay {
        TimeOfDayHelper.current()
    }

    var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }


    init(forecastDay: ForecastDay, dayLabel: String) {
        self.dateString = forecastDay.date
        self.dayLabel = dayLabel

        if dayLabel == "Today" {
            let currentHour = Calendar.current.component(.hour, from: Date())
            self.hours = forecastDay.hour.filter { hourWeather in
                let hour = HourlyForecastViewModel.parseHour(from: hourWeather.time)
                return hour >= currentHour
            }
        } else {
            self.hours = forecastDay.hour
        }
    }


    func hourLabel(for hour: HourWeather) -> String {
        let parsedHour = HourlyForecastViewModel.parseHour(from: hour.time)

        if dayLabel == "Today" {
            let currentHour = Calendar.current.component(.hour, from: Date())
            if parsedHour == currentHour {
                return "Now"
            }
        }

        return HourlyForecastViewModel.format12Hour(parsedHour)
    }

    func iconURL(for hour: HourWeather) -> URL? {
        let icon = hour.condition.icon
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }

    func temperature(for hour: HourWeather) -> String {
        "\(Int(hour.tempC))°"
    }


    private static func parseHour(from timeString: String) -> Int {
        let components = timeString.components(separatedBy: " ")
        guard components.count == 2 else { return 0 }
        let timePart = components[1]
        let timeComponents = timePart.components(separatedBy: ":")
        guard let hourString = timeComponents.first, let hour = Int(hourString) else { return 0 }
        return hour
    }

    private static func format12Hour(_ hour: Int) -> String {
        switch hour {
        case 0:
            return "12 AM"
        case 1...11:
            return "\(hour) AM"
        case 12:
            return "12 PM"
        default:
            return "\(hour - 12) PM"
        }
    }
}
