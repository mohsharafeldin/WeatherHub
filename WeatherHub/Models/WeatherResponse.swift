//
//  WeatherResponse.swift
//  WeatherHub
//

import Foundation

// MARK: - Root Response

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}

// MARK: - Location

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

// MARK: - Current Weather

struct CurrentWeather: Codable {
    let tempC: Double
    let isDay: Int
    let condition: WeatherCondition
    let windKph: Double
    let humidity: Int
    let feelslikeC: Double
    let visKm: Double
    let pressureMb: Double

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case isDay = "is_day"
        case condition
        case windKph = "wind_kph"
        case humidity
        case feelslikeC = "feelslike_c"
        case visKm = "vis_km"
        case pressureMb = "pressure_mb"
    }
}

// MARK: - Weather Condition

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

// MARK: - Forecast Day

struct ForecastDay: Codable, Identifiable {
    let date: String
    let day: Day
    let hour: [HourWeather]

    var id: String { date }
}

// MARK: - Day

struct Day: Codable {
    let maxtempC: Double
    let mintempC: Double
    let condition: WeatherCondition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

// MARK: - Hour Weather

struct HourWeather: Codable, Identifiable {
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let isDay: Int
    let condition: WeatherCondition

    var id: Int { timeEpoch }

    enum CodingKeys: String, CodingKey {
        case timeEpoch = "time_epoch"
        case time
        case tempC = "temp_c"
        case isDay = "is_day"
        case condition
    }
}
