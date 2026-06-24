
import SwiftUI

struct Home: View {
    @State private var selectedTab = 0
    @StateObject private var locationManager = LocationManager()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(white: 0.08, alpha: 0.85)
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)

        let normalColor = UIColor(white: 1.0, alpha: 0.5)
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        let selectedColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
        .accentColor(.white)
        .onAppear {
            locationManager.requestLocation()
        }
    }


    @ViewBuilder
    private var currentLocationWeatherView: some View {
        if let query = locationManager.coordinateQuery {
            WeatherDetailView(query: query)
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
                colors: TimeOfDayHelper.backgroundGradient(for: TimeOfDayHelper.current()),
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
