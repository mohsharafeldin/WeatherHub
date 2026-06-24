
import SwiftUI

struct WeatherInfoCard: View {

    let title: String

    let value: String

    let systemIcon: String

    let textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                    .font(.caption)

                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(textColor.opacity(0.7))

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassmorphic()
    }
}


struct WeatherInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    WeatherInfoCard(
                        title: "Humidity",
                        value: "72%",
                        systemIcon: "humidity",
                        textColor: .white
                    )

                    WeatherInfoCard(
                        title: "Feels Like",
                        value: "19°",
                        systemIcon: "thermometer.medium",
                        textColor: .white
                    )
                }

                HStack(spacing: 16) {
                    WeatherInfoCard(
                        title: "Visibility",
                        value: "10 km",
                        systemIcon: "eye.fill",
                        textColor: .white
                    )

                    WeatherInfoCard(
                        title: "Pressure",
                        value: "1013 mb",
                        systemIcon: "gauge.medium",
                        textColor: .white
                    )
                }
            }
            .padding()
        }
    }
}
