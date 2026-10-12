import SwiftUI
import UniformTypeIdentifiers

/// Imports per-animal tables (CSV / TSV), raw measurement tables, bandit trial logs and
/// RodentFlow JSON exports into the results library.
struct ImportSheet: View {
    @ObservedObject var library: ResultsLibrary
    let onImported: ((Int) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var assay: AssayKind
    @State private var defaultGroup = ""
    @State private var showingImporter = false
    @State private var fileName = ""
    @State private var fileText: String?
    @State private var fileData: Data?
    @State private var isJSON = false
    @State private var preview: ImportPreview?
    @State private var errorText: String?
    @State private var shareItem: ShareItem?

    init(library: ResultsLibrary, initialAssay: AssayKind, onImported: ((Int) -> Void)? = nil) {
        _library = ObservedObject(wrappedValue: library)
        self.onImported = onImported
        _assay = State(initialValue: initialAssay)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Assay", selection: $assay) {
                        ForEach(AssayKind.allCases) { a in
                            Text(a.displayName).tag(a)
                        }
                    }
                    .disabled(isJSON)
                    TextField("Group for rows without a group column", text: $defaultGroup)
                        .autocorrectionDisabled()
                } footer: {
                    Text("CSV / TSV with a header row: subject, group and optionally sex, day, trial, phase, then measurements. Headers are matched to this assay's metrics or raw fields (e.g. bottle weights, trial times); other numeric columns are kept as custom metrics. JSON files exported from RodentFlow keep their own assay.")
                }

                Section {
                    Button {
                        showingImporter = true
                    } label: {
                        Label(fileName.isEmpty ? "Choose File (CSV, TSV, JSON)" : "Choose Another File", systemImage: "doc.badge.plus")
                    }
                    Button {
                        shareTemplate()
                    } label: {
                        Label(locf("CSV Template for %@", assay.displayShortName), systemImage: "tablecells")
                    }
                } footer: {
                    if !fileName.isEmpty { Text(fileName) }
                }

                if let errorText {
                    Section {
                        MessageBanner(text: errorText)
                            .listRowInsets(EdgeInsets())
                    }
                }

                if let preview {
                    previewSections(preview)
                }
            }
            .navigationTitle("Import data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") { commit() }
                        .disabled(preview?.records.isEmpty ?? true)
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.commaSeparatedText, .tabSeparatedText, .plainText, .json, .text, .data],
                allowsMultipleSelection: false
            ) { result in
                handle(result)
            }
            .onChange(of: assay) { _, _ in reparse() }
            .onChange(of: defaultGroup) { _, _ in reparse() }
            .sheet(item: $shareItem) { item in
                ActivityView(items: item.urls)
            }
        }
    }

    @ViewBuilder
    private func previewSections(_ p: ImportPreview) -> some View {
        Section("Preview") {
            KeyValueRow(key: "Format", value: loc(p.kind.rawValue))
            KeyValueRow(key: "Records", value: "\(p.records.count)")
            KeyValueRow(key: "Animals", value: "\(Set(p.records.map { $0.displayGroup + "|" + $0.subjectID }).count)")
            KeyValueRow(key: "Groups", value: p.groups.joined(separator: ", "))
            if isJSON {
                KeyValueRow(key: "Assays", value: Array(Set(p.records.map(\.assay.displayShortName))).sorted().joined(separator: ", "))
            }
        }
        if !p.matched.isEmpty {
            Section("Recognized columns") {
                ForEach(Array(p.matched.enumerated()), id: \.offset) { _, match in
                    KeyValueRow(key: match.column, value: match.target)
                }
            }
        }
        if !p.unmatched.isEmpty {
            Section("Ignored columns") {
                Text(p.unmatched.joined(separator: ", "))
                    .appFont(14.5)
                    .foregroundStyle(.secondary)
            }
        }
        if !p.warnings.isEmpty {
            Section {
                ForEach(p.warnings, id: \.self) { warning in
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .appFont(14)
                        .foregroundStyle(.orange)
                }
            }
        }
        Section("First records") {
            ForEach(p.records.prefix(6)) { r in
                ResultRow(result: r)
            }
        }
    }

    private func handle(_ result: Result<[URL], Error>) {
        errorText = nil
        preview = nil
        switch result {
        case .failure(let error):
            errorText = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                fileName = url.lastPathComponent
                let ext = url.pathExtension.lowercased()
                if ["xlsx", "xls", "numbers"].contains(ext) {
                    fileText = nil
                    fileData = nil
                    errorText = loc("Spreadsheet files can't be read directly. Export the sheet as CSV (File › Export / Save As › CSV) and import that file.")
                    return
                }
                let firstByte = data.first { !($0 == 0x20 || $0 == 0x0A || $0 == 0x0D || $0 == 0x09 || $0 == 0xEF || $0 == 0xBB || $0 == 0xBF) }
                if ext == "json" || firstByte == UInt8(ascii: "{") || firstByte == UInt8(ascii: "[") {
                    isJSON = true
                    fileData = data
                    fileText = nil
                } else {
                    isJSON = false
                    fileData = nil
                    fileText = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .windowsCP1252)
                    if fileText == nil { errorText = ImportError.unreadable.localizedDescription }
                }
                reparse()
            } catch {
                errorText = error.localizedDescription
            }
        }
    }

    private func reparse() {
        guard fileText != nil || fileData != nil else { return }
        errorText = nil
        do {
            if isJSON, let data = fileData {
                preview = try DataImporter.importJSON(data: data, fileName: fileName)
            } else if let text = fileText {
                preview = try DataImporter.importCSV(text: text, fileName: fileName, assay: assay, defaultGroup: defaultGroup)
            }
        } catch {
            preview = nil
            errorText = error.localizedDescription
        }
    }

    private func commit() {
        guard let preview else { return }
        let count = library.add(preview.records)
        onImported?(count)
        dismiss()
    }

    private func shareTemplate() {
        do {
            shareItem = ShareItem(urls: [try ResultsStore.writeTemplate(for: assay)])
        } catch {
            errorText = error.localizedDescription
        }
    }
}
