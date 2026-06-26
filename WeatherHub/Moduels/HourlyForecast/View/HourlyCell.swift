
import SwiftUI

struct HourlyCell: View {

    let hour: String

    let iconURL: URL?

    let temperature: String

    let textColor: Color

    var body: some View {
        VStack(spacing: 14) {
            Text(hour)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(textColor)

            AsyncWeatherIcon(iconURL: iconURL, size: 48)

            Text(temperature)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .frame(minWidth: 80, maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassmorphic()
    }
}


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
