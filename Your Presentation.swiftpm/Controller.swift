import SwiftUI

struct Controller: View {
    @EnvironmentObject var pageManager: PageManager
        
    private let lessons = ["Intro", "Voice&Face", "Posture", "Finish"]
    private var currentLessonTitle: String {
        if pageManager.currentPage != nil {
            return lessons[pageManager.currentPage!]
        }
        return ""
    }
    
    var body: some View {
        NavigationStack {
            lesson
                .toolbar { ToolbarItem(placement: .topBarTrailing) { description } }
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationTitle(currentLessonTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var lesson: some View {
        switch pageManager.currentPage {
        case 0: Intro()
        case 1: VoiceAndFace()
        case 2: PostureView()
        case 3: Finish()
        default: Intro()
        }
    }
    
    @State private var showDescription = false
    
    private var description: some View {
        Button {
            showDescription = true
        } label: {
            Image(systemName: "info.circle")
                .font(.title2)
        }
        .sheet(isPresented: $showDescription) {
            NavigationStack {
                Description()
            }
        }
    }
}
