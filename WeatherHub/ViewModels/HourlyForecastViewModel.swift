// HourlyForecastViewModel.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import Foundation
import SwiftUI

/// ViewModel for the hourly forecast detail screen.
/// Filters hours for "Today" to show only remaining hours, and formats labels for display.
final class HourlyForecastViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The hourly weather entries to display (filtered for today, full list for other days).
    @Published var hours: [HourWeather]

    // MARK: - Properties

    /// The raw date string for this forecast day (e.g. "2024-01-15").
    let dateString: String

    /// A human-readable label such as "Today", "Tomorrow", or a weekday name.
    let dayLabel: String

    // MARK: - Theming

    /// The current time of day classification.
    var timeOfDay: TimeOfDay {
        TimeOfDayHelper.current()
    }

    /// Background gradient colours for the current time of day.
    var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    /// Primary text colour for the current time of day.
    var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    /// Secondary text colour for the current time of day.
    var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }

    // MARK: - Initialization

    /// Creates a new HourlyForecastViewModel.
    /// - Parameters:
    ///   - forecastDay: The forecast day data containing hourly entries.
    ///   - dayLabel: A display label for the day (e.g. "Today", "Tomorrow", "Wednesday").
    init(forecastDay: ForecastDay, dayLabel: String) {
        self.dateString = forecastDay.date
        self.dayLabel = dayLabel

        // For today, only show hours from the current hour onwards.
        // For other days, show all 24 hours.
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

    // MARK: - Display Helpers

    /// Returns a formatted hour label for the given hour entry.
    /// - If the entry represents the current hour of today, returns "Now".
    /// - Otherwise returns a 12-hour formatted string (e.g. "1 PM", "12 AM").
    /// - Parameter hour: The hourly weather entry.
    /// - Returns: A formatted string for display.
    func hourLabel(for hour: HourWeather) -> String {
        let parsedHour = HourlyForecastViewModel.parseHour(from: hour.time)

        // Check if this is the current hour on "Today"
        if dayLabel == "Today" {
            let currentHour = Calendar.current.component(.hour, from: Date())
            if parsedHour == currentHour {
                return "Now"
            }
        }

        return HourlyForecastViewModel.format12Hour(parsedHour)
    }

    /// Builds a full HTTPS URL for an hourly weather icon.
    /// - Parameter hour: The hourly weather entry.
    /// - Returns: A valid `URL` or `nil` if the icon string is empty.
    func iconURL(for hour: HourWeather) -> URL? {
        let icon = hour.condition.icon
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }

    /// Formats the temperature as an integer with a degree symbol (e.g. "18°").
    /// - Parameter hour: The hourly weather entry.
    /// - Returns: A formatted temperature string.
    func temperature(for hour: HourWeather) -> String {
        "\(Int(hour.tempC))°"
    }

    // MARK: - Private Helpers

    /// Extracts the hour component from a time string in the format "YYYY-MM-DD HH:mm".
    /// - Parameter timeString: The raw time string from the API.
    /// - Returns: The integer hour (0-23), or 0 if parsing fails.
    private static func parseHour(from timeString: String) -> Int {
        let components = timeString.components(separatedBy: " ")
        guard components.count == 2 else { return 0 }
        let timePart = components[1] // "HH:mm"
        let timeComponents = timePart.components(separatedBy: ":")
        guard let hourString = timeComponents.first, let hour = Int(hourString) else { return 0 }
        return hour
    }

    /// Converts a 24-hour integer to a 12-hour formatted string.
    /// - Parameter hour: An integer from 0 to 23.
    /// - Returns: A string like "12 AM", "1 PM", "12 PM", etc.
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
