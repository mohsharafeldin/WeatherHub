
import SwiftUI

@main
struct WeatherHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(TimeOfDayHelper.current() == .morning ? .light : .dark)
        }
    }
}
