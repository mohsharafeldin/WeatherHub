
import Foundation
import Combine
import CoreData

final class SearchViewModel: ObservableObject {


    @Published var searchText = ""

    @Published var filteredCities: [City] = []

    @Published var favourites: [FavouriteLocation] = []

    @Published var showDeleteAlert = false

    @Published var locationToDelete: FavouriteLocation?


    private let favouriteRepository: FavouriteRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()


    init(favouriteRepository: FavouriteRepositoryProtocol = CoreDataService()) {
        self.favouriteRepository = favouriteRepository
        setupSearchSubscription()
        loadFavourites()
    }


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
}
