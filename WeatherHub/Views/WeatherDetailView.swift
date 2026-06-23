//
//  WeatherDetailView.swift
//  WeatherHub
//
//  Created by mohamed sharaf on 23/06/2026.
//

import SwiftUI

struct WeatherDetailView: View {
    @StateObject private var viewModel = WeatherViewModel()
    let query: String
    
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dynamic gradient background filling entire screen
            LinearGradient(
                colors: viewModel.backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(viewModel.textColor)
                        .scaleEffect(1.5)
                    Text("Loading weather...")
                        .font(.subheadline)
                        .foregroundColor(viewModel.secondaryTextColor)
                }
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        topSection
                        forecastSection
                        detailsGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .opacity(contentOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.6)) {
                        contentOpacity = 1
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchWeather(for: query)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.icloud.fill")
                .font(.system(size: 56))
                .foregroundColor(viewModel.textColor.opacity(0.6))
            
            Text("Something went wrong")
                .font(.title2.weight(.semibold))
                .foregroundColor(viewModel.textColor)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(viewModel.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.fetchWeather(for: query)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.body.weight(.medium))
                .foregroundColor(viewModel.textColor)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    // MARK: - Top Section
    
    private var topSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.locationName)
                .font(.title.weight(.medium))
                .foregroundColor(viewModel.textColor)
            
            Text(viewModel.currentTemp)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .foregroundColor(viewModel.textColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 6) {
                AsyncWeatherIcon(iconURL: viewModel.conditionIconURL, size: 36)
                
                Text(viewModel.conditionText)
                    .font(.title3.weight(.medium))
                    .foregroundColor(viewModel.textColor)
            }
            
            HStack(spacing: 16) {
                Label {
                    Text(viewModel.highTemp)
                        .font(.body.weight(.medium))
                } icon: {
                    Text("H:")
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(viewModel.textColor)
                
                Label {
                    Text(viewModel.lowTemp)
                        .font(.body.weight(.medium))
                } icon: {
                    Text("L:")
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(viewModel.textColor.opacity(0.8))
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Forecast Section
    
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption.weight(.semibold))
                Text("3-DAY FORECAST")
                    .font(.caption.weight(.semibold))
                    .tracking(1)
            }
            .foregroundColor(viewModel.secondaryTextColor)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)
            
            Divider()
                .background(viewModel.textColor.opacity(0.2))
                .padding(.horizontal, 16)
            
            // Forecast Rows
            VStack(spacing: 0) {
                ForEach(Array(viewModel.forecastDays.enumerated()), id: \.element.id) { index, day in
                    let iconURLString = day.day.condition.icon.hasPrefix("//")
                        ? "https:\(day.day.condition.icon)"
                        : day.day.condition.icon
                    let iconURL = URL(string: iconURLString)
                    let lowTemp = "\(Int(day.day.mintempC))°"
                    let highTemp = "\(Int(day.day.maxtempC))°"
                    let label = viewModel.dayLabel(for: index)
                    
                    NavigationLink(destination: HourlyForecastView(forecastDay: day, dayLabel: label)) {
                        ForecastRowView(
                            dayLabel: label,
                            iconURL: iconURL,
                            lowTemp: lowTemp,
                            highTemp: highTemp,
                            textColor: viewModel.textColor
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    
                    if index < viewModel.forecastDays.count - 1 {
                        Divider()
                            .background(viewModel.textColor.opacity(0.15))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .glassmorphic()
    }
    
    // MARK: - Details Grid
    
    private var detailsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            WeatherInfoCard(
                title: "Visibility",
                value: viewModel.visibility,
                systemIcon: "eye.fill",
                textColor: viewModel.textColor
            )
            
            WeatherInfoCard(
                title: "Humidity",
                value: viewModel.humidity,
                systemIcon: "humidity.fill",
                textColor: viewModel.textColor
            )
            
            WeatherInfoCard(
                title: "Feels Like",
                value: viewModel.feelsLike,
                systemIcon: "thermometer.medium",
                textColor: viewModel.textColor
            )
            
            WeatherInfoCard(
                title: "Pressure",
                value: viewModel.pressure,
                systemIcon: "gauge.medium",
                textColor: viewModel.textColor
            )
        }
    }
}

// MARK: - Preview

struct WeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeatherDetailView(query: "Cairo")
        }
    }
}
