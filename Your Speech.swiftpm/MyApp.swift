import SwiftUI

@main
struct MyApp: App {
    @StateObject var pageManager = PageManager()
    @StateObject var faceManager = FaceManager()
    
    var body: some Scene {
        WindowGroup {
            Controller()
                .environmentObject(pageManager)
                .environmentObject(faceManager)
                .preferredColorScheme(.dark)
        }
    }
}
