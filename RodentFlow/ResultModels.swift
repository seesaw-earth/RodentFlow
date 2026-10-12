import Foundation

// MARK: - Per-animal result record
//
// One `ExperimentResult` = one animal × one session (phase / day / trial). It is the unit
// stored in the Results library, shown in the single-experiment tab, and aggregated by the
// group-analysis tab. Decoding is tolerant: missing keys fall back to defaults so files from
// older or newer builds still open.

enum ResultSource: String, Codable, CaseIterable {
    case video
    case manual
    case imported

    var displayName: String {
        switch self {
        case .video: return loc("Video tracking")
        case .manual: return loc("Manual entry")
        case .imported: return loc("Imported")
        }
    }

    var systemImage: String {
        switch self {
        case .video: return "video"
        case .manual: return "keyboard"
        case .imported: return "square.and.arrow.down"
        }
    }

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ResultSource(rawValue: raw) ?? .imported
    }
}

struct ResultSeries: Codable, Hashable, Identifiable {
    var key: String
    var name: String
    var unit: String
    var xLabel: String
    var x: [Double]
    var y: [Double]
    var id: String { key }
}

/// A point in arena coordinates (centimeters, origin at the arena's top-left).
struct ArenaPoint: Codable, Hashable {
    var x: Double
    var y: Double
}

/// Post-hoc analysis parameters for video-derived results. Editing these re-computes the
/// metrics from the saved tracking samples without re-running the tracker.
struct ZoneConfig: Codable, Hashable {
    var arenaShape: ArenaShape = .rectangle
    var arenaWidthCM: Double = 40
    var arenaHeightCM: Double = 40
    /// Analysis window relative to the first tracked sample. Duration 0 = until the end.
    var analysisStartSeconds: Double = 0
    var analysisDurationSeconds: Double = 0
    var entryMinSeconds: Double = 0.3

    // Open field
    var centerFraction: Double = 0.5
    var movingSpeedCMs: Double = 2.0
    var immobilityMinSeconds: Double = 2.0
    var timeBinSeconds: Double = 300

    // Elevated plus maze
    var plusArmLengthCM: Double = 30
    var plusArmWidthCM: Double = 5
    var plusOpenAxis: String = "NS"
    var plusCenterMarginCM: Double = 0

    // Light–dark box
    var lightFraction: Double = 0.667
    var lightOnLeft: Bool = true
    var undetectedIsDark: Bool = true

    // Conditioned place preference
    var cppChambers: Int = 2
    var cppDivider: Double = 0.5
    var cppNeutralFraction: Double = 0.2
    var cppPairedOnLeft: Bool = true

    // Novel object recognition
    var objectA: ArenaPoint?
    var objectB: ArenaPoint?
    /// Body-centroid radius around the object centre. The centroid sits ~4–5 cm behind the nose,
    /// so sniffing a 2–3 cm object puts it ~6–9 cm from the object centre.
    var objectZoneRadiusCM: Double = 8
    var novelObject: String = "B"
    var minTotalExplorationSeconds: Double = 10

    // Morris water maze / Barnes maze
    var target: ArenaPoint?
    var targetRadiusCM: Double = 6
    var maxTrialSeconds: Double = 60
    var platformStaySeconds: Double = 1.0
    var wallZoneCM: Double = 10
    var holeCount: Int = 20

    // Fear conditioning
    var freezeThresholdPct: Double = 5
    var freezeMinSeconds: Double = 1.0
    var protocolOffsetSeconds: Double = 0
    var baselineSeconds: Double = 120
    var csOnsetsSeconds: [Double] = []
    var csDurationSeconds: Double = 30
    var fearBinSeconds: Double = 60

    // T / Y maze
    var mazeEntryMinSeconds: Double = 0.25

    init() {}

    /// Sensible starting values for each assay.
    static func defaults(for assay: AssayKind, shape: ArenaShape, widthCM: Double, heightCM: Double) -> ZoneConfig {
        var c = ZoneConfig()
        c.arenaShape = shape
        c.arenaWidthCM = widthCM
        c.arenaHeightCM = heightCM
        switch assay {
        case .novelObject:
            c.analysisDurationSeconds = 300
            c.objectA = ArenaPoint(x: widthCM * 0.3, y: heightCM * 0.3)
            c.objectB = ArenaPoint(x: widthCM * 0.7, y: heightCM * 0.7)
        case .morrisWaterMaze:
            c.maxTrialSeconds = 60
            c.targetRadiusCM = 6
            c.wallZoneCM = 10
            c.target = ArenaPoint(x: widthCM * 0.75, y: heightCM * 0.25)
        case .barnesMaze:
            c.maxTrialSeconds = 180
            // A dark mouse's head disappears into the hole during a poke, so the visible-body
            // centroid stays ~5–7 cm from the hole centre. Visits go to the nearest hole, so the
            // zone may exceed half the hole spacing.
            c.targetRadiusCM = 8
            c.entryMinSeconds = 0.2
            c.target = ArenaPoint(x: widthCM * 0.5, y: heightCM * 0.06)
        case .elevatedPlusMaze:
            c.entryMinSeconds = 0.25
        case .lightDark:
            c.entryMinSeconds = 0.5
        case .placePreference:
            c.entryMinSeconds = 0.5
        default:
            break
        }
        return c
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = ZoneConfig()
        arenaShape = c.value(.arenaShape, d.arenaShape)
        arenaWidthCM = c.value(.arenaWidthCM, d.arenaWidthCM)
        arenaHeightCM = c.value(.arenaHeightCM, d.arenaHeightCM)
        analysisStartSeconds = c.value(.analysisStartSeconds, d.analysisStartSeconds)
        analysisDurationSeconds = c.value(.analysisDurationSeconds, d.analysisDurationSeconds)
        entryMinSeconds = c.value(.entryMinSeconds, d.entryMinSeconds)
        centerFraction = c.value(.centerFraction, d.centerFraction)
        movingSpeedCMs = c.value(.movingSpeedCMs, d.movingSpeedCMs)
        immobilityMinSeconds = c.value(.immobilityMinSeconds, d.immobilityMinSeconds)
        timeBinSeconds = c.value(.timeBinSeconds, d.timeBinSeconds)
        plusArmLengthCM = c.value(.plusArmLengthCM, d.plusArmLengthCM)
        plusArmWidthCM = c.value(.plusArmWidthCM, d.plusArmWidthCM)
        plusOpenAxis = c.value(.plusOpenAxis, d.plusOpenAxis)
        plusCenterMarginCM = c.value(.plusCenterMarginCM, d.plusCenterMarginCM)
        lightFraction = c.value(.lightFraction, d.lightFraction)
        lightOnLeft = c.value(.lightOnLeft, d.lightOnLeft)
        undetectedIsDark = c.value(.undetectedIsDark, d.undetectedIsDark)
        cppChambers = c.value(.cppChambers, d.cppChambers)
        cppDivider = c.value(.cppDivider, d.cppDivider)
        cppNeutralFraction = c.value(.cppNeutralFraction, d.cppNeutralFraction)
        cppPairedOnLeft = c.value(.cppPairedOnLeft, d.cppPairedOnLeft)
        objectA = c.optionalValue(.objectA)
        objectB = c.optionalValue(.objectB)
        objectZoneRadiusCM = c.value(.objectZoneRadiusCM, d.objectZoneRadiusCM)
        novelObject = c.value(.novelObject, d.novelObject)
        minTotalExplorationSeconds = c.value(.minTotalExplorationSeconds, d.minTotalExplorationSeconds)
        target = c.optionalValue(.target)
        targetRadiusCM = c.value(.targetRadiusCM, d.targetRadiusCM)
        maxTrialSeconds = c.value(.maxTrialSeconds, d.maxTrialSeconds)
        platformStaySeconds = c.value(.platformStaySeconds, d.platformStaySeconds)
        wallZoneCM = c.value(.wallZoneCM, d.wallZoneCM)
        holeCount = c.value(.holeCount, d.holeCount)
        freezeThresholdPct = c.value(.freezeThresholdPct, d.freezeThresholdPct)
        freezeMinSeconds = c.value(.freezeMinSeconds, d.freezeMinSeconds)
        protocolOffsetSeconds = c.value(.protocolOffsetSeconds, d.protocolOffsetSeconds)
        baselineSeconds = c.value(.baselineSeconds, d.baselineSeconds)
        csOnsetsSeconds = c.value(.csOnsetsSeconds, d.csOnsetsSeconds)
        csDurationSeconds = c.value(.csDurationSeconds, d.csDurationSeconds)
        fearBinSeconds = c.value(.fearBinSeconds, d.fearBinSeconds)
        mazeEntryMinSeconds = c.value(.mazeEntryMinSeconds, d.mazeEntryMinSeconds)
    }
}

// MARK: - Manual entry storage

struct ManualRow: Codable, Hashable, Identifiable {
    var id = UUID()
    var values: [String: Double] = [:]

    init(values: [String: Double] = [:]) {
        self.values = values
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.value(.id, UUID())
        values = c.value(.values, [:])
    }
}

struct ManualInput: Codable, Hashable {
    /// Animal-level numeric fields (choice fields store the option index).
    var values: [String: Double] = [:]
    /// Free-text fields (e.g. a Y-maze arm sequence typed by hand).
    var text: [String: String] = [:]
    /// Repeated rows: trials, days, strides…
    var rows: [ManualRow] = []

    init(values: [String: Double] = [:], text: [String: String] = [:], rows: [ManualRow] = []) {
        self.values = values
        self.text = text
        self.rows = rows
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        values = c.value(.values, [:])
        text = c.value(.text, [:])
        rows = c.value(.rows, [])
    }
}

// MARK: - Experiment result

struct ExperimentResult: Codable, Identifiable, Hashable {
    var schemaVersion = "1.1"
    var id = UUID()
    var assay: AssayKind
    var subjectID: String
    var group: String
    var sex: String = ""
    var phase: String = ""
    var day: Int?
    var trial: Int?
    var experimentDate = Date()
    var createdAt = Date()
    var updatedAt = Date()
    var source: ResultSource
    var metrics: [String: Double] = [:]
    var series: [ResultSeries] = []
    /// Categorical outputs, e.g. Barnes search strategy or a maze arm sequence.
    var labels: [String: String] = [:]
    /// Analysis parameters recorded for Methods / reproducibility.
    var parameters: [String: String] = [:]
    var qcFlags: [String] = []
    var excluded = false
    var exclusionReason = ""
    var notes = ""
    /// Folder name under Documents/Experiments that holds the tracking JSON for video results.
    var runFolderName: String?
    var zoneConfig: ZoneConfig?
    var manualInput: ManualInput?
    /// Source file name for imported records.
    var datasetName: String?
    /// Display names for imported metrics that are not in the catalog.
    var customMetricNames: [String: String]?

    init(assay: AssayKind, subjectID: String, group: String, source: ResultSource) {
        self.assay = assay
        self.subjectID = subjectID
        self.group = group
        self.source = source
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = c.value(.schemaVersion, "1.1")
        id = c.value(.id, UUID())
        assay = c.value(.assay, AssayKind.custom)
        subjectID = c.value(.subjectID, "")
        group = c.value(.group, "")
        sex = c.value(.sex, "")
        phase = c.value(.phase, "")
        day = c.optionalValue(.day)
        trial = c.optionalValue(.trial)
        experimentDate = c.value(.experimentDate, Date())
        createdAt = c.value(.createdAt, Date())
        updatedAt = c.value(.updatedAt, Date())
        source = c.value(.source, ResultSource.imported)
        metrics = c.value(.metrics, [:])
        series = c.value(.series, [])
        labels = c.value(.labels, [:])
        parameters = c.value(.parameters, [:])
        qcFlags = c.value(.qcFlags, [])
        excluded = c.value(.excluded, false)
        exclusionReason = c.value(.exclusionReason, "")
        notes = c.value(.notes, "")
        runFolderName = c.optionalValue(.runFolderName)
        zoneConfig = c.optionalValue(.zoneConfig)
        manualInput = c.optionalValue(.manualInput)
        datasetName = c.optionalValue(.datasetName)
        customMetricNames = c.optionalValue(.customMetricNames)
    }

    var displaySubject: String { subjectID.isEmpty ? loc("Unnamed") : subjectID }
    /// Group used for grouping and display; records without a group share one localized label.
    var displayGroup: String { group.isEmpty ? ExperimentResult.ungroupedLabel : group }
    static var ungroupedLabel: String { loc("Ungrouped") }

    var sessionLabel: String {
        var parts: [String] = []
        if !phase.isEmpty { parts.append(AssayKind.phaseTitle(phase)) }
        if let day { parts.append(locf("Day %ld", day)) }
        if let trial { parts.append(locf("Trial %ld", trial)) }
        return parts.joined(separator: " · ")
    }

    var primaryMetricKey: String {
        let key = assay.primaryMetricKey(phase: phase)
        if !key.isEmpty, metrics[key] != nil { return key }
        if assay == .twoArmedBandit, metrics["p_high_pct"] == nil { return "reward_rate_pct" }
        return key.isEmpty ? (metrics.keys.sorted().first ?? "") : key
    }

    /// Applies a freshly computed set of outputs, keeping identity and metadata.
    mutating func apply(_ computation: AssayComputation) {
        metrics = computation.metrics
        series = computation.series
        labels = computation.labels
        parameters = computation.parameters
        qcFlags = computation.qcFlags
        updatedAt = Date()
    }
}

/// Output of any assay computation (video, manual or trial import).
struct AssayComputation: Hashable {
    var metrics: [String: Double] = [:]
    var series: [ResultSeries] = []
    var labels: [String: String] = [:]
    var parameters: [String: String] = [:]
    var qcFlags: [String] = []

    /// Stores a value only if it is finite (JSON cannot encode NaN / infinity).
    mutating func set(_ key: String, _ value: Double?) {
        guard let value, value.isFinite else { return }
        metrics[key] = value
    }

    mutating func param(_ key: String, _ value: Double, decimals: Int = 2) {
        parameters[key] = String(format: "%.\(decimals)f", value)
    }

    mutating func addSeries(_ key: String, _ name: String, unit: String, xLabel: String, x: [Double], y: [Double]) {
        var xs: [Double] = []
        var ys: [Double] = []
        for (a, b) in zip(x, y) where a.isFinite && b.isFinite {
            xs.append(a)
            ys.append(b)
        }
        guard !xs.isEmpty else { return }
        series.append(ResultSeries(key: key, name: name, unit: unit, xLabel: xLabel, x: xs, y: ys))
    }
}

// MARK: - Tolerant decoding helpers

extension KeyedDecodingContainer {
    func value<T: Decodable>(_ key: Key, _ fallback: T) -> T {
        (try? decodeIfPresent(T.self, forKey: key)) ?? fallback
    }

    func optionalValue<T: Decodable>(_ key: Key) -> T? {
        (try? decodeIfPresent(T.self, forKey: key)) ?? nil
    }
}
