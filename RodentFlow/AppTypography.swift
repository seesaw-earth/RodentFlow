import SwiftUI
import UIKit

// MARK: - Scalable fonts

/// System font whose point size follows the text-size setting (in-app or iOS Dynamic Type).
/// `size` is the size at the standard ("Large") text size.
struct ScaledSystemFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, weight: Font.Weight, design: Font.Design) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: ScaledSystemFont.textStyle(for: size))
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }

    /// Scale small text like captions and large text like titles, so the hierarchy is kept.
    static func textStyle(for size: CGFloat) -> Font.TextStyle {
        switch size {
        case ..<13: return .caption
        case ..<14.5: return .footnote
        case ..<16: return .subheadline
        case ..<19: return .body
        case ..<24: return .title3
        default: return .title
        }
    }
}

extension View {
    /// App type scale. Use instead of `.font(.system(size:))` so text follows the text-size setting.
    ///
    /// Reference sizes: 13 caption · 14 secondary text · 15 control text · 16.5 primary text ·
    /// 17 card titles · 21 screen titles.
    func appFont(_ size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(ScaledSystemFont(size: size, weight: weight, design: design))
    }
}

// MARK: - Text-size setting

/// In-app text size. "System" follows the iOS Text Size setting; the others override it.
enum AppTextSize: String, CaseIterable, Identifiable {
    case system
    case small
    case standard
    case large
    case extraLarge
    case huge

    static let storageKey = "rf.textSize"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return loc("Same as iPhone")
        case .small: return loc("Small")
        case .standard: return loc("Standard")
        case .large: return loc("Large")
        case .extraLarge: return loc("Extra large")
        case .huge: return loc("Largest")
        }
    }

    /// Sizes allowed for this setting: one fixed size, or the system setting capped below the
    /// accessibility sizes so dense controls and calibration stay usable.
    var allowedRange: ClosedRange<DynamicTypeSize> {
        if let fixed = dynamicTypeSize { return fixed ... fixed }
        return .xSmall ... .xxxLarge
    }

    /// nil = follow the system setting.
    var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .system: return nil
        case .small: return .small
        case .standard: return .large
        case .large: return .xLarge
        case .extraLarge: return .xxLarge
        case .huge: return .xxxLarge
        }
    }
}

/// Applies the in-app text size to the whole view tree. A single code path for every setting:
/// switching the setting only changes the allowed range and never rebuilds the screens.
struct AppTextSizeModifier: ViewModifier {
    let textSize: AppTextSize

    func body(content: Content) -> some View {
        content.dynamicTypeSize(textSize.allowedRange)
    }
}

/// Toolbar control for the text size and the app language ("Aa" button with a menu).
struct TextSizeMenu: View {
    @AppStorage(AppTextSize.storageKey) private var textSize: AppTextSize = .standard
    @Environment(\.openURL) private var openURL

    var body: some View {
        Menu {
            Picker("Text size", selection: $textSize) {
                ForEach(AppTextSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }
            Divider()
            // iOS keeps a per-app language in Settings › RodentFlow › Language (English / 简体中文).
            // The label is bilingual so it can be found whichever language is active.
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            } label: {
                Label {
                    Text(verbatim: "Language / 语言")
                } icon: {
                    Image(systemName: "globe")
                }
            }
        } label: {
            Image(systemName: "textformat.size")
                .accessibilityLabel("Text size")
        }
    }
}
