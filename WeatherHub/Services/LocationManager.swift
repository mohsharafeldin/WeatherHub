//
//  LocationManager.swift
//  WeatherHub
//

import Foundation
import CoreLocation
import Combine

/// Manages device location access using CoreLocation.
/// Publishes the user's current coordinates so the app can fetch local weather.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published Properties

    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: String?

    // MARK: - Private Properties

    private let manager = CLLocationManager()

    // MARK: - Computed Properties

    /// Returns a "lat,lon" query string suitable for the weather API, or `nil` if location is unavailable.
    var coordinateQuery: String? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return "\(lat),\(lon)"
    }

    /// Whether the user has granted location permission.
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    /// Whether the authorization has been determined yet.
    var isDetermined: Bool {
        authorizationStatus != .notDetermined
    }

    // MARK: - Initialization

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public Methods

    /// Requests location permission and starts updating location.
    func requestLocation() {
        locationError = nil

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Please enable it in Settings."
        @unknown default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Unable to determine your location."
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if isAuthorized {
            manager.requestLocation()
        }
    }
}
