import SwiftUI

struct Controller: View {
    @EnvironmentObject var pageManager: PageManager
    
    @State private var nav: NavigationSplitViewVisibility = .all
    
    private let lessons = ["Intro", "Voice", "Script", "Face", "Attitude", "Finish"]
    private var currentLessonTitle: String {
        if pageManager.currentPage != nil {
            return lessons[pageManager.currentPage!]
        }
        return ""
    }
    
    var body: some View {
        NavigationStack {
            lesson
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            testButton
                            currentProgress
                        }
                    }
                }
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationTitle(currentLessonTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var lesson: some View {
        switch pageManager.currentPage {
        case 0: Intro()
        case 1: Voice()
        case 2: Script()
        case 3: Face()
        case 4: Attitude()
        case 5: Finish()
        default: Intro()
        }
    }
    
    private var testButton: some View {
        Button(action: {
            pageManager.addPage()
        }, label: {
            Image(systemName: "arrowtriangle.right.fill")
        })
    }
    
    @State private var showCurrentProgress = false
    
    private var currentProgress: some View {
        Button {
            showCurrentProgress = true
        } label: {
            Image(systemName: "info.circle")
                .font(.title2)
        }
        .sheet(isPresented: $showCurrentProgress) {
            CurrentProgressView()
        }
    }
}
