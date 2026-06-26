
import SwiftUI

@main
struct WeatherHubApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject private var timeOfDayManager = TimeOfDayManager.shared

    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(timeOfDayManager.timeOfDay == .morning ? .light : .dark)
        }
    }
}
