
import Foundation
import Combine


enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case network(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let statusCode):
            return "Server returned HTTP \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}


protocol WeatherNetworkServiceProtocol {
    func fetchWeather(query: String) -> AnyPublisher<WeatherResponse, NetworkError>
    func searchCities(query: String) -> AnyPublisher<[SearchLocationResponse], NetworkError>
}


final class NetworkService: WeatherNetworkServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchWeather(query: String) -> AnyPublisher<WeatherResponse, NetworkError> {
        guard var components = URLComponents(string: Constants.baseURL + Constants.forecastEndpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "days", value: "\(Constants.forecastDays)"),
            URLQueryItem(name: "aqi", value: "no"),
            URLQueryItem(name: "alerts", value: "no")
        ]

        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decodingError(error)
                }
                if let urlError = error as? URLError {
                    return NetworkError.network(urlError)
                }
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return NetworkError.unknown(error)
            }
            .eraseToAnyPublisher()
    }

    func searchCities(query: String) -> AnyPublisher<[SearchLocationResponse], NetworkError> {
        guard var components = URLComponents(string: Constants.baseURL + Constants.searchEndpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        components.queryItems = [
            URLQueryItem(name: "key", value: Constants.apiKey),
            URLQueryItem(name: "q", value: query)
        ]

        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }
                return data
            }
            .decode(type: [SearchLocationResponse].self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decodingError(error)
                }
                if let urlError = error as? URLError {
                    return NetworkError.network(urlError)
                }
                if let networkError = error as? NetworkError {
                    return networkError
                }
                return NetworkError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
}
