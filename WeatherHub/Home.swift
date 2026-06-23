//
//  Home.swift
//  WeatherHub
//
//  Created by mohamed sharaf on 20/06/2026.
//

import SwiftUI

struct Home: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                WeatherDetailView(query: "30.0444,31.2357")
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "cloud.sun.fill")
                Text("Weather")
            }
            .tag(0)
            
            SavedLocationsView()
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Locations")
                }
                .tag(1)
        }
        .accentColor(.white)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
