import Foundation

protocol FavouriteLocationRepositoryProtocol {
    func fetchFavourites() -> [FavouriteLocation]
    func addFavourite(cityName: String, country: String, latitude: Double, longitude: Double)
    func deleteFavourite(_ location: FavouriteLocation)
    func isFavourite(cityName: String) -> Bool
}

final class FavouriteLocationRepository: FavouriteLocationRepositoryProtocol {

    private let coreDataService: CoreDataServiceProtocol

    init(coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        self.coreDataService = coreDataService
    }

    func fetchFavourites() -> [FavouriteLocation] {
        return coreDataService.fetchFavourites()
    }

    func addFavourite(cityName: String, country: String, latitude: Double, longitude: Double) {
        coreDataService.addFavourite(cityName: cityName, country: country, latitude: latitude, longitude: longitude)
    }

    func deleteFavourite(_ location: FavouriteLocation) {
        coreDataService.deleteFavourite(location)
    }

    func isFavourite(cityName: String) -> Bool {
        return coreDataService.isFavourite(cityName: cityName)
    }
}
