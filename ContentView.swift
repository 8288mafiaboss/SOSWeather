import SwiftUI

struct ContentView: View {
    @StateObject private var service = WeatherService()
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color(hex: "0f0f0f")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                
                if service.isLoading {
                    loadingView
                } else if let error = service.errorMessage {
                    errorView(error)
                } else if let weather = service.weather {
                    weatherView(weather)
                } else {
                    placeholderView
                }
                
                Spacer()
                bottomBar
            }
        }
        .preferredColorScheme(.dark)
    }
    
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "444444"))
            TextField("Search city...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(Color(hex: "888888"))
                .onSubmit {
                    Task {
                        await service.searchCity(searchText)
                    }
                }
        }
        .padding(10)
        .background(Color(hex: "1a1a1a"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "2a2a2a"), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    func weatherView(_ weather: WeatherData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(service.cityName), \(service.country)")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "888888"))
                    .kerning(1.2)
                    .textCase(.uppercase)
                
                HStack(alignment: .top, spacing: 0) {
                    Text("\(Int(weather.current.temperature_2m))")
                        .font(.system(size: 72, weight: .medium))
                        .foregroundColor(Color(hex: "f0f0f0"))
                    Text("°C")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(Color(hex: "555555"))
                        .padding(.top, 14)
                }
                
                Text(weatherCondition(code: weather.current.weather_code))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "666666"))
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
                .background(Color(hex: "1e1e1e"))
                .padding(.horizontal, 24)
            
            HStack {
                statItem(label: "Feels like", value: "\(Int(weather.current.apparent_temperature))°", sub: "celsius")
                Spacer()
                statItem(label: "Humidity", value: "\(Int(weather.current.relative_humidity_2m))%", sub: "percent")
                Spacer()
                statItem(label: "Wind", value: "\(Int(weather.current.wind_speed_10m))", sub: "km/h")
                Spacer()
                statItem(label: "Visibility", value: "\(Int(weather.current.visibility / 1000))", sub: "km")
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    func statItem(label: String, value: String, sub: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "444444"))
                .kerning(0.8)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "bbbbbb"))
            Text(sub)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "555555"))
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(hex: "444444"))
            Text("Fetching weather...")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "444444"))
        }
        .padding(.top, 80)
    }
    
    func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "444444"))
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "444444"))
        }
        .padding(.top, 80)
    }
    
    var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "cloud")
                .font(.system(size: 36))
                .foregroundColor(Color(hex: "222222"))
            Text("Search for a city")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "333333"))
        }
        .padding(.top, 80)
    }
    
    var bottomBar: some View {
        HStack {
            Text("Updated just now")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "333333"))
            Spacer()
            Text("SOS WEATHER")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "2a2a2a"))
                .kerning(1.5)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color(hex: "111111"))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(hex: "1e1e1e")),
            alignment: .top
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
