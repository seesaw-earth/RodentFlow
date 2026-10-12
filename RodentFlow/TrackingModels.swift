import Foundation
import CoreGraphics

enum ArenaShape: String, Codable, CaseIterable, Identifiable {
    case rectangle
    case circle
    case tMaze = "t_maze"
    case yMaze = "y_maze"
    case plusMaze = "plus_maze"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rectangle: return loc("Open Field · Rectangle")
        case .circle: return loc("Open Field · Circle")
        case .tMaze: return loc("T-Maze")
        case .yMaze: return loc("Y-Maze")
        case .plusMaze: return loc("Elevated Plus Maze")
        }
    }

    var shortName: String {
        switch self {
        case .rectangle: return loc("Rectangle")
        case .circle: return loc("Circle")
        case .tMaze: return loc("T-Maze")
        case .yMaze: return loc("Y-Maze")
        case .plusMaze: return loc("Plus maze")
        }
    }

    var systemImage: String {
        switch self {
        case .rectangle: return "rectangle.dashed"
        case .circle: return "circle.dashed"
        case .tMaze: return "arrow.triangle.branch"
        case .yMaze: return "arrow.triangle.branch"
        case .plusMaze: return "plus"
        }
    }

    var isMaze: Bool { self == .tMaze || self == .yMaze || self == .plusMaze }
}

struct NormalizedPoint: Codable, Hashable {
    var x: Double
    var y: Double

    static let topLeft = NormalizedPoint(x: 0.06, y: 0.06)
    static let topRight = NormalizedPoint(x: 0.94, y: 0.06)
    static let bottomRight = NormalizedPoint(x: 0.94, y: 0.94)
    static let bottomLeft = NormalizedPoint(x: 0.06, y: 0.94)
    static let center = NormalizedPoint(x: 0.50, y: 0.50)
    static let circleEdge = NormalizedPoint(x: 0.88, y: 0.50)

    static let tJunction = NormalizedPoint(x: 0.50, y: 0.34)
    static let tStart = NormalizedPoint(x: 0.50, y: 0.90)
    static let tLeft = NormalizedPoint(x: 0.12, y: 0.34)
    static let tRight = NormalizedPoint(x: 0.88, y: 0.34)

    static let yJunction = NormalizedPoint(x: 0.50, y: 0.55)
    static let yA = NormalizedPoint(x: 0.50, y: 0.10)
    static let yB = NormalizedPoint(x: 0.16, y: 0.84)
    static let yC = NormalizedPoint(x: 0.84, y: 0.84)

    static let plusCenter = NormalizedPoint(x: 0.50, y: 0.50)
    static let plusN = NormalizedPoint(x: 0.50, y: 0.06)
    static let plusE = NormalizedPoint(x: 0.80, y: 0.50)
    static let plusS = NormalizedPoint(x: 0.50, y: 0.94)
    static let plusW = NormalizedPoint(x: 0.20, y: 0.50)

    static let markerA = NormalizedPoint(x: 0.35, y: 0.35)
    static let markerB = NormalizedPoint(x: 0.65, y: 0.65)
    static let markerTarget = NormalizedPoint(x: 0.68, y: 0.32)

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

struct ArenaCalibration: Codable, Hashable {
    var topLeft: NormalizedPoint = .topLeft
    var topRight: NormalizedPoint = .topRight
    var bottomRight: NormalizedPoint = .bottomRight
    var bottomLeft: NormalizedPoint = .bottomLeft

    var circleCenter: NormalizedPoint = .center
    var circleEdge: NormalizedPoint = .circleEdge

    var tJunction: NormalizedPoint = .tJunction
    var tStart: NormalizedPoint = .tStart
    var tLeft: NormalizedPoint = .tLeft
    var tRight: NormalizedPoint = .tRight

    var yJunction: NormalizedPoint = .yJunction
    var yA: NormalizedPoint = .yA
    var yB: NormalizedPoint = .yB
    var yC: NormalizedPoint = .yC

    // Elevated plus maze: center junction and the four arm ends (image-relative N/E/S/W).
    var plusCenter: NormalizedPoint = .plusCenter
    var plusN: NormalizedPoint = .plusN
    var plusE: NormalizedPoint = .plusE
    var plusS: NormalizedPoint = .plusS
    var plusW: NormalizedPoint = .plusW

    // Assay zone markers placed on the calibration frame (object A/B, platform / target hole).
    var markerA: NormalizedPoint = .markerA
    var markerB: NormalizedPoint = .markerB
    var markerTarget: NormalizedPoint = .markerTarget

    var corners: [NormalizedPoint] { [topLeft, topRight, bottomRight, bottomLeft] }
    var tPoints: [NormalizedPoint] { [tJunction, tStart, tLeft, tRight] }
    var yPoints: [NormalizedPoint] { [yJunction, yA, yB, yC] }
    var plusPoints: [NormalizedPoint] { [plusCenter, plusN, plusE, plusS, plusW] }

    init() {}

    // Tolerant decoding so recovery records written by v1.0 (without the new points) still load.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        topLeft = c.value(.topLeft, .topLeft)
        topRight = c.value(.topRight, .topRight)
        bottomRight = c.value(.bottomRight, .bottomRight)
        bottomLeft = c.value(.bottomLeft, .bottomLeft)
        circleCenter = c.value(.circleCenter, .center)
        circleEdge = c.value(.circleEdge, .circleEdge)
        tJunction = c.value(.tJunction, .tJunction)
        tStart = c.value(.tStart, .tStart)
        tLeft = c.value(.tLeft, .tLeft)
        tRight = c.value(.tRight, .tRight)
        yJunction = c.value(.yJunction, .yJunction)
        yA = c.value(.yA, .yA)
        yB = c.value(.yB, .yB)
        yC = c.value(.yC, .yC)
        plusCenter = c.value(.plusCenter, .plusCenter)
        plusN = c.value(.plusN, .plusN)
        plusE = c.value(.plusE, .plusE)
        plusS = c.value(.plusS, .plusS)
        plusW = c.value(.plusW, .plusW)
        markerA = c.value(.markerA, .markerA)
        markerB = c.value(.markerB, .markerB)
        markerTarget = c.value(.markerTarget, .markerTarget)
    }

    mutating func setPlusMazePoint(_ index: Int, to point: NormalizedPoint) {
        switch index {
        case 0: plusCenter = point
        case 1: plusN = point
        case 2: plusE = point
        case 3: plusS = point
        case 4: plusW = point
        default: break
        }
    }

    mutating func setCorner(_ index: Int, to point: NormalizedPoint) {
        switch index {
        case 0: topLeft = point
        case 1: topRight = point
        case 2: bottomRight = point
        case 3: bottomLeft = point
        default: break
        }
    }

    mutating func setTMazePoint(_ index: Int, to point: NormalizedPoint) {
        switch index {
        case 0: tJunction = point
        case 1: tStart = point
        case 2: tLeft = point
        case 3: tRight = point
        default: break
        }
    }

    mutating func setYMazePoint(_ index: Int, to point: NormalizedPoint) {
        switch index {
        case 0: yJunction = point
        case 1: yA = point
        case 2: yB = point
        case 3: yC = point
        default: break
        }
    }
}

struct VideoMetadata: Codable, Equatable {
    var durationSeconds: Double
    var pixelWidth: Double
    var pixelHeight: Double
    var nominalFPS: Double
    var creationDate: Date?

    var aspectRatio: CGFloat {
        guard pixelHeight > 0 else { return 16.0 / 9.0 }
        return CGFloat(pixelWidth / pixelHeight)
    }
}

enum VideoSource: String, Codable {
    case photos
    case files
}

enum ExperimentDateSource: String, Codable {
    case videoMetadata = "video_metadata"
    case userEntered = "user_entered"
    case importTimeFallback = "import_time_fallback"
}

struct AnalysisProgressSnapshot: Equatable {
    let fraction: Double
    let processedSamples: Int
    let estimatedTotalSamples: Int?
    let elapsedSeconds: Double
    let remainingSeconds: Double?

    static let zero = AnalysisProgressSnapshot(
        fraction: 0,
        processedSamples: 0,
        estimatedTotalSamples: nil,
        elapsedSeconds: 0,
        remainingSeconds: nil
    )
}

struct TrackingPoint: Codable, Identifiable, Hashable, Sendable {
    var id: Int { frameIndex }
    let frameIndex: Int
    let clipTimeSeconds: Double
    let videoTimeSeconds: Double

    let imageXNormalized: Double
    let imageYNormalized: Double

    let arenaXNormalized: Double
    let arenaYNormalized: Double

    let xCentimeters: Double
    let yCentimeters: Double
    let confidence: Double
    let interpolated: Bool
    let zone: String
    /// Fraction of arena pixels that changed since the previous 10 Hz sample (freezing analysis).
    var motionIndex: Double? = nil
    /// Area of the selected foreground component as a fraction of the arena area.
    var blobAreaFraction: Double? = nil
}

struct MazeEvent: Codable, Hashable, Identifiable {
    var id: String { "\(eventIndex)-\(timeSeconds)-\(toZone)" }
    let eventIndex: Int
    let timeSeconds: Double
    let fromZone: String
    let toZone: String
}

struct TrackingPreviewResult: Codable, Equatable {
    let startSeconds: Double
    let durationSeconds: Double
    let processingFPS: Double
    let points: [TrackingPoint]

    var meanConfidence: Double {
        guard !points.isEmpty else { return 0 }
        return points.map(\.confidence).reduce(0, +) / Double(points.count)
    }

    var trackedFraction: Double {
        guard !points.isEmpty else { return 0 }
        return Double(points.filter { !$0.interpolated }.count) / Double(points.count)
    }

    var distanceCentimeters: Double {
        guard points.count > 1 else { return 0 }
        return zip(points.dropFirst(), points).reduce(0) { partial, pair in
            let (current, previous) = pair
            guard !current.interpolated, !previous.interpolated else { return partial }
            return partial + hypot(current.xCentimeters - previous.xCentimeters, current.yCentimeters - previous.yCentimeters)
        }
    }
}

struct FullAnalysisResult: Equatable {
    let durationSeconds: Double
    let processingFPS: Double
    let points: [TrackingPoint]
    let mazeEvents: [MazeEvent]
    /// Zone markers (object A/B, platform / target hole "T") converted to arena centimeters
    /// with the same mapping the tracker used for the mouse.
    var markersCM: [String: ArenaPoint] = [:]

    var meanConfidence: Double {
        guard !points.isEmpty else { return 0 }
        return points.map(\.confidence).reduce(0, +) / Double(points.count)
    }

    var trackedFraction: Double {
        guard !points.isEmpty else { return 0 }
        return Double(points.filter { !$0.interpolated }.count) / Double(points.count)
    }

    var distanceCentimeters: Double {
        guard points.count > 1 else { return 0 }
        var total = 0.0
        for index in 1..<points.count {
            let a = points[index - 1]
            let b = points[index]
            guard !a.interpolated, !b.interpolated else { continue }
            total += hypot(b.xCentimeters - a.xCentimeters, b.yCentimeters - a.yCentimeters)
        }
        return total
    }

    var meanSpeedCentimetersPerSecond: Double {
        let elapsed = max(0, (points.last?.videoTimeSeconds ?? 0) - (points.first?.videoTimeSeconds ?? 0))
        guard elapsed > 0 else { return 0 }
        return distanceCentimeters / elapsed
    }

    var armEntrySequence: [String] { mazeEvents.map(\.toZone) }

    var yMazeAlternationPercent: Double? {
        let sequence = armEntrySequence.filter { ["A", "B", "C"].contains($0) }
        guard sequence.count >= 3 else { return nil }
        var successful = 0
        for i in 2..<sequence.count {
            let triple = Set([sequence[i - 2], sequence[i - 1], sequence[i]])
            if triple.count == 3 { successful += 1 }
        }
        return 100.0 * Double(successful) / Double(sequence.count - 2)
    }

    var tMazeFirstChoice: String? {
        armEntrySequence.first(where: { $0 == "left" || $0 == "right" })
    }
}

enum MazeEventAnalyzer {
    static func events(points: [TrackingPoint], arenaShape: ArenaShape, stableDuration: Double = 0.25) -> [MazeEvent] {
        guard arenaShape.isMaze else { return [] }
        let allowed: Set<String>
        let arms: Set<String>
        switch arenaShape {
        case .tMaze:
            allowed = ["start", "center", "left", "right"]
            arms = ["left", "right"]
        case .yMaze:
            allowed = ["center", "A", "B", "C"]
            arms = ["A", "B", "C"]
        case .plusMaze:
            allowed = ["center", "N", "E", "S", "W"]
            arms = ["N", "E", "S", "W"]
        default:
            return []
        }

        var committed: String?
        var candidate: String?
        var candidateStart = 0.0
        var output: [MazeEvent] = []

        for point in points where !point.interpolated && allowed.contains(point.zone) {
            let zone = point.zone
            if zone == committed {
                candidate = nil
                continue
            }
            if zone != candidate {
                candidate = zone
                candidateStart = point.videoTimeSeconds
                continue
            }
            guard point.videoTimeSeconds - candidateStart >= stableDuration else { continue }

            let old = committed ?? "none"
            committed = zone
            candidate = nil
            if arms.contains(zone) {
                output.append(MazeEvent(
                    eventIndex: output.count + 1,
                    timeSeconds: point.videoTimeSeconds,
                    fromZone: old,
                    toZone: zone
                ))
            }
        }
        return output
    }
}
