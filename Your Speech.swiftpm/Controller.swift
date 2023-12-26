import SwiftUI

struct Controller: View {
    @EnvironmentObject var pageManager: PageManager
    
    @State private var nav: NavigationSplitViewVisibility = .all
    
    private let lessons = ["Intro", "Voice", "Script", "Face", "Attitude", "Finish"]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $nav) {
            List(0..<6, selection: $pageManager.currentPage) { index in
                Text("\(index+1). \(lessons[index])")
                    .listRowSeparator(.visible, edges: .bottom)
                    .listRowSeparatorTint(.gray.opacity(0.4))
            }
            .navigationTitle("Lessons")
            .onChange(of: pageManager.currentPage) { _ in // hide sidebar setting
                nav = .detailOnly
            }
        } detail: {
            NavigationStack {
                lesson
            }
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
}
