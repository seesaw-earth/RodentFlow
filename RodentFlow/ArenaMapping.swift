import Foundation

/// 4-point planar homography (source quad → destination quad). Used to draw arena-space zones
/// (center square, dividers, chambers) on the calibration frame during setup.
struct PlanarHomography {
    private let h: [Double]

    init?(source: [(Double, Double)], destination: [(Double, Double)]) {
        guard source.count == 4, destination.count == 4 else { return nil }
        var a = Array(repeating: Array(repeating: 0.0, count: 9), count: 8)
        for i in 0..<4 {
            let (x, y) = source[i]
            let (u, v) = destination[i]
            let r = 2 * i
            a[r][0] = x; a[r][1] = y; a[r][2] = 1
            a[r][6] = -u * x; a[r][7] = -u * y; a[r][8] = u
            a[r + 1][3] = x; a[r + 1][4] = y; a[r + 1][5] = 1
            a[r + 1][6] = -v * x; a[r + 1][7] = -v * y; a[r + 1][8] = v
        }
        for col in 0..<8 {
            var pivot = col
            for row in col..<8 where abs(a[row][col]) > abs(a[pivot][col]) { pivot = row }
            guard abs(a[pivot][col]) > 1e-12 else { return nil }
            if pivot != col { a.swapAt(pivot, col) }
            let divisor = a[col][col]
            for j in col..<9 { a[col][j] /= divisor }
            for row in 0..<8 where row != col {
                let factor = a[row][col]
                guard factor != 0 else { continue }
                for j in col..<9 { a[row][j] -= factor * a[col][j] }
            }
        }
        h = (0..<8).map { a[$0][8] }
    }

    func map(_ x: Double, _ y: Double) -> (Double, Double) {
        let d = h[6] * x + h[7] * y + 1
        guard abs(d) > 1e-12 else { return (x, y) }
        return ((h[0] * x + h[1] * y + h[2]) / d, (h[3] * x + h[4] * y + h[5]) / d)
    }

    /// Maps arena-normalized (0…1) coordinates to normalized image coordinates for a calibrated
    /// rectangle with corners TL, TR, BR, BL.
    static func arenaToImage(_ calibration: ArenaCalibration) -> PlanarHomography? {
        PlanarHomography(
            source: [(0, 0), (1, 0), (1, 1), (0, 1)],
            destination: calibration.corners.map { ($0.x, $0.y) }
        )
    }
}
