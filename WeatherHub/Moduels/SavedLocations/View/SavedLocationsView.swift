
import SwiftUI

struct SavedLocationsView: View {
    @StateObject private var viewModel = SearchViewModel()
    @ObservedObject private var timeOfDayManager = TimeOfDayManager.shared

    private var timeOfDay: TimeOfDay {
        timeOfDayManager.timeOfDay
    }

    private var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    private var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    private var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    Section {
                        if viewModel.favourites.isEmpty {
                            emptyFavouritesView
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                )
                        } else {
                            ForEach(viewModel.favourites, id: \.self) { location in
                                NavigationLink(destination: WeatherDetailView(query: location.cityName ?? "")) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(location.cityName ?? "Unknown")
                                            .font(.title3.weight(.semibold))
                                            .foregroundColor(textColor)

                                        if let country = location.country, !country.isEmpty {
                                            Text(country)
                                                .font(.subheadline)
                                                .foregroundColor(secondaryTextColor)
                                        }
                                    }
                                    .padding(.vertical, 14)
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.ultraThinMaterial)
                                        .padding(.vertical, 5)
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first,
                                   index < viewModel.favourites.count {
                                    viewModel.confirmDelete(viewModel.favourites[index])
                                }
                            }
                        }
                    } header: {
                        Label {
                            Text("Saved Locations")
                                .textCase(.uppercase)
                                .tracking(0.5)
                        } icon: {
                            Image(systemName: "heart.fill")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(secondaryTextColor)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddCityView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundColor(textColor)
                    }
                }
            }
            .alert("Delete Location", isPresented: $viewModel.showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteConfirmed()
                }
            } message: {
                Text("Are you sure you want to remove \(viewModel.locationToDelete?.cityName ?? "") from your saved locations?")
            }
            .onAppear {
                viewModel.loadFavourites()
                TimeOfDayManager.shared.resetToCurrentLocation()
            }
        }
    }



    private var emptyFavouritesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 32))
                .foregroundColor(secondaryTextColor)

            Text("No saved locations")
                .font(.subheadline.weight(.medium))
                .foregroundColor(textColor)

            Text("Tap + to search and add cities")
                .font(.caption)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}




struct AddCityView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject private var timeOfDayManager = TimeOfDayManager.shared

    private var timeOfDay: TimeOfDay {
        timeOfDayManager.timeOfDay
    }

    private var backgroundColors: [Color] {
        TimeOfDayHelper.backgroundGradient(for: timeOfDay)
    }

    private var textColor: Color {
        TimeOfDayHelper.textColor(for: timeOfDay)
    }

    private var secondaryTextColor: Color {
        TimeOfDayHelper.secondaryTextColor(for: timeOfDay)
    }


    private var displayMode: DisplayMode {
        let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .browse
        } else if viewModel.isSearching {
            return .loading
        } else if let error = viewModel.searchError {
            return .error(error)
        } else if viewModel.searchResults.isEmpty {
            return .noResults
        } else {
            return .results(viewModel.searchResults)
        }
    }

    private enum DisplayMode {
        case browse
        case loading
        case error(String)
        case noResults
        case results([City])
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            List {
                switch displayMode {
                case .browse:
                    browseCitiesContent
                case .loading:
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(textColor)
                                    .scaleEffect(1.2)
                                Text("Searching…")
                                    .font(.subheadline)
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.vertical, 32)
                            Spacer()
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                        )
                    }
                case .error(let message):
                    Section {
                        errorView(message: message)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                case .noResults:
                    Section {
                        noResultsView
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.ultraThinMaterial)
                            )
                            .listRowSeparator(.hidden)
                    }
                case .results(let cities):
                    Section {
                        ForEach(cities) { city in
                            cityRow(for: city)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    } header: {
                        Label {
                            Text("Search Results")
                                .textCase(.uppercase)
                                .tracking(0.5)
                        } icon: {
                            Image(systemName: "magnifyingglass")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(secondaryTextColor)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Add City")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            TimeOfDayManager.shared.resetToCurrentLocation()
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search for a city…"
        )
    }



    private var browseCitiesContent: some View {
        ForEach(viewModel.groupedCities, id: \.country) { group in
            Section {
                ForEach(group.cities) { city in
                    cityRow(for: city)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                }
            } header: {
                HStack(spacing: 6) {
                    Text(countryFlag(for: group.country))
                    Text(group.country)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(secondaryTextColor)
            }
        }
    }



    private func cityRow(for city: City) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(textColor)

                Text(city.country)
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.addToFavourites(city)
                }
            } label: {
                Image(systemName: viewModel.isFavourite(cityName: city.name) ? "heart.fill" : "heart")
                    .font(.body)
                    .foregroundColor(viewModel.isFavourite(cityName: city.name) ? .red : textColor.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .scaleEffect(viewModel.isFavourite(cityName: city.name) ? 1.15 : 1.0)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }



    @State private var globeRotating = false

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.americas")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: [textColor.opacity(0.5), secondaryTextColor.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .rotationEffect(.degrees(globeRotating ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                        globeRotating = true
                    }
                }

            VStack(spacing: 6) {
                Text("No cities found")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(textColor)

                Text("\"\(viewModel.searchText)\" doesn't match any location")
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Text("Try searching for a city or country name")
                .font(.caption)
                .foregroundColor(secondaryTextColor.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(textColor.opacity(0.06))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeOut(duration: 0.3), value: viewModel.showNoResults)
    }



    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundColor(secondaryTextColor)

            Text("Search failed")
                .font(.subheadline.weight(.medium))
                .foregroundColor(textColor)

            Text(message)
                .font(.caption)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }



    private func countryFlag(for country: String) -> String {
        let countryMap: [String: String] = [
            "Egypt": "🇪🇬", "Nigeria": "🇳🇬", "Ghana": "🇬🇭", "Kenya": "🇰🇪",
            "Tanzania": "🇹🇿", "Ethiopia": "🇪🇹", "Morocco": "🇲🇦", "Tunisia": "🇹🇳",
            "Algeria": "🇩🇿", "South Africa": "🇿🇦", "Rwanda": "🇷🇼", "Uganda": "🇺🇬",
            "Senegal": "🇸🇳", "Ivory Coast": "🇨🇮", "Mozambique": "🇲🇿", "Zambia": "🇿🇲",
            "Zimbabwe": "🇿🇼", "Namibia": "🇳🇦", "UAE": "🇦🇪", "Saudi Arabia": "🇸🇦",
            "Qatar": "🇶🇦", "Kuwait": "🇰🇼", "Oman": "🇴🇲", "Bahrain": "🇧🇭",
            "Jordan": "🇯🇴", "Lebanon": "🇱🇧", "Iraq": "🇮🇶", "Iran": "🇮🇷",
            "Yemen": "🇾🇪", "United Kingdom": "🇬🇧", "Ireland": "🇮🇪", "France": "🇫🇷",
            "Netherlands": "🇳🇱", "Belgium": "🇧🇪", "Switzerland": "🇨🇭", "Portugal": "🇵🇹",
            "Iceland": "🇮🇸", "Luxembourg": "🇱🇺", "Germany": "🇩🇪", "Austria": "🇦🇹",
            "Czech Republic": "🇨🇿", "Hungary": "🇭🇺", "Poland": "🇵🇱", "Slovakia": "🇸🇰",
            "Slovenia": "🇸🇮", "Italy": "🇮🇹", "Spain": "🇪🇸", "Greece": "🇬🇷",
            "Turkey": "🇹🇷", "Malta": "🇲🇹", "Cyprus": "🇨🇾", "Denmark": "🇩🇰",
            "Sweden": "🇸🇪", "Norway": "🇳🇴", "Finland": "🇫🇮", "Estonia": "🇪🇪",
            "Latvia": "🇱🇻", "Lithuania": "🇱🇹", "Russia": "🇷🇺", "Romania": "🇷🇴",
            "Bulgaria": "🇧🇬", "Serbia": "🇷🇸", "Croatia": "🇭🇷",
            "Bosnia and Herzegovina": "🇧🇦", "Montenegro": "🇲🇪", "North Macedonia": "🇲🇰",
            "Albania": "🇦🇱", "Kosovo": "🇽🇰", "Belarus": "🇧🇾", "Ukraine": "🇺🇦",
            "Moldova": "🇲🇩", "Georgia": "🇬🇪", "Armenia": "🇦🇲", "Azerbaijan": "🇦🇿",
            "Uzbekistan": "🇺🇿", "Kazakhstan": "🇰🇿", "Kyrgyzstan": "🇰🇬",
            "Tajikistan": "🇹🇯", "Turkmenistan": "🇹🇲", "India": "🇮🇳", "Pakistan": "🇵🇰",
            "Bangladesh": "🇧🇩", "Sri Lanka": "🇱🇰", "Nepal": "🇳🇵", "Afghanistan": "🇦🇫",
            "China": "🇨🇳", "Japan": "🇯🇵", "South Korea": "🇰🇷", "Taiwan": "🇹🇼",
            "Mongolia": "🇲🇳", "Thailand": "🇹🇭", "Singapore": "🇸🇬", "Indonesia": "🇮🇩",
            "Philippines": "🇵🇭", "Malaysia": "🇲🇾", "Vietnam": "🇻🇳", "Cambodia": "🇰🇭",
            "Myanmar": "🇲🇲", "Laos": "🇱🇦", "United States": "🇺🇸", "Canada": "🇨🇦",
            "Mexico": "🇲🇽", "Cuba": "🇨🇺", "Panama": "🇵🇦", "Costa Rica": "🇨🇷",
            "Guatemala": "🇬🇹", "Honduras": "🇭🇳", "El Salvador": "🇸🇻",
            "Nicaragua": "🇳🇮", "Jamaica": "🇯🇲", "Haiti": "🇭🇹",
            "Dominican Republic": "🇩🇴", "Bahamas": "🇧🇸", "Colombia": "🇨🇴",
            "Peru": "🇵🇪", "Chile": "🇨🇱", "Argentina": "🇦🇷", "Uruguay": "🇺🇾",
            "Brazil": "🇧🇷", "Ecuador": "🇪🇨", "Venezuela": "🇻🇪", "Bolivia": "🇧🇴",
            "Paraguay": "🇵🇾", "Guyana": "🇬🇾", "Australia": "🇦🇺",
            "New Zealand": "🇳🇿", "Fiji": "🇫🇯"
        ]
        return countryMap[country] ?? "🌍"
    }
}


struct SavedLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationsView()
    }
}
