import Foundation

class WeatherService: ObservableObject {
    @Published var weather: WeatherData?
    @Published var cityName: String = ""
    @Published var country: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func searchCity(_ query: String) async {
        guard !query.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let geoURL = "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedQuery)&count=1"
        
        guard let url = URL(string: geoURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode(GeocodingResult.self, from: data)
            
            guard let location = result.results?.first else {
                DispatchQueue.main.async {
                    self.errorMessage = "City not found"
                    self.isLoading = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.cityName = location.name
                self.country = location.country
            }
            
            await fetchWeather(lat: location.latitude, lon: location.longitude)
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Something went wrong"
                self.isLoading = false
            }
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) async {
        let weatherURL = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,visibility,weather_code"
        
        guard let url = URL(string: weatherURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let weather = try JSONDecoder().decode(WeatherData.self, from: data)
            
            DispatchQueue.main.async {
                self.weather = weather
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch weather"
                self.isLoading = false
            }
        }
    }
}
