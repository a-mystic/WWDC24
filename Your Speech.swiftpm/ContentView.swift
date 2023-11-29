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
            if let currentPage = pageManager.currentPage {
                lessons(page: currentPage)
            }
        }
    }
    
    @ViewBuilder
    private func lessons(page: Int) -> some View {
        if page == 0 {
            Intro()
        } else if page == 1 {
            Voice()
        } else if page == 2 {
            Attitude()
        } else if page == 3 {
            Final()
        }
    }
}
