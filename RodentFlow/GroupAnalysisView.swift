import SwiftUI
import UIKit

/// Tab 2: compare control / experimental groups (or more) for any assay, with figures and statistics.
struct GroupAnalysisView: View {
    @ObservedObject var library: ResultsLibrary
    /// Assay requested by another screen ("Compare in Groups"); consumed when the tab shows it.
    @Binding var requestedAssay: AssayKind?
    @StateObject private var vm = GroupAnalysisViewModel()
    @State private var shareItem: ShareItem?
    @State private var showingImport = false
    @State private var message: String?
    @Environment(\.appNavigator) private var navigator

    init(library: ResultsLibrary, requestedAssay: Binding<AssayKind?> = .constant(nil)) {
        _library = ObservedObject(wrappedValue: library)
        _requestedAssay = requestedAssay
    }

    private var sections: [JumpSection] {
        var list = [
            JumpSection(id: "assay", title: "Assay", systemImage: "square.stack.3d.up"),
            JumpSection(id: "analysis", title: "Analysis", systemImage: "slider.horizontal.3"),
            JumpSection(id: "groups", title: "Groups", systemImage: "person.3")
        ]
        if let result = vm.result, !result.isEmpty {
            list.append(JumpSection(id: "figure", title: "Figure", systemImage: "chart.bar.xaxis"))
            list.append(JumpSection(id: "stats", title: "Statistics", systemImage: "function"))
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if library.results.isEmpty {
                            emptyState
                        } else {
                            assayCard.id("assay")
                            if vm.assay != nil {
                                designCard.id("analysis")
                                groupsCard.id("groups")
                                if let result = vm.result {
                                    if result.isEmpty {
                                        MessageBanner(text: "No values for this selection. Check the phase filter, included groups and measure.", style: .info)
                                    } else {
                                        figureCard(result).id("figure")
                                        statsCard(result).id("stats")
                                    }
                                }
                            }
                        }
                        if let message { MessageBanner(text: message, style: .notice) }
                    }
                    .frame(maxWidth: 620, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .safeAreaInset(edge: .top, spacing: 0) {
                    if !library.results.isEmpty && vm.assay != nil {
                        SectionJumpBar(sections: sections) { id in
                            withAnimation { proxy.scrollTo(id, anchor: .top) }
                        }
                    }
                }
            }
            .navigationTitle("Group analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingImport = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) { TextSizeMenu() }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportFigure()
                        } label: {
                            Label("Figure (PNG)", systemImage: "photo")
                        }
                        .disabled(vm.result?.isEmpty ?? true)
                        Button {
                            exportAnalysis()
                        } label: {
                            Label("Statistics (JSON)", systemImage: "function")
                        }
                        .disabled(vm.result?.isEmpty ?? true)
                        Button {
                            exportData()
                        } label: {
                            Label(locf("All %@ records (JSON)", vm.assay?.displayShortName ?? ""), systemImage: "tray.and.arrow.up")
                        }
                        .disabled(vm.assay == nil)
                        Button {
                            UIPasteboard.general.string = vm.summaryText()
                            message = loc("Summary copied to the clipboard.")
                        } label: {
                            Label("Copy text summary", systemImage: "doc.on.doc")
                        }
                        .disabled(vm.result?.isEmpty ?? true)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportSheet(library: library, initialAssay: vm.assay ?? .openField) { count in
                    message = locf("Imported %ld record(s).", count)
                }
            }
            .sheet(item: $shareItem) { item in
                ActivityView(items: item.urls)
            }
            .onAppear {
                vm.update(records: library.results)
                consumeRequestedAssay()
            }
            .onChange(of: library.results) { _, newValue in vm.update(records: newValue) }
            .onChange(of: requestedAssay) { _, _ in consumeRequestedAssay() }
            .onChange(of: vm.request) { _, _ in vm.run() }
            .onChange(of: vm.request.phaseFilter) { _, _ in vm.didChangePhase() }
        }
    }

    private func consumeRequestedAssay() {
        guard let assay = requestedAssay else { return }
        requestedAssay = nil
        vm.update(records: library.results)
        if vm.availableAssays.contains(assay) { vm.select(assay) }
    }

    // MARK: Cards

    private var emptyState: some View {
        SectionCard("Compare groups", icon: "chart.bar.xaxis") {
            Text("Analyze a video, enter values or import a table in the Experiment tab — or import a CSV / JSON here. Every record carries a subject ID and a group (e.g. WT vs KO, Vehicle vs Drug); this tab averages trials within each animal, compares groups with the appropriate test and draws the figure.")
                .appFont(14.5)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                navigator.openExperiment()
            } label: {
                Label("Go to Experiment", systemImage: "scope")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 40)
            }
            .buttonStyle(.borderedProminent)
            Button {
                showingImport = true
            } label: {
                Label("Import Data", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 40)
            }
            .buttonStyle(.bordered)
        }
    }

    private var assayCard: some View {
        SectionCard("Assay", icon: "square.stack.3d.up") {
            Menu {
                ForEach(vm.availableAssays) { assay in
                    Button {
                        vm.select(assay)
                    } label: {
                        Label(assay.displayName, systemImage: assay.systemImage)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    AssayRow(assay: vm.assay ?? .openField)
                    Image(systemName: "chevron.up.chevron.down")
                        .appFont(14.5, weight: .semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(9)
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .buttonStyle(.plain)
            Text(vm.summaryLine)
                .appFont(13.5, design: .monospaced)
                .foregroundStyle(.secondary)
        }
    }

    private var designCard: some View {
        SectionCard("Analysis", icon: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Design", selection: $vm.request.design) {
                    ForEach(vm.designs) { d in
                        Text(d.displayName).tag(d)
                    }
                }
                .pickerStyle(.menu)
                Text(vm.request.design.explanation)
                    .appFont(13)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                switch vm.request.design {
                case .betweenGroups, .byDay, .phaseChange:
                    Picker("Measure", selection: $vm.request.metricKey) {
                        ForEach(vm.metricOptions) { m in
                            Text(m.axisTitle).tag(m.key)
                        }
                    }
                    .pickerStyle(.menu)
                case .withinSession:
                    Picker("Series", selection: $vm.request.seriesKey) {
                        ForEach(vm.seriesOptions) { s in
                            Text(s.unit.isEmpty ? s.name : "\(s.name) (\(s.unit))").tag(s.key)
                        }
                    }
                    .pickerStyle(.menu)
                case .pairedMeasures:
                    Picker("Comparison", selection: $vm.request.pairKey) {
                        ForEach(vm.pairOptions) { p in
                            Text(p.name).tag(p.key)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if vm.request.design == .phaseChange {
                    HStack {
                        Picker("From", selection: $vm.request.phaseA) {
                            ForEach(vm.phases, id: \.self) { Text(AssayKind.phaseTitle($0)).tag($0) }
                        }
                        Image(systemName: "arrow.right").foregroundStyle(.secondary)
                        Picker("To", selection: $vm.request.phaseB) {
                            ForEach(vm.phases, id: \.self) { Text(AssayKind.phaseTitle($0)).tag($0) }
                        }
                    }
                    .pickerStyle(.menu)
                } else if !vm.phases.isEmpty {
                    Picker((vm.assay?.phaseLabel ?? loc("Phase")), selection: $vm.request.phaseFilter) {
                        Text("All").tag(String?.none)
                        ForEach(vm.phases, id: \.self) { p in
                            Text(AssayKind.phaseTitle(p)).tag(String?.some(p))
                        }
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                Picker("Statistics", selection: $vm.request.mode) {
                    ForEach(StatMode.allCases) { m in
                        Text(m.displayName).tag(m)
                    }
                }
                .pickerStyle(.segmented)

                if vm.request.groups.count >= 3 && vm.request.design != .pairedMeasures {
                    Picker("Comparisons", selection: $vm.request.comparison) {
                        ForEach(ComparisonMode.allCases) { c in
                            Text(c.displayName).tag(c)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let chance = vm.currentMetric?.chance, vm.request.design == .betweenGroups {
                    Toggle(locf("Test each group against %@", StatsFormat.number(chance)), isOn: $vm.request.testAgainstChance)
                        .appFont(15.5)
                }
                Toggle("Include excluded records", isOn: $vm.request.includeExcluded)
                    .appFont(15.5)
            }
        }
    }

    private var groupsCard: some View {
        SectionCard("Groups", icon: "person.3", trailing: loc("first = control")) {
            VStack(spacing: 6) {
                ForEach(Array(vm.availableGroups.enumerated()), id: \.element) { index, group in
                    HStack(spacing: 10) {
                        Button {
                            vm.cycleColor(group, paletteCount: GroupPalette.colors.count)
                        } label: {
                            Circle()
                                .fill(GroupPalette.color(vm.colorIndex(group)))
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(.primary.opacity(0.15), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(group)
                                .appFont(16, weight: .medium)
                                .foregroundStyle(vm.isIncluded(group) ? Color.primary : Color.secondary)
                            Text(groupCaption(group))
                                .appFont(12.5)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 4)
                        Button {
                            vm.move(group, by: -1)
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(index == 0)
                        Button {
                            vm.move(group, by: 1)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(index == vm.availableGroups.count - 1)
                        Toggle("", isOn: Binding(get: { vm.isIncluded(group) }, set: { _ in vm.toggle(group) }))
                            .labelsHidden()
                    }
                    .buttonStyle(.borderless)
                    if index < vm.availableGroups.count - 1 { Divider() }
                }
                Text("Tap a color dot to change it. Group names come from each record's Group field.")
                    .appFont(12.5)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func groupCaption(_ group: String) -> String {
        let recs = vm.assayRecords.filter { $0.displayGroup == group }
        let animals = Set(recs.map { GroupAnalysisEngine.subjectKey($0) }).count
        let excluded = recs.filter(\.excluded).count
        var text = locf("%ld animal(s) · %ld record(s)", animals, recs.count)
        if excluded > 0 { text += " · " + locf("%ld excluded", excluded) }
        if vm.request.groups.first == group { text += " · " + loc("control") }
        return text
    }

    private func figureCard(_ result: GroupAnalysisResult) -> some View {
        SectionCard("Figure", icon: "chart.bar.xaxis") {
            if result.request.design == .betweenGroups || result.request.design == .phaseChange {
                Picker("Style", selection: $vm.chartStyle) {
                    ForEach(GroupChartStyle.allCases) { s in
                        Text(s.displayName).tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }
            GroupChartView(
                result: result,
                colorFor: { GroupPalette.color(vm.colorIndex($0)) },
                style: vm.chartStyle,
                showNonSignificant: vm.showNonSignificant
            )
            .frame(height: 320)
            Toggle("Show non-significant comparisons (ns)", isOn: $vm.showNonSignificant)
                .appFont(14.5)
            Button {
                exportFigure()
            } label: {
                Label("Export Figure (PNG)", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func statsCard(_ result: GroupAnalysisResult) -> some View {
        SectionCard("Statistics", icon: "function") {
            VStack(alignment: .leading, spacing: 10) {
                if !result.report.methodSummary.isEmpty {
                    Text(result.report.methodSummary)
                        .appFont(14)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let omnibus = result.report.omnibus {
                    statLine(omnibus.name, omnibus.reportLine, p: omnibus.p)
                }
                if let mixed = result.report.mixed {
                    if let g = mixed.group { statLine("Group", g.reportLine, p: g.p) }
                    statLine(result.levelLabel.isEmpty ? loc("Within") : result.levelLabel, mixed.level.reportLine, p: mixed.level.p)
                    if let i = mixed.interaction { statLine(locf("Group × %@", result.levelLabel.isEmpty ? loc("within") : result.levelLabel.lowercased()), i.reportLine, p: i.p) }
                    if let note = mixed.level.note { Text(note).appFont(12.5).foregroundStyle(.secondary) }
                }
                if !result.report.perGroup.isEmpty {
                    Divider()
                    Text(locf("Within each group · %@", result.report.perGroupLabel))
                        .appFont(13.5, weight: .semibold)
                    ForEach(result.report.perGroup.keys.sorted(), id: \.self) { g in
                        if let t = result.report.perGroup[g] {
                            statLine(g, t.reportLine, p: t.p)
                        }
                    }
                }
                if !result.report.pairwise.isEmpty {
                    Divider()
                    Text("Pairwise comparisons (adjusted p)")
                        .appFont(13.5, weight: .semibold)
                    ForEach(result.report.pairwise) { c in
                        HStack(alignment: .firstTextBaseline) {
                            Text(locf("%@ vs %@", c.groupA, c.groupB) + (c.level.map { " · \($0)" } ?? ""))
                                .appFont(14)
                            Spacer(minLength: 6)
                            Text("\(StatsFormat.p(c.pAdjusted))  \(StatsFormat.stars(c.pAdjusted))")
                                .appFont(13.5, weight: .semibold, design: .monospaced)
                                .foregroundStyle(c.pAdjusted < 0.05 ? Color.primary : Color.secondary)
                        }
                    }
                }
                Divider()
                Text("Descriptive statistics (n = animals)")
                    .appFont(13.5, weight: .semibold)
                ForEach(result.groups, id: \.self) { g in
                    if let d = result.descriptives[g], d.n > 0 {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(g).appFont(14, weight: .medium)
                            Text(locf("n = %ld · mean %@ ± SEM %@ · SD %@ · median %@ [%@, %@]", d.n, StatsFormat.number(d.mean), StatsFormat.number(d.sem), StatsFormat.number(d.sd), StatsFormat.number(d.median), StatsFormat.number(d.q1), StatsFormat.number(d.q3)))
                                .appFont(12.5, design: .monospaced)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                if result.request.design == .pairedMeasures {
                    Text(locf("Descriptives are for the %@ − %@ difference.", result.pairLabelA, result.pairLabelB))
                        .appFont(12.5)
                        .foregroundStyle(.secondary)
                }
                if !result.notes.isEmpty {
                    Divider()
                    ForEach(result.notes, id: \.self) { note in
                        Label(note, systemImage: "info.circle")
                            .appFont(13)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func statLine(_ title: String, _ value: String, p: Double) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                Text(loc(title)).appFont(14, weight: .medium)
                Spacer()
                Text(StatsFormat.stars(p))
                    .appFont(13.5, weight: .bold)
                    .foregroundStyle(p < 0.05 ? Color.accentColor : Color.secondary)
            }
            Text(value)
                .appFont(13, design: .monospaced)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }

    // MARK: Export

    private func exportFigure() {
        guard let result = vm.result, !result.isEmpty else { return }
        let figure = GroupFigureView(
            result: result,
            colorFor: { GroupPalette.color(vm.colorIndex($0)) },
            style: vm.chartStyle,
            showNonSignificant: vm.showNonSignificant
        )
        .frame(width: 420, height: 400)
        .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: figure)
        renderer.scale = 3
        guard let image = renderer.uiImage, let data = image.pngData() else {
            message = loc("The figure could not be rendered.")
            return
        }
        let url = ResultsStore.temporaryURL("RodentFlow_\(result.request.assay.shortName)_\(result.metricName)", ext: "png")
        do {
            try data.write(to: url, options: .atomic)
            shareItem = ShareItem(urls: [url])
        } catch {
            message = error.localizedDescription
        }
    }

    private func exportAnalysis() {
        guard let result = vm.result else { return }
        do {
            let url = try ResultsStore.exportAnalysis(result, name: "RodentFlow_stats_\(result.request.assay.shortName)_\(result.metricName)")
            shareItem = ShareItem(urls: [url])
        } catch {
            message = error.localizedDescription
        }
    }

    private func exportData() {
        guard let assay = vm.assay else { return }
        do {
            let url = try ResultsStore.exportBundle(vm.assayRecords, name: "RodentFlow_records_\(assay.shortName)")
            shareItem = ShareItem(urls: [url])
        } catch {
            message = error.localizedDescription
        }
    }
}
