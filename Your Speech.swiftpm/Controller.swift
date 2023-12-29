import SwiftUI

struct Controller: View {
    @EnvironmentObject var pageManager: PageManager
    
    @State private var nav: NavigationSplitViewVisibility = .all
    
    private let lessons = ["Intro", "Voice", "Face", "Posture", "Finish"]
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
                        currentProgress
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            testMinusButton
                            testPlusButton
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
        case 2: Face()
        case 3: Posture()
        case 4: Finish()
        default: Intro()
        }
    }
    
    private var testMinusButton: some View {
        Button(action: {
            pageManager.minusPage()
        }, label: {
            Image(systemName: "arrowtriangle.left.fill")
        })
    }
    
    private var testPlusButton: some View {
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
            Image(systemName: "info.circle.fill")
                .font(.title2)
        }
        .sheet(isPresented: $showCurrentProgress) {
            NavigationStack {
                CurrentProgressView()
            }
        }
    }
}
