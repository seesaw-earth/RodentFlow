import SwiftUI
import UIKit

// MARK: - Colors

/// Color-blind-safe palette (Okabe–Ito). Index 0 is a neutral gray for the control group.
enum GroupPalette {
    static let colors: [Color] = [
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(white: 0.80, alpha: 1) : UIColor(white: 0.32, alpha: 1)
        }),
        Color(red: 0.000, green: 0.447, blue: 0.698),
        Color(red: 0.835, green: 0.369, blue: 0.000),
        Color(red: 0.000, green: 0.620, blue: 0.451),
        Color(red: 0.902, green: 0.624, blue: 0.000),
        Color(red: 0.800, green: 0.475, blue: 0.655),
        Color(red: 0.337, green: 0.706, blue: 0.914),
        Color(red: 0.550, green: 0.350, blue: 0.200)
    ]

    static func color(_ index: Int) -> Color {
        let n = colors.count
        return colors[((index % n) + n) % n]
    }
}

extension AssayKind {
    /// "Video · Manual · CSV"
    var sourceSummary: String {
        var parts: [String] = []
        if supportsVideo { parts.append(loc("Video")) }
        if supportsManualEntry { parts.append(self == .twoArmedBandit ? loc("Trials", context: "source.trials") : loc("Manual")) }
        parts.append("CSV")
        return parts.joined(separator: " · ")
    }
}

// MARK: - Cards and rows
//
// Titles, keys and messages passed to these components as `String` are looked up in the
// string catalog when shown (`loc`), so callers can pass English literals or text that is
// already localized.

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String?
    let trailing: String?
    let content: Content

    init(_ title: String, icon: String? = nil, trailing: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.trailing = trailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                if let icon {
                    Label(loc(title), systemImage: icon)
                } else {
                    Text(loc(title))
                }
                Spacer(minLength: 8)
                if let trailing {
                    Text(trailing)
                        .appFont(13, weight: .semibold, design: .monospaced)
                        .foregroundStyle(.secondary)
                }
            }
            .appFont(17, weight: .semibold)
            content
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var highlight = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(loc(title))
                .appFont(13)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(value)
                .appFont(18, weight: .bold, design: .monospaced)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .padding(11)
        .background(highlight ? Color.accentColor.opacity(0.13) : Color(uiColor: .tertiarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// Grid of the metrics present in a result, in catalog order, primary metric first.
struct MetricGrid: View {
    let result: ExperimentResult
    var limit: Int?

    var body: some View {
        let defs = orderedDefinitions
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: 8)], spacing: 8) {
            ForEach(defs) { def in
                MetricTile(
                    title: def.name,
                    value: result.metrics[def.key].map { def.format($0) } ?? "—",
                    highlight: def.key == result.primaryMetricKey
                )
            }
        }
    }

    private var orderedDefinitions: [MetricDefinition] {
        let all = AssayCatalog.metricDefinitions(for: result).filter { result.metrics[$0.key] != nil }
        let primary = all.filter { $0.key == result.primaryMetricKey }
        let rest = all.filter { $0.key != result.primaryMetricKey }
        let ordered = primary + rest
        if let limit { return Array(ordered.prefix(limit)) }
        return ordered
    }
}

struct FlagList: View {
    let flags: [String]

    var body: some View {
        if !flags.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(flags, id: \.self) { flag in
                    Label {
                        Text(loc(flag)).fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .appFont(14)
                    .foregroundStyle(.orange)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct KeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(loc(key)).foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .appFont(14.5)
    }
}

struct MessageBanner: View {
    enum Style { case error, notice, info }
    let text: String
    var style: Style = .error

    var body: some View {
        Label {
            Text(loc(text)).fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: icon)
        }
        .appFont(15)
        .foregroundStyle(color)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
    }

    private var icon: String {
        switch style {
        case .error: return "exclamationmark.triangle.fill"
        case .notice: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private var color: Color {
        switch style {
        case .error: return .red
        case .notice: return .green
        case .info: return .blue
        }
    }
}

/// One line in a results list.
struct ResultRow: View {
    let result: ExperimentResult

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: result.assay.systemImage)
                .appFont(16.5, weight: .semibold)
                .foregroundStyle(.tint)
                .frame(width: 34, height: 34)
                .background(.tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(result.displaySubject)
                        .appFont(16, weight: .semibold)
                        .strikethrough(result.excluded)
                    Text(result.displayGroup)
                        .appFont(13, weight: .medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1.5)
                        .background(Color.secondary.opacity(0.13), in: Capsule())
                    if !result.qcFlags.isEmpty {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .appFont(12)
                            .foregroundStyle(.orange)
                    }
                }
                Text([result.assay.displayShortName, result.sessionLabel].filter { !$0.isEmpty }.joined(separator: " · "))
                    .appFont(13)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 6)
            VStack(alignment: .trailing, spacing: 2) {
                Text(primaryValue)
                    .appFont(15, weight: .semibold, design: .monospaced)
                Image(systemName: result.source.systemImage)
                    .appFont(12)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }

    private var primaryValue: String {
        let key = result.primaryMetricKey
        guard let value = result.metrics[key] else { return "—" }
        let def = AssayCatalog.metricDefinitions(for: result).first { $0.key == key }
        return def?.format(value) ?? StatsFormat.number(value)
    }
}

// MARK: - Inputs

/// Numeric text field bound to an optional value (blank = nil). Accepts "," as decimal separator.
struct OptionalNumberField: View {
    let title: String
    var unit = ""
    @Binding var value: Double?
    var integer = false
    var help: String?

    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                Text(loc(title))
                    .appFont(15.5)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 6)
                TextField(integer ? "0" : "—", text: $text)
                    .keyboardType(integer ? .numberPad : .decimalPad)
                    .multilineTextAlignment(.trailing)
                    .appFont(15.5, design: .monospaced)
                    .frame(maxWidth: 110)
                    .focused($focused)
                if !unit.isEmpty {
                    Text(unit)
                        .appFont(13.5)
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 22, alignment: .leading)
                }
            }
            if let help {
                Text(loc(help))
                    .appFont(12.5)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { text = Self.format(value, integer: integer) }
        .onChange(of: text) { _, newValue in
            let parsed = Self.parse(newValue)
            if parsed != value { value = parsed }
        }
        .onChange(of: value) { _, newValue in
            if !focused { text = Self.format(newValue, integer: integer) }
        }
    }

    static func parse(_ s: String) -> Double? {
        let t = s.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")
        guard !t.isEmpty, let v = Double(t), v.isFinite else { return nil }
        return v
    }

    static func format(_ v: Double?, integer: Bool) -> String {
        guard let v else { return "" }
        if integer || abs(v - v.rounded()) < 1e-9 { return String(format: "%.0f", v) }
        return String(format: "%g", v)
    }
}

/// Optional integer (day / trial) entered as text.
struct OptionalIntField: View {
    let title: String
    @Binding var value: Int?

    var body: some View {
        OptionalNumberField(
            title: title,
            value: Binding(
                get: { value.map(Double.init) },
                set: { value = $0.map { Int($0.rounded()) } }
            ),
            integer: true
        )
    }
}

// MARK: - Sharing

struct ShareItem: Identifiable {
    let id = UUID()
    let urls: [URL]
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Assay picker

struct AssayPickerSheet: View {
    @Binding var selection: AssayKind
    var videoOnly = false
    var onPick: ((AssayKind) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(AssayCategory.allCases) { category in
                    let assays = AssayKind.allCases.filter { $0.category == category && (!videoOnly || $0.supportsVideo) }
                    if !assays.isEmpty {
                        Section(category.displayName) {
                            ForEach(assays) { assay in
                                Button {
                                    selection = assay
                                    onPick?(assay)
                                    dismiss()
                                } label: {
                                    AssayRow(assay: assay, selected: assay == selection)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle(videoOnly ? "Video assay" : "Choose assay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct AssayRow: View {
    let assay: AssayKind
    var selected = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: assay.systemImage)
                .appFont(16.5, weight: .semibold)
                .foregroundStyle(.tint)
                .frame(width: 32, height: 32)
                .background(.tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(assay.displayName)
                    .appFont(16.5, weight: .medium)
                Text(assay.sourceSummary)
                    .appFont(13)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark")
                    .appFont(15.5, weight: .semibold)
                    .foregroundStyle(.tint)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 2)
    }
}
