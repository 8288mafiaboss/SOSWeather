import SwiftUI

@main
struct SOSWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 420, minHeight: 580)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
