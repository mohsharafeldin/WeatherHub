
import SwiftUI
import Combine




final class TimeOfDayManager: ObservableObject {

    static let shared = TimeOfDayManager()

    @Published private(set) var currentLocationTimeOfDay: TimeOfDay = .morning
    @Published private(set) var timeOfDay: TimeOfDay = .morning

    private init() {}



    func update(from weatherResponse: WeatherResponse, isCurrentLocation: Bool = false) {
        let newTimeOfDay: TimeOfDay = weatherResponse.current.isDay == 1 ? .morning : .evening
        if isCurrentLocation {
            currentLocationTimeOfDay = newTimeOfDay
        }
        if newTimeOfDay != timeOfDay {
            withAnimation(.easeInOut(duration: 0.5)) {
                timeOfDay = newTimeOfDay
            }
        }
    }


    func resetToCurrentLocation() {
        if timeOfDay != currentLocationTimeOfDay {
            withAnimation(.easeInOut(duration: 0.5)) {
                timeOfDay = currentLocationTimeOfDay
            }
        }
    }



    var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }


    func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        switch timeOfDay {
        case .evening:

            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)

            let normalColor = UIColor(white: 1.0, alpha: 0.6)
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

            let selectedColor = UIColor.white
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        case .morning:

            let morningBg = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 0.92)
            appearance.backgroundColor = morningBg
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialLight)

            let normalColor = UIColor(red: 0.25, green: 0.35, blue: 0.50, alpha: 0.6)
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

            let selectedColor = UIColor(red: 0.10, green: 0.25, blue: 0.55, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance


        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                windowScene.windows.forEach { window in
                    self.updateTabBar(in: window, appearance: appearance)
                }
            }
        }
    }

    private func updateTabBar(in view: UIView, appearance: UITabBarAppearance) {
        if let tabBar = view as? UITabBar {
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        for subview in view.subviews {
            updateTabBar(in: subview, appearance: appearance)
        }
    }
}
