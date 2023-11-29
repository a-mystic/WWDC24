import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pageManager: PageManager
    
    @State private var nav: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $nav) {
            List(0..<5, selection: $pageManager.currentPage) { index in
                Text("\(index+1). lesson")
                    .listRowSeparator(.visible, edges: .bottom)
                    .listRowSeparatorTint(.gray.opacity(0.4))
            }
            .navigationTitle("Lessons")
            .onChange(of: pageManager.currentPage) { _ in // hide sidebar setting
                nav = .detailOnly
            }
        } detail: {
            lessons
        }
    }
    
    @ViewBuilder
    private var lessons: some View {
        switch pageManager.currentPage {
        case 0: Intro()
        case 1: Voice()
        case 2: Face()
        case 3: Attitude()
        case 4: Final()
        default: Intro()
        }
    }
}
