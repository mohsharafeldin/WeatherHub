
import Foundation


struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let country: String

    var fullName: String { "\(name), \(country)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(country)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.name == rhs.name && lhs.country == rhs.country
    }
}
