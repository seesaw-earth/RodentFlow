import Foundation

// MARK: - Manual entry schema

struct ManualField: Hashable, Identifiable {
    enum Kind: Hashable {
        case number
        case integer
        case toggle
        case choice([String])
        case text
    }

    var key: String
    /// Localized label and help text (written in English in the schema, translated here).
    var label: String
    var unit: String = ""
    /// Choice options stay English: they are the stored/imported values. Display with `loc`.
    var kind: Kind = .number
    var defaultValue: Double?
    var required = false
    var help: String?
    /// English label, kept for matching imported column headers in either language.
    var englishLabel: String

    var id: String { key }

    init(key: String, label: String, unit: String = "", kind: Kind = .number, defaultValue: Double? = nil, required: Bool = false, help: String? = nil) {
        self.key = key
        self.englishLabel = label
        self.label = loc(label)
        self.unit = unit
        self.kind = kind
        self.defaultValue = defaultValue
        self.required = required
        self.help = help.map(loc)
    }
}

struct ManualSchema {
    var fields: [ManualField] = []
    var rowFields: [ManualField] = []
    /// Singular name of a repeated row, e.g. "Trial", "Day", "Stride". Empty = no rows.
    /// English: also used as a CSV template column. Show `displayRowName` in the interface.
    var rowName = ""
    var minRows = 0
    /// Localized footnote.
    var note = ""

    init(fields: [ManualField] = [], rowFields: [ManualField] = [], rowName: String = "", minRows: Int = 0, note: String = "") {
        self.fields = fields
        self.rowFields = rowFields
        self.rowName = rowName
        self.minRows = minRows
        self.note = loc(note)
    }

    var hasRows: Bool { !rowFields.isEmpty }
    var displayRowName: String { loc(rowName) }

    // Row wording, written out per row type so each language can phrase it naturally
    // ("Day 2" / "第 2 天", "Add day" / "添加一天").

    /// Title of one repeated row, `index` counted from 0.
    func rowTitle(_ index: Int) -> String {
        switch rowName {
        case "Day": return locf("Day %ld", index + 1)
        case "Trial": return locf("Trial %ld", index + 1)
        case "CS": return locf("CS %ld", index + 1)
        case "Stride": return locf("Stride %ld", index + 1)
        default: return "\(displayRowName) \(index + 1)"
        }
    }

    var addRowTitle: String {
        switch rowName {
        case "Day": return loc("Add day")
        case "Trial": return loc("Add trial")
        case "CS": return loc("Add CS")
        case "Stride": return loc("Add stride")
        default: return locf("Add %@", displayRowName.lowercased())
        }
    }

    var removeRowTitle: String {
        switch rowName {
        case "Day": return loc("Remove day")
        case "Trial": return loc("Remove trial")
        case "CS": return loc("Remove CS")
        case "Stride": return loc("Remove stride")
        default: return locf("Remove %@", displayRowName.lowercased())
        }
    }

    var duplicateRowTitle: String {
        switch rowName {
        case "Day": return loc("Duplicate last day")
        case "Trial": return loc("Duplicate last trial")
        case "CS": return loc("Duplicate last CS")
        case "Stride": return loc("Duplicate last stride")
        default: return locf("Duplicate last %@", displayRowName.lowercased())
        }
    }

    /// "at least 2 trials"
    func minimumRowsText(_ n: Int) -> String {
        switch rowName {
        case "Day": return locf("at least %ld day(s)", n)
        case "Trial": return locf("at least %ld trial(s)", n)
        case "CS": return locf("at least %ld CS presentation(s)", n)
        case "Stride": return locf("at least %ld stride(s)", n)
        default: return locf("at least %ld %@", n, displayRowName.lowercased())
        }
    }

    /// Label for the number of rows ("Trials", "Days").
    var rowCountTitle: String {
        switch rowName {
        case "Day": return loc("Days")
        case "Trial": return loc("Trials")
        case "CS": return loc("CS presentations")
        case "Stride": return loc("Strides")
        default: return displayRowName
        }
    }
}

enum ManualAssays {
    static func schema(for assay: AssayKind) -> ManualSchema {
        switch assay {
        case .openField:
            return ManualSchema(fields: [
                ManualField(key: "distance_m", label: "Total distance", unit: "m"),
                ManualField(key: "center_time_s", label: "Center time", unit: "s"),
                ManualField(key: "total_time_s", label: "Test duration", unit: "s", defaultValue: 600),
                ManualField(key: "center_entries", label: "Center entries", kind: .integer),
                ManualField(key: "center_latency_s", label: "Latency to center", unit: "s")
            ], note: "Values scored with another tracker or by hand.")
        case .elevatedPlusMaze:
            return ManualSchema(fields: [
                ManualField(key: "open_time_s", label: "Open-arm time", unit: "s", required: true),
                ManualField(key: "closed_time_s", label: "Closed-arm time", unit: "s", required: true),
                ManualField(key: "center_time_s", label: "Center time", unit: "s"),
                ManualField(key: "open_entries", label: "Open-arm entries", kind: .integer),
                ManualField(key: "closed_entries", label: "Closed-arm entries", kind: .integer),
                ManualField(key: "distance_m", label: "Total distance", unit: "m")
            ])
        case .lightDark:
            return ManualSchema(fields: [
                ManualField(key: "light_time_s", label: "Light-box time", unit: "s", required: true),
                ManualField(key: "total_time_s", label: "Test duration", unit: "s", defaultValue: 600, required: true),
                ManualField(key: "transitions", label: "Transitions", kind: .integer),
                ManualField(key: "latency_dark_s", label: "Latency to dark", unit: "s")
            ])
        case .marbleBurying:
            return ManualSchema(fields: [
                ManualField(key: "total_marbles", label: "Marbles in cage", kind: .integer, defaultValue: 20, required: true),
                ManualField(key: "buried", label: "Buried (≥ 2/3 covered)", kind: .integer, required: true),
                ManualField(key: "partial", label: "Partially buried", kind: .integer),
                ManualField(key: "duration_min", label: "Test duration", unit: "min", defaultValue: 30)
            ])
        case .sucrosePreference:
            return ManualSchema(
                fields: [
                    ManualField(key: "body_weight_g", label: "Body weight", unit: "g", help: "Optional — enables intake per kg."),
                    ManualField(key: "sucrose_conc_pct", label: "Sucrose concentration", unit: "%", defaultValue: 1)
                ],
                rowFields: [
                    ManualField(key: "sucrose_start", label: "Sucrose bottle — start", unit: "g", required: true),
                    ManualField(key: "sucrose_end", label: "Sucrose bottle — end", unit: "g", required: true),
                    ManualField(key: "water_start", label: "Water bottle — start", unit: "g", required: true),
                    ManualField(key: "water_end", label: "Water bottle — end", unit: "g", required: true),
                    ManualField(key: "sucrose_leak", label: "Sucrose leak control", unit: "g", help: "Loss from a bottle on an empty cage."),
                    ManualField(key: "water_leak", label: "Water leak control", unit: "g"),
                    ManualField(key: "hours", label: "Measurement period", unit: "h", defaultValue: 24)
                ],
                rowName: "Day", minRows: 1,
                note: "Swap bottle sides between days to control for side preference. Weights in g (≈ mL)."
            )
        case .yMaze:
            return ManualSchema(fields: [
                ManualField(key: "sequence", label: "Arm sequence", kind: .text, required: true, help: "Arms in order of entry, e.g. ABCABACB.")
            ])
        case .tMaze:
            return ManualSchema(fields: [
                ManualField(key: "first_choice", label: "First choice", kind: .choice(["Left", "Right"]), defaultValue: 0, required: true),
                ManualField(key: "left_entries", label: "Left-arm entries", kind: .integer),
                ManualField(key: "right_entries", label: "Right-arm entries", kind: .integer),
                ManualField(key: "choice_latency_s", label: "Choice latency", unit: "s")
            ])
        case .novelObject:
            return ManualSchema(fields: [
                ManualField(key: "novel_time_s", label: "Novel object exploration", unit: "s", required: true),
                ManualField(key: "familiar_time_s", label: "Familiar object exploration", unit: "s", required: true),
                ManualField(key: "novel_bouts", label: "Novel object bouts", kind: .integer),
                ManualField(key: "familiar_bouts", label: "Familiar object bouts", kind: .integer),
                ManualField(key: "min_total_s", label: "Exclusion criterion (total)", unit: "s", defaultValue: 10)
            ], note: "Hand scoring: nose within ~2 cm of and directed at the object.")
        case .morrisWaterMaze:
            return ManualSchema(
                fields: [
                    ManualField(key: "target_quadrant_pct", label: "Probe: target quadrant", unit: "%"),
                    ManualField(key: "opposite_quadrant_pct", label: "Probe: opposite quadrant", unit: "%"),
                    ManualField(key: "platform_crossings", label: "Probe: platform crossings", kind: .integer),
                    ManualField(key: "max_trial_s", label: "Trial maximum", unit: "s", defaultValue: 60)
                ],
                rowFields: [
                    ManualField(key: "latency_s", label: "Escape latency", unit: "s"),
                    ManualField(key: "path_m", label: "Path length", unit: "m"),
                    ManualField(key: "speed_cms", label: "Swim speed", unit: "cm/s")
                ],
                rowName: "Trial",
                note: "Acquisition: one record per animal per day with its trials. Probe: fill the probe fields."
            )
        case .barnesMaze:
            return ManualSchema(
                fields: [
                    ManualField(key: "target_quadrant_pct", label: "Probe: target quadrant", unit: "%")
                ],
                rowFields: [
                    ManualField(key: "primary_latency_s", label: "Primary latency", unit: "s"),
                    ManualField(key: "primary_errors", label: "Primary errors", kind: .integer),
                    ManualField(key: "total_errors", label: "Total errors", kind: .integer),
                    ManualField(key: "path_m", label: "Path length", unit: "m")
                ],
                rowName: "Trial"
            )
        case .fearConditioning:
            return ManualSchema(
                fields: [
                    ManualField(key: "freezing_pct", label: "Freezing (session)", unit: "%"),
                    ManualField(key: "baseline_freezing_pct", label: "Baseline freezing", unit: "%")
                ],
                rowFields: [
                    ManualField(key: "cs_freezing_pct", label: "Freezing during CS", unit: "%"),
                    ManualField(key: "post_cs_freezing_pct", label: "Freezing after CS", unit: "%")
                ],
                rowName: "CS",
                note: "Values from FreezeFrame, VideoFreeze, ezTrack or hand scoring."
            )
        case .beamWalking:
            return ManualSchema(
                fields: [
                    ManualField(key: "beam_width_mm", label: "Beam width", unit: "mm", help: "Optional; use the Beam field for the label.")
                ],
                rowFields: [
                    ManualField(key: "time_s", label: "Traversal time", unit: "s", required: true),
                    ManualField(key: "slips", label: "Foot slips", kind: .integer, defaultValue: 0),
                    ManualField(key: "fell", label: "Fell", kind: .toggle, defaultValue: 0)
                ],
                rowName: "Trial", minRows: 1
            )
        case .gait:
            return ManualSchema(
                fields: [
                    ManualField(key: "run_duration_s", label: "Run duration", unit: "s", help: "Optional — for cadence and speed."),
                    ManualField(key: "run_distance_cm", label: "Run distance", unit: "cm")
                ],
                rowFields: [
                    ManualField(key: "side", label: "Side", kind: .choice(["—", "Left", "Right"]), defaultValue: 0),
                    ManualField(key: "hind_stride_cm", label: "Hind stride length", unit: "cm"),
                    ManualField(key: "fore_stride_cm", label: "Fore stride length", unit: "cm"),
                    ManualField(key: "hind_base_cm", label: "Hind base width", unit: "cm"),
                    ManualField(key: "fore_base_cm", label: "Fore base width", unit: "cm"),
                    ManualField(key: "overlap_cm", label: "Paw overlap", unit: "cm")
                ],
                rowName: "Stride", minRows: 1,
                note: "Footprint test: measure consecutive strides in the middle of the run, skipping the first and last steps."
            )
        case .placePreference:
            return ManualSchema(fields: [
                ManualField(key: "paired_time_s", label: "Paired chamber time", unit: "s", required: true),
                ManualField(key: "unpaired_time_s", label: "Unpaired chamber time", unit: "s", required: true),
                ManualField(key: "neutral_time_s", label: "Neutral chamber time", unit: "s"),
                ManualField(key: "paired_entries", label: "Paired chamber entries", kind: .integer)
            ])
        case .twoArmedBandit:
            return ManualSchema(
                fields: [],
                rowFields: [
                    ManualField(key: "choice", label: "Choice", kind: .choice(["Left", "Right"]), defaultValue: 0, required: true),
                    ManualField(key: "reward", label: "Rewarded", kind: .toggle, defaultValue: 0, required: true),
                    ManualField(key: "p_left", label: "P(reward | left)", help: "Optional, 0–1."),
                    ManualField(key: "p_right", label: "P(reward | right)", help: "Optional, 0–1."),
                    ManualField(key: "rt_s", label: "Reaction time", unit: "s")
                ],
                rowName: "Trial", minRows: 2,
                note: "Usually imported from a trial CSV (columns: choice, reward, optional p_left, p_right, rt)."
            )
        case .custom:
            return ManualSchema()
        }
    }

    // MARK: Compute

    static func compute(assay: AssayKind, phase: String, input: ManualInput) -> AssayComputation {
        var out = AssayComputation()
        let v = input.values
        func rowValues(_ key: String) -> [Double] { input.rows.compactMap { $0.values[key] }.filter { $0.isFinite } }
        func mean(_ key: String) -> Double? {
            let x = rowValues(key)
            return x.isEmpty ? nil : Stats.mean(x)
        }

        switch assay {
        case .openField:
            out.set("distance_m", v["distance_m"])
            out.set("center_time_s", v["center_time_s"])
            if let total = v["total_time_s"], total > 0 {
                if let c = v["center_time_s"] { out.set("center_time_pct", c / total * 100) }
                if let d = v["distance_m"] { out.set("mean_speed_cms", d * 100 / total) }
            }
            out.set("center_entries", v["center_entries"])
            out.set("center_latency_s", v["center_latency_s"])

        case .elevatedPlusMaze:
            let open = v["open_time_s"], closed = v["closed_time_s"]
            out.set("open_time_s", open)
            out.set("closed_time_s", closed)
            out.set("center_time_s", v["center_time_s"])
            if let open, let closed { out.set("open_time_pct", AssayEngine.pct(open, open + closed)) }
            out.set("open_entries", v["open_entries"])
            out.set("closed_entries", v["closed_entries"])
            if let oe = v["open_entries"], let ce = v["closed_entries"] {
                out.set("total_entries", oe + ce)
                out.set("open_entries_pct", AssayEngine.pct(oe, oe + ce))
            }
            out.set("distance_m", v["distance_m"])

        case .lightDark:
            if let light = v["light_time_s"], let total = v["total_time_s"], total > 0 {
                out.set("light_time_s", light)
                out.set("dark_time_s", max(0, total - light))
                out.set("light_time_pct", light / total * 100)
            }
            out.set("transitions", v["transitions"])
            out.set("latency_dark_s", v["latency_dark_s"])

        case .marbleBurying:
            if let total = v["total_marbles"], total > 0, let buried = v["buried"] {
                out.set("buried_count", buried)
                out.set("buried_pct", buried / total * 100)
                if buried > total { out.qcFlags.append(loc("More marbles buried than present — check the counts.")) }
            }
            out.set("partial_count", v["partial"])
            if let d = v["duration_min"] { out.param("duration_min", d, decimals: 0) }

        case .sucrosePreference:
            var sucroseTotal = 0.0, waterTotal = 0.0, days = 0.0
            var daily: [Double] = []
            var dayIndex: [Double] = []
            for (i, row) in input.rows.enumerated() {
                let r = row.values
                guard let ss = r["sucrose_start"], let se = r["sucrose_end"], let ws = r["water_start"], let we = r["water_end"] else { continue }
                let sucrose = ss - se - (r["sucrose_leak"] ?? 0)
                let water = ws - we - (r["water_leak"] ?? 0)
                if sucrose < 0 || water < 0 { out.qcFlags.append(locf("Day %ld: negative intake — check bottle weights.", i + 1)) }
                let hours = (r["hours"] ?? 24) > 0 ? (r["hours"] ?? 24) : 24
                sucroseTotal += max(0, sucrose)
                waterTotal += max(0, water)
                days += hours / 24
                if sucrose + water > 0 {
                    daily.append(max(0, sucrose) / (max(0, sucrose) + max(0, water)) * 100)
                    dayIndex.append(Double(i + 1))
                }
            }
            if days > 0 {
                out.set("preference_pct", AssayEngine.pct(sucroseTotal, sucroseTotal + waterTotal))
                out.set("sucrose_intake_g_day", sucroseTotal / days)
                out.set("water_intake_g_day", waterTotal / days)
                out.set("total_intake_g_day", (sucroseTotal + waterTotal) / days)
                if let bw = v["body_weight_g"], bw > 0 { out.set("sucrose_intake_g_kg_day", sucroseTotal / days / (bw / 1000)) }
                if (sucroseTotal + waterTotal) / days < 1 { out.qcFlags.append(loc("Total intake below 1 g/day — possible leak or measurement error.")) }
            }
            if !daily.isEmpty {
                out.set("mean_daily_preference_pct", Stats.mean(daily))
                if daily.count >= 2 {
                    out.addSeries("preference_by_day", "Preference per day", unit: "%", xLabel: "Day", x: dayIndex, y: daily)
                }
            }
            if let c = v["sucrose_conc_pct"] { out.param("sucrose_concentration_pct", c, decimals: 1) }

        case .yMaze:
            let raw = (input.text["sequence"] ?? "").uppercased()
            let seq = raw.compactMap { ch -> String? in ["A", "B", "C"].contains(String(ch)) ? String(ch) : nil }
            out.set("arm_entries", Double(seq.count))
            if seq.count >= 3 {
                var ok = 0
                for i in 2..<seq.count where Set([seq[i - 2], seq[i - 1], seq[i]]).count == 3 { ok += 1 }
                out.set("alternations", Double(ok))
                out.set("alternation_pct", Double(ok) / Double(seq.count - 2) * 100)
            }
            out.labels["arm_sequence"] = seq.joined()

        case .tMaze:
            if let choice = v["first_choice"] {
                out.set("right_choice_pct", choice >= 0.5 ? 100 : 0)
                out.labels["first_choice"] = choice >= 0.5 ? "right" : "left"
            }
            out.set("left_entries", v["left_entries"])
            out.set("right_entries", v["right_entries"])
            if let l = v["left_entries"], let r = v["right_entries"] { out.set("arm_entries", l + r) }
            out.set("choice_latency_s", v["choice_latency_s"])

        case .novelObject:
            if let n = v["novel_time_s"], let f = v["familiar_time_s"] {
                out.set("novel_time_s", n)
                out.set("familiar_time_s", f)
                out.set("total_exploration_s", n + f)
                if n + f > 0 {
                    out.set("discrimination_index", (n - f) / (n + f))
                    out.set("recognition_index_pct", n / (n + f) * 100)
                }
                let criterion = v["min_total_s"] ?? 10
                if n + f < criterion {
                    out.qcFlags.append(locf("Low exploration: %.1f s total (criterion %.0f s).", n + f, criterion))
                }
            }
            out.set("novel_bouts", v["novel_bouts"])
            out.set("familiar_bouts", v["familiar_bouts"])

        case .morrisWaterMaze:
            if let latency = mean("latency_s") {
                out.set("escape_latency_s", latency)
                let maxTrial = v["max_trial_s"] ?? 60
                let latencies = rowValues("latency_s")
                out.set("found_platform_pct", Double(latencies.filter { $0 < maxTrial }.count) / Double(latencies.count) * 100)
                out.addSeries("latency_by_trial", "Latency per trial", unit: "s", xLabel: "Trial",
                              x: input.rows.indices.map { Double($0 + 1) }, y: input.rows.map { $0.values["latency_s"] ?? .nan })
            }
            out.set("path_length_m", mean("path_m"))
            out.set("swim_speed_cms", mean("speed_cms"))
            out.set("target_quadrant_pct", v["target_quadrant_pct"])
            out.set("opposite_quadrant_pct", v["opposite_quadrant_pct"])
            out.set("platform_crossings", v["platform_crossings"])
            if input.rows.count > 1 { out.parameters["trials_averaged"] = "\(input.rows.count)" }

        case .barnesMaze:
            out.set("primary_latency_s", mean("primary_latency_s"))
            out.set("primary_errors", mean("primary_errors"))
            out.set("total_errors", mean("total_errors"))
            out.set("path_length_m", mean("path_m"))
            out.set("target_quadrant_pct", v["target_quadrant_pct"])
            if input.rows.count > 1 { out.parameters["trials_averaged"] = "\(input.rows.count)" }

        case .fearConditioning:
            out.set("freezing_pct", v["freezing_pct"])
            out.set("baseline_freezing_pct", v["baseline_freezing_pct"])
            let cs = rowValues("cs_freezing_pct")
            if !cs.isEmpty {
                out.set("cs_freezing_pct", Stats.mean(cs))
                out.addSeries("freezing_by_cs", "Freezing per CS", unit: "%", xLabel: "CS",
                              x: input.rows.indices.map { Double($0 + 1) }, y: input.rows.map { $0.values["cs_freezing_pct"] ?? .nan })
            }
            out.set("iti_freezing_pct", mean("post_cs_freezing_pct"))

        case .beamWalking:
            let times = rowValues("time_s")
            out.set("traversal_time_s", times.isEmpty ? nil : Stats.mean(times))
            let slips = input.rows.map { $0.values["slips"] ?? 0 }
            if !input.rows.isEmpty {
                out.set("slips_per_trial", Stats.mean(slips))
                out.set("total_slips", slips.reduce(0, +))
                out.set("fall_pct", Double(input.rows.filter { ($0.values["fell"] ?? 0) >= 0.5 }.count) / Double(input.rows.count) * 100)
                out.set("trial_count", Double(input.rows.count))
                out.addSeries("time_by_trial", "Traversal time per trial", unit: "s", xLabel: "Trial",
                              x: input.rows.indices.map { Double($0 + 1) }, y: input.rows.map { $0.values["time_s"] ?? .nan })
            }
            if let w = v["beam_width_mm"] { out.param("beam_width_mm", w, decimals: 0) }

        case .gait:
            for key in ["hind_stride_cm", "fore_stride_cm", "hind_base_cm", "fore_base_cm", "overlap_cm"] {
                out.set(key, mean(key))
            }
            let hind = rowValues("hind_stride_cm")
            if hind.count >= 2, let m = mean("hind_stride_cm"), m > 0 {
                out.set("hind_stride_cv_pct", Stats.sd(hind) / m * 100)
            }
            let left = input.rows.filter { ($0.values["side"] ?? 0) == 1 }.compactMap { $0.values["hind_stride_cm"] }
            let right = input.rows.filter { ($0.values["side"] ?? 0) == 2 }.compactMap { $0.values["hind_stride_cm"] }
            if !left.isEmpty && !right.isEmpty {
                let l = Stats.mean(left), r = Stats.mean(right)
                if l + r > 0 { out.set("hind_stride_asymmetry_pct", abs(l - r) / ((l + r) / 2) * 100) }
            }
            if let d = v["run_duration_s"], d > 0 {
                out.set("cadence_strides_s", Double(input.rows.count) / d)
                if let dist = v["run_distance_cm"] { out.set("speed_cms", dist / d) }
            }
            out.parameters["strides_measured"] = "\(input.rows.count)"

        case .placePreference:
            if let p = v["paired_time_s"], let u = v["unpaired_time_s"] {
                out.set("paired_time_s", p)
                out.set("unpaired_time_s", u)
                out.set("preference_score_s", p - u)
                out.set("preference_pct", AssayEngine.pct(p, p + u))
            }
            out.set("neutral_time_s", v["neutral_time_s"])
            out.set("paired_entries", v["paired_entries"])

        case .twoArmedBandit:
            out = Bandit.analyze(input.rows)

        case .custom:
            break
        }
        return out
    }

    /// Fields that must be filled before the record can be saved.
    static func missingRequired(assay: AssayKind, input: ManualInput) -> [String] {
        let s = schema(for: assay)
        var missing: [String] = []
        for f in s.fields where f.required {
            switch f.kind {
            case .text:
                if (input.text[f.key] ?? "").trimmingCharacters(in: .whitespaces).isEmpty { missing.append(f.label) }
            default:
                if input.values[f.key] == nil { missing.append(f.label) }
            }
        }
        if s.hasRows {
            if input.rows.count < s.minRows { missing.append(s.minimumRowsText(s.minRows)) }
            for (i, row) in input.rows.enumerated() {
                for f in s.rowFields where f.required && row.values[f.key] == nil {
                    missing.append(s.rowTitle(i) + ": " + f.label)
                }
            }
        }
        return missing
    }
}

// MARK: - Two-armed bandit

enum Bandit {
    struct Trial {
        var choice: Int      // 0 = left, 1 = right
        var reward: Double   // 0 / 1 (or reward magnitude)
        var pLeft: Double?
        var pRight: Double?
        var rt: Double?
    }

    static func trials(_ rows: [ManualRow]) -> [Trial] {
        rows.compactMap { row in
            guard let c = row.values["choice"], let r = row.values["reward"] else { return nil }
            return Trial(choice: c >= 0.5 ? 1 : 0, reward: r, pLeft: row.values["p_left"], pRight: row.values["p_right"], rt: row.values["rt_s"])
        }
    }

    static func analyze(_ rows: [ManualRow]) -> AssayComputation {
        var out = AssayComputation()
        let t = trials(rows)
        guard t.count >= 2 else {
            out.qcFlags.append(loc("Need at least 2 trials with choice and reward."))
            return out
        }
        let n = Double(t.count)
        out.set("trial_count", n)
        out.set("reward_rate_pct", t.reduce(0) { $0 + ($1.reward > 0 ? 1 : 0) } / n * 100)
        out.set("right_choice_pct", Double(t.filter { $0.choice == 1 }.count) / n * 100)

        var stayAfterWin = 0.0, wins = 0.0, shiftAfterLoss = 0.0, losses = 0.0, switches = 0.0
        for i in 1..<t.count {
            let switched = t[i].choice != t[i - 1].choice
            if switched { switches += 1 }
            if t[i - 1].reward > 0 {
                wins += 1
                if !switched { stayAfterWin += 1 }
            } else {
                losses += 1
                if switched { shiftAfterLoss += 1 }
            }
        }
        out.set("win_stay_pct", AssayEngine.pct(stayAfterWin, wins))
        out.set("lose_shift_pct", AssayEngine.pct(shiftAfterLoss, losses))
        out.set("switch_rate_pct", switches / (n - 1) * 100)

        // High-value choices and reversal-aligned behavior when probabilities are provided.
        var highChosen = 0.0, informative = 0.0
        var highSide: [Int?] = []
        for trial in t {
            if let pl = trial.pLeft, let pr = trial.pRight, pl != pr {
                let high = pr > pl ? 1 : 0
                highSide.append(high)
                informative += 1
                if trial.choice == high { highChosen += 1 }
            } else {
                highSide.append(nil)
            }
        }
        if informative > 0 { out.set("p_high_pct", highChosen / informative * 100) }

        var switchPoints: [Int] = []
        var lastHigh: Int?
        for (i, h) in highSide.enumerated() {
            guard let h else { continue }
            if let lastHigh, lastHigh != h { switchPoints.append(i) }
            lastHigh = h
        }
        if !switchPoints.isEmpty {
            let offsets = Array(-5...20)
            var ys: [Double] = []
            for off in offsets {
                var hits = 0.0, count = 0.0
                for sp in switchPoints {
                    let i = sp + off
                    guard i >= 0, i < t.count, let newHigh = highSide[sp] else { continue }
                    count += 1
                    if t[i].choice == newHigh { hits += 1 }
                }
                ys.append(count > 0 ? hits / count * 100 : .nan)
            }
            out.addSeries("p_new_high_by_reversal", "Choice of the new best arm around reversals", unit: "%",
                          xLabel: "Trials from reversal", x: offsets.map(Double.init), y: ys)
            out.parameters["reversals"] = "\(switchPoints.count)"
        }

        let rts = t.compactMap(\.rt).filter { $0.isFinite }
        if !rts.isEmpty { out.set("mean_rt_s", Stats.mean(rts)) }

        if let fit = fitQLearning(t) {
            out.set("q_alpha", fit.alpha)
            out.set("q_beta", fit.beta)
            out.set("q_pseudo_r2", 1 - fit.nll / (n * log(2.0)))
            out.param("q_nll", fit.nll, decimals: 2)
            out.param("q_bic", 2 * fit.nll + 2 * log(n), decimals: 2)
        }
        out.parameters["model"] = loc("Q-learning, chosen-arm update, softmax; Q0 = 0.5; α ∈ (0, 1), β ∈ (0, 50]")
        return out
    }

    static func negativeLogLikelihood(_ t: [Trial], alpha: Double, beta: Double) -> Double {
        var q = [0.5, 0.5]
        var nll = 0.0
        for trial in t {
            let diff = beta * (q[1] - q[0])
            // log P(choice) with a numerically stable log-sigmoid.
            let logitChosen = trial.choice == 1 ? diff : -diff
            nll += logitChosen >= 0 ? log1p(exp(-logitChosen)) : -logitChosen + log1p(exp(logitChosen))
            let r = trial.reward > 0 ? 1.0 : 0.0
            q[trial.choice] += alpha * (r - q[trial.choice])
        }
        return nll
    }

    static func fitQLearning(_ t: [Trial]) -> (alpha: Double, beta: Double, nll: Double)? {
        guard t.count >= 10 else { return nil }
        var best = (alpha: 0.5, beta: 1.0, nll: Double.infinity)
        let alphas = stride(from: 0.02, through: 0.98, by: 0.04).map { $0 }
        let betas = (0..<30).map { 0.1 * pow(500.0, Double($0) / 29.0) } // 0.1 … 50, log-spaced
        for a in alphas {
            for b in betas {
                let v = negativeLogLikelihood(t, alpha: a, beta: b)
                if v < best.nll { best = (a, b, v) }
            }
        }
        // Local refinement by shrinking coordinate search.
        var stepA = 0.04, stepLogB = log(500.0) / 29
        for _ in 0..<40 {
            var improved = false
            let candidates = [
                (best.alpha + stepA, best.beta), (best.alpha - stepA, best.beta),
                (best.alpha, best.beta * exp(stepLogB)), (best.alpha, best.beta * exp(-stepLogB))
            ]
            for (a, b) in candidates where a > 0.001 && a < 0.999 && b > 0.01 && b <= 50 {
                let v = negativeLogLikelihood(t, alpha: a, beta: b)
                if v < best.nll - 1e-12 {
                    best = (a, b, v)
                    improved = true
                }
            }
            if !improved {
                stepA /= 2
                stepLogB /= 2
                if stepA < 1e-5 { break }
            }
        }
        return best.nll.isFinite ? best : nil
    }
}
