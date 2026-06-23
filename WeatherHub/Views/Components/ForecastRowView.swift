// ForecastRowView.swift
// WeatherHub
//
// Created by WeatherHub on 2024.
//

import SwiftUI

/// A reusable row view for the multi-day weather forecast.
///
/// Displays the day name on the leading edge, a weather condition icon in the centre,
/// and the low-to-high temperature range on the trailing edge.
///
/// Usage:
/// ```swift
/// ForecastRowView(
///     dayLabel: "Tomorrow",
///     iconURL: url,
///     lowTemp: "14°",
///     highTemp: "25°",
///     textColor: .white
/// )
/// ```
struct ForecastRowView: View {

    /// The display label for the day (e.g. "Today", "Tomorrow", "Wednesday").
    let dayLabel: String

    /// The URL for the day's condition icon.
    let iconURL: URL?

    /// The formatted low temperature (e.g. "14°").
    let lowTemp: String

    /// The formatted high temperature (e.g. "25°").
    let highTemp: String

    /// The primary text colour, adapted to the current theme.
    let textColor: Color

    var body: some View {
        HStack {
            Text(dayLabel)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
                .foregroundColor(textColor)

            AsyncWeatherIcon(iconURL: iconURL, size: 32)

            Spacer()

            HStack(spacing: 4) {
                Text(lowTemp)
                    .foregroundColor(textColor.opacity(0.7))

                Text("-")
                    .foregroundColor(textColor.opacity(0.5))

                Text(highTemp)
                    .foregroundColor(textColor)
            }
            .font(.body)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct ForecastRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                ForecastRowView(
                    dayLabel: "Today",
                    iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/113.png"),
                    lowTemp: "14°",
                    highTemp: "25°",
                    textColor: .white
                )

                Divider().background(.white.opacity(0.3))

                ForecastRowView(
                    dayLabel: "Tomorrow",
                    iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/116.png"),
                    lowTemp: "12°",
                    highTemp: "22°",
                    textColor: .white
                )

                Divider().background(.white.opacity(0.3))

                ForecastRowView(
                    dayLabel: "Wednesday",
                    iconURL: URL(string: "https://cdn.weatherapi.com/weather/64x64/day/119.png"),
                    lowTemp: "10°",
                    highTemp: "20°",
                    textColor: .white
                )
            }
            .padding()
            .glassmorphic()
            .padding(.horizontal)
        }
    }
}
