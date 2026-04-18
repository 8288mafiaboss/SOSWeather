import Foundation

struct WeatherData: Codable {
    let current: CurrentWeather
    
    struct CurrentWeather: Codable {
        let temperature_2m: Double
        let apparent_temperature: Double
        let relative_humidity_2m: Double
        let wind_speed_10m: Double
        let visibility: Double
        let weather_code: Int
    }
}

struct GeocodingResult: Codable {
    let results: [GeoLocation]?
    
    struct GeoLocation: Codable {
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String
    }
}

func weatherCondition(code: Int) -> String {
    switch code {
    case 0: return "Clear Sky"
    case 1, 2, 3: return "Partly Cloudy"
    case 45, 48: return "Foggy"
    case 51, 53, 55: return "Drizzle"
    case 61, 63, 65: return "Rain"
    case 71, 73, 75: return "Snow"
    case 80, 81, 82: return "Rain Showers"
    case 95: return "Thunderstorm"
    default: return "Unknown"
    }
}
