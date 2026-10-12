import SwiftUI

@main
struct RodentFlowApp: App {
    /// Owned here with @State (created once per launch) so that no view above the screens
    /// observes AppState: its frequent changes then only redraw the screen that shows them.
    @State private var model = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
