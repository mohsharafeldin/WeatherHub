
import Foundation
import Combine
import SwiftUI

final class WeatherViewModel: ObservableObject {


    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?


    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()


    init(weatherService: WeatherServiceProtocol = NetworkService()) {
        self.weatherService = weatherService
    }


    var locationName: String {
        weatherResponse?.location.name ?? "--"
    }

    var currentTemp: String {
        guard let temp = weatherResponse?.current.tempC else { return "--" }
        return "\(Int(temp))°"
    }

    var conditionText: String {
        weatherResponse?.current.condition.text ?? "--"
    }

    var conditionIconURL: URL? {
        guard let icon = weatherResponse?.current.condition.icon else { return nil }
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }


    var highTemp: String {
        guard let maxTemp = weatherResponse?.forecast.forecastday.first?.day.maxtempC else { return "H:--" }
        return "H:\(Int(maxTemp))°"
    }

    var lowTemp: String {
        guard let minTemp = weatherResponse?.forecast.forecastday.first?.day.mintempC else { return "L:--" }
        return "L:\(Int(minTemp))°"
    }


    var humidity: String {
        guard let hum = weatherResponse?.current.humidity else { return "--" }
        return "\(hum)%"
    }

    var visibility: String {
        guard let vis = weatherResponse?.current.visKm else { return "--" }
        return "\(Int(vis)) km"
    }

    var feelsLike: String {
        guard let feels = weatherResponse?.current.feelslikeC else { return "--" }
        return "\(Int(feels))°"
    }

    var pressure: String {
        guard let press = weatherResponse?.current.pressureMb else { return "--" }
        return "\(Int(press)) mb"
    }


    var forecastDays: [ForecastDay] {
        weatherResponse?.forecast.forecastday ?? []
    }

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

    func iconURL(for forecastDay: ForecastDay) -> URL? {
        let icon = forecastDay.day.condition.icon
        let urlString = icon.hasPrefix("//") ? "https:\(icon)" : icon
        return URL(string: urlString)
    }
}
