import SwiftUI

/// Single-experiment result: metrics, plots, post-hoc zone / threshold adjustment with live
/// re-computation (video results), metadata, exclusion and export.
struct ResultDetailView: View {
    @ObservedObject var library: ResultsLibrary
    /// Set when the result was opened from the video workflow: offers "Next animal".
    let onNextAnimal: (() -> Void)?

    /// The result shown; the up / down buttons move through the results of the same assay.
    @State private var resultID: UUID
    @Environment(\.appNavigator) private var navigator

    init(library: ResultsLibrary, resultID: UUID, onNextAnimal: (() -> Void)? = nil) {
        _library = ObservedObject(wrappedValue: library)
        self.onNextAnimal = onNextAnimal
        _resultID = State(initialValue: resultID)
    }

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case unavailable(String)
    }

    @State private var draft: ExperimentResult?
    @State private var saved: ExperimentResult?
    @State private var samples: [AnalysisSample] = []
    @State private var loadState: LoadState = .idle
    @State private var plotMode: ArenaPlotMode = .trajectory
    @State private var showingManualEdit = false
    @State private var showingDelete = false
    @State private var shareItem: ShareItem?
    @State private var shareError: String?
    /// Bumped whenever new tracking samples are loaded (cheap identity for the plots).
    @State private var samplesVersion = 0
    /// Checked once when the result loads, not on every redraw.
    @State private var hasTrackingFolder = false
    @Environment(\.dismiss) private var dismiss

    private var hasChanges: Bool {
        guard let draft, let saved else { return false }
        return draft != saved
    }

    var body: some View {
        Group {
            if let r = draft {
                content(r)
            } else {
                ContentUnavailableView("Result not found", systemImage: "questionmark.folder")
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(draft?.displaySubject ?? loc("Result"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if siblings.count > 1 {
                    Button {
                        step(by: -1)
                    } label: {
                        Image(systemName: "chevron.up")
                            .accessibilityLabel("Previous result")
                    }
                    .disabled(siblingIndex.map { $0 == 0 } ?? true || hasChanges)
                    Button {
                        step(by: 1)
                    } label: {
                        Image(systemName: "chevron.down")
                            .accessibilityLabel("Next result")
                    }
                    .disabled(siblingIndex.map { $0 >= siblings.count - 1 } ?? true || hasChanges)
                }
                Menu {
                    Button {
                        shareJSON()
                    } label: {
                        Label("Share result (JSON)", systemImage: "curlybraces")
                    }
                    if let name = saved?.runFolderName, hasTrackingFolder {
                        Button {
                            shareRunFolder(name)
                        } label: {
                            Label("Share tracking folder", systemImage: "folder")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(draft == nil)
            }
        }
        .task(id: resultID) { await load() }
        .onChange(of: library.results) { _, _ in refreshFromLibrary() }
        .sheet(isPresented: $showingManualEdit) {
            if let r = saved {
                ManualEntryView(library: library, assay: r.assay, existing: r)
            }
        }
        .sheet(item: $shareItem) { item in
            ActivityView(items: item.urls)
        }
        .confirmationDialog("Delete this result?", isPresented: $showingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let r = saved { library.delete(r) }
                dismiss()
            }
        } message: {
            Text("The tracking files in the run folder are kept.")
        }
    }

    // MARK: Layout

    private func content(_ r: ExperimentResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header(r)
                Group {
                    if r.excluded {
                        MessageBanner(text: r.exclusionReason.isEmpty ? loc("Excluded from group analysis.") : locf("Excluded from group analysis: %@", r.exclusionReason), style: .info)
                    }
                    FlagList(flags: r.qcFlags)
                    if let shareError { MessageBanner(text: shareError) }
                }

                SectionCard("Results", icon: "number", trailing: r.assay.displayShortName) {
                    if r.metrics.isEmpty {
                        Text("No metrics could be computed.")
                            .appFont(14.5)
                            .foregroundStyle(.secondary)
                    } else {
                        MetricGrid(result: r)
                    }
                }

                visuals(r)

                Group {
                    if !r.labels.isEmpty { labelsCard(r) }

                    if r.source == .video, r.zoneConfig != nil, r.assay.supportsVideo {
                        SectionCard("Analysis settings", icon: "slider.horizontal.3") {
                            if samples.isEmpty {
                                Text("Settings can be changed once the tracking data is loaded.")
                                    .appFont(14)
                                    .foregroundStyle(.secondary)
                            } else {
                                ZoneParameterEditor(assay: r.assay, config: configBinding)
                            }
                        }
                    }

                    if r.manualInput != nil && r.assay.supportsManualEntry {
                        manualCard(r)
                    }
                }

                detailsCard(r)
                methodsCard(r)

                Button(role: .destructive) {
                    showingDelete = true
                } label: {
                    Label("Delete Result", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 4)
            }
            .frame(maxWidth: 620, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if hasChanges {
                unsavedBar
            } else {
                resultNavigationBar(r)
            }
        }
    }

    /// Results of the same assay in library order (newest first), for the up / down buttons.
    private var siblings: [UUID] {
        guard let assay = (draft ?? library.result(id: resultID))?.assay else { return [] }
        return library.results.filter { $0.assay == assay }.map(\.id)
    }

    private var siblingIndex: Int? { siblings.firstIndex(of: resultID) }

    private func step(by offset: Int) {
        guard !hasChanges, let i = siblingIndex else { return }
        let j = i + offset
        guard siblings.indices.contains(j) else { return }
        resultID = siblings[j]
    }

    private func resultNavigationBar(_ r: ExperimentResult) -> some View {
        let groups = FlowAction(title: "Compare in Groups", systemImage: "chart.bar.xaxis", prominent: onNextAnimal == nil) {
            navigator.openGroups(r.assay)
        }
        return Group {
            if let onNextAnimal {
                FlowNavigationBar(
                    secondary: FlowAction(title: loc("Groups", context: "tab.groups"), systemImage: "chart.bar.xaxis") { navigator.openGroups(r.assay) },
                    next: FlowAction(title: "Next Animal", systemImage: "forward.end", action: onNextAnimal)
                ) {
                    positionText
                }
            } else {
                FlowNavigationBar(next: groups) {
                    positionText
                }
            }
        }
    }

    @ViewBuilder
    private var positionText: some View {
        if siblings.count > 1, let i = siblingIndex, let assay = draft?.assay {
            Text(locf("%@ result %ld of %ld · use ▲▼ at the top to browse", assay.displayShortName, i + 1, siblings.count))
                .appFont(13)
                .foregroundStyle(.secondary)
        }
    }

    private func header(_ r: ExperimentResult) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: r.assay.systemImage)
                .appFont(22, weight: .semibold)
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(r.assay.displayName)
                    .appFont(18.5, weight: .semibold)
                Text([r.displayGroup, r.sex, r.sessionLabel].filter { !$0.isEmpty }.joined(separator: " · "))
                    .appFont(14.5)
                    .foregroundStyle(.secondary)
                Label(r.experimentDate.formatted(date: .abbreviated, time: .omitted) + " · " + r.source.displayName, systemImage: r.source.systemImage)
                    .appFont(13)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func visuals(_ r: ExperimentResult) -> some View {
        if r.source == .video {
            SectionCard(r.assay == .fearConditioning ? "Freezing" : "Arena", icon: r.assay == .fearConditioning ? "waveform.path.ecg" : "map") {
                switch loadState {
                case .loading, .idle:
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Loading tracking data…").appFont(14.5).foregroundStyle(.secondary)
                    }
                case .unavailable(let message):
                    Text(loc(message))
                        .appFont(14)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                case .loaded:
                    if let config = r.zoneConfig {
                        if r.assay != .fearConditioning {
                            Picker("Plot", selection: $plotMode) {
                                ForEach(ArenaPlotMode.allCases) { mode in
                                    Text(loc(mode.rawValue)).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        TrackingVisuals(
                            assay: r.assay,
                            config: config,
                            samples: samples,
                            samplesVersion: samplesVersion,
                            mode: plotMode,
                            markers: markers(r.assay, config),
                            onMoveMarker: { id, point in moveMarker(id, point) }
                        )
                        .equatable()
                        if r.assay != .fearConditioning {
                            if !markers(r.assay, config).isEmpty {
                                Text("Drag the markers onto the true positions — results update immediately. Tap Save to keep the changes.")
                                    .appFont(12.5)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        if r.assay == .twoArmedBandit, let rows = r.manualInput?.rows, rows.count >= 2 {
            SectionCard("Session", icon: "dice") {
                BanditSessionChart(rows: rows)
            }
        }
        ForEach(r.series) { s in
            SectionCard(s.name, icon: "chart.bar") {
                SeriesChartView(series: s)
            }
        }
    }

    private func labelsCard(_ r: ExperimentResult) -> some View {
        SectionCard("Sequence & labels", icon: "text.alignleft") {
            ForEach(r.labels.keys.sorted(), id: \.self) { key in
                VStack(alignment: .leading, spacing: 2) {
                    Text(locKey(key, capitalized: true))
                        .appFont(13)
                        .foregroundStyle(.secondary)
                    Text(loc(r.labels[key] ?? ""))
                        .appFont(15, design: .monospaced)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func manualCard(_ r: ExperimentResult) -> some View {
        SectionCard("Entered values", icon: "keyboard") {
            let schema = ManualAssays.schema(for: r.assay)
            if let input = r.manualInput {
                ForEach(schema.fields) { field in
                    if let value = input.values[field.key] {
                        KeyValueRow(key: field.label, value: displayValue(value, field: field))
                    } else if let text = input.text[field.key], !text.isEmpty {
                        KeyValueRow(key: field.label, value: text)
                    }
                }
                if schema.hasRows {
                    KeyValueRow(key: schema.rowCountTitle, value: "\(input.rows.count)")
                }
            }
            Button {
                showingManualEdit = true
            } label: {
                Label("Edit Values", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(hasChanges)
            if hasChanges {
                Text("Save or revert the other changes first.")
                    .appFont(12.5)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func detailsCard(_ r: ExperimentResult) -> some View {
        SectionCard("Details", icon: "tag") {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                field("Subject ID") {
                    TextField("Subject ID", text: bind(\.subjectID, ""))
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }
                field("Group") {
                    TextField("Group", text: bind(\.group, ""))
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                }
                Picker("Sex", selection: bind(\.sex, "")) {
                    Text("—").tag("")
                    Text("Male").tag("M")
                    Text("Female").tag("F")
                }
                .pickerStyle(.segmented)
                if !r.assay.phases.isEmpty {
                    field(r.assay.phaseLabel) {
                        Picker(r.assay.phaseLabel, selection: phaseBinding) {
                            Text("—").tag("")
                            ForEach(r.assay.phases, id: \.self) { p in
                                Text(AssayKind.phaseTitle(p)).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } else {
                    field(r.assay.phaseLabel) {
                        TextField("Optional", text: phaseBinding)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                OptionalIntField(title: "Day", value: bind(\.day, nil))
                OptionalIntField(title: "Trial", value: bind(\.trial, nil))
                DatePicker("Date", selection: bind(\.experimentDate, Date()), displayedComponents: [.date])
                    .appFont(15.5)
                }
                Divider()
                Group {
                Toggle("Exclude from group analysis", isOn: bind(\.excluded, false))
                    .appFont(15.5)
                if r.excluded {
                    TextField("Reason (e.g. fell off maze, low exploration)", text: bind(\.exclusionReason, ""))
                        .textFieldStyle(.roundedBorder)
                }
                field("Notes") {
                    TextField("Optional", text: bind(\.notes, ""), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                }
                }
                Divider()
                Group {
                KeyValueRow(key: "Source", value: r.source.displayName)
                if let dataset = r.datasetName { KeyValueRow(key: "File", value: dataset) }
                if let run = r.runFolderName { KeyValueRow(key: "Run folder", value: run) }
                KeyValueRow(key: "Created", value: r.createdAt.formatted(date: .abbreviated, time: .shortened))
                KeyValueRow(key: "Updated", value: r.updatedAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
        }
    }

    private func methodsCard(_ r: ExperimentResult) -> some View {
        SectionCard("Methods", icon: "doc.text.magnifyingglass") {
            DisclosureGroup("How these numbers are computed") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(r.assay.methodsNote)
                        .appFont(14)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(AssayCatalog.metricDefinitions(for: r).filter { r.metrics[$0.key] != nil }) { def in
                        VStack(alignment: .leading, spacing: 1) {
                            Text(def.unit.isEmpty ? def.name : "\(def.name) (\(def.unit))")
                                .appFont(13.5, weight: .semibold)
                            Text(def.definition)
                                .appFont(13)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if !r.parameters.isEmpty {
                        Divider()
                        Text("Parameters").appFont(13.5, weight: .semibold)
                        ForEach(r.parameters.keys.sorted(), id: \.self) { key in
                            KeyValueRow(key: locKey(key), value: loc(r.parameters[key] ?? ""))
                        }
                    }
                }
                .padding(.top, 6)
            }
            .appFont(15)
        }
    }

    private var unsavedBar: some View {
        HStack(spacing: 10) {
            Text("Unsaved changes")
                .appFont(15, weight: .semibold)
            Spacer()
            Button("Revert") { draft = saved }
                .buttonStyle(.bordered)
            Button("Save") { saveDraft() }
                .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(loc(title)).appFont(13).foregroundStyle(.secondary)
            content()
        }
    }

    // MARK: Bindings & actions

    private func bind<T>(_ keyPath: WritableKeyPath<ExperimentResult, T>, _ fallback: T) -> Binding<T> {
        Binding(
            get: { draft?[keyPath: keyPath] ?? fallback },
            set: { draft?[keyPath: keyPath] = $0 }
        )
    }

    /// Phase changes can change the computation (e.g. water-maze probe vs acquisition).
    private var phaseBinding: Binding<String> {
        Binding(
            get: { draft?.phase ?? "" },
            set: { newValue in
                guard var d = draft else { return }
                d.phase = newValue
                if let config = d.zoneConfig, !samples.isEmpty {
                    d.apply(AssayEngine.compute(assay: d.assay, phase: newValue, samples: samples, config: config))
                } else if let input = d.manualInput, d.assay.supportsManualEntry, d.source != .video {
                    d.apply(ManualAssays.compute(assay: d.assay, phase: newValue, input: input))
                }
                draft = d
            }
        )
    }

    private var configBinding: Binding<ZoneConfig> {
        Binding(
            get: { draft?.zoneConfig ?? ZoneConfig() },
            set: { updateConfig($0) }
        )
    }

    private func updateConfig(_ config: ZoneConfig) {
        guard var d = draft else { return }
        d.zoneConfig = config
        if !samples.isEmpty {
            d.apply(AssayEngine.compute(assay: d.assay, phase: d.phase, samples: samples, config: config))
        }
        draft = d
    }

    private func markers(_ assay: AssayKind, _ c: ZoneConfig) -> [ArenaMarker] {
        switch assay {
        case .novelObject:
            var m: [ArenaMarker] = []
            if let a = c.objectA { m.append(ArenaMarker(id: "A", label: "A", point: a)) }
            if let b = c.objectB { m.append(ArenaMarker(id: "B", label: "B", point: b)) }
            return m
        case .morrisWaterMaze:
            return c.target.map { [ArenaMarker(id: "T", label: "P", point: $0)] } ?? []
        case .barnesMaze:
            return c.target.map { [ArenaMarker(id: "T", label: "T", point: $0)] } ?? []
        default:
            return []
        }
    }

    private func moveMarker(_ id: String, _ point: ArenaPoint) {
        guard var c = draft?.zoneConfig else { return }
        switch id {
        case "A": c.objectA = point
        case "B": c.objectB = point
        default: c.target = point
        }
        updateConfig(c)
    }

    private func displayValue(_ value: Double, field: ManualField) -> String {
        switch field.kind {
        case .choice(let options):
            let i = Int(value)
            return options.indices.contains(i) ? loc(options[i]) : String(i)
        case .toggle:
            return value >= 0.5 ? loc("Yes") : loc("No")
        default:
            let number = abs(value - value.rounded()) < 1e-9 ? String(format: "%.0f", value) : String(format: "%g", value)
            return field.unit.isEmpty ? number : "\(number) \(field.unit)"
        }
    }

    private func load() async {
        samples = []
        samplesVersion += 1
        hasTrackingFolder = false
        loadState = .idle
        shareError = nil
        guard let r = library.result(id: resultID) else {
            draft = nil
            return
        }
        saved = r
        draft = r
        guard r.source == .video, let name = r.runFolderName else {
            loadState = .unavailable(loc("No tracking data linked to this result."))
            return
        }
        loadState = .loading
        let task = Task.detached(priority: .userInitiated) { () -> (samples: [AnalysisSample]?, hasFolder: Bool) in
            (try? ResultsStore.loadTrackingSamples(runFolderName: name), ResultsStore.hasTrackingData(runFolderName: name))
        }
        let loadedData = await task.value
        hasTrackingFolder = loadedData.hasFolder
        if let loaded = loadedData.samples, !loaded.isEmpty {
            samples = loaded
            samplesVersion += 1
            loadState = .loaded
        } else {
            loadState = .unavailable(loc("The tracking file for this result was not found (run folder moved or deleted). The saved metrics are shown; zones can't be re-analyzed."))
        }
    }

    private func refreshFromLibrary() {
        guard let stored = library.result(id: resultID) else { return }
        if stored == saved { return }
        if draft == saved { draft = stored }
        saved = stored
    }

    private func saveDraft() {
        guard let d = draft else { return }
        if library.save(d) {
            let stored = library.result(id: d.id) ?? d
            saved = stored
            draft = stored
        }
    }

    private func shareJSON() {
        guard let r = draft else { return }
        do {
            let url = try ResultsStore.exportBundle([r], name: "RodentFlow_\(r.assay.shortName)_\(r.displaySubject)")
            shareItem = ShareItem(urls: [url])
        } catch {
            shareError = error.localizedDescription
        }
    }

    private func shareRunFolder(_ name: String) {
        do {
            shareItem = ShareItem(urls: [try ResultsStore.runFolder(named: name)])
        } catch {
            shareError = error.localizedDescription
        }
    }
}

/// Arena plot or freezing timeline. Equatable, so that typing in the Details fields (which
/// changes the draft but neither the tracking nor the zones) does not recompute and redraw
/// thousands of tracking points on every keystroke.
private struct TrackingVisuals: View, Equatable {
    let assay: AssayKind
    let config: ZoneConfig
    let samples: [AnalysisSample]
    let samplesVersion: Int
    let mode: ArenaPlotMode
    let markers: [ArenaMarker]
    let onMoveMarker: (String, ArenaPoint) -> Void

    static func == (a: TrackingVisuals, b: TrackingVisuals) -> Bool {
        a.assay == b.assay && a.samplesVersion == b.samplesVersion && a.mode == b.mode
            && a.config == b.config && a.markers == b.markers
    }

    var body: some View {
        if assay == .fearConditioning {
            FreezingTimelineView(trace: AssayEngine.freezingTrace(samples, config), config: config)
        } else {
            ArenaPlotView(
                samples: windowed(samples, config),
                config: config,
                overlays: AssayEngine.overlays(assay: assay, config: config),
                mode: mode,
                markers: markers,
                onMoveMarker: onMoveMarker
            )
        }
    }

    /// Trajectory restricted to the analysis window (so the plot matches the numbers).
    private func windowed(_ s: [AnalysisSample], _ c: ZoneConfig) -> [AnalysisSample] {
        guard let first = s.first?.t else { return s }
        let start = first + c.analysisStartSeconds
        var duration = c.analysisDurationSeconds
        if duration <= 0, assay == .morrisWaterMaze || assay == .barnesMaze { duration = c.maxTrialSeconds }
        let end = duration > 0 ? start + duration : Double.infinity
        return s.filter { $0.t >= start && $0.t < end }
    }
}
