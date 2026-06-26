
import Foundation

struct SearchLocationResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String


    var asCity: City {
        City(name: name, country: country)
    }
}
