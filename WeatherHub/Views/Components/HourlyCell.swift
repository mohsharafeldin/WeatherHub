// HourlyCell.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import SwiftUI

/// A compact glassmorphic cell for displaying a single hour's weather forecast.
///
/// Designed to be used inside a horizontal `ScrollView` or `LazyHStack`.
///
/// Usage:
/// ```swift
/// HourlyCell(
///     hour: "3 PM",
///     iconURL: url,
///     temperature: "22°",
///     textColor: .white
/// )
/// ```
struct HourlyCell: View {

    /// The formatted hour label (e.g. "Now", "3 PM", "12 AM").
    let hour: String

    /// The URL for this hour's condition icon.
    let iconURL: URL?

    /// The formatted temperature string (e.g. "22°").
    let temperature: String

    /// The primary text colour, adapted to the current theme.
    let textColor: Color

    var body: some View {
        VStack(spacing: 12) {
            Text(hour)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(textColor)

            AsyncWeatherIcon(iconURL: iconURL, size: 40)

            Text(temperature)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .frame(width: 70)
        .padding(.vertical, 16)
        .glassmorphic()
    }
}

// MARK: - Preview

struct HourlyCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HourlyCell(
                        hour: "Now",
                        iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/113.png"),
                        temperature: "22°",
                        textColor: .white
                    )

                    HourlyCell(
                        hour: "3 PM",
                        iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/116.png"),
                        temperature: "21°",
                        textColor: .white
                    )

                    HourlyCell(
                        hour: "4 PM",
                        iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/119.png"),
                        temperature: "20°",
                        textColor: .white
                    )

                    HourlyCell(
                        hour: "5 PM",
                        iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/night/113.png"),
                        temperature: "18°",
                        textColor: .white
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
