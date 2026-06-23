
import Foundation
import CoreData


protocol FavouriteRepositoryProtocol {
    func fetchFavourites() -> [FavouriteLocation]
    func addFavourite(cityName: String, country: String, latitude: Double, longitude: Double)
    func deleteFavourite(_ location: FavouriteLocation)
    func isFavourite(cityName: String) -> Bool
}


final class CoreDataService: FavouriteRepositoryProtocol {

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }


    func fetchFavourites() -> [FavouriteLocation] {
        let request: NSFetchRequest<FavouriteLocation> = FavouriteLocation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavouriteLocation.addedAt, ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("CoreDataService: Failed to fetch favourites – \(error.localizedDescription)")
            return []
        }
    }


    func addFavourite(cityName: String, country: String, latitude: Double, longitude: Double) {
        let favourite = FavouriteLocation(context: viewContext)
        favourite.id = UUID()
        favourite.cityName = cityName
        favourite.country = country
        favourite.latitude = latitude
        favourite.longitude = longitude
        favourite.addedAt = Date()

        saveContext()
    }


    func deleteFavourite(_ location: FavouriteLocation) {
        viewContext.delete(location)
        saveContext()
    }


    func isFavourite(cityName: String) -> Bool {
        let request: NSFetchRequest<FavouriteLocation> = FavouriteLocation.fetchRequest()
        request.predicate = NSPredicate(format: "cityName ==[cd] %@", cityName)
        request.fetchLimit = 1

        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            print("CoreDataService: Failed to check favourite – \(error.localizedDescription)")
            return false
        }
    }


    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            print("CoreDataService: Failed to save context – \(error.localizedDescription)")
        }
    }
}
