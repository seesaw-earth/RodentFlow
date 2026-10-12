import SwiftUI

struct SetupView: View {
    @ObservedObject var model: AppState
    @State private var showingAssayPicker = false
    @State private var showingSettings = false
    @State private var confirmingClose = false

    private static let sections = [
        JumpSection(id: "video", title: "Video", systemImage: "video"),
        JumpSection(id: "experiment", title: "Experiment", systemImage: "tag"),
        JumpSection(id: "arena", title: "Assay & arena", systemImage: "square.dashed"),
        JumpSection(id: "settings", title: "Analysis settings", systemImage: "slider.horizontal.3"),
        JumpSection(id: "window", title: "Preview window", systemImage: "play.rectangle"),
        JumpSection(id: "calibration", title: "Calibration", systemImage: "viewfinder")
    ]

    private var maxPreviewStart: Double { max(0, (model.videoMetadata?.durationSeconds ?? 0) - 10) }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        if model.canReusePreviousSetup { reuseCard }
                        videoInfo.id("video")
                        experimentInfo.id("experiment")
                        arenaInfo.id("arena")
                        assaySettings.id("settings")
                        previewRange.id("window")
                        calibrationSection.id("calibration")
                        if let error = model.errorMessage { errorCard(error) }
                    }
                    .frame(maxWidth: 620, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(uiColor: .systemGroupedBackground))
                .safeAreaInset(edge: .top, spacing: 0) {
                    WorkflowStepBar(
                        current: .setup,
                        isAvailable: { model.isStepAvailable($0) },
                        isDone: { model.isStepDone($0) },
                        onSelect: { model.go(to: $0) }
                    )
                }
                .safeAreaInset(edge: .bottom, spacing: 0) { navigationBar }
                .navigationTitle("Experiment setup")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .destructive) {
                            confirmingClose = true
                        } label: {
                            Label("Close video", systemImage: "xmark")
                        }
                        .disabled(model.isBusy)
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        SectionJumpMenu(sections: Self.sections) { id in
                            withAnimation { proxy.scrollTo(id, anchor: .top) }
                        }
                        TextSizeMenu()
                    }
                }
            }
            .sheet(isPresented: $showingAssayPicker) {
                AssayPickerSheet(selection: Binding(get: { model.assay }, set: { model.selectAssay($0) }), videoOnly: true)
            }
            .confirmationDialog("Close this video?", isPresented: $confirmingClose, titleVisibility: .visible) {
                Button("Close Video", role: .destructive) { model.reset() }
            } message: {
                Text("The setup of this video is discarded. Results that were already saved stay in Results.")
            }
        }
    }

    private var reuseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Same setup as the previous video?", systemImage: "arrow.triangle.2.circlepath")
                .appFont(16, weight: .semibold)
            Text(locf("Apply the arena size, calibration and analysis settings used for %@. Check the calibration handles afterwards if the camera moved.", model.previousSetup?.videoName ?? loc("the previous video")))
                .appFont(14)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                model.reusePreviousSetup()
            } label: {
                Label("Use Previous Setup", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 40)
            }
            .buttonStyle(.bordered)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Check 10 seconds before full analysis")
                .appFont(21, weight: .semibold)
            Text("Preview and full analysis use the same classic-centroid tracker at 10 Hz. The preview is only a 10-second visual QC.")
                .appFont(15)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }

    private var videoInfo: some View {
        sectionCard(title: "Video", icon: "video") {
            if let metadata = model.videoMetadata {
                VStack(spacing: 8) {
                    keyValue("Source", model.videoSource == .photos ? loc("Photos") : loc("Files"))
                    keyValue("Filename", model.originalVideoFilename.isEmpty ? loc("Video") : model.originalVideoFilename)
                    Divider()
                    keyValue("Duration", metadata.durationSeconds.minuteSecondString)
                    keyValue("Resolution", "\(Int(metadata.pixelWidth)) × \(Int(metadata.pixelHeight))")
                    keyValue("Source frame rate", String(format: "%.2f fps", metadata.nominalFPS))
                    Divider()
                    keyValue("Created", metadata.creationDate.map { $0.formatted(date: .abbreviated, time: .shortened) } ?? loc("Not available"))
                    keyValue(loc("Imported", context: "setup.importedAt"), model.importedAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
        }
    }

    private var experimentInfo: some View {
        sectionCard(title: "Experiment", icon: "tag") {
            VStack(alignment: .leading, spacing: 10) {
                labeledField("Mouse ID") {
                    TextField("e.g. C01", text: $model.mouseID)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                }
                labeledField("Group") {
                    TextField("e.g. WT, KO, Vehicle", text: $model.group)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                Picker("Sex", selection: $model.sex) {
                    Text("—").tag("")
                    Text("Male").tag("M")
                    Text("Female").tag("F")
                }
                .pickerStyle(.segmented)
                if !model.assay.phases.isEmpty {
                    labeledField(model.assay.phaseLabel) {
                        Picker(model.assay.phaseLabel, selection: $model.phase) {
                            ForEach(model.assay.phases, id: \.self) { p in
                                Text(AssayKind.phaseTitle(p)).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                if model.assay.usesDays || model.assay.usesTrials {
                    HStack(spacing: 12) {
                        if model.assay.usesDays { OptionalIntField(title: "Day", value: $model.day) }
                        if model.assay.usesTrials { OptionalIntField(title: "Trial", value: $model.trial) }
                    }
                }
                DatePicker(
                    "Experiment date",
                    selection: Binding(
                        get: { model.experimentDate },
                        set: { model.experimentDate = $0; model.markExperimentDateEdited() }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                keyValue("Date source", dateSourceLabel)
            }
        }
    }

    private var arenaInfo: some View {
        sectionCard(title: "Assay & arena", icon: model.assay.systemImage) {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    showingAssayPicker = true
                } label: {
                    HStack(spacing: 8) {
                        AssayRow(assay: model.assay)
                        Image(systemName: "chevron.up.chevron.down")
                            .appFont(14.5, weight: .semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(9)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(.plain)

                if model.assay.videoArenaShapes.count > 1 {
                    Picker("Arena shape", selection: $model.arenaShape) {
                        ForEach(model.assay.videoArenaShapes) { shape in
                            Text(shape.shortName).tag(shape)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                switch model.arenaShape {
                case .rectangle:
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 9) {
                            arenaDimensionField("Width", value: $model.arenaWidthCM)
                            arenaDimensionField("Height", value: $model.arenaHeightCM)
                        }
                        VStack(spacing: 9) {
                            arenaDimensionField("Width", value: $model.arenaWidthCM)
                            arenaDimensionField("Height", value: $model.arenaHeightCM)
                        }
                    }
                case .circle:
                    arenaDimensionField("Diameter", value: $model.arenaWidthCM)
                case .tMaze:
                    arenaDimensionField("Start arm length", value: $model.tStartArmLengthCM)
                    arenaDimensionField("Choice arm length (each side)", value: $model.tChoiceArmLengthCM)
                    arenaDimensionField("Arm width", value: $model.mazeArmWidthCM)
                case .yMaze:
                    arenaDimensionField("Arm length", value: $model.yArmLengthCM)
                    arenaDimensionField("Arm width", value: $model.mazeArmWidthCM)
                case .plusMaze:
                    arenaDimensionField("Arm length (excluding center)", value: $model.plusArmLengthCM)
                    arenaDimensionField("Arm width", value: $model.plusArmWidthCM)
                }
            }
        }
    }

    private var assaySettings: some View {
        sectionCard(title: "Analysis settings", icon: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Zones and thresholds are applied after tracking and can be changed later on the result screen without re-analyzing the video.")
                    .appFont(13.5)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                DisclosureGroup(isExpanded: $showingSettings) {
                    ZoneParameterEditor(assay: model.assay, config: $model.zoneConfig)
                        .padding(.top, 8)
                } label: {
                    Text(showingSettings ? loc("Hide settings") : locf("Show settings for %@", model.assay.displayShortName))
                        .appFont(15.5, weight: .medium)
                }
            }
        }
    }

    private var previewRange: some View {
        sectionCard(title: "10-second preview", icon: "play.rectangle") {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text("Start").appFont(15)
                    Spacer()
                    Text(model.previewStartSeconds.minuteSecondString)
                        .appFont(15, weight: .semibold, design: .monospaced)
                }
                Slider(value: $model.previewStartSeconds, in: 0...max(0.001, maxPreviewStart), step: 0.5)
                    .disabled(maxPreviewStart <= 0)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { useFrameButton; randomButton }
                    VStack(spacing: 8) { useFrameButton; randomButton }
                }
            }
        }
    }

    private var useFrameButton: some View {
        Button { Task { await model.refreshCalibrationFrame() } } label: {
            Label("Use this frame", systemImage: "photo").frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var randomButton: some View {
        Button { Task { await model.randomizePreviewStart() } } label: {
            Label("Random 10s", systemImage: "shuffle").frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(maxPreviewStart <= 0)
    }

    private var calibrationSection: some View {
        sectionCard(title: calibrationTitle, icon: "viewfinder") {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .firstTextBaseline) {
                    Text(calibrationInstruction)
                        .appFont(15)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Button("Reset") { model.calibration = ArenaCalibration() }
                        .appFont(15, weight: .semibold)
                }
                if let image = model.calibrationImage {
                    CalibrationCanvas(image: image, shape: model.arenaShape, calibration: $model.calibration,
                                      calibrationValue: model.calibration, assay: model.assay, zoneConfig: model.zoneConfig)
                        .equatable()
                } else {
                    RoundedRectangle(cornerRadius: 13).fill(.quaternary).frame(height: 180).overlay(ProgressView())
                }
                Text(calibrationFootnote)
                    .appFont(13)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Back to the start screen (the video stays open) · forward to the preview.
    private var navigationBar: some View {
        let previewIsCurrent = model.previewResult != nil && !model.isPreviewStale
        let next: FlowAction
        if model.isBusy {
            next = FlowAction(title: "Analyzing at 10 Hz…", systemImage: "hourglass", enabled: false) {}
        } else if previewIsCurrent {
            next = FlowAction(title: "Preview", systemImage: "play.rectangle") { model.go(to: .preview) }
        } else {
            next = FlowAction(title: model.previewResult == nil ? "Generate Preview" : "Update Preview", systemImage: "scope",
                              enabled: canAnalyzePreview) {
                Task { await model.generatePreview() }
            }
        }
        return FlowNavigationBar(
            back: FlowAction(title: "Start", enabled: !model.isBusy) { model.go(to: .start) },
            next: next
        ) {
            if model.isBusy && model.previewAnalysisProgress.fraction > 0 {
                analysisProgressView(model.previewAnalysisProgress, title: "Analyzing 10-second preview")
            } else if model.previewResult != nil && model.isPreviewStale {
                Label("The setup changed since the last preview. Update the preview before the full analysis.", systemImage: "exclamationmark.arrow.triangle.2.circlepath")
                    .appFont(13.5)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var canAnalyzePreview: Bool {
        guard !model.isBusy, model.calibrationImage != nil else { return false }
        switch model.arenaShape {
        case .rectangle: return model.arenaWidthCM > 0 && model.arenaHeightCM > 0
        case .circle: return model.arenaWidthCM > 0
        case .tMaze: return model.tStartArmLengthCM > 0 && model.tChoiceArmLengthCM > 0 && model.mazeArmWidthCM > 0
        case .yMaze: return model.yArmLengthCM > 0 && model.mazeArmWidthCM > 0
        case .plusMaze: return model.plusArmLengthCM > 0 && model.plusArmWidthCM > 0
        }
    }

    private func analysisProgressView(_ snapshot: AnalysisProgressSnapshot, title: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(loc(title)).appFont(13, weight: .semibold)
                Spacer()
                Text(String(format: "%.0f%%", snapshot.fraction * 100))
                    .appFont(13, weight: .semibold, design: .monospaced)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.16))
                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .mint], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(3, geo.size.width * snapshot.fraction))
                }
            }
            .frame(height: 7)
            HStack {
                Text(frameProgressText(snapshot)).appFont(12, design: .monospaced)
                Spacer()
                Text(remainingText(snapshot.remainingSeconds)).appFont(12, design: .monospaced)
            }
            .foregroundStyle(.secondary)
        }
    }

    private func frameProgressText(_ snapshot: AnalysisProgressSnapshot) -> String {
        if let total = snapshot.estimatedTotalSamples { return locf("%ld / ~%ld samples", snapshot.processedSamples, total) }
        return locf("%ld samples", snapshot.processedSamples)
    }

    private func remainingText(_ seconds: Double?) -> String {
        guard let seconds else { return loc("Estimating…") }
        if seconds < 60 { return locf("~%lds remaining", Int(seconds.rounded())) }
        return locf("~%.1f min remaining", seconds / 60)
    }

    private func arenaDimensionField(_ title: String, value: Binding<Double>) -> some View {
        labeledField(loc(title) + " (cm)") {
            TextField("40", value: value, format: .number.precision(.fractionLength(0...1)))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loc(title)).appFont(13).foregroundStyle(.secondary)
            content()
        }
    }

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(loc(title), systemImage: icon).appFont(17, weight: .semibold)
            content()
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var calibrationTitle: String {
        switch model.arenaShape {
        case .rectangle: return loc("Arena corners")
        case .circle: return loc("Arena circle")
        case .tMaze: return loc("T-maze centerlines")
        case .yMaze: return loc("Y-maze centerlines")
        case .plusMaze: return loc("Plus-maze centerlines")
        }
    }

    private var calibrationInstruction: String {
        let base: String
        switch model.arenaShape {
        case .rectangle: base = loc("Drag 1 → 2 → 3 → 4 around the inner floor boundary.")
        case .circle: base = loc("Drag C to the arena center, then drag R to the inner wall boundary.")
        case .tMaze: base = loc("Drag J to the junction, S to the end of the start arm, and L/R to the two choice-arm ends.")
        case .yMaze: base = loc("Drag J to the center junction and A/B/C to the three arm ends.")
        case .plusMaze: base = loc("Drag C to the maze center and N/E/S/W to the ends of the four arms.")
        }
        switch model.assay {
        case .novelObject: return base + " " + loc("Then drag A and B onto the centers of the two objects.")
        case .morrisWaterMaze: return base + " " + loc("Then drag P onto the platform center.")
        case .barnesMaze: return base + " " + loc("Then drag T onto the target (escape) hole.")
        default: return base
        }
    }

    private var calibrationFootnote: String {
        switch model.arenaShape {
        case .rectangle: return loc("Coordinates are perspective-corrected before conversion to centimeters.")
        case .circle: return loc("Best with a top-down or near-top-down camera. C defines center and R defines radius.")
        case .tMaze: return loc("The app builds a lightweight corridor mask from the three centerlines and the entered arm width.")
        case .yMaze: return loc("The app builds a lightweight three-arm corridor mask. Arm entries require 0.25 s of stable zone occupancy.")
        case .plusMaze: return loc("Arms are labeled by image direction (N = top). Choose which pair is open in Analysis settings.")
        }
    }

    private var dateSourceLabel: String {
        switch model.experimentDateSource {
        case .videoMetadata: return loc("Video metadata")
        case .userEntered: return loc("User entered")
        case .importTimeFallback: return loc("Import time fallback")
        }
    }

    private func keyValue(_ key: String, _ value: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(loc(key)).foregroundStyle(.secondary)
                Spacer(minLength: 12)
                Text(value).multilineTextAlignment(.trailing).lineLimit(2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(loc(key)).foregroundStyle(.secondary)
                Text(value).fixedSize(horizontal: false, vertical: true)
            }
        }
        .appFont(15)
    }

    private func errorCard(_ error: String) -> some View {
        Label { Text(error).fixedSize(horizontal: false, vertical: true) } icon: { Image(systemName: "exclamationmark.triangle.fill") }
            .appFont(15)
            .foregroundStyle(.red)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 13))
    }
}

/// The calibration image with its handles. Equatable, so typing the mouse ID or group (which
/// redraws the setup form) does not redraw the image and its overlays on every keystroke.
private struct CalibrationCanvas: View, Equatable {
    let image: UIImage
    let shape: ArenaShape
    @Binding var calibration: ArenaCalibration
    /// Snapshot of the calibration, compared to decide whether the canvas must redraw.
    let calibrationValue: ArenaCalibration
    let assay: AssayKind
    let zoneConfig: ZoneConfig

    static func == (a: CalibrationCanvas, b: CalibrationCanvas) -> Bool {
        a.image === b.image && a.shape == b.shape && a.calibrationValue == b.calibrationValue
            && a.assay == b.assay && a.zoneConfig == b.zoneConfig
    }

    var body: some View {
        ArenaCalibrationView(image: image, shape: shape, calibration: $calibration, assay: assay, zoneConfig: zoneConfig)
    }
}
