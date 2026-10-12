import SwiftUI

/// Assay-specific analysis settings. Used before tracking (setup) and afterwards on the result
/// screen, where every change re-computes the metrics from the saved tracking samples.
struct ZoneParameterEditor: View {
    let assay: AssayKind
    @Binding var config: ZoneConfig
    var showWindow = true

    @State private var csText = ""
    @State private var csCount = 3
    @State private var csFirst: Double = 120
    @State private var csInterval: Double = 90

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch assay {
            case .openField: openFieldControls
            case .elevatedPlusMaze: plusMazeControls
            case .lightDark: lightDarkControls
            case .placePreference: cppControls
            case .novelObject: norControls
            case .morrisWaterMaze: waterMazeControls
            case .barnesMaze: barnesControls
            case .fearConditioning: fearControls
            case .yMaze, .tMaze: mazeControls
            default: EmptyView()
            }
            if showWindow && assay != .fearConditioning {
                windowControls
            }
        }
        .onAppear { csText = Self.formatList(config.csOnsetsSeconds) }
    }

    // MARK: Assays

    private var openFieldControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Center zone size", value: $config.centerFraction, range: 0.3...0.8, step: 0.05) { f in
                String(format: loc("%.0f%% of side · %.0f%% of area"), f * 100, f * f * 100)
            }
            sliderRow("Moving threshold", value: $config.movingSpeedCMs, range: 0.5...6, step: 0.5) { String(format: "%.1f cm/s", $0) }
            sliderRow("Minimum immobility bout", value: $config.immobilityMinSeconds, range: 0.5...5, step: 0.5) { String(format: "%.1f s", $0) }
            Picker("Time bins", selection: $config.timeBinSeconds) {
                Text("1 min").tag(60.0)
                Text("2 min").tag(120.0)
                Text("5 min").tag(300.0)
                Text("10 min").tag(600.0)
            }
            .pickerStyle(.segmented)
            entryRow
        }
    }

    private var plusMazeControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeled("Open arms") {
                Picker("Open arms", selection: $config.plusOpenAxis) {
                    Text("N–S (top/bottom)").tag("NS")
                    Text("E–W (left/right)").tag("EW")
                }
                .pickerStyle(.segmented)
            }
            sliderRow("Extra center margin", value: $config.plusCenterMarginCM, range: 0...4, step: 0.5) { String(format: "+%.1f cm", $0) }
            entryRow
        }
    }

    private var lightDarkControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeled("Light compartment") {
                Picker("Light side", selection: $config.lightOnLeft) {
                    Text("Left").tag(true)
                    Text("Right").tag(false)
                }
                .pickerStyle(.segmented)
            }
            sliderRow("Light compartment length", value: $config.lightFraction, range: 0.3...1.0, step: 0.01) { String(format: loc("%.0f%% of arena"), $0 * 100) }
            Toggle("Count unseen samples as dark", isOn: $config.undetectedIsDark)
                .appFont(15.5)
            Text(loc("If only the light compartment was calibrated, use 100%."))
                .appFont(12.5)
                .foregroundStyle(.secondary)
            entryRow
        }
    }

    private var cppControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeled("Apparatus") {
                Picker("Chambers", selection: $config.cppChambers) {
                    Text("2 chambers").tag(2)
                    Text("3 chambers").tag(3)
                }
                .pickerStyle(.segmented)
            }
            if config.cppChambers >= 3 {
                sliderRow("Neutral chamber width", value: $config.cppNeutralFraction, range: 0.05...0.5, step: 0.01) { String(format: loc("%.0f%% of arena"), $0 * 100) }
            } else {
                sliderRow("Divider position", value: $config.cppDivider, range: 0.2...0.8, step: 0.01) { String(format: loc("%.0f%% from left"), $0 * 100) }
            }
            labeled("Paired (drug / reward) side") {
                Picker("Paired side", selection: $config.cppPairedOnLeft) {
                    Text("Left").tag(true)
                    Text("Right").tag(false)
                }
                .pickerStyle(.segmented)
            }
            entryRow
        }
    }

    private var norControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeled("Novel object") {
                Picker("Novel object", selection: $config.novelObject) {
                    Text("A").tag("A")
                    Text("B").tag("B")
                }
                .pickerStyle(.segmented)
            }
            sliderRow("Interaction radius (centroid)", value: $config.objectZoneRadiusCM, range: 2...14, step: 0.5) { String(format: "%.1f cm", $0) }
            Text("Measured from the body centre, which sits ~4–5 cm behind the nose: use about object radius + 5 cm.")
                .appFont(12.5)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            sliderRow("Exclusion criterion (total)", value: $config.minTotalExplorationSeconds, range: 0...30, step: 1) { String(format: "%.0f s", $0) }
            entryRow
        }
    }

    private var waterMazeControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Platform zone radius", value: $config.targetRadiusCM, range: 3...15, step: 0.5) { String(format: "%.1f cm", $0) }
            sliderRow("Trial maximum", value: $config.maxTrialSeconds, range: 30...180, step: 5) { String(format: "%.0f s", $0) }
            sliderRow("Must stay on platform", value: $config.platformStaySeconds, range: 0...5, step: 0.5) { String(format: "%.1f s", $0) }
            sliderRow("Wall zone width", value: $config.wallZoneCM, range: 0...25, step: 1) { String(format: "%.0f cm", $0) }
        }
    }

    private var barnesControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper(value: $config.holeCount, in: 8...40) {
                Text(locf("Holes: %ld", config.holeCount)).appFont(15.5)
            }
            sliderRow("Hole zone radius", value: $config.targetRadiusCM, range: 2...14, step: 0.5) { String(format: "%.1f cm", $0) }
            Text("Measured from the body centre. During a poke the head disappears into the hole, so the centre stays ~5–7 cm away; visits go to the nearest hole.")
                .appFont(12.5)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            sliderRow("Trial maximum", value: $config.maxTrialSeconds, range: 60...600, step: 10) { String(format: "%.0f s", $0) }
            entryRow
        }
    }

    private var mazeControls: some View {
        sliderRow("Arm entry criterion", value: $config.mazeEntryMinSeconds, range: 0.1...1.5, step: 0.05) { String(format: loc("%.2f s stable"), $0) }
    }

    private var fearControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Freezing threshold", value: $config.freezeThresholdPct, range: 0.5...30, step: 0.5) { String(format: loc("%.1f%% of body changing"), $0) }
            sliderRow("Minimum freezing bout", value: $config.freezeMinSeconds, range: 0.3...3, step: 0.1) { String(format: "%.1f s", $0) }
            numberRow("Protocol start in video", unit: "s", value: $config.protocolOffsetSeconds)
            numberRow("Baseline (pre-CS)", unit: "s", value: $config.baselineSeconds)
            numberRow("CS duration", unit: "s", value: $config.csDurationSeconds)
            numberRow("Analyzed length (0 = all)", unit: "s", value: $config.analysisDurationSeconds)
            Picker("Time bins", selection: $config.fearBinSeconds) {
                Text("30 s").tag(30.0)
                Text("1 min").tag(60.0)
                Text("2 min").tag(120.0)
            }
            .pickerStyle(.segmented)
            VStack(alignment: .leading, spacing: 4) {
                Text("CS onsets (s from protocol start)").appFont(15.5)
                TextField("e.g. 120, 210, 300", text: $csText)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                    .appFont(15.5, design: .monospaced)
                    .onChange(of: csText) { _, newValue in
                        let parsed = Self.parseList(newValue)
                        if parsed != config.csOnsetsSeconds { config.csOnsetsSeconds = parsed }
                    }
                DisclosureGroup("Fill evenly") {
                    VStack(alignment: .leading, spacing: 8) {
                        Stepper(value: $csCount, in: 1...30) { Text(locf("CS count: %ld", csCount)).appFont(15) }
                        numberRow("First onset", unit: "s", value: $csFirst)
                        numberRow("Onset-to-onset interval", unit: "s", value: $csInterval)
                        Button("Apply") {
                            let onsets = (0..<csCount).map { csFirst + Double($0) * csInterval }
                            config.csOnsetsSeconds = onsets
                            csText = Self.formatList(onsets)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 4)
                }
                .appFont(15)
            }
            Text("Freezing = motion below the threshold for at least the minimum bout. Check the threshold against a few hand-scored clips from your own setup.")
                .appFont(12.5)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var windowControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text("Analysis window").appFont(14.5, weight: .semibold)
            numberRow(assay == .morrisWaterMaze || assay == .barnesMaze ? "Trial start in video" : "Start after", unit: "s", value: $config.analysisStartSeconds)
            if assay != .morrisWaterMaze && assay != .barnesMaze {
                numberRow("Length (0 = to end)", unit: "s", value: $config.analysisDurationSeconds)
            }
        }
    }

    private var entryRow: some View {
        sliderRow("Zone entry criterion", value: $config.entryMinSeconds, range: 0...2, step: 0.1) { String(format: loc("%.1f s stable"), $0) }
    }

    // MARK: Building blocks

    private func sliderRow(_ title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, format: (Double) -> String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(loc(title)).appFont(15.5)
                Spacer(minLength: 8)
                Text(format(value.wrappedValue))
                    .appFont(14, weight: .semibold, design: .monospaced)
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range, step: step)
        }
    }

    private func numberRow(_ title: String, unit: String, value: Binding<Double>) -> some View {
        OptionalNumberField(
            title: title,
            unit: unit,
            value: Binding(get: { value.wrappedValue }, set: { if let v = $0 { value.wrappedValue = max(0, v) } })
        )
    }

    private func labeled<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(loc(title)).appFont(13.5).foregroundStyle(.secondary)
            content()
        }
    }

    static func parseList(_ s: String) -> [Double] {
        s.split(whereSeparator: { $0 == "," || $0 == ";" || $0 == " " || $0 == "\n" })
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 >= 0 }
            .sorted()
    }

    static func formatList(_ values: [Double]) -> String {
        values.map { abs($0 - $0.rounded()) < 1e-9 ? String(format: "%.0f", $0) : String(format: "%.1f", $0) }.joined(separator: ", ")
    }
}
