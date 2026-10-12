import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum HomeRoute: Hashable {
    case allResults
}

struct HomeView: View {
    @ObservedObject var model: AppState
    @ObservedObject var library: ResultsLibrary
    @State private var photoItem: PhotosPickerItem?
    @State private var showingFileImporter = false
    @State private var showingAssayPicker = false
    @State private var showingManualEntry = false
    @State private var showingImport = false
    @State private var path = NavigationPath()
    @State private var notice: String?
    @State private var confirmingDiscard = false
    @Environment(\.appNavigator) private var navigator

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    if let homeNotice = model.homeNotice {
                        MessageBanner(text: homeNotice, style: .info)
                    }
                    if model.hasActiveVideo { currentVideoCard }
                    if let recovery = model.recoverableRun, !model.isFullAnalysisRunning { recoveryCard(recovery) }
                    newExperimentCard
                    if library.unlinkedRunCount > 0 { earlierRunsCard }

                    if model.isBusy {
                        statusCard
                    }
                    if let notice {
                        MessageBanner(text: notice, style: .notice)
                    }
                    if let error = model.errorMessage {
                        MessageBanner(text: error)
                    }
                    if let error = library.lastError {
                        MessageBanner(text: error)
                    }
                    resultsCard
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                if model.hasActiveVideo {
                    WorkflowStepBar(
                        current: .start,
                        isAvailable: { model.isStepAvailable($0) },
                        isDone: { model.isStepDone($0) },
                        onSelect: { model.go(to: $0) }
                    )
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if model.hasActiveVideo {
                    FlowNavigationBar(
                        next: FlowAction(title: locf("Continue: %@", model.continueStep.destinationTitle), systemImage: nil) {
                            model.go(to: model.continueStep)
                        }
                    )
                }
            }
            .confirmationDialog("Close this video?", isPresented: $confirmingDiscard, titleVisibility: .visible) {
                Button("Close Video", role: .destructive) { model.reset() }
            } message: {
                Text("The setup and preview of this video are discarded. Results that were already saved stay in Results.")
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                ResultDetailView(library: library, resultID: id)
            }
            .navigationDestination(for: HomeRoute.self) { _ in
                ResultsListView(library: library)
            }
            .onChange(of: photoItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    do {
                        if let movie = try await newValue.loadTransferable(type: ImportedMovie.self) {
                            await model.importVideo(url: movie.url, source: .photos)
                        }
                    } catch {
                        model.errorMessage = error.localizedDescription
                    }
                    photoItem = nil
                }
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.movie, .mpeg4Movie, .quickTimeMovie],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task { await model.importVideo(url: url, source: .files) }
                    }
                case .failure(let error):
                    model.errorMessage = error.localizedDescription
                }
            }
            .sheet(isPresented: $showingAssayPicker) {
                AssayPickerSheet(selection: Binding(get: { model.assay }, set: { model.selectAssay($0) }))
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(library: library, assay: model.assay) { saved in
                    path.append(saved.id)
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportSheet(library: library, initialAssay: model.assay) { count in
                    notice = locf("Imported %ld record(s). Open the Groups tab to compare them.", count)
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: "scope")
                    .appFont(26, weight: .semibold)
                    .foregroundStyle(.tint)
                    .frame(width: 46, height: 46)
                    .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                Spacer()
                TextSizeMenu()
                    .appFont(19, weight: .medium)
                    .frame(width: 44, height: 44)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: Circle())
            }

            Text("RodentFlow")
                .appFont(30, weight: .bold, design: .rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text("Track, score and compare rodent behavior — on device")
                .appFont(16)
                .foregroundStyle(.secondary)
        }
    }

    private func recoveryCard(_ recovery: FullAnalysisRecoveryRecord) -> some View {
        let duration = max(0.001, recovery.videoMetadata.durationSeconds)
        let fraction = min(1, max(0, recovery.lastVideoTimeSeconds / duration))

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Unfinished analysis found", systemImage: "arrow.clockwise.circle.fill")
                    .appFont(17, weight: .semibold)
                Spacer()
                Text(String(format: "%.0f%%", fraction * 100))
                    .appFont(13.5, weight: .semibold, design: .monospaced)
            }

            ProgressView(value: fraction)

            VStack(alignment: .leading, spacing: 3) {
                Text(recovery.mouseID.isEmpty ? recovery.originalVideoFilename : recovery.mouseID)
                    .appFont(15, weight: .semibold)
                    .lineLimit(1)
                Text(locf("%@ · %ld saved samples · %@ / %@", recovery.assayContext?.assay.displayName ?? recovery.arenaShape.displayName, recovery.completedSamples, recovery.lastVideoTimeSeconds.minuteSecondString, duration.minuteSecondString))
                    .appFont(13, design: .monospaced)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                Button {
                    Task { await model.resumeInterruptedAnalysis(recovery) }
                } label: {
                    Label("Resume Analysis", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(role: .destructive) {
                    model.discardRecoverableRun()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var currentVideoCard: some View {
        SectionCard("Open video", icon: "film", trailing: model.workflowStatusText) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.mouseID.isEmpty ? (model.originalVideoFilename.isEmpty ? loc("Video") : model.originalVideoFilename) : model.mouseID)
                    .appFont(16.5, weight: .semibold)
                    .lineLimit(1)
                Text([model.assay.displayName, model.group, model.videoMetadata.map { $0.durationSeconds.minuteSecondString } ?? ""]
                        .filter { !$0.isEmpty }.joined(separator: " · "))
                    .appFont(14)
                    .foregroundStyle(.secondary)
            }
            if model.isFullAnalysisRunning {
                ProgressView(value: model.fullAnalysisProgress.fraction)
                Text(locf("Full analysis running · %.0f%%", model.fullAnalysisProgress.fraction * 100))
                    .appFont(13, design: .monospaced)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                if model.latestResultExists, let id = model.latestResultID {
                    Button {
                        path.append(id)
                    } label: {
                        Label("Open Result", systemImage: "chart.xyaxis.line")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 40)
                    }
                    .buttonStyle(.bordered)
                }
                Button(role: .destructive) {
                    confirmingDiscard = true
                } label: {
                    Label("Close Video", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 40)
                }
                .buttonStyle(.bordered)
                .disabled(model.isFullAnalysisRunning)
            }
            Text("Use the bar at the bottom to continue where you left off, or the steps at the top to jump.")
                .appFont(13)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var newExperimentCard: some View {
        SectionCard("New experiment", icon: "plus.circle") {
            Button {
                showingAssayPicker = true
            } label: {
                HStack(spacing: 8) {
                    AssayRow(assay: model.assay)
                    Image(systemName: "chevron.up.chevron.down")
                        .appFont(14.5, weight: .semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            if model.assay.supportsVideo && model.isFullAnalysisRunning {
                Text("A full analysis is running. New videos can be chosen when it finishes or is paused.")
                    .appFont(14)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if model.assay.supportsVideo {
                PhotosPicker(selection: $photoItem, matching: .videos) {
                    Label("Analyze Video from Photos", systemImage: "photo.on.rectangle")
                        .appFont(16.5, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showingFileImporter = true
                } label: {
                    Label("Choose Video from Files", systemImage: "folder")
                        .appFont(16.5, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { secondaryActions }
                VStack(spacing: 8) { secondaryActions }
            }

            Text(model.assay.supportsVideo
                 ? (model.hasActiveVideo
                    ? loc("Choosing another video replaces the open one (saved results are kept).")
                    : loc("Track a video, or enter values scored by hand or by another tracker."))
                 : loc("Enter values by hand or import a table (CSV / JSON)."))
                .appFont(13)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var secondaryActions: some View {
        if model.assay.supportsManualEntry {
            if model.assay.supportsVideo {
                manualEntryButton.buttonStyle(.bordered)
            } else {
                manualEntryButton.buttonStyle(.borderedProminent)
            }
        }
        Button {
            showingImport = true
        } label: {
            Label("Import Table", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 38)
        }
        .buttonStyle(.bordered)
    }

    private var manualEntryButton: some View {
        Button {
            showingManualEntry = true
        } label: {
            Label(model.assay == .twoArmedBandit ? "Enter Trials" : "Enter Values", systemImage: "keyboard")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 38)
        }
    }

    private var earlierRunsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(locf("%ld earlier tracking run(s) without results", library.unlinkedRunCount), systemImage: "clock.arrow.circlepath")
                .appFont(15.5, weight: .semibold)
            Text("Runs saved by RodentFlow 1.0 can be re-analyzed into Open Field / Y-maze / T-maze results with the new metrics (center zone, immobility, time bins).")
                .appFont(13.5)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                let count = library.reanalyzeEarlierRuns()
                notice = locf("Created %ld result(s) from earlier runs.", count)
            } label: {
                Label("Create Results", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.07), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var resultsCard: some View {
        SectionCard("Results", icon: "list.bullet.rectangle", trailing: library.results.isEmpty ? nil : "\(library.results.count)") {
            if library.results.isEmpty {
                Text("Per-animal results from tracked videos, manual entry and imports are saved here and in Files › RodentFlow › Results.")
                    .appFont(14)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 0) {
                    ForEach(library.results.prefix(8)) { result in
                        NavigationLink(value: result.id) {
                            ResultRow(result: result)
                                .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                HStack(spacing: 8) {
                    NavigationLink(value: HomeRoute.allResults) {
                        Label("All results", systemImage: "list.bullet")
                            .appFont(15.5, weight: .medium)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                    Button {
                        navigator.openGroups(library.results.first?.assay)
                    } label: {
                        Label("Compare groups", systemImage: "chart.bar.xaxis")
                            .appFont(15.5, weight: .medium)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 12) {
            ProgressView()
            VStack(alignment: .leading, spacing: 2) {
                Text("Reading video")
                    .font(.subheadline.weight(.semibold))
                Text("Loading metadata and preview frame…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - All results

struct ResultsListView: View {
    @ObservedObject var library: ResultsLibrary
    @State private var filter: AssayKind?
    @State private var search = ""

    private var filtered: [ExperimentResult] {
        library.results.filter { r in
            (filter == nil || r.assay == filter) &&
            (search.isEmpty || [r.subjectID, r.group, r.phase, AssayKind.phaseTitle(r.phase), r.assay.displayName, r.assay.englishName, r.notes]
                .joined(separator: " ").localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { result in
                NavigationLink(value: result.id) {
                    ResultRow(result: result)
                }
            }
            .onDelete { offsets in
                let items = offsets.map { filtered[$0] }
                for item in items { library.delete(item) }
            }
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView("No results", systemImage: "tray", description: Text("Nothing matches the current filter."))
            }
        }
        .searchable(text: $search, prompt: "Subject, group, phase")
        .navigationTitle(filter?.displayShortName ?? loc("All results"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Assay", selection: $filter) {
                        Text("All assays").tag(AssayKind?.none)
                        ForEach(library.assaysWithData) { assay in
                            Text(assay.displayName).tag(AssayKind?.some(assay))
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }
}
