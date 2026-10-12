import SwiftUI
import UIKit

/// Data-driven form for assays scored by hand (or with another tool). The form is generated
/// from `ManualAssays.schema(for:)`; results are computed live with `ManualAssays.compute`.
struct ManualEntryView: View {
    @ObservedObject var library: ResultsLibrary
    let assay: AssayKind
    let existing: ExperimentResult?
    let onSaved: ((ExperimentResult) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var subjectID: String
    @State private var group: String
    @State private var sex: String
    @State private var phase: String
    @State private var day: Int?
    @State private var trial: Int?
    @State private var date: Date
    @State private var notes: String
    @State private var input: ManualInput

    private let schema: ManualSchema

    init(library: ResultsLibrary, assay: AssayKind, existing: ExperimentResult? = nil, onSaved: ((ExperimentResult) -> Void)? = nil) {
        _library = ObservedObject(wrappedValue: library)
        self.assay = assay
        self.existing = existing
        self.onSaved = onSaved
        let schema = ManualAssays.schema(for: assay)
        self.schema = schema
        _subjectID = State(initialValue: existing?.subjectID ?? "")
        _group = State(initialValue: existing?.group ?? "")
        _sex = State(initialValue: existing?.sex ?? "")
        _phase = State(initialValue: existing?.phase ?? assay.defaultPhase)
        _day = State(initialValue: existing?.day)
        _trial = State(initialValue: existing?.trial)
        _date = State(initialValue: existing?.experimentDate ?? Date())
        _notes = State(initialValue: existing?.notes ?? "")

        var initial = existing?.manualInput ?? ManualInput()
        if existing?.manualInput == nil {
            for field in schema.fields {
                if let d = field.defaultValue { initial.values[field.key] = d }
            }
            for _ in 0..<max(0, schema.minRows) {
                initial.rows.append(ManualEntryView.newRow(schema))
            }
        }
        _input = State(initialValue: initial)
    }

    static func newRow(_ schema: ManualSchema) -> ManualRow {
        var row = ManualRow()
        for field in schema.rowFields {
            if let d = field.defaultValue { row.values[field.key] = d }
        }
        return row
    }

    private var computation: AssayComputation {
        ManualAssays.compute(assay: assay, phase: phase, input: input)
    }

    private var missing: [String] {
        var m = ManualAssays.missingRequired(assay: assay, input: input)
        if subjectID.trimmingCharacters(in: .whitespaces).isEmpty { m.insert(loc("Subject ID"), at: 0) }
        return m
    }

    var body: some View {
        NavigationStack {
            Form {
                animalSection

                if !schema.fields.isEmpty {
                    Section {
                        ForEach(schema.fields) { field in
                            fieldView(field, value: valueBinding(field.key), text: textBinding(field.key))
                        }
                    } header: {
                        Text("Measurements")
                    } footer: {
                        if !schema.note.isEmpty { Text(schema.note) }
                    }
                }

                if schema.hasRows {
                    ForEach(Array(input.rows.enumerated()), id: \.element.id) { index, row in
                        Section(schema.rowTitle(index)) {
                            ForEach(schema.rowFields) { field in
                                fieldView(field, value: rowBinding(row.id, field.key), text: .constant(""))
                            }
                            Button(role: .destructive) {
                                input.rows.removeAll { $0.id == row.id }
                            } label: {
                                Label(schema.removeRowTitle, systemImage: "minus.circle")
                            }
                        }
                    }
                    Section {
                        Button {
                            addRow()
                        } label: {
                            Label(schema.addRowTitle, systemImage: "plus.circle.fill")
                        }
                        if !input.rows.isEmpty {
                            Button {
                                duplicateLastRow()
                            } label: {
                                Label(schema.duplicateRowTitle, systemImage: "plus.square.on.square")
                            }
                        }
                    } footer: {
                        if schema.fields.isEmpty && !schema.note.isEmpty { Text(schema.note) }
                    }
                }

                previewSection

                Section("Notes") {
                    TextField("Optional", text: $notes, axis: .vertical)
                        .lineLimit(1...4)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(existing == nil ? assay.displayName : loc("Edit values"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!missing.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }

    // MARK: Sections

    private var animalSection: some View {
        Section("Animal & session") {
            TextField("Subject ID (e.g. M01)", text: $subjectID)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            HStack {
                TextField("Group (e.g. WT, KO, Vehicle)", text: $group)
                    .autocorrectionDisabled()
                let suggestions = library.groups(for: assay)
                if !suggestions.isEmpty {
                    Menu {
                        ForEach(suggestions, id: \.self) { g in
                            Button(g) { group = g }
                        }
                    } label: {
                        Image(systemName: "list.bullet.circle")
                    }
                }
            }
            Picker("Sex", selection: $sex) {
                Text("—").tag("")
                Text("Male").tag("M")
                Text("Female").tag("F")
            }
            .pickerStyle(.segmented)
            if !assay.phases.isEmpty {
                Picker(assay.phaseLabel, selection: $phase) {
                    ForEach(assay.phases, id: \.self) { p in
                        Text(AssayKind.phaseTitle(p)).tag(p)
                    }
                }
            } else {
                TextField(locf("%@ (optional)", assay.phaseLabel), text: $phase)
            }
            if assay.usesDays || day != nil {
                OptionalIntField(title: "Day", value: $day)
            }
            if assay.usesTrials || trial != nil {
                OptionalIntField(title: "Trial", value: $trial)
            }
            DatePicker("Date", selection: $date, displayedComponents: [.date])
        }
    }

    private var previewSection: some View {
        let result = computation
        let defs = AssayCatalog.metrics(for: assay).filter { result.metrics[$0.key] != nil }
        return Section {
            if defs.isEmpty {
                Text(missing.isEmpty ? loc("No results yet.") : locf("Missing: %@", missing.prefix(4).joined(separator: ", ") + (missing.count > 4 ? "…" : "")))
                    .appFont(14.5)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(defs) { def in
                    KeyValueRow(key: def.name, value: result.metrics[def.key].map { def.format($0) } ?? "—")
                }
            }
            ForEach(result.qcFlags, id: \.self) { flag in
                Label(flag, systemImage: "exclamationmark.triangle.fill")
                    .appFont(14)
                    .foregroundStyle(.orange)
            }
        } header: {
            Text("Result")
        } footer: {
            Text(assay.methodsNote)
        }
    }

    // MARK: Field rendering

    @ViewBuilder
    private func fieldView(_ field: ManualField, value: Binding<Double?>, text: Binding<String>) -> some View {
        switch field.kind {
        case .number:
            OptionalNumberField(title: field.label, unit: field.unit, value: value, help: field.help)
        case .integer:
            OptionalNumberField(title: field.label, unit: field.unit, value: value, integer: true, help: field.help)
        case .toggle:
            Toggle(field.label, isOn: Binding(
                get: { (value.wrappedValue ?? 0) >= 0.5 },
                set: { value.wrappedValue = $0 ? 1 : 0 }
            ))
        case .choice(let options):
            Picker(field.label, selection: Binding(
                get: { min(max(0, Int(value.wrappedValue ?? field.defaultValue ?? 0)), max(0, options.count - 1)) },
                set: { value.wrappedValue = Double($0) }
            )) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Text(loc(option)).tag(index)
                }
            }
        case .text:
            VStack(alignment: .leading, spacing: 4) {
                TextField(field.label, text: text)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .appFont(16.5, design: .monospaced)
                if let help = field.help {
                    Text(help)
                        .appFont(12.5)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func valueBinding(_ key: String) -> Binding<Double?> {
        Binding(get: { input.values[key] }, set: { input.values[key] = $0 })
    }

    private func textBinding(_ key: String) -> Binding<String> {
        Binding(get: { input.text[key] ?? "" }, set: { input.text[key] = $0 })
    }

    private func rowBinding(_ id: UUID, _ key: String) -> Binding<Double?> {
        Binding(
            get: { input.rows.first(where: { $0.id == id })?.values[key] },
            set: { newValue in
                if let index = input.rows.firstIndex(where: { $0.id == id }) {
                    input.rows[index].values[key] = newValue
                }
            }
        )
    }

    private func addRow() {
        input.rows.append(ManualEntryView.newRow(schema))
    }

    private func duplicateLastRow() {
        guard let last = input.rows.last else { return }
        input.rows.append(ManualRow(values: last.values))
    }

    private func save() {
        var r = existing ?? ExperimentResult(assay: assay, subjectID: "", group: "", source: .manual)
        r.subjectID = subjectID.trimmingCharacters(in: .whitespaces)
        r.group = group.trimmingCharacters(in: .whitespaces)
        r.sex = sex
        r.phase = phase.trimmingCharacters(in: .whitespaces)
        r.day = day
        r.trial = trial
        r.experimentDate = date
        r.notes = notes
        r.manualInput = input
        r.apply(computation)
        if library.save(r) {
            onSaved?(r)
            dismiss()
        }
    }
}
