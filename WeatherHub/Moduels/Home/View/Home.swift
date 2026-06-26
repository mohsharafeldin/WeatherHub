
import SwiftUI

struct Home: View {
    @State private var selectedTab = 0
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var timeOfDayManager = TimeOfDayManager.shared

    init() {

        TimeOfDayManager.shared.applyTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                currentLocationWeatherView
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Image(systemName: "location.fill")
                Text("My Location")
            }
            .tag(0)

            SavedLocationsView()
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Locations")
                }
                .tag(1)
        }
        .accentColor(timeOfDayManager.timeOfDay == .morning
                      ? Color(red: 0.10, green: 0.25, blue: 0.55)
                      : .white)
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: selectedTab) { newTab in
            if newTab == 0 {
                timeOfDayManager.resetToCurrentLocation()
            }
        }
        .onChange(of: timeOfDayManager.timeOfDay) { _ in
            timeOfDayManager.applyTabBarAppearance()
        }
    }


    @ViewBuilder
    private var currentLocationWeatherView: some View {
        if let query = locationManager.coordinateQuery {
            WeatherDetailView(query: query, isCurrentLocation: true)
        } else if let error = locationManager.locationError {
            locationStatusView(
                icon: "location.slash.fill",
                title: "Location Unavailable",
                message: error,
                showSettingsButton: locationManager.authorizationStatus == .denied
            )
        } else {
            locationStatusView(
                icon: "location.circle",
                title: "Finding Your Location…",
                message: "WeatherHub needs your location to show local weather.",
                showSettingsButton: false
            )
        }
    }

    private func locationStatusView(icon: String, title: String, message: String, showSettingsButton: Bool) -> some View {
        ZStack {
            LinearGradient(
                colors: TimeOfDayHelper.backgroundGradient(for: timeOfDayManager.timeOfDay),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundColor(.white.opacity(0.7))

                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                if showSettingsButton {
                    Button(action: openAppSettings) {
                        HStack(spacing: 8) {
                            Image(systemName: "gear")
                            Text("Open Settings")
                        }
                        .font(.body.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                } else if !locationManager.isDetermined {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.3)
                }
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
