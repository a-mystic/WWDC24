import SwiftUI

@main
struct MyApp: App {
    @StateObject private var pageManager = PageManager()
    
    var body: some Scene {
        WindowGroup {
            Controller()
                .environmentObject(pageManager)
                .preferredColorScheme(.dark)
        }
    }
}
