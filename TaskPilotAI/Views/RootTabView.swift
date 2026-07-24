import SwiftUI

struct RootTabView: View {
    let container: AppDependencyContainer

    var body: some View {
        TabView {
            DashboardView(container: container)
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }

            TaskListView(container: container)
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
        }
    }
}

#if DEBUG
#Preview {
    RootTabView(container: .preview())
}
#endif
