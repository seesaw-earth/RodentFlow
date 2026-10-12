import Foundation

// MARK: - CSV parsing

struct CSVTable {
    var header: [String]
    var rows: [[String]]
    var delimiter: Character
}

enum CSVParser {
    /// RFC 4180-style parser with delimiter detection (comma, semicolon, tab) and BOM handling.
    static func parse(_ raw: String) -> CSVTable? {
        var text = raw
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
        let firstLine = text.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let candidates: [Character] = [",", ";", "\t"]
        let delimiter = candidates.max { a, b in count(a, in: firstLine) < count(b, in: firstLine) } ?? ","

        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        var iterator = Array(text).makeIterator()
        var pending: Character?
        while let ch = pending ?? iterator.next() {
            pending = nil
            if inQuotes {
                if ch == "\"" {
                    if let next = iterator.next() {
                        if next == "\"" { field.append("\"") } else { inQuotes = false; pending = next }
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(ch)
                }
                continue
            }
            if ch == "\"" && field.isEmpty {
                inQuotes = true
            } else if ch == delimiter {
                row.append(field)
                field = ""
            } else if ch == "\n" || ch == "\r" || ch == "\r\n" {
                row.append(field)
                field = ""
                if !row.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).isEmpty }) { rows.append(row) }
                row = []
            } else {
                field.append(ch)
            }
        }
        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            if !row.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).isEmpty }) { rows.append(row) }
        }
        guard let header = rows.first else { return nil }
        let trimmedHeader = header.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let body = rows.dropFirst().map { r -> [String] in
            var padded = r.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if padded.count < trimmedHeader.count { padded += Array(repeating: "", count: trimmedHeader.count - padded.count) }
            return padded
        }
        return CSVTable(header: trimmedHeader, rows: Array(body), delimiter: delimiter)
    }

    private static func count(_ c: Character, in s: String) -> Int { s.filter { $0 == c }.count }

    /// Parses numbers such as "12.5", "12,5" (semicolon files), "1e-3"; returns nil for blanks / NA.
    static func number(_ s: String, decimalComma: Bool) -> Double? {
        var t = s.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return nil }
        let lower = t.lowercased()
        if ["na", "nan", "n/a", "-", "—", "null", "none", ".", "#n/a"].contains(lower) { return nil }
        if lower == "true" || lower == "yes" || lower == "y" { return 1 }
        if lower == "false" || lower == "no" || lower == "n" { return 0 }
        if t.hasSuffix("%") { t.removeLast() }
        if decimalComma { t = t.replacingOccurrences(of: ",", with: ".") }
        guard let v = Double(t), v.isFinite else { return nil }
        return v
    }
}

// MARK: - Import

struct ImportPreview {
    enum Kind: String {
        case metricsTable = "Per-animal results table"
        case longTable = "Long table (metric, value)"
        case rawTable = "Raw measurements"
        case banditTrials = "Trial-by-trial choices"
        case resultsJSON = "RodentFlow results"
        case legacySummary = "RodentFlow 1.0 summary"
    }

    var kind: Kind
    var records: [ExperimentResult]
    var matched: [(column: String, target: String)] = []
    var unmatched: [String] = []
    var warnings: [String] = []

    var groups: [String] { Array(Set(records.map(\.displayGroup))).sorted() }
}

enum ImportError: LocalizedError {
    case unreadable
    case noHeader
    case noSubjectColumn
    case nothingRecognized

    var errorDescription: String? {
        switch self {
        case .unreadable: return loc("The file could not be read as text (UTF-8) or JSON.")
        case .noHeader: return loc("The table has no header row.")
        case .noSubjectColumn: return loc("No subject column found. Add a column named subject (or mouse, animal, id).")
        case .nothingRecognized: return loc("No usable values were found in the file.")
        }
    }
}

enum DataImporter {
    // English column names first; Chinese headers (编号, 组别, 性别, …) are accepted as well.
    static let subjectAliases = ["subject", "subject_id", "subjectid", "mouse", "mouse_id", "mouseid", "animal", "animal_id", "id", "rat", "rat_id", "name",
                                 "编号", "动物编号", "小鼠编号", "大鼠编号", "动物", "小鼠", "大鼠", "个体"]
    static let groupAliases = ["group", "condition", "genotype", "treatment", "cohort", "group_name", "组", "组别", "分组", "处理", "基因型"]
    static let sexAliases = ["sex", "gender", "性别"]
    static let dayAliases = ["day", "session_day", "day_number", "天", "天数", "第几天"]
    static let trialAliases = ["trial", "trial_number", "trial_no", "run", "试次", "试次编号"]
    static let phaseAliases = ["phase", "stage", "session", "session_type", "test", "beam", "block", "阶段"]
    static let dateAliases = ["date", "experiment_date", "test_date", "日期", "实验日期"]
    static let notesAliases = ["notes", "note", "comment", "comments", "备注"]
    static let metricColumnAliases = ["metric", "measure", "variable", "parameter"]
    static let valueColumnAliases = ["value", "result", "score"]

    /// "Center time (%)" → "center_time_pct"
    static func normalize(_ s: String) -> String {
        var t = s.lowercased()
        t = t.replacingOccurrences(of: "%", with: " pct ")
        t = t.replacingOccurrences(of: "/", with: " ")
        var out = ""
        var lastUnderscore = false
        for ch in t {
            if ch.isLetter || ch.isNumber {
                out.append(ch)
                lastUnderscore = false
            } else if !lastUnderscore {
                out.append("_")
                lastUnderscore = true
            }
        }
        return out.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }

    static func unitToken(_ unit: String) -> String {
        switch unit {
        case "%": return "pct"
        case "": return ""
        default: return normalize(unit)
        }
    }

    static func metricAliases(_ m: MetricDefinition) -> Set<String> {
        // English and localized names are both accepted, so a table written on an English phone
        // imports on a Chinese one and vice versa.
        let names = [m.englishName ?? m.name, m.name]
        var set: Set<String> = [normalize(m.key)]
        let u = unitToken(m.unit)
        for name in names {
            set.insert(normalize(name))
            if !u.isEmpty { set.insert(normalize(name) + "_" + u) }
        }
        set.remove("")
        return set
    }

    static func fieldAliases(_ f: ManualField) -> Set<String> {
        var set: Set<String> = [normalize(f.key)]
        let u = unitToken(f.unit)
        for label in [f.englishLabel, f.label] {
            set.insert(normalize(label))
            if !u.isEmpty { set.insert(normalize(label) + "_" + u) }
        }
        set.remove("")
        return set
    }

    static func columnIndex(_ header: [String], _ aliases: [String]) -> Int? {
        let normalized = header.map(normalize)
        for a in aliases { if let i = normalized.firstIndex(of: a) { return i } }
        return nil
    }

    // MARK: CSV

    static func importCSV(text: String, fileName: String, assay: AssayKind, defaultGroup: String = "") throws -> ImportPreview {
        guard let table = CSVParser.parse(text), !table.header.isEmpty else { throw ImportError.noHeader }
        let decimalComma = table.delimiter == ";"
        let header = table.header
        let normalized = header.map(normalize)

        let iSubject = columnIndex(header, subjectAliases)
        let iGroup = columnIndex(header, groupAliases)
        let iSex = columnIndex(header, sexAliases)
        let iDay = columnIndex(header, dayAliases)
        let iTrial = columnIndex(header, trialAliases)
        let iPhase = columnIndex(header, phaseAliases)
        let iDate = columnIndex(header, dateAliases)
        let iNotes = columnIndex(header, notesAliases)
        let metaIndices = Set([iSubject, iGroup, iSex, iDay, iTrial, iPhase, iDate, iNotes].compactMap { $0 })

        func meta(_ row: [String], _ i: Int?) -> String { i.map { row[$0] } ?? "" }

        func baseRecord(_ row: [String], source: ResultSource) -> ExperimentResult {
            var r = ExperimentResult(assay: assay, subjectID: meta(row, iSubject),
                                     group: iGroup.map { row[$0] } ?? defaultGroup, source: source)
            r.sex = normalizeSex(meta(row, iSex))
            r.phase = normalizePhase(meta(row, iPhase), assay: assay)
            r.day = iDay.flatMap { CSVParser.number(row[$0], decimalComma: decimalComma) }.map { Int($0.rounded()) }
            r.trial = iTrial.flatMap { CSVParser.number(row[$0], decimalComma: decimalComma) }.map { Int($0.rounded()) }
            if let iDate, let d = parseDate(row[iDate]) { r.experimentDate = d }
            r.notes = meta(row, iNotes)
            r.datasetName = fileName
            return r
        }

        // Two-armed bandit trials.
        if assay == .twoArmedBandit, normalized.contains("choice"), normalized.contains(where: { $0 == "reward" || $0 == "rewarded" || $0 == "outcome" }) {
            return try importBandit(table: table, fileName: fileName, decimalComma: decimalComma, base: baseRecord)
        }

        // Long format: metric + value columns.
        if let iMetric = columnIndex(header, metricColumnAliases), let iValue = columnIndex(header, valueColumnAliases) {
            guard iSubject != nil else { throw ImportError.noSubjectColumn }
            var records: [String: ExperimentResult] = [:]
            var order: [String] = []
            var matched: [String: String] = [:]
            let catalog = AssayCatalog.metrics(for: assay)
            for row in table.rows {
                guard let v = CSVParser.number(row[iValue], decimalComma: decimalComma) else { continue }
                let rawName = row[iMetric]
                let key = catalog.first { metricAliases($0).contains(normalize(rawName)) }?.key ?? normalize(rawName)
                matched[rawName] = key
                let id = [meta(row, iSubject), meta(row, iGroup), meta(row, iPhase), meta(row, iDay), meta(row, iTrial)].joined(separator: "|")
                if records[id] == nil {
                    records[id] = baseRecord(row, source: .imported)
                    order.append(id)
                }
                records[id]!.metrics[key] = v
                if !catalog.contains(where: { $0.key == key }) {
                    var names = records[id]!.customMetricNames ?? [:]
                    names[key] = rawName
                    records[id]!.customMetricNames = names
                }
            }
            let list = order.compactMap { records[$0] }
            guard !list.isEmpty else { throw ImportError.nothingRecognized }
            return ImportPreview(kind: .longTable, records: list,
                                 matched: matched.sorted { $0.key < $1.key }.map { ($0.key, $0.value) })
        }

        guard let iSubjectIndex = iSubject else { throw ImportError.noSubjectColumn }
        _ = iSubjectIndex

        // Decide between raw manual measurements and computed metrics.
        let schema = ManualAssays.schema(for: assay)
        let catalog = AssayCatalog.metrics(for: assay)
        var metricColumns: [Int: MetricDefinition] = [:]
        var subjectFieldColumns: [Int: ManualField] = [:]
        var rowFieldColumns: [Int: ManualField] = [:]
        for (i, h) in normalized.enumerated() where !metaIndices.contains(i) {
            if let m = catalog.first(where: { metricAliases($0).contains(h) }) { metricColumns[i] = m }
            if let f = schema.fields.first(where: { fieldAliases($0).contains(h) }) { subjectFieldColumns[i] = f }
            if let f = schema.rowFields.first(where: { fieldAliases($0).contains(h) }) { rowFieldColumns[i] = f }
        }
        let rawCount = subjectFieldColumns.count + rowFieldColumns.count
        let metricOnly = metricColumns.filter { subjectFieldColumns[$0.key] == nil && rowFieldColumns[$0.key] == nil }
        let useRaw = assay != .custom && rawCount > 0 && metricOnly.count <= rawCount

        if useRaw {
            // Rows are days for sucrose preference: one record per animal (and phase) with day rows.
            let rowsAreDays = schema.rowName == "Day"
            let keys: [Int?] = rowsAreDays ? [iSubject, iGroup, iPhase] : [iSubject, iGroup, iPhase, iDay]
            return try importRaw(table: table, fileName: fileName, assay: assay, decimalComma: decimalComma,
                                 subjectFields: subjectFieldColumns, rowFields: rowFieldColumns, metricOnly: metricOnly,
                                 metaIndices: metaIndices, keyColumns: keys, clearDay: rowsAreDays, base: baseRecord)
        }

        // Wide metrics table: one record per row.
        var records: [ExperimentResult] = []
        var unmatched: [String] = []
        var customColumns: [Int: String] = [:]
        for (i, h) in header.enumerated() where !metaIndices.contains(i) && metricColumns[i] == nil {
            let numeric = table.rows.contains { CSVParser.number($0[i], decimalComma: decimalComma) != nil }
            if numeric { customColumns[i] = normalize(h) } else { unmatched.append(h) }
        }
        for row in table.rows {
            var r = baseRecord(row, source: .imported)
            for (i, m) in metricColumns {
                if let v = CSVParser.number(row[i], decimalComma: decimalComma) { r.metrics[m.key] = v }
            }
            var names: [String: String] = [:]
            for (i, key) in customColumns {
                if let v = CSVParser.number(row[i], decimalComma: decimalComma) {
                    r.metrics[key] = v
                    names[key] = header[i]
                }
            }
            if !names.isEmpty { r.customMetricNames = names }
            if !r.metrics.isEmpty { records.append(r) }
        }
        guard !records.isEmpty else { throw ImportError.nothingRecognized }
        var preview = ImportPreview(kind: .metricsTable, records: records)
        preview.matched = metricColumns.sorted { $0.key < $1.key }.map { (header[$0.key], $0.value.name) }
            + customColumns.sorted { $0.key < $1.key }.map { (header[$0.key], locf("custom: %@", $0.value)) }
        preview.unmatched = unmatched
        if iGroup == nil { preview.warnings.append(defaultGroup.isEmpty ? loc("No group column — all animals are ungrouped.") : locf("No group column — all animals assigned to %@.", defaultGroup)) }
        if !customColumns.isEmpty && assay != .custom {
            preview.warnings.append(locf("%ld column(s) did not match a %@ metric and were kept as custom metrics.", customColumns.count, assay.displayName))
        }
        return preview
    }

    private static func importRaw(table: CSVTable, fileName: String, assay: AssayKind, decimalComma: Bool,
                                  subjectFields: [Int: ManualField], rowFields: [Int: ManualField], metricOnly: [Int: MetricDefinition],
                                  metaIndices: Set<Int>, keyColumns: [Int?], clearDay: Bool,
                                  base: ([String], ResultSource) -> ExperimentResult) throws -> ImportPreview {
        var inputs: [String: (record: ExperimentResult, input: ManualInput)] = [:]
        var direct: [String: [String: [Double]]] = [:]
        var order: [String] = []
        for row in table.rows {
            let id = keyColumns.map { $0.map { row[$0] } ?? "" }.joined(separator: "|")
            if inputs[id] == nil {
                inputs[id] = (base(row, .imported), ManualInput())
                order.append(id)
            }
            for (i, f) in subjectFields {
                if case .text = f.kind {
                    if !row[i].isEmpty { inputs[id]!.input.text[f.key] = row[i] }
                } else if let v = parseFieldValue(row[i], field: f, decimalComma: decimalComma) {
                    inputs[id]!.input.values[f.key] = v
                }
            }
            for (i, m) in metricOnly {
                if let v = CSVParser.number(row[i], decimalComma: decimalComma) { direct[id, default: [:]][m.key, default: []].append(v) }
            }
            if !rowFields.isEmpty {
                var mrow = ManualRow()
                for (i, f) in rowFields {
                    if let v = parseFieldValue(row[i], field: f, decimalComma: decimalComma) { mrow.values[f.key] = v }
                }
                if !mrow.values.isEmpty { inputs[id]!.input.rows.append(mrow) }
            }
        }
        var records: [ExperimentResult] = []
        for id in order {
            guard var entry = inputs[id] else { continue }
            var computation = ManualAssays.compute(assay: assay, phase: entry.record.phase, input: entry.input)
            for (key, values) in direct[id] ?? [:] where computation.metrics[key] == nil && !values.isEmpty {
                computation.metrics[key] = Stats.mean(values)
            }
            entry.record.manualInput = entry.input
            entry.record.apply(computation)
            if !rowFields.isEmpty { entry.record.trial = nil }
            if clearDay { entry.record.day = nil }
            if !entry.record.metrics.isEmpty { records.append(entry.record) }
        }
        guard !records.isEmpty else { throw ImportError.nothingRecognized }
        var preview = ImportPreview(kind: .rawTable, records: records)
        preview.matched = (subjectFields.sorted { $0.key < $1.key } + rowFields.sorted { $0.key < $1.key })
            .map { (table.header[$0.key], $0.value.label) }
            + metricOnly.sorted { $0.key < $1.key }.map { (table.header[$0.key], $0.value.name) }
        preview.unmatched = table.header.enumerated()
            .filter { !metaIndices.contains($0.offset) && subjectFields[$0.offset] == nil && rowFields[$0.offset] == nil && metricOnly[$0.offset] == nil }
            .map(\.element)
        return preview
    }

    private static func importBandit(table: CSVTable, fileName: String, decimalComma: Bool,
                                     base: ([String], ResultSource) -> ExperimentResult) throws -> ImportPreview {
        let h = table.header
        let iChoice = columnIndex(h, ["choice", "side", "action"])!
        let iReward = columnIndex(h, ["reward", "rewarded", "outcome"])!
        let iPL = columnIndex(h, ["p_left", "pl", "prob_left", "p_l", "left_prob"])
        let iPR = columnIndex(h, ["p_right", "pr", "prob_right", "p_r", "right_prob"])
        let iRT = columnIndex(h, ["rt", "rt_s", "reaction_time", "latency"])
        let iSubject = columnIndex(h, subjectAliases)
        let iGroup = columnIndex(h, groupAliases)
        let iPhase = columnIndex(h, phaseAliases)
        let iDay = columnIndex(h, dayAliases)
        var sessions: [String: (record: ExperimentResult, rows: [ManualRow])] = [:]
        var order: [String] = []
        var skipped = 0
        for row in table.rows {
            guard let choice = parseChoice(row[iChoice]), let reward = CSVParser.number(row[iReward], decimalComma: decimalComma) else {
                skipped += 1
                continue
            }
            let id = [iSubject, iGroup, iPhase, iDay].map { $0.map { row[$0] } ?? "" }.joined(separator: "|")
            if sessions[id] == nil {
                sessions[id] = (base(row, .imported), [])
                order.append(id)
            }
            var values: [String: Double] = ["choice": Double(choice), "reward": reward]
            if let iPL, let v = CSVParser.number(row[iPL], decimalComma: decimalComma) { values["p_left"] = v }
            if let iPR, let v = CSVParser.number(row[iPR], decimalComma: decimalComma) { values["p_right"] = v }
            if let iRT, let v = CSVParser.number(row[iRT], decimalComma: decimalComma) { values["rt_s"] = v }
            sessions[id]!.rows.append(ManualRow(values: values))
        }
        var records: [ExperimentResult] = []
        for id in order {
            guard var s = sessions[id] else { continue }
            s.record.manualInput = ManualInput(rows: s.rows)
            s.record.apply(Bandit.analyze(s.rows))
            if s.record.metrics.isEmpty {
                skipped += s.rows.count
                continue
            }
            records.append(s.record)
        }
        guard !records.isEmpty else { throw ImportError.nothingRecognized }
        var preview = ImportPreview(kind: .banditTrials, records: records)
        preview.matched = [("choice", loc("Choice (left/right)")), ("reward", loc("Reward"))]
            + (iPL != nil ? [("p_left", loc("P(reward | left)"))] : []) + (iPR != nil ? [("p_right", loc("P(reward | right)"))] : [])
        if skipped > 0 { preview.warnings.append(locf("%ld row(s) without a readable choice/reward were skipped.", skipped)) }
        if iPL == nil || iPR == nil { preview.warnings.append(loc("No reward-probability columns: the high-value choice percentage and reversal curves are not available.")) }
        return preview
    }

    static func parseChoice(_ s: String) -> Int? {
        let t = s.trimmingCharacters(in: .whitespaces).lowercased()
        if ["l", "left", "0", "a"].contains(t) { return 0 }
        if ["r", "right", "1", "b"].contains(t) { return 1 }
        return nil
    }

    static func parseFieldValue(_ s: String, field: ManualField, decimalComma: Bool) -> Double? {
        switch field.kind {
        case .choice(let options):
            let t = s.trimmingCharacters(in: .whitespaces).lowercased()
            if let i = options.firstIndex(where: { $0.lowercased() == t || $0.lowercased().prefix(1) == t }) { return Double(i) }
            return CSVParser.number(s, decimalComma: decimalComma)
        case .text:
            return nil
        default:
            return CSVParser.number(s, decimalComma: decimalComma)
        }
    }

    static func normalizeSex(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces).lowercased()
        if ["m", "male", "♂", "雄", "雄性", "公"].contains(t) { return "M" }
        if ["f", "female", "♀", "雌", "雌性", "母"].contains(t) { return "F" }
        return s.trimmingCharacters(in: .whitespaces)
    }

    static func normalizePhase(_ s: String, assay: AssayKind) -> String {
        let t = s.trimmingCharacters(in: .whitespaces)
        // Stored phases are English; the translated names are accepted too.
        if let match = assay.phases.first(where: { normalize($0) == normalize(t) || normalize(AssayKind.phaseTitle($0)) == normalize(t) }) { return match }
        let n = normalize(t)
        if assay == .placePreference {
            if n.contains("pre") { return "Pre-test" }
            if n == "post" || n == "post_test" || n == "posttest" { return "Test" }
        }
        if assay == .morrisWaterMaze || assay == .barnesMaze {
            if n.contains("probe") { return "Probe" }
            if n.contains("acq") || n.contains("train") { return "Acquisition" }
        }
        if assay == .fearConditioning {
            if n.contains("context") { return "Context test" }
            if n.contains("cue") || n.contains("tone") { return "Cue test" }
            if n.contains("train") || n.contains("acq") { return "Training" }
        }
        return t
    }

    static func parseDate(_ s: String) -> Date? {
        let t = s.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()
        if let d = iso.date(from: t) { return d }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd", "yyyy/MM/dd", "MM/dd/yyyy", "dd.MM.yyyy", "yyyy-MM-dd HH:mm", "yyyy-MM-dd'T'HH:mm:ss"] {
            f.dateFormat = format
            if let d = f.date(from: t) { return d }
        }
        return nil
    }

    // MARK: JSON

    struct ResultsBundle: Codable {
        var schemaVersion = "1.1"
        var app = "RodentFlow"
        var exportedAt = Date()
        var results: [ExperimentResult]
    }

    static func importJSON(data: Data, fileName: String) throws -> ImportPreview {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let bundle = try? decoder.decode(ResultsBundle.self, from: data), !bundle.results.isEmpty {
            return ImportPreview(kind: .resultsJSON, records: bundle.results.map { relabel($0, fileName) })
        }
        if let list = try? decoder.decode([ExperimentResult].self, from: data), !list.isEmpty, list.contains(where: { !$0.metrics.isEmpty }) {
            return ImportPreview(kind: .resultsJSON, records: list.map { relabel($0, fileName) })
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw ImportError.unreadable }
        if object["subjectID"] != nil, object["assay"] != nil, let single = try? decoder.decode(ExperimentResult.self, from: data) {
            return ImportPreview(kind: .resultsJSON, records: [relabel(single, fileName)])
        }
        if let legacy = legacySummary(object, fileName: fileName) {
            return ImportPreview(kind: .legacySummary, records: [legacy])
        }
        throw ImportError.nothingRecognized
    }

    /// Imported copies get a fresh identity so re-importing never overwrites local records.
    private static func relabel(_ r: ExperimentResult, _ fileName: String) -> ExperimentResult {
        var copy = r
        copy.id = UUID()
        if copy.source != .imported { copy.datasetName = fileName }
        copy.runFolderName = nil
        copy.source = .imported
        if copy.datasetName == nil { copy.datasetName = fileName }
        return copy
    }

    /// Converts a RodentFlow 1.0 `summary.json` into a result record.
    static func legacySummary(_ o: [String: Any], fileName: String) -> ExperimentResult? {
        guard let shape = o["arenaShape"] as? String, o["distanceCentimeters"] != nil else { return nil }
        let assay: AssayKind
        switch shape {
        case "t_maze": assay = .tMaze
        case "y_maze": assay = .yMaze
        case "plus_maze": assay = .elevatedPlusMaze
        default: assay = .openField
        }
        var r = ExperimentResult(assay: assay, subjectID: o["mouseID"] as? String ?? "", group: o["group"] as? String ?? "", source: .imported)
        if let ds = o["experimentDate"] as? String, let d = ISO8601DateFormatter().date(from: ds) { r.experimentDate = d }
        if let d = o["distanceCentimeters"] as? Double { r.metrics["distance_m"] = d / 100 }
        if let v = o["meanSpeedCentimetersPerSecond"] as? Double { r.metrics["mean_speed_cms"] = v }
        if let v = o["trackedPercent"] as? Double { r.metrics["tracked_pct"] = v }
        if let v = o["yMazeAlternationPercent"] as? Double { r.metrics["alternation_pct"] = v }
        if assay.isMazeAssay, let v = o["armEntryCount"] as? Double { r.metrics["arm_entries"] = v }
        if assay.isMazeAssay, let v = o["armEntryCount"] as? Int { r.metrics["arm_entries"] = Double(v) }
        if let c = o["tMazeFirstChoice"] as? String { r.metrics["right_choice_pct"] = c == "right" ? 100 : 0 }
        if let seq = o["armEntrySequence"] as? [String] { r.labels["arm_sequence"] = seq.joined(separator: " ") }
        r.datasetName = fileName
        r.notes = loc("Imported from a RodentFlow 1.0 summary (center-zone metrics need the full tracking file).")
        return r
    }

    // MARK: Templates

    static func template(for assay: AssayKind) -> String {
        let schema = ManualAssays.schema(for: assay)
        var columns = ["subject", "group", "sex"]
        let rowsAreDays = schema.rowName == "Day"
        if assay.usesDays && !rowsAreDays { columns.append("day") }
        if !assay.phases.isEmpty || assay == .beamWalking { columns.append("phase") }
        var example: [String] = ["M01", "Control", "M"]
        if assay.usesDays && !rowsAreDays { example.append("1") }
        if !assay.phases.isEmpty { example.append(assay.defaultPhase) } else if assay == .beamWalking { example.append("12 mm") }
        switch assay {
        case .twoArmedBandit:
            columns += ["trial", "choice", "reward", "p_left", "p_right", "rt"]
            let prefix = example
            example += ["1", "L", "1", "0.8", "0.2", "0.45"]
            let second = prefix + ["2", "R", "0", "0.8", "0.2", "0.52"]
            return columns.joined(separator: ",") + "\n" + example.joined(separator: ",") + "\n" + second.joined(separator: ",") + "\n"
        case .custom:
            columns += ["my_measure_1", "my_measure_2"]
            example += ["12.3", "4"]
        default:
            if schema.hasRows || !schema.fields.isEmpty {
                for f in schema.fields where f.kind != .text || assay == .yMaze {
                    columns.append(f.key)
                    example.append(exampleValue(f))
                }
                if schema.hasRows {
                    columns.append(schema.rowName.lowercased())
                    example.append("1")
                    for f in schema.rowFields {
                        columns.append(f.key)
                        example.append(exampleValue(f))
                    }
                }
            } else {
                for m in AssayCatalog.metrics(for: assay).prefix(4) {
                    columns.append(m.key)
                    example.append("0")
                }
            }
        }
        return columns.joined(separator: ",") + "\n" + example.joined(separator: ",") + "\n"
    }

    private static func exampleValue(_ f: ManualField) -> String {
        switch f.kind {
        case .choice(let options): return options.last ?? ""
        case .toggle: return "0"
        case .text: return "ABCABACB"
        case .integer: return f.defaultValue.map { String(format: "%.0f", $0) } ?? "3"
        case .number: return f.defaultValue.map { String(format: "%g", $0) } ?? "10.5"
        }
    }
}

extension AssayKind {
    var isMazeAssay: Bool { self == .yMaze || self == .tMaze || self == .elevatedPlusMaze }
}
