import SwiftUI

@main
struct FocusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // iOS için: Ekran boyutuna otomatik uyum sağlar
            // macOS için sabit boyut kaldırıldı - artık her cihaza uyumlu
        }
    }
}
