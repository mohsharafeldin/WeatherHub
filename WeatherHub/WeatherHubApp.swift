//
//  WeatherHubApp.swift
//  WeatherHub
//
//  Created by mohamed sharaf on 20/06/2026.
//

import SwiftUI

@main
struct WeatherHubApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
