// WeatherViewModel.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel responsible for fetching and exposing weather data to the UI.
/// Uses Combine for reactive data flow and supports dependency injection for testability.
final class WeatherViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new WeatherViewModel with the given weather service.
    /// - Parameter weatherService: The service used to fetch weather data. Defaults to `NetworkService`.
    init(weatherService: WeatherServiceProtocol = NetworkService()) {
        self.weatherService = weatherService
    }

    // MARK: - Computed Properties – Location & Temperature

    /// The name of the current weather location, or "--" if unavailable.
    var locationName: String {
        weatherResponse?.location.name ?? "--"
    }

    /// The current temperature formatted as an integer with a degree symbol (e.g. "21°").
    var currentTemp: String {
        guard let temp = weatherResponse?.current.tempC else { return "--" }
        return "\(Int(temp))°"
    }

    /// A human-readable description of the current weather condition.
    var conditionText: String {
        weatherResponse?.current.condition.text ?? "--"
    }

    /// The URL for the current condition's weather icon.
    /// The API may return protocol-relative URLs (starting with "//"), so "https:" is prepended when needed.
    var conditionIconURL: URL? {
        guard let icon = weatherResponse?.current.condition.icon else { return nil }
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }

    // MARK: - Computed Properties – Forecast Extremes

    /// Today's high temperature from the first forecast day (e.g. "H:25°").
    var highTemp: String {
        guard let maxTemp = weatherResponse?.forecast.forecastday.first?.day.maxtempC else { return "H:--" }
        return "H:\(Int(maxTemp))°"
    }

    /// Today's low temperature from the first forecast day (e.g. "L:14°").
    var lowTemp: String {
        guard let minTemp = weatherResponse?.forecast.forecastday.first?.day.mintempC else { return "L:--" }
        return "L:\(Int(minTemp))°"
    }

    // MARK: - Computed Properties – Detail Stats

    /// Current humidity as a percentage string (e.g. "72%").
    var humidity: String {
        guard let hum = weatherResponse?.current.humidity else { return "--" }
        return "\(hum)%"
    }

    /// Current visibility in kilometres (e.g. "10 km").
    var visibility: String {
        guard let vis = weatherResponse?.current.visKm else { return "--" }
        return "\(Int(vis)) km"
    }

    /// The "feels like" temperature (e.g. "19°").
    var feelsLike: String {
        guard let feels = weatherResponse?.current.feelslikeC else { return "--" }
        return "\(Int(feels))°"
    }

    /// Atmospheric pressure in millibars (e.g. "1013 mb").
    var pressure: String {
        guard let press = weatherResponse?.current.pressureMb else { return "--" }
        return "\(Int(press)) mb"
    }

    // MARK: - Computed Properties – Forecast & Theming

    /// All available forecast days from the response.
    var forecastDays: [ForecastDay] {
        weatherResponse?.forecast.forecastday ?? []
    }

    /// The current time of day classification used for theming.
    var timeOfDay: TimeOfDay {
        TimeOfDayHelper.current()
    }

    /// Background gradient colours appropriate for the current time of day.
    var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    /// Primary text colour appropriate for the current time of day.
    var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    /// Secondary text colour appropriate for the current time of day.
    var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }

    // MARK: - Data Fetching

    /// Fetches the weather for the given query string (city name or coordinates).
    /// Updates `weatherResponse`, `isLoading`, and `errorMessage` reactively.
    /// - Parameter query: A search query such as a city name, postal code, or lat/lon pair.
    func fetchWeather(for query: String) {
        isLoading = true
        errorMessage = nil

        weatherService.fetchWeather(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.weatherResponse = response
            })
            .store(in: &cancellables)
    }

    // MARK: - Helpers

    /// Returns a human-readable label for a forecast day at the given index.
    /// - Parameter index: Zero-based index into `forecastDays`.
    /// - Returns: "Today" for index 0, "Tomorrow" for index 1, or an abbreviated day name (e.g. "Wednesday").
    func dayLabel(for index: Int) -> String {
        switch index {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            guard index < forecastDays.count else { return "--" }
            let dateString = forecastDays[index].date
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")

            guard let date = inputFormatter.date(from: dateString) else { return dateString }

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "EEEE"
            outputFormatter.locale = Locale.current
            return outputFormatter.string(from: date)
        }
    }

    /// Builds a full HTTPS URL for a forecast day's condition icon.
    /// - Parameter forecastDay: The forecast day whose icon URL to resolve.
    /// - Returns: A valid `URL` or `nil` if the icon string is missing.
    func iconURL(for forecastDay: ForecastDay) -> URL? {
        let icon = forecastDay.day.condition.icon
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }
}
