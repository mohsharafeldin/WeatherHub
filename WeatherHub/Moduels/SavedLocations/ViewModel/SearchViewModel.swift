
import Foundation
import Combine
import CoreData

final class SearchViewModel: ObservableObject {


    @Published var showSearchSheet = false
    @Published var searchText = ""
    @Published var searchResults: [City] = []
    @Published var isSearching = false
    @Published var searchError: String?


    @Published var favourites: [FavouriteLocation] = []
    @Published var showDeleteAlert = false
    @Published var locationToDelete: FavouriteLocation?


    private let favouriteRepository: FavouriteLocationRepositoryProtocol
    private let networkService: WeatherNetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()


    var allCities: [City] {
        CityList.allCities
    }


    var groupedCities: [(country: String, cities: [City])] {
        let grouped = Dictionary(grouping: allCities) { $0.country }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (country: $0.key, cities: $0.value) }
    }

    init(
        favouriteRepository: FavouriteLocationRepositoryProtocol = FavouriteLocationRepository(),
        networkService: WeatherNetworkServiceProtocol = NetworkService()
    ) {
        self.favouriteRepository = favouriteRepository
        self.networkService = networkService
        setupSearchSubscription()
        loadFavourites()
    }



    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    self.searchResults = []
                    self.isSearching = false
                    self.searchError = nil
                } else {
                    self.searchFromAPI(query: trimmed)
                }
            }
            .store(in: &cancellables)
    }

    private func searchFromAPI(query: String) {
        isSearching = true
        searchError = nil

        networkService.searchCities(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSearching = false
                if case .failure(let error) = completion {
                    self?.searchError = error.localizedDescription
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results.map { $0.asCity }
            }
            .store(in: &cancellables)
    }



    func loadFavourites() {
        favourites = favouriteRepository.fetchFavourites()
    }

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

    func confirmDelete(_ location: FavouriteLocation) {
        locationToDelete = location
        showDeleteAlert = true
    }

    func deleteConfirmed() {
        guard let location = locationToDelete else { return }
        favouriteRepository.deleteFavourite(location)
        locationToDelete = nil
        loadFavourites()
    }

    func isFavourite(cityName: String) -> Bool {
        favouriteRepository.isFavourite(cityName: cityName)
    }

    var showNoResults: Bool {
        !isSearching
        && searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        && searchResults.isEmpty
        && searchError == nil
    }
}
