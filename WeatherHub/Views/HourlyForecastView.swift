
import SwiftUI

struct HourlyForecastView: View {
    @StateObject var viewModel: HourlyForecastViewModel

    @State private var contentOpacity: Double = 0

    init(forecastDay: ForecastDay, dayLabel: String) {
        _viewModel = StateObject(wrappedValue: HourlyForecastViewModel(
            forecastDay: forecastDay,
            dayLabel: dayLabel
        ))
    }

    private let columns = [
        GridItem(.adaptive(minimum: 72), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: viewModel.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.dayLabel)
                            .font(.title.weight(.semibold))
                            .foregroundColor(viewModel.textColor)

                        Text(viewModel.dateString)
                            .font(.subheadline)
                            .foregroundColor(viewModel.secondaryTextColor)
                    }
                    .padding(.horizontal, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption.weight(.semibold))
                            Text("HOURLY FORECAST")
                                .font(.caption.weight(.semibold))
                                .tracking(1)
                        }
                        .foregroundColor(viewModel.secondaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                        Divider()
                            .background(viewModel.textColor.opacity(0.2))
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.hours) { hour in
                                HourlyCell(
                                    hour: viewModel.hourLabel(for: hour),
                                    iconURL: viewModel.iconURL(for: hour),
                                    temperature: viewModel.temperature(for: hour),
                                    textColor: viewModel.textColor
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)
                    }
                    .glassmorphic()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .opacity(contentOpacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    contentOpacity = 1
                }
            }
        }
        .navigationTitle(viewModel.dayLabel)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct HourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleHours: [HourWeather] = (0..<24).map { i in
            HourWeather(
                timeEpoch: 1700000000 + (i * 3600),
                time: "2026-06-23 \(String(format: "%02d", i)):00",
                tempC: Double.random(in: 20...35),
                isDay: (i >= 6 && i <= 18) ? 1 : 0,
                condition: WeatherCondition(
                    text: "Sunny",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                    code: 1000
                )
            )
        }
        let sampleDay = ForecastDay(
            date: "2026-06-23",
            day: Day(
                maxtempC: 35,
                mintempC: 22,
                condition: WeatherCondition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000)
            ),
            hour: sampleHours
        )

        NavigationView {
            HourlyForecastView(forecastDay: sampleDay, dayLabel: "Today")
        }
    }
}
