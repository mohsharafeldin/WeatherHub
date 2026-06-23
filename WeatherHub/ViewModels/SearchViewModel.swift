// SearchViewModel.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import Foundation
import Combine
import CoreData

/// ViewModel that manages city search, filtering, and favourite location persistence.
/// Uses Combine for debounced search and dependency injection for the favourites repository.
final class SearchViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The current search text entered by the user.
    @Published var searchText = ""

    /// Cities matching the current search query.
    @Published var filteredCities: [City] = []

    /// The user's saved favourite locations from Core Data.
    @Published var favourites: [FavouriteLocation] = []

    /// Controls visibility of the delete confirmation alert.
    @Published var showDeleteAlert = false

    /// The favourite location pending deletion (set before showing the alert).
    @Published var locationToDelete: FavouriteLocation?

    // MARK: - Private Properties

    private let favouriteRepository: FavouriteRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Creates a new SearchViewModel.
    /// - Parameter favouriteRepository: The repository used for favourite CRUD operations.
    ///   Defaults to `CoreDataService`.
    init(favouriteRepository: FavouriteRepositoryProtocol = CoreDataService()) {
        self.favouriteRepository = favouriteRepository
        setupSearchSubscription()
        loadFavourites()
    }

    // MARK: - Search

    /// Sets up a reactive pipeline that debounces search text changes and filters the city list.
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text -> [City] in
                guard !text.isEmpty else { return [] }
                return CityList.allCities.filter { city in
                    city.name.localizedCaseInsensitiveContains(text) ||
                    city.country.localizedCaseInsensitiveContains(text)
                }
            }
            .assign(to: &$filteredCities)
    }

    // MARK: - Favourites Management

    /// Reloads the favourites list from the repository.
    func loadFavourites() {
        favourites = favouriteRepository.fetchFavourites()
    }

    /// Adds a city to favourites if it is not already saved.
    /// - Parameter city: The city to add.
    func addToFavourites(_ city: City) {
        guard !favouriteRepository.isFavourite(cityName: city.name) else { return }
        favouriteRepository.addFavourite(
            cityName: city.name,
            country: city.country,
            latitude: 0,
            longitude: 0
        )
        loadFavourites()
    }

    /// Prepares to delete a favourite by storing it and showing the confirmation alert.
    /// - Parameter location: The favourite location the user wants to remove.
    func confirmDelete(_ location: FavouriteLocation) {
        locationToDelete = location
        showDeleteAlert = true
    }

    /// Executes the pending deletion after the user confirms via the alert.
    func deleteConfirmed() {
        guard let location = locationToDelete else { return }
        favouriteRepository.deleteFavourite(location)
        locationToDelete = nil
        loadFavourites()
    }

    /// Checks whether a city is already in the user's favourites.
    /// - Parameter cityName: The city name to look up.
    /// - Returns: `true` if the city is already a favourite.
    func isFavourite(cityName: String) -> Bool {
        favouriteRepository.isFavourite(cityName: cityName)
    }
}
