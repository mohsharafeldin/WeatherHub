
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let favourite = FavouriteLocation(context: viewContext)
            favourite.id = UUID()
            favourite.cityName = ["Cairo", "London", "Tokyo", "New York", "Dubai"][i]
            favourite.country = ["Egypt", "United Kingdom", "Japan", "United States", "UAE"][i]
            favourite.latitude = [30.04, 51.51, 35.68, 40.71, 25.20][i]
            favourite.longitude = [31.24, -0.13, 139.69, -74.01, 55.27][i]
            favourite.addedAt = Date().addingTimeInterval(Double(-i) * 3600)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WeatherHub")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
