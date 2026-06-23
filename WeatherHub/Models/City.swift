//
//  City.swift
//  WeatherHub
//

import Foundation

// MARK: - City Model

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let country: String

    var fullName: String { "\(name), \(country)" }

    // Conform to Hashable by name + country (exclude UUID so duplicates match).
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(country)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.name == rhs.name && lhs.country == rhs.country
    }
}
