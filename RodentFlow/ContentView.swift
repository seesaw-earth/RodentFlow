import SwiftUI

struct ContentView: View {
    enum Tab: Hashable { case experiment, groups }

    /// Not observed here on purpose: ContentView only switches tabs. Each screen observes the
    /// model itself, so a progress update does not rebuild both tabs.
    let model: AppState
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: Tab = .experiment
    /// Assay the Groups tab should show when it is opened from a result ("Compare in Groups").
    @State private var groupsAssayRequest: AssayKind?
    @AppStorage(AppTextSize.storageKey) private var textSize: AppTextSize = .standard
    /// Created once; its actions are connected in `onAppear` (see `AppNavigator`).
    @State private var navigator = AppNavigator()

    var body: some View {
        TabView(selection: $selectedTab) {
            ExperimentTab(model: model)
                .tabItem { Label(loc("Experiment", context: "tab.experiment"), systemImage: "scope") }
                .tag(Tab.experiment)

            GroupAnalysisView(library: model.library, requestedAssay: $groupsAssayRequest)
                .tabItem { Label(loc("Groups", context: "tab.groups"), systemImage: "chart.bar.xaxis") }
                .tag(Tab.groups)
        }
        .environment(\.appNavigator, navigator)
        .onAppear {
            navigator.openGroups = { assay in
                groupsAssayRequest = assay
                selectedTab = .groups
            }
            navigator.openExperiment = {
                selectedTab = .experiment
            }
        }
        // Text size: the in-app setting (Aa button) or the iPhone setting, capped below the
        // accessibility sizes so dense controls and calibration stay usable.
        .modifier(AppTextSizeModifier(textSize: textSize))
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                model.handleAppEnteredBackground()
            }
        }
    }
}

/// Tab 1: single-experiment processing (video tracking, manual entry, results).
struct ExperimentTab: View {
    @ObservedObject var model: AppState

    var body: some View {
        Group {
            switch model.stage {
            case .home:
                HomeView(model: model, library: model.library)
            case .setup:
                SetupView(model: model)
            case .preview:
                PreviewView(model: model)
            }
        }
    }
}
