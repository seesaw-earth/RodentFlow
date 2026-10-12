import Foundation

// MARK: - Localization
//
// The English text is the lookup key in Localizable.xcstrings (Simplified Chinese is the second
// language). SwiftUI string literals (`Text("Save")`, `Button("Cancel")`) are looked up by SwiftUI
// itself; every other user-facing string goes through `loc` / `locf`. Values that are stored or
// exported (assay ids, phases, metric keys, CSV columns) stay English so files are identical
// whatever language the phone uses.

/// Translation of `key` for the app's current language; the key itself (English) if there is none.
func loc(_ key: String) -> String {
    key.isEmpty ? key : NSLocalizedString(key, comment: "")
}

/// Translated printf-style format, e.g. `locf("Day %ld: negative intake", day)`.
func locf(_ key: String, _ args: CVarArg...) -> String {
    String(format: loc(key), arguments: args)
}

/// For a short English word that needs different translations in different places ("Groups"
/// the tab vs. "Groups" the list of groups): looks up a context key such as "tab.groups" and
/// falls back to the English text.
func loc(_ english: String, context key: String) -> String {
    let translated = NSLocalizedString(key, comment: "")
    return translated == key ? english : translated
}

/// Display title for a stored identifier such as a parameter key: the translation if there is
/// one, otherwise the key with spaces ("light_side" → "light side" in English, "明箱位置" in Chinese).
func locKey(_ key: String, capitalized: Bool = false) -> String {
    let translated = loc(key)
    if translated != key { return translated }
    let plain = key.replacingOccurrences(of: "_", with: " ")
    return capitalized ? plain.capitalized : plain
}

// MARK: - Assay catalog
//
// One place that defines, for every behavioral paradigm, where its data can come from,
// which per-animal readouts it produces, how each readout is defined, and how it is
// usually compared between groups. Both tabs (single experiment and group analysis)
// read from this catalog so names, units and definitions stay consistent.

enum AssayCategory: String, CaseIterable, Codable, Identifiable {
    case anxiety = "Anxiety & affect"
    case memory = "Learning & memory"
    case motor = "Motor function"
    case reward = "Reward & decision"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String { loc(rawValue) }
}

enum AssayKind: String, Codable, CaseIterable, Identifiable {
    case openField = "open_field"
    case elevatedPlusMaze = "elevated_plus_maze"
    case lightDark = "light_dark_box"
    case marbleBurying = "marble_burying"
    case sucrosePreference = "sucrose_preference"
    case yMaze = "y_maze"
    case tMaze = "t_maze"
    case novelObject = "novel_object_recognition"
    case morrisWaterMaze = "morris_water_maze"
    case barnesMaze = "barnes_maze"
    case fearConditioning = "fear_conditioning"
    case beamWalking = "beam_walking"
    case gait = "gait_analysis"
    case placePreference = "conditioned_place_preference"
    case twoArmedBandit = "two_armed_bandit"
    case custom = "custom"

    var id: String { rawValue }

    /// Robust decoding: unknown raw values from a newer build fall back to `.custom`.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = AssayKind(rawValue: raw) ?? .custom
    }

    /// Localized assay name for the interface.
    var displayName: String { loc(englishName) }

    /// English assay name (stable; used as the translation key).
    var englishName: String {
        switch self {
        case .openField: return "Open Field / Center"
        case .elevatedPlusMaze: return "Elevated Plus Maze"
        case .lightDark: return "Light–Dark Box"
        case .marbleBurying: return "Marble Burying"
        case .sucrosePreference: return "Sucrose Preference"
        case .yMaze: return "Y-Maze"
        case .tMaze: return "T-Maze"
        case .novelObject: return "Novel Object Recognition"
        case .morrisWaterMaze: return "Morris Water Maze"
        case .barnesMaze: return "Barnes Maze"
        case .fearConditioning: return "Fear Conditioning"
        case .beamWalking: return "Beam Walking"
        case .gait: return "Gait Analysis"
        case .placePreference: return "Conditioned Place Preference"
        case .twoArmedBandit: return "Two-Armed Bandit"
        case .custom: return "Other / Custom Table"
        }
    }

    /// Localized abbreviation for the interface. File names keep the English `shortName`.
    var displayShortName: String { loc(shortName) }

    /// English abbreviation, also used in exported file names.
    var shortName: String {
        switch self {
        case .openField: return "OF"
        case .elevatedPlusMaze: return "EPM"
        case .lightDark: return "LDB"
        case .marbleBurying: return "Marbles"
        case .sucrosePreference: return "SPT"
        case .yMaze: return "Y-Maze"
        case .tMaze: return "T-Maze"
        case .novelObject: return "NOR"
        case .morrisWaterMaze: return "MWM"
        case .barnesMaze: return "Barnes"
        case .fearConditioning: return "Fear"
        case .beamWalking: return "Beam"
        case .gait: return "Gait"
        case .placePreference: return "CPP"
        case .twoArmedBandit: return "Bandit"
        case .custom: return "Custom"
        }
    }

    var category: AssayCategory {
        switch self {
        case .openField, .elevatedPlusMaze, .lightDark, .marbleBurying, .sucrosePreference: return .anxiety
        case .yMaze, .tMaze, .novelObject, .morrisWaterMaze, .barnesMaze, .fearConditioning: return .memory
        case .beamWalking, .gait: return .motor
        case .placePreference, .twoArmedBandit: return .reward
        case .custom: return .other
        }
    }

    var systemImage: String {
        switch self {
        case .openField: return "square.dashed"
        case .elevatedPlusMaze: return "plus"
        case .lightDark: return "circle.lefthalf.filled"
        case .marbleBurying: return "circle.grid.3x3.fill"
        case .sucrosePreference: return "drop.fill"
        case .yMaze, .tMaze: return "arrow.triangle.branch"
        case .novelObject: return "cube"
        case .morrisWaterMaze: return "water.waves"
        case .barnesMaze: return "circle.dotted"
        case .fearConditioning: return "bolt.heart"
        case .beamWalking: return "figure.walk"
        case .gait: return "pawprint"
        case .placePreference: return "rectangle.split.3x1"
        case .twoArmedBandit: return "dice"
        case .custom: return "tablecells"
        }
    }

    /// Arena shapes that the on-device tracker supports for this assay (empty = no video tracking).
    var videoArenaShapes: [ArenaShape] {
        switch self {
        case .openField, .novelObject: return [.rectangle, .circle]
        case .elevatedPlusMaze: return [.plusMaze]
        case .lightDark, .placePreference, .fearConditioning: return [.rectangle]
        case .morrisWaterMaze, .barnesMaze: return [.circle]
        case .yMaze: return [.yMaze]
        case .tMaze: return [.tMaze]
        case .marbleBurying, .sucrosePreference, .beamWalking, .gait, .twoArmedBandit, .custom: return []
        }
    }

    var supportsVideo: Bool { !videoArenaShapes.isEmpty }
    var supportsManualEntry: Bool { self != .custom }

    /// Fixed phase/session labels. Empty means the phase field is optional free text.
    /// These English values are what is stored and exported; show them with `AssayKind.phaseTitle`.
    var phases: [String] {
        switch self {
        case .novelObject: return ["Training", "Test"]
        case .morrisWaterMaze: return ["Acquisition", "Probe"]
        case .barnesMaze: return ["Acquisition", "Probe"]
        case .fearConditioning: return ["Training", "Context test", "Cue test"]
        case .placePreference: return ["Pre-test", "Conditioning", "Test"]
        default: return []
        }
    }

    var phaseLabel: String {
        switch self {
        case .beamWalking: return loc("Beam")
        case .twoArmedBandit: return loc("Session / block")
        default: return loc("Phase")
        }
    }

    /// Display text for a stored phase value ("Probe" → "探索测试" in Chinese). Free-text phases
    /// typed by the user have no translation and are shown as entered.
    static func phaseTitle(_ phase: String) -> String { loc(phase) }

    /// Whether a "Day" factor is natural for this assay (learning curves across days).
    var usesDays: Bool {
        switch self {
        case .morrisWaterMaze, .barnesMaze, .beamWalking, .twoArmedBandit, .placePreference, .custom: return true
        default: return false
        }
    }

    var usesTrials: Bool {
        switch self {
        case .morrisWaterMaze, .barnesMaze, .tMaze: return true
        default: return false
        }
    }

    var defaultPhase: String { phases.last ?? "" }

    /// Phase analyzed by default in the Groups tab (different phases should not be pooled).
    var analysisDefaultPhase: String? {
        switch self {
        case .novelObject, .placePreference: return "Test"
        case .morrisWaterMaze, .barnesMaze: return "Acquisition"
        case .fearConditioning: return "Cue test"
        default: return nil
        }
    }

    func primaryMetricKey(phase: String) -> String {
        switch self {
        case .openField: return "distance_m"
        case .elevatedPlusMaze: return "open_time_pct"
        case .lightDark: return "light_time_pct"
        case .marbleBurying: return "buried_pct"
        case .sucrosePreference: return "preference_pct"
        case .yMaze: return "alternation_pct"
        case .tMaze: return "right_choice_pct"
        case .novelObject: return "discrimination_index"
        case .morrisWaterMaze: return phase == "Probe" ? "target_quadrant_pct" : "escape_latency_s"
        case .barnesMaze: return phase == "Probe" ? "target_quadrant_pct" : "primary_latency_s"
        case .fearConditioning: return phase == "Cue test" ? "cs_freezing_pct" : "freezing_pct"
        case .beamWalking: return "traversal_time_s"
        case .gait: return "hind_stride_cm"
        case .placePreference: return "preference_score_s"
        case .twoArmedBandit: return "p_high_pct"
        case .custom: return ""
        }
    }

    var metrics: [MetricDefinition] { AssayCatalog.metrics(for: self) }

    func metric(_ key: String) -> MetricDefinition? { metrics.first { $0.key == key } }

    /// Within-animal comparisons that are standard for this assay.
    var withinPairs: [MetricPair] {
        switch self {
        case .novelObject:
            return [MetricPair(key: "novel_vs_familiar", name: loc("Novel vs familiar exploration"),
                               metricA: "novel_time_s", metricB: "familiar_time_s", labelA: loc("Novel"), labelB: loc("Familiar"))]
        case .placePreference:
            return [MetricPair(key: "paired_vs_unpaired", name: loc("Paired vs unpaired side"),
                               metricA: "paired_time_s", metricB: "unpaired_time_s", labelA: loc("Paired"), labelB: loc("Unpaired"))]
        case .sucrosePreference:
            return [MetricPair(key: "sucrose_vs_water", name: loc("Sucrose vs water intake"),
                               metricA: "sucrose_intake_g_day", metricB: "water_intake_g_day", labelA: loc("Sucrose"), labelB: loc("Water"))]
        case .morrisWaterMaze, .barnesMaze:
            return [MetricPair(key: "target_vs_opposite", name: loc("Target vs opposite quadrant"),
                               metricA: "target_quadrant_pct", metricB: "opposite_quadrant_pct", labelA: loc("Target"), labelB: loc("Opposite"))]
        case .fearConditioning:
            return [MetricPair(key: "baseline_vs_cs", name: loc("Baseline vs CS freezing"),
                               metricA: "baseline_freezing_pct", metricB: "cs_freezing_pct", labelA: loc("Baseline"), labelB: loc("CS"))]
        case .elevatedPlusMaze:
            return [MetricPair(key: "open_vs_closed", name: loc("Open vs closed arm time"),
                               metricA: "open_time_s", metricB: "closed_time_s", labelA: loc("Open"), labelB: loc("Closed"))]
        default:
            return []
        }
    }

    /// Short statement for Methods sections and for the in-app "How is this computed?" sheet.
    var methodsNote: String {
        switch self {
        case .openField:
            return loc("Body-centroid tracking at 10 Hz. The center zone is a concentric square (or circle) whose side (or radius) is a set fraction of the arena. Zone times use detected samples only.")
        case .elevatedPlusMaze:
            return loc("Centroid tracking on a calibrated plus-maze. An arm entry requires the centroid to leave the central square and stay in the arm for the entry criterion. Open-arm % = open / (open + closed).")
        case .lightDark:
            return loc("The light compartment is defined by a divider line in arena coordinates. If the dark box is covered, samples where the mouse is not visible are counted as dark.")
        case .marbleBurying:
            return loc("Marbles counted as buried when at least two-thirds covered by bedding (scored by the experimenter).")
        case .sucrosePreference:
            return loc("Intake = bottle weight before − after − leak control. Preference = sucrose / (sucrose + water) × 100, pooled across measurement days.")
        case .yMaze:
            return loc("Arm entries require 0.25 s of stable centroid occupancy. Alternation % = consecutive triplets of three different arms / (entries − 2) × 100.")
        case .tMaze:
            return loc("Arm entries require stable centroid occupancy. First choice is the first choice-arm entry.")
        case .novelObject:
            return loc("Exploration is approximated as the body centroid within the object interaction zone (radius set by the user). Nose-directed scoring by hand can be entered manually instead. DI = (novel − familiar) / (novel + familiar).")
        case .morrisWaterMaze:
            return loc("Escape = centroid within the platform zone for at least the stay criterion. Quadrants are 90° sectors centered on the platform direction. Mean distance to platform = Gallagher proximity.")
        case .barnesMaze:
            return loc("Holes are placed evenly around the ring defined by the target hole. A hole visit = centroid within the hole zone for the entry criterion. Errors are visits to non-target holes before the first target visit (body-centroid proxy for nose pokes).")
        case .fearConditioning:
            return loc("Motion index = fraction of arena pixels changing between consecutive 10 Hz frames, normalized to the median mouse body area. Freezing = motion below threshold for at least the minimum bout duration. Validate the threshold against hand-scored clips.")
        case .beamWalking:
            return loc("Per-trial traversal time and foot slips are entered by the experimenter and averaged per animal.")
        case .gait:
            return loc("Footprint measurements are averaged per animal; variability is reported as the coefficient of variation.")
        case .placePreference:
            return loc("Chamber times from centroid tracking. Preference score = paired − unpaired time; CPP score = test − pre-test (computed in group analysis).")
        case .twoArmedBandit:
            return loc("Trial-by-trial choices and rewards. Win-stay = P(repeat | rewarded); lose-shift = P(switch | unrewarded). Q-learning (α, β) fitted by maximum likelihood with a softmax choice rule.")
        case .custom:
            return loc("Values imported from a table; metric names come from the column headers.")
        }
    }
}

// MARK: - Metric definitions

struct MetricDefinition: Codable, Hashable, Identifiable {
    var key: String
    /// Localized name and definition (catalog entries are written in English and translated here).
    var name: String
    var unit: String
    var definition: String
    /// Reference value for an optional one-sample test (e.g. DI vs 0, quadrant vs 25%).
    var chance: Double?
    var decimals: Int
    /// English name, kept for matching imported column headers in either language.
    var englishName: String?

    var id: String { key }

    init(_ key: String, _ name: String, _ unit: String, _ definition: String, chance: Double? = nil, decimals: Int = 1) {
        self.key = key
        self.englishName = name
        self.name = loc(name)
        self.unit = unit
        self.definition = loc(definition)
        self.chance = chance
        self.decimals = decimals
    }

    var axisTitle: String { unit.isEmpty ? name : "\(name) (\(unit))" }

    func format(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        let number = String(format: "%.\(decimals)f", value)
        switch unit {
        case "": return number
        case "%": return number + "%"
        default: return number + " " + unit
        }
    }
}

struct MetricPair: Codable, Hashable, Identifiable {
    var key: String
    var name: String
    var metricA: String
    var metricB: String
    var labelA: String
    var labelB: String
    var id: String { key }
}

enum AssayCatalog {
    static func metrics(for assay: AssayKind) -> [MetricDefinition] {
        switch assay {
        case .openField:
            return [
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps between consecutive detected samples.", decimals: 2),
                MetricDefinition("mean_speed_cms", "Mean speed", "cm/s", "Total distance / analyzed duration.", decimals: 2),
                MetricDefinition("mobile_time_pct", "Mobile time", "%", "Time with speed ≥ moving threshold / time with known speed."),
                MetricDefinition("immobile_time_s", "Immobility", "s", "Sum of bouts with speed below threshold lasting at least the minimum duration."),
                MetricDefinition("center_time_s", "Center time", "s", "Time with the centroid inside the center zone."),
                MetricDefinition("center_time_pct", "Center time", "%", "Center time / detected time × 100."),
                MetricDefinition("center_entries", "Center entries", "", "Periphery → center transitions meeting the entry criterion.", decimals: 0),
                MetricDefinition("center_latency_s", "Latency to center", "s", "Time to the first center entry (analysis duration if never)."),
                MetricDefinition("center_distance_pct", "Center distance", "%", "Distance traveled inside the center zone / total distance × 100."),
                MetricDefinition("tracked_pct", "Tracked samples", "%", "Samples with a detected mouse / all samples.")
            ]
        case .elevatedPlusMaze:
            return [
                MetricDefinition("open_time_pct", "Open-arm time", "%", "Open / (open + closed) arm time × 100."),
                MetricDefinition("open_entries_pct", "Open-arm entries", "%", "Open / (open + closed) arm entries × 100."),
                MetricDefinition("open_time_s", "Open-arm time", "s", "Time in both open arms."),
                MetricDefinition("closed_time_s", "Closed-arm time", "s", "Time in both closed arms."),
                MetricDefinition("center_time_s", "Center time", "s", "Time in the central square."),
                MetricDefinition("open_entries", "Open-arm entries", "", "Entries into open arms.", decimals: 0),
                MetricDefinition("closed_entries", "Closed-arm entries", "", "Entries into closed arms.", decimals: 0),
                MetricDefinition("total_entries", "Total arm entries", "", "Open + closed entries (locomotor index).", decimals: 0),
                MetricDefinition("open_latency_s", "Latency to open arm", "s", "Time to the first open-arm entry."),
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps.", decimals: 2),
                MetricDefinition("tracked_pct", "Tracked samples", "%", "Samples with a detected mouse / all samples.")
            ]
        case .lightDark:
            return [
                MetricDefinition("light_time_pct", "Light-box time", "%", "Light time / total time × 100."),
                MetricDefinition("light_time_s", "Light-box time", "s", "Time with the centroid in the light compartment."),
                MetricDefinition("dark_time_s", "Dark-box time", "s", "Time in the dark compartment (including unseen samples if enabled)."),
                MetricDefinition("transitions", "Transitions", "", "Compartment changes meeting the entry criterion.", decimals: 0),
                MetricDefinition("latency_dark_s", "Latency to dark", "s", "Time to the first entry into the dark compartment."),
                MetricDefinition("light_distance_m", "Distance in light", "m", "Distance traveled inside the light compartment.", decimals: 2),
                MetricDefinition("tracked_pct", "Visible samples", "%", "Samples with a detected mouse / all samples.")
            ]
        case .marbleBurying:
            return [
                MetricDefinition("buried_pct", "Marbles buried", "%", "Buried (≥ 2/3 covered) / total marbles × 100."),
                MetricDefinition("buried_count", "Marbles buried", "", "Number of marbles at least two-thirds covered.", decimals: 0),
                MetricDefinition("partial_count", "Partially buried", "", "Marbles partially covered (optional).", decimals: 0)
            ]
        case .sucrosePreference:
            return [
                MetricDefinition("preference_pct", "Sucrose preference", "%", "Σ sucrose / (Σ sucrose + Σ water) × 100.", chance: 50),
                MetricDefinition("mean_daily_preference_pct", "Mean daily preference", "%", "Average of the daily preference values.", chance: 50),
                MetricDefinition("sucrose_intake_g_day", "Sucrose intake", "g/day", "Mean daily sucrose intake.", decimals: 2),
                MetricDefinition("water_intake_g_day", "Water intake", "g/day", "Mean daily water intake.", decimals: 2),
                MetricDefinition("total_intake_g_day", "Total intake", "g/day", "Mean daily total fluid intake.", decimals: 2),
                MetricDefinition("sucrose_intake_g_kg_day", "Sucrose intake / BW", "g/kg/day", "Sucrose intake normalized to body weight.", decimals: 1)
            ]
        case .yMaze:
            return [
                MetricDefinition("alternation_pct", "Spontaneous alternation", "%", "Triplets of three different arms / (entries − 2) × 100."),
                MetricDefinition("arm_entries", "Arm entries", "", "Total arm entries.", decimals: 0),
                MetricDefinition("alternations", "Alternations", "", "Number of successful triplets.", decimals: 0),
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps.", decimals: 2),
                MetricDefinition("tracked_pct", "Tracked samples", "%", "Samples with a detected mouse / all samples.")
            ]
        case .tMaze:
            return [
                MetricDefinition("right_choice_pct", "Right first choice", "%", "100 if the first choice-arm entry is right, 0 if left; averages to % right across runs.", decimals: 0),
                MetricDefinition("left_entries", "Left-arm entries", "", "Entries into the left arm.", decimals: 0),
                MetricDefinition("right_entries", "Right-arm entries", "", "Entries into the right arm.", decimals: 0),
                MetricDefinition("arm_entries", "Choice-arm entries", "", "Left + right entries.", decimals: 0),
                MetricDefinition("choice_latency_s", "Choice latency", "s", "Time to the first choice-arm entry."),
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps.", decimals: 2)
            ]
        case .novelObject:
            return [
                MetricDefinition("discrimination_index", "Discrimination index", "", "(novel − familiar) / (novel + familiar).", chance: 0, decimals: 3),
                MetricDefinition("recognition_index_pct", "Recognition index", "%", "novel / (novel + familiar) × 100.", chance: 50),
                MetricDefinition("novel_time_s", "Novel object exploration", "s", "Time in the novel-object zone (object B in training)."),
                MetricDefinition("familiar_time_s", "Familiar object exploration", "s", "Time in the familiar-object zone (object A in training)."),
                MetricDefinition("total_exploration_s", "Total exploration", "s", "novel + familiar exploration time."),
                MetricDefinition("novel_bouts", "Novel object bouts", "", "Approaches to the novel object.", decimals: 0),
                MetricDefinition("familiar_bouts", "Familiar object bouts", "", "Approaches to the familiar object.", decimals: 0),
                MetricDefinition("first_approach_latency_s", "Latency to first approach", "s", "Time to the first approach to either object."),
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps.", decimals: 2)
            ]
        case .morrisWaterMaze:
            return [
                MetricDefinition("escape_latency_s", "Escape latency", "s", "Time to reach and stay on the platform (capped at the trial maximum)."),
                MetricDefinition("path_length_m", "Path length", "m", "Swim path until escape (or trial end).", decimals: 2),
                MetricDefinition("swim_speed_cms", "Swim speed", "cm/s", "Path length / swim time.", decimals: 1),
                MetricDefinition("found_platform_pct", "Platform found", "%", "100 if the platform was reached, else 0.", decimals: 0),
                MetricDefinition("target_quadrant_pct", "Target quadrant time", "%", "Time in the 90° sector centered on the platform.", chance: 25),
                MetricDefinition("opposite_quadrant_pct", "Opposite quadrant time", "%", "Time in the quadrant opposite the platform.", chance: 25),
                MetricDefinition("platform_crossings", "Platform crossings", "", "Entries into the platform zone.", decimals: 0),
                MetricDefinition("first_crossing_latency_s", "Latency to platform zone", "s", "Time to the first platform-zone entry."),
                MetricDefinition("mean_platform_distance_cm", "Mean distance to platform", "cm", "Average distance to the platform center (Gallagher proximity)."),
                MetricDefinition("thigmotaxis_pct", "Wall-zone time", "%", "Time within the wall zone / swim time × 100.")
            ]
        case .barnesMaze:
            return [
                MetricDefinition("primary_latency_s", "Primary latency", "s", "Time to the first target-hole visit."),
                MetricDefinition("primary_errors", "Primary errors", "", "Non-target hole visits before the first target visit.", decimals: 0),
                MetricDefinition("total_errors", "Total errors", "", "All non-target hole visits within the trial.", decimals: 0),
                MetricDefinition("path_length_m", "Path length to target", "m", "Distance traveled until the first target visit.", decimals: 2),
                MetricDefinition("mean_speed_cms", "Mean speed", "cm/s", "Distance / time over the analyzed trial.", decimals: 1),
                MetricDefinition("escape_latency_s", "Escape latency", "s", "Time until the mouse disappears into the escape box (if detectable)."),
                MetricDefinition("target_quadrant_pct", "Target quadrant time", "%", "Time in the 90° sector centered on the target hole.", chance: 25),
                MetricDefinition("opposite_quadrant_pct", "Opposite quadrant time", "%", "Time in the opposite quadrant.", chance: 25),
                MetricDefinition("mean_target_distance_cm", "Mean distance to target", "cm", "Average distance to the target hole.")
            ]
        case .fearConditioning:
            return [
                MetricDefinition("freezing_pct", "Freezing (session)", "%", "Freezing time / analyzed time × 100."),
                MetricDefinition("baseline_freezing_pct", "Baseline freezing", "%", "Freezing during the pre-CS baseline."),
                MetricDefinition("cs_freezing_pct", "CS freezing", "%", "Freezing averaged over all CS presentations."),
                MetricDefinition("iti_freezing_pct", "Post-CS / ITI freezing", "%", "Freezing outside CS periods after the first CS."),
                MetricDefinition("freezing_bouts", "Freezing bouts", "", "Number of freezing bouts.", decimals: 0),
                MetricDefinition("mean_bout_s", "Mean bout duration", "s", "Average freezing bout duration.")
            ]
        case .beamWalking:
            return [
                MetricDefinition("traversal_time_s", "Traversal time", "s", "Mean time to cross the beam across trials."),
                MetricDefinition("slips_per_trial", "Foot slips per trial", "", "Mean number of foot slips per trial.", decimals: 2),
                MetricDefinition("total_slips", "Total foot slips", "", "Sum of foot slips.", decimals: 0),
                MetricDefinition("fall_pct", "Falls", "%", "Trials with a fall / trials × 100.", decimals: 0),
                MetricDefinition("trial_count", "Trials", "", "Number of trials entered.", decimals: 0)
            ]
        case .gait:
            return [
                MetricDefinition("hind_stride_cm", "Hind stride length", "cm", "Mean hindlimb stride length.", decimals: 2),
                MetricDefinition("fore_stride_cm", "Fore stride length", "cm", "Mean forelimb stride length.", decimals: 2),
                MetricDefinition("hind_base_cm", "Hind base width", "cm", "Mean hindlimb base of support.", decimals: 2),
                MetricDefinition("fore_base_cm", "Fore base width", "cm", "Mean forelimb base of support.", decimals: 2),
                MetricDefinition("overlap_cm", "Paw overlap", "cm", "Mean fore–hind paw print distance.", decimals: 2),
                MetricDefinition("hind_stride_cv_pct", "Hind stride CV", "%", "SD / mean of hind stride length × 100."),
                MetricDefinition("hind_stride_asymmetry_pct", "Hind stride asymmetry", "%", "|L − R| / mean(L, R) × 100."),
                MetricDefinition("cadence_strides_s", "Cadence", "strides/s", "Strides / run duration.", decimals: 2),
                MetricDefinition("speed_cms", "Walking speed", "cm/s", "Run distance / run duration.", decimals: 1)
            ]
        case .placePreference:
            return [
                MetricDefinition("preference_score_s", "Preference score", "s", "Paired − unpaired chamber time."),
                MetricDefinition("preference_pct", "Paired-side preference", "%", "Paired / (paired + unpaired) × 100.", chance: 50),
                MetricDefinition("paired_time_s", "Paired chamber time", "s", "Time in the drug/reward-paired chamber."),
                MetricDefinition("unpaired_time_s", "Unpaired chamber time", "s", "Time in the unpaired chamber."),
                MetricDefinition("neutral_time_s", "Neutral chamber time", "s", "Time in the middle chamber (3-chamber apparatus)."),
                MetricDefinition("paired_entries", "Paired chamber entries", "", "Entries into the paired chamber.", decimals: 0),
                MetricDefinition("distance_m", "Total distance", "m", "Sum of centroid steps.", decimals: 2)
            ]
        case .twoArmedBandit:
            return [
                MetricDefinition("p_high_pct", "High-value choices", "%", "Choices of the arm with the higher reward probability.", chance: 50),
                MetricDefinition("reward_rate_pct", "Reward rate", "%", "Rewarded trials / trials × 100."),
                MetricDefinition("win_stay_pct", "Win-stay", "%", "P(repeat choice | previous trial rewarded) × 100."),
                MetricDefinition("lose_shift_pct", "Lose-shift", "%", "P(switch choice | previous trial unrewarded) × 100."),
                MetricDefinition("switch_rate_pct", "Switch rate", "%", "P(switch choice) × 100."),
                MetricDefinition("right_choice_pct", "Right choices", "%", "Side bias: right choices / trials × 100.", chance: 50),
                MetricDefinition("q_alpha", "Learning rate α", "", "Q-learning learning rate (maximum likelihood).", decimals: 3),
                MetricDefinition("q_beta", "Inverse temperature β", "", "Softmax inverse temperature (maximum likelihood).", decimals: 2),
                MetricDefinition("q_pseudo_r2", "Model pseudo-R²", "", "1 − NLL / (n · ln 2).", decimals: 3),
                MetricDefinition("trial_count", "Trials", "", "Number of trials.", decimals: 0),
                MetricDefinition("mean_rt_s", "Mean reaction time", "s", "Mean of the RT column (if provided).", decimals: 3)
            ]
        case .custom:
            return []
        }
    }

    /// Metrics for a record, including custom (imported) metrics that are not in the catalog.
    static func metricDefinitions(for result: ExperimentResult) -> [MetricDefinition] {
        var defs = metrics(for: result.assay)
        let known = Set(defs.map(\.key))
        for key in result.metrics.keys.sorted() where !known.contains(key) {
            let name = result.customMetricNames?[key] ?? key
            defs.append(MetricDefinition(key, name, "", "Imported value.", decimals: 3))
        }
        return defs
    }
}
