import SwiftUI

@main
struct MyApp: App {
    @StateObject private var pageManager = PageManager()
    @StateObject private var faceManager = FaceManager()
    @StateObject private var postureManager = PostureManager.shared
    
    var body: some Scene {
        WindowGroup {
            Controller()
                .environmentObject(pageManager)
                .environmentObject(faceManager)
                .environmentObject(postureManager)
                .preferredColorScheme(.dark)
                .tint(.white)
        }
    }
}
