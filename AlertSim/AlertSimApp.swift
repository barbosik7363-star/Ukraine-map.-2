import SwiftUI

@main
struct AlertSimApp: App {
    @StateObject private var store = AlertStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
