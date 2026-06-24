
import SwiftUI

struct SavedLocationsView: View {
    @StateObject private var viewModel = SearchViewModel()

    private var timeOfDay: TimeOfDay {
        TimeOfDayHelper.current()
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
                    if !viewModel.filteredCities.isEmpty {
                        Section {
                            ForEach(viewModel.filteredCities) { city in
                                searchResultRow(for: city)
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
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search for a city..."
            )
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
            }
        }
    }


    private func searchResultRow(for city: City) -> some View {
        ZStack(alignment: .leading) {
            NavigationLink(destination: WeatherDetailView(query: city.name)) {
                EmptyView()
            }
            .opacity(0)

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
                }
                .buttonStyle(.plain)
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

            Text("Search for a city and tap the heart to save it")
                .font(.caption)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}


struct SavedLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationsView()
    }
}
