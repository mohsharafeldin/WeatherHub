import Foundation
import Combine

protocol WeatherRepositoryProtocol {
    func fetchWeather(query: String) -> AnyPublisher<WeatherResponse, NetworkError>
}

final class WeatherRepository: WeatherRepositoryProtocol {

    private let networkService: WeatherNetworkServiceProtocol

    init(networkService: WeatherNetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchWeather(query: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        return networkService.fetchWeather(query: query)
    }
}
