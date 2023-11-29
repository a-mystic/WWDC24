import SwiftUI

@main
struct MyApp: App {
    @StateObject var pageManager = PageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pageManager)
        }
    }
}
