// AsyncWeatherIcon.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import SwiftUI

/// A reusable view that asynchronously loads and displays a weather condition icon from a URL.
///
/// The WeatherAPI returns icon URLs like `"//cdn.weatherapi.com/weather/64x64/day/113.png"`.
/// Callers should prepend `"https:"` before constructing the URL.
///
/// Usage:
/// ```swift
/// AsyncWeatherIcon(iconURL: viewModel.conditionIconURL, size: 48)
/// ```
struct AsyncWeatherIcon: View {

    /// The URL of the weather icon to load. `nil` displays a fallback icon.
    let iconURL: URL?

    /// The width and height of the icon. Defaults to 40pt.
    var size: CGFloat = 40

    var body: some View {
        if let url = iconURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)

                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)

                case .failure:
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .foregroundColor(.gray)

                @unknown default:
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                        .foregroundColor(.gray)
                }
            }
        } else {
            Image(systemName: "cloud.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Preview

struct AsyncWeatherIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AsyncWeatherIcon(
                iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/113.png"),
                size: 64
            )

            AsyncWeatherIcon(iconURL: nil, size: 48)

            AsyncWeatherIcon(
                iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/night/116.png"),
                size: 32
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
