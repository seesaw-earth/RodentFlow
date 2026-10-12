import SwiftUI
import AVKit

struct PreviewView: View {
    @ObservedObject var model: AppState
    @State private var path = NavigationPath()
    @State private var confirmingClose = false
    @Environment(\.appNavigator) private var navigator

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                if let url = model.videoURL,
                   let metadata = model.videoMetadata,
                   let result = model.previewResult {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                        if model.isPreviewStale { staleCard }
                        TrackingPreviewPlayer(url: url, result: result, videoAspectRatio: metadata.aspectRatio)
                        previewMetrics(result)
                        qualityCard
                        fullAnalysisCard
                        if let notice = model.fullAnalysisNotice { noticeCard(notice) }
                        if let error = model.errorMessage { errorCard(error) }
                    }
                    .frame(maxWidth: 620, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .top, spacing: 0) {
                WorkflowStepBar(
                    current: .preview,
                    isAvailable: { model.isStepAvailable($0) },
                    isDone: { model.isStepDone($0) },
                    onSelect: { step in
                        if step == .result, let id = model.latestResultID {
                            path.append(id)
                        } else {
                            model.go(to: step)
                        }
                    }
                )
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { navigationBar }
            .navigationTitle("Tracking preview")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { id in
                ResultDetailView(library: model.library, resultID: id, onNextAnimal: model.isFullAnalysisRunning ? nil : {
                    model.startNextAnimal()
                })
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        confirmingClose = true
                    } label: {
                        Label("Close video", systemImage: "xmark")
                    }
                    .disabled(model.isFullAnalysisRunning || model.isBusy)
                }
                ToolbarItem(placement: .topBarTrailing) { TextSizeMenu() }
            }
            .confirmationDialog("Close this video?", isPresented: $confirmingClose, titleVisibility: .visible) {
                Button("Close Video", role: .destructive) { model.reset() }
            } message: {
                Text("Saved results stay in Results. The preview and the imported copy of the video are removed.")
            }
            .onAppear(perform: consumePendingResult)
            .onChange(of: model.pendingResultPush) { _, _ in consumePendingResult() }
        }
    }

    private func consumePendingResult() {
        guard let id = model.pendingResultPush else { return }
        model.pendingResultPush = nil
        path.append(id)
    }

    /// Back to the setup · forward to the full analysis, then to the saved result.
    private var navigationBar: some View {
        let next: FlowAction?
        if model.isFullAnalysisRunning {
            next = FlowAction(title: locf("Analyzing… %.0f%%", model.fullAnalysisProgress.fraction * 100), systemImage: "hourglass", enabled: false) {}
        } else if model.isPreviewStale {
            next = FlowAction(title: "Update Preview", systemImage: "scope", enabled: !model.isBusy) {
                Task { await model.generatePreview() }
            }
        } else if model.fullAnalysisResult != nil, let id = model.latestResultID, model.latestResultExists {
            next = FlowAction(title: "Result", systemImage: "chart.xyaxis.line") { path.append(id) }
        } else if model.fullAnalysisResult == nil && !(model.hasRecoverableRunForCurrentVideo && model.recoverableRun != nil) {
            next = FlowAction(title: "Analyze Full Video", systemImage: "waveform.path.ecg.rectangle", enabled: !model.isBusy) {
                model.startFullVideoAnalysis()
            }
        } else {
            next = nil
        }
        return FlowNavigationBar(
            back: FlowAction(title: "Setup", enabled: model.isStepAvailable(.setup) && !model.isBusy) { model.go(to: .setup) },
            next: next
        )
    }

    private var staleCard: some View {
        Label("The setup changed after this preview was made. Update the preview (button below) before analyzing the full video, or go back to Setup.", systemImage: "exclamationmark.arrow.triangle.2.circlepath")
            .appFont(14.5)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Does the dot stay on the mouse?")
                .appFont(21, weight: .semibold)
            Text("The preview is only 10 seconds. Preview and full analysis use the same classic-centroid tracker at 10 Hz.")
                .appFont(15)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var qualityCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Quality check").appFont(17, weight: .semibold)
                Spacer()
                Text("CLASSIC CENTROID").appFont(12, weight: .bold).foregroundStyle(.secondary)
            }
            checkRow("Dot follows the selected mouse foreground component consistently")
            checkRow("Trail does not jump to shadows, reflections, or the arena wall")
            checkRow(calibrationCheckText)
            if model.arenaShape.isMaze {
                checkRow("Zone label changes correctly as the mouse enters each arm")
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var calibrationCheckText: String {
        switch model.arenaShape {
        case .rectangle: return loc("Rectangle matches the inner floor boundary")
        case .circle: return loc("Circle matches the inner floor boundary")
        case .tMaze: return loc("J/S/L/R centerline points match the T-maze")
        case .yMaze: return loc("J/A/B/C centerline points match the Y-maze")
        case .plusMaze: return loc("C/N/E/S/W centerline points match the plus maze")
        }
    }

    private var fullAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Full video data").appFont(17, weight: .semibold)
                    if let metadata = model.videoMetadata {
                        Text(locf("Whole recording · 10 Hz analysis · source %.2f fps", metadata.nominalFPS))
                            .appFont(13)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                if let result = model.fullAnalysisResult {
                    Text(locf("%ld samples", result.points.count))
                        .appFont(13, weight: .semibold, design: .monospaced)
                        .foregroundStyle(.secondary)
                }
            }

            if model.isFullAnalysisRunning {
                analysisProgressView(model.fullAnalysisProgress)
                Button { model.pauseFullVideoAnalysis() } label: {
                    Label("Pause & Save", systemImage: "pause.fill")
                        .appFont(16, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 40)
                }
                .buttonStyle(.bordered)

                Text("Progress is checkpointed about every 30 seconds. Leaving the app pauses and saves the current analysis.")
                    .appFont(13)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if let result = model.fullAnalysisResult {
                fullMetrics(result)
                if model.arenaShape.isMaze { mazeSummary(result) }
                assayResultLink
                savedFolderCard
                fullExportActions
            } else if model.hasRecoverableRunForCurrentVideo, let recovery = model.recoverableRun {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Saved checkpoint available", systemImage: "externaldrive.fill.badge.checkmark")
                        .appFont(15, weight: .semibold)
                        .foregroundStyle(.orange)
                    Text(locf("%ld samples saved · through %@", recovery.completedSamples, recovery.lastVideoTimeSeconds.minuteSecondString))
                        .appFont(13, design: .monospaced)
                        .foregroundStyle(.secondary)
                }

                Button { model.resumeSavedFullAnalysis() } label: {
                    Label("Resume Analysis", systemImage: "play.fill")
                        .appFont(16.5, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)

                Button { model.restartFullVideoAnalysisFromBeginning() } label: {
                    Label("Start Over", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button { model.startFullVideoAnalysis() } label: {
                    Label("Analyze Full Video", systemImage: "waveform.path.ecg.rectangle")
                        .appFont(16.5, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.isPreviewStale || model.isBusy)

                Text("Full analysis reads the complete recording from start to finish at 10 Hz. A recoverable checkpoint is saved about every 30 seconds.")
                    .appFont(13)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private func analysisProgressView(_ snapshot: AnalysisProgressSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.16))
                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .mint], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(3, geo.size.width * snapshot.fraction))
                }
            }
            .frame(height: 9)

            HStack {
                Text(String(format: "%.0f%%", snapshot.fraction * 100))
                    .appFont(13.5, weight: .semibold, design: .monospaced)
                Spacer()
                Text(remainingText(snapshot.remainingSeconds))
                    .appFont(13.5, weight: .semibold, design: .monospaced)
            }
            HStack {
                Text(frameProgressText(snapshot))
                Spacer()
                Text(locf("elapsed %.1fs", snapshot.elapsedSeconds))
            }
            .appFont(12, design: .monospaced)
            .foregroundStyle(.secondary)
        }
    }

    private func frameProgressText(_ snapshot: AnalysisProgressSnapshot) -> String {
        if let total = snapshot.estimatedTotalSamples { return locf("%ld / ~%ld samples", snapshot.processedSamples, total) }
        return locf("%ld samples", snapshot.processedSamples)
    }

    private func remainingText(_ seconds: Double?) -> String {
        guard let seconds else { return loc("Estimating remaining time…") }
        if seconds < 60 { return locf("~%lds left", Int(seconds.rounded())) }
        return locf("~%.1f min left", seconds / 60)
    }

    @ViewBuilder
    private func mazeSummary(_ result: FullAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Divider()
            Text("Maze readout").appFont(15, weight: .semibold)
            if model.arenaShape == .tMaze {
                keyValue("First choice", result.tMazeFirstChoice?.capitalized ?? "—")
                keyValue("Arm entries", "\(result.mazeEvents.count)")
            } else if model.arenaShape == .yMaze {
                keyValue("Arm entries", "\(result.mazeEvents.count)")
                keyValue("Alternation", result.yMazeAlternationPercent.map { String(format: "%.1f%%", $0) } ?? "—")
            }
            keyValue("Sequence", result.armEntrySequence.isEmpty ? "—" : result.armEntrySequence.joined(separator: " → "))
        }
    }

    @ViewBuilder
    private var assayResultLink: some View {
        if let id = model.latestResultID, let r = model.library.result(id: id) {
            VStack(alignment: .leading, spacing: 9) {
                Divider()
                Label(locf("%@ result", r.assay.displayName), systemImage: r.assay.systemImage)
                    .appFont(15, weight: .semibold)
                MetricGrid(result: r, limit: 4)
                FlagList(flags: r.qcFlags)
                Button {
                    path.append(id)
                } label: {
                    Label("Open Result", systemImage: "chart.xyaxis.line")
                        .appFont(16.5, weight: .semibold)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 42)
                }
                .buttonStyle(.borderedProminent)
                HStack(spacing: 8) {
                    Button {
                        navigator.openGroups(r.assay)
                    } label: {
                        Label("Compare in Groups", systemImage: "chart.bar.xaxis")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                    Button {
                        model.startNextAnimal()
                    } label: {
                        Label("Next Animal", systemImage: "forward.end")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                }
                Text("Saved to Results. Adjust zones on the result screen; compare groups in the Groups tab.")
                    .appFont(12.5)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var savedFolderCard: some View {
        if let folder = model.savedRunFolderURL {
            VStack(alignment: .leading, spacing: 6) {
                Label("Automatically saved", systemImage: "folder.fill")
                    .appFont(14, weight: .semibold)
                    .foregroundStyle(.green)
                Text(locf("Files › On My iPhone › RodentFlow › Experiments › %@", folder.lastPathComponent))
                    .appFont(12)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                ShareLink(item: folder) {
                    Label("Share Run Folder", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(10)
            .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var fullExportActions: some View {
        VStack(spacing: 8) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { fullExportButtons }
                VStack(spacing: 8) { fullExportButtons }
            }
            if let events = model.mazeEventsJSONURL {
                ShareLink(item: events) {
                    Label("Maze Events JSON", systemImage: "arrow.triangle.branch")
                        .frame(maxWidth: .infinity).frame(minHeight: 38)
                }
                .buttonStyle(.bordered)
            }
            if let previewJSON = model.previewJSONURL {
                ShareLink(item: previewJSON) {
                    Label("10s Preview JSON", systemImage: "play.rectangle")
                        .frame(maxWidth: .infinity).frame(minHeight: 38)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    private var fullExportButtons: some View {
        if let json = model.fullTrackingJSONURL {
            ShareLink(item: json) {
                Label("Full Tracking JSON", systemImage: "curlybraces").frame(maxWidth: .infinity).frame(minHeight: 40)
            }
            .buttonStyle(.borderedProminent)
        }
        if let summary = model.summaryJSONURL {
            ShareLink(item: summary) {
                Label("Summary JSON", systemImage: "doc.text").frame(maxWidth: .infinity).frame(minHeight: 40)
            }
            .buttonStyle(.bordered)
        }
        if let metadata = model.metadataJSONURL {
            ShareLink(item: metadata) {
                Label("Metadata JSON", systemImage: "info.circle").frame(maxWidth: .infinity).frame(minHeight: 40)
            }
            .buttonStyle(.bordered)
        }
    }

    private func checkRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "checkmark.circle").foregroundStyle(.tint).padding(.top, 1)
            Text(loc(text)).appFont(15).fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func previewMetrics(_ result: TrackingPreviewResult) -> some View {
        let cards: [(String, String, String)] = [
            ("Tracked", String(format: "%.1f%%", result.trackedFraction * 100), "scope"),
            ("Confidence", String(format: "%.0f%%", result.meanConfidence * 100), "waveform.path.ecg"),
            ("10s distance", String(format: "%.1f cm", result.distanceCentimeters), "point.topleft.down.curvedto.point.bottomright.up"),
            ("Analysis Hz", String(format: "%.1f", result.processingFPS), "timer")
        ]
        metricGrid(cards)
    }

    @ViewBuilder
    private func fullMetrics(_ result: FullAnalysisResult) -> some View {
        let cards: [(String, String, String)] = [
            ("Distance", String(format: "%.1f m", result.distanceCentimeters / 100), "point.topleft.down.curvedto.point.bottomright.up"),
            ("Mean speed", String(format: "%.2f cm/s", result.meanSpeedCentimetersPerSecond), "speedometer"),
            ("Tracked", String(format: "%.1f%%", result.trackedFraction * 100), "scope"),
            ("Analysis Hz", String(format: "%.1f", result.processingFPS), "timer")
        ]
        metricGrid(cards)
    }

    private func metricGrid(_ cards: [(String, String, String)]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
            ForEach(cards, id: \.0) { card in
                VStack(alignment: .leading, spacing: 6) {
                    Label(loc(card.0), systemImage: card.2).appFont(13).foregroundStyle(.secondary)
                    Text(card.1).appFont(18.5, weight: .bold, design: .monospaced).minimumScaleFactor(0.72).lineLimit(1)
                }
                .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
                .padding(12)
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 13))
            }
        }
    }

    private func keyValue(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(loc(key)).foregroundStyle(.secondary)
            Spacer()
            Text(value).multilineTextAlignment(.trailing)
        }
        .appFont(14)
    }

    private func noticeCard(_ notice: String) -> some View {
        Label {
            Text(loc(notice)).fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "checkmark.circle.fill")
        }
        .appFont(15)
        .foregroundStyle(.green)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 13))
    }

    private func errorCard(_ error: String) -> some View {
        Label { Text(error).fixedSize(horizontal: false, vertical: true) } icon: { Image(systemName: "exclamationmark.triangle.fill") }
            .appFont(14.5).foregroundStyle(.red).padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct TrackingPreviewPlayer: View {
    let url: URL
    let result: TrackingPreviewResult
    let videoAspectRatio: CGFloat
    /// Created after the screen has appeared (see `preparePlayer`), not while it is being built.
    @State private var controller: PreviewPlayerController?

    init(url: URL, result: TrackingPreviewResult, videoAspectRatio: CGFloat) {
        self.url = url
        self.result = result
        self.videoAspectRatio = videoAspectRatio
    }

    var body: some View {
        ZStack {
            if let controller {
                // The player itself does not depend on the playback time, so it is not redrawn
                // 15 times a second; only the overlay below observes the time.
                VideoPlayer(player: controller.player)
                    .aspectRatio(videoAspectRatio, contentMode: .fit)
                PreviewTimeOverlay(
                    controller: controller,
                    points: result.points,
                    durationSeconds: result.durationSeconds,
                    videoAspectRatio: videoAspectRatio
                )
            } else {
                Color.black
                    .aspectRatio(videoAspectRatio, contentMode: .fit)
                    .overlay { ProgressView().tint(.white) }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .task(id: result.startSeconds) { await preparePlayer() }
        .onDisappear { controller?.pause() }
    }

    private func preparePlayer() async {
        if let controller, controller.startSeconds == result.startSeconds {
            controller.play()
            return
        }
        // Let the screen transition finish first: setting up AVPlayer and its view is the most
        // expensive part of showing this screen.
        try? await Task.sleep(nanoseconds: 150_000_000)
        guard !Task.isCancelled else { return }
        let made = await PreviewPlayerController.make(
            url: url,
            startSeconds: result.startSeconds,
            durationSeconds: max(0.5, result.durationSeconds)
        )
        guard !Task.isCancelled else { return }
        controller = made
        made.play()
    }
}

/// Trail, current dot and time label; the only part that changes during playback.
private struct PreviewTimeOverlay: View {
    @ObservedObject var controller: PreviewPlayerController
    let points: [TrackingPoint]
    let durationSeconds: Double
    let videoAspectRatio: CGFloat

    var body: some View {
        TrackingOverlayView(
            points: points,
            relativeTime: controller.relativeTime,
            videoAspectRatio: videoAspectRatio
        )
        .overlay(alignment: .bottomTrailing) {
            Text(String(format: "%.1f / %.1f s", controller.relativeTime, durationSeconds))
                .appFont(12.5, design: .monospaced)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.black.opacity(0.68), in: Capsule())
                .foregroundStyle(.white)
                .padding(9)
        }
    }
}
