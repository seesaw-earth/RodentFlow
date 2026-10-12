import SwiftUI

// MARK: - Cross-tab navigation

/// Lets any screen switch tabs ("Compare in Groups", "Add data") without knowing the tab container.
/// A single instance is created by `ContentView` and kept for the app's lifetime, so the
/// environment value never changes and does not make the screens re-render. The default
/// instance does nothing, so views also work outside `ContentView` (previews, sheets).
final class AppNavigator {
    var openGroups: (AssayKind?) -> Void
    var openExperiment: () -> Void

    init(openGroups: @escaping (AssayKind?) -> Void = { _ in }, openExperiment: @escaping () -> Void = {}) {
        self.openGroups = openGroups
        self.openExperiment = openExperiment
    }
}

private struct AppNavigatorKey: EnvironmentKey {
    static let defaultValue = AppNavigator()
}

extension EnvironmentValues {
    var appNavigator: AppNavigator {
        get { self[AppNavigatorKey.self] }
        set { self[AppNavigatorKey.self] = newValue }
    }
}

// MARK: - Workflow steps (Experiment tab, video analysis)

enum WorkflowStep: Int, CaseIterable, Identifiable {
    case start, setup, preview, result

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .start: return loc("Start")
        case .setup: return loc("Set up")
        case .preview: return loc("Preview")
        case .result: return loc("Result")
        }
    }

    /// Title used on "next" buttons: "Preview", "Result", …
    var destinationTitle: String {
        switch self {
        case .start: return loc("Start")
        case .setup: return loc("Setup")
        case .preview: return loc("Preview")
        case .result: return loc("Result")
        }
    }
}

/// Numbered step indicator. Completed steps show a check mark; every step that is already
/// possible can be tapped to jump there, forward or back.
struct WorkflowStepBar: View {
    let current: WorkflowStep
    let isAvailable: (WorkflowStep) -> Bool
    let isDone: (WorkflowStep) -> Bool
    let onSelect: (WorkflowStep) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(WorkflowStep.allCases) { step in
                if step != .start {
                    Capsule()
                        .fill(step.rawValue <= current.rawValue || isDone(step) ? Color.accentColor.opacity(0.55) : Color.secondary.opacity(0.22))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                }
                chip(step)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 7)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func chip(_ step: WorkflowStep) -> some View {
        let available = isAvailable(step)
        let isCurrent = step == current
        let done = isDone(step) && !isCurrent
        return Button {
            if !isCurrent { onSelect(step) }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(isCurrent ? Color.accentColor : (done ? Color.accentColor.opacity(0.16) : Color.secondary.opacity(0.13)))
                        .frame(width: 28, height: 28)
                    if done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.tint)
                    } else {
                        Text("\(step.rawValue + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(isCurrent ? Color.white : (available ? Color.primary : Color.secondary))
                    }
                }
                Text(step.title)
                    .appFont(12.5, weight: isCurrent ? .semibold : .medium)
                    .foregroundStyle(isCurrent || available ? Color.primary : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!available && !isCurrent)
        .opacity(available || isCurrent ? 1 : 0.55)
        .accessibilityLabel(locf("Step %ld of %ld: %@", step.rawValue + 1, WorkflowStep.allCases.count, step.title) + (isCurrent ? loc(", current") : (done ? loc(", done") : "")))
    }
}

// MARK: - Back / next bar

struct FlowAction {
    /// English literal or already-localized text; looked up in the string catalog when shown.
    var title: String
    var systemImage: String?
    var enabled = true
    var prominent = true
    var action: () -> Void
}

/// Bottom bar with a back button on the left and the next step on the right, the same on every
/// screen of a workflow. An optional status view (progress, hints) sits above the buttons.
struct FlowNavigationBar<Status: View>: View {
    let back: FlowAction?
    let secondary: FlowAction?
    let next: FlowAction?
    let status: Status

    init(back: FlowAction? = nil, secondary: FlowAction? = nil, next: FlowAction? = nil, @ViewBuilder status: () -> Status) {
        self.back = back
        self.secondary = secondary
        self.next = next
        self.status = status()
    }

    var body: some View {
        VStack(spacing: 8) {
            Divider()
            status
                .frame(maxWidth: 620, alignment: .leading)
                .padding(.horizontal, 14)
            // Large text sizes: fall back to a compact row (secondary button as icon, no next icon).
            ViewThatFits(in: .horizontal) {
                row(compact: false)
                row(compact: true)
            }
            .frame(maxWidth: 620)
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    private func row(compact: Bool) -> some View {
        HStack(spacing: 10) {
            if let back {
                Button(action: back.action) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(loc(back.title))
                            .appFont(16, weight: .medium)
                            .lineLimit(1)
                    }
                    .frame(minHeight: 44)
                    .padding(.horizontal, 2)
                }
                .buttonStyle(.bordered)
                .disabled(!back.enabled)
            }
            if let secondary {
                Button(action: secondary.action) {
                    HStack(spacing: 5) {
                        if let icon = secondary.systemImage {
                            Image(systemName: icon)
                        }
                        if !compact || secondary.systemImage == nil {
                            Text(loc(secondary.title))
                                .lineLimit(1)
                        }
                    }
                    .appFont(16, weight: .medium)
                    .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .disabled(!secondary.enabled)
                .accessibilityLabel(loc(secondary.title))
            }
            if let next {
                if next.prominent {
                    Button(action: next.action) { nextLabel(next, compact: compact) }
                        .buttonStyle(.borderedProminent)
                        .disabled(!next.enabled)
                } else {
                    Button(action: next.action) { nextLabel(next, compact: compact) }
                        .buttonStyle(.bordered)
                        .disabled(!next.enabled)
                }
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    private func nextLabel(_ next: FlowAction, compact: Bool) -> some View {
        HStack(spacing: 6) {
            if let icon = next.systemImage, !compact {
                Image(systemName: icon)
            }
            Text(loc(next.title))
                .lineLimit(1)
                .minimumScaleFactor(compact ? 0.7 : 1)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
        }
        .appFont(16.5, weight: .semibold)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 44)
    }
}

extension FlowNavigationBar where Status == EmptyView {
    init(back: FlowAction? = nil, secondary: FlowAction? = nil, next: FlowAction? = nil) {
        self.init(back: back, secondary: secondary, next: next) { EmptyView() }
    }
}

// MARK: - Jumping between sections of a long screen

struct JumpSection: Identifiable, Hashable {
    let id: String
    /// English title; translated when shown.
    let title: String
    let systemImage: String
}

/// Row of section chips pinned under the navigation bar; tapping one scrolls to that card.
struct SectionJumpBar: View {
    let sections: [JumpSection]
    let onJump: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sections) { section in
                    Button {
                        onJump(section.id)
                    } label: {
                        Label(loc(section.title), systemImage: section.systemImage)
                            .appFont(14.5, weight: .medium)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                            .overlay(Capsule().stroke(Color.secondary.opacity(0.18), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
        .overlay(alignment: .bottom) { Divider() }
    }
}

/// Toolbar menu listing the sections of a long screen.
struct SectionJumpMenu: View {
    let sections: [JumpSection]
    let onJump: (String) -> Void

    var body: some View {
        Menu {
            ForEach(sections) { section in
                Button {
                    onJump(section.id)
                } label: {
                    Label(loc(section.title), systemImage: section.systemImage)
                }
            }
        } label: {
            Image(systemName: "list.bullet.indent")
                .accessibilityLabel("Jump to section")
        }
    }
}
