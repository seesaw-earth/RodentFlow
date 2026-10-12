import SwiftUI

struct ArenaCalibrationView: View {
    let image: UIImage
    let shape: ArenaShape
    @Binding var calibration: ArenaCalibration
    var assay: AssayKind = .openField
    var zoneConfig: ZoneConfig?

    private let handleSize: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            let container = CGRect(origin: .zero, size: geometry.size)
            let imageAspect = image.size.width / max(image.size.height, 1)
            let rect = aspectFitRect(aspectRatio: imageAspect, in: container)

            ZStack {
                Color.black.opacity(0.04)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                zonePreview(in: rect)

                switch shape {
                case .rectangle:
                    rectangularOverlay(in: rect)
                case .circle:
                    circularOverlay(in: rect)
                case .tMaze:
                    tMazeOverlay(in: rect)
                case .yMaze:
                    yMazeOverlay(in: rect)
                case .plusMaze:
                    plusMazeOverlay(in: rect)
                }

                markerOverlay(in: rect)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .aspectRatio(image.size.width / max(image.size.height, 1), contentMode: .fit)
        .frame(minHeight: 170, maxHeight: 270)
    }

    @ViewBuilder
    private func rectangularOverlay(in rect: CGRect) -> some View {
        Path { path in
            let pts = calibration.corners.map { displayPoint($0, in: rect) }
            guard let first = pts.first else { return }
            path.move(to: first)
            for p in pts.dropFirst() { path.addLine(to: p) }
            path.closeSubpath()
        }
        .stroke(.yellow, style: StrokeStyle(lineWidth: 2, dash: [7, 5]))

        ForEach(0..<4, id: \.self) { index in
            let p = displayPoint(calibration.corners[index], in: rect)
            calibrationHandle(label: "\(index + 1)", at: p)
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    var updated = calibration
                    updated.setCorner(index, to: normalizedPoint(from: value.location, in: rect))
                    calibration = updated
                })
        }
    }

    @ViewBuilder
    private func circularOverlay(in rect: CGRect) -> some View {
        let center = displayPoint(calibration.circleCenter, in: rect)
        let edge = displayPoint(calibration.circleEdge, in: rect)
        let radius = hypot(edge.x - center.x, edge.y - center.y)

        Circle()
            .stroke(.yellow, style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
            .frame(width: radius * 2, height: radius * 2)
            .position(center)

        Path { path in
            path.move(to: center)
            path.addLine(to: edge)
        }
        .stroke(.yellow.opacity(0.8), lineWidth: 2)

        calibrationHandle(label: "C", at: center)
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                let oldCenter = displayPoint(calibration.circleCenter, in: rect)
                let oldEdge = displayPoint(calibration.circleEdge, in: rect)
                let dx = oldEdge.x - oldCenter.x
                let dy = oldEdge.y - oldCenter.y
                var updated = calibration
                updated.circleCenter = normalizedPoint(from: value.location, in: rect)
                updated.circleEdge = normalizedPoint(from: CGPoint(x: value.location.x + dx, y: value.location.y + dy), in: rect)
                calibration = updated
            })

        calibrationHandle(label: "R", at: edge)
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                var updated = calibration
                updated.circleEdge = normalizedPoint(from: value.location, in: rect)
                calibration = updated
            })
    }

    @ViewBuilder
    private func tMazeOverlay(in rect: CGRect) -> some View {
        let pts = calibration.tPoints.map { displayPoint($0, in: rect) }
        let labels = ["J", "S", "L", "R"]
        if pts.count == 4 {
            Path { path in
                path.move(to: pts[1]); path.addLine(to: pts[0])
                path.move(to: pts[2]); path.addLine(to: pts[0]); path.addLine(to: pts[3])
            }
            .stroke(.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 5]))

            ForEach(0..<4, id: \.self) { index in
                calibrationHandle(label: labels[index], at: pts[index])
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        var updated = calibration
                        updated.setTMazePoint(index, to: normalizedPoint(from: value.location, in: rect))
                        calibration = updated
                    })
            }
        }
    }

    @ViewBuilder
    private func yMazeOverlay(in rect: CGRect) -> some View {
        let pts = calibration.yPoints.map { displayPoint($0, in: rect) }
        let labels = ["J", "A", "B", "C"]
        if pts.count == 4 {
            Path { path in
                for endpoint in pts.dropFirst() {
                    path.move(to: pts[0])
                    path.addLine(to: endpoint)
                }
            }
            .stroke(.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 5]))

            ForEach(0..<4, id: \.self) { index in
                calibrationHandle(label: labels[index], at: pts[index])
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        var updated = calibration
                        updated.setYMazePoint(index, to: normalizedPoint(from: value.location, in: rect))
                        calibration = updated
                    })
            }
        }
    }

    @ViewBuilder
    private func plusMazeOverlay(in rect: CGRect) -> some View {
        let pts = calibration.plusPoints.map { displayPoint($0, in: rect) }
        let labels = ["C", "N", "E", "S", "W"]
        let openAxis = zoneConfig?.plusOpenAxis ?? "NS"
        if pts.count == 5 {
            Path { path in
                for endpoint in pts.dropFirst() {
                    path.move(to: pts[0])
                    path.addLine(to: endpoint)
                }
            }
            .stroke(.yellow, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 5]))

            ForEach(0..<5, id: \.self) { index in
                let isOpen = index > 0 && (openAxis == "EW" ? (index == 2 || index == 4) : (index == 1 || index == 3))
                calibrationHandle(label: labels[index], at: pts[index], color: isOpen ? .cyan : .yellow)
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        var updated = calibration
                        updated.setPlusMazePoint(index, to: normalizedPoint(from: value.location, in: rect))
                        calibration = updated
                    })
            }
        }
    }

    // MARK: Assay zones and markers

    /// Read-only preview of arena-space zones (center square, light/dark divider, CPP chambers).
    @ViewBuilder
    private func zonePreview(in rect: CGRect) -> some View {
        if let config = zoneConfig {
            if shape == .rectangle, let h = PlanarHomography.arenaToImage(calibration) {
                Path { path in
                    for polyline in rectangleZoneLines(config) {
                        guard let first = polyline.first else { continue }
                        let p0 = h.map(first.0, first.1)
                        path.move(to: CGPoint(x: rect.minX + CGFloat(p0.0) * rect.width, y: rect.minY + CGFloat(p0.1) * rect.height))
                        for q in polyline.dropFirst() {
                            let p = h.map(q.0, q.1)
                            path.addLine(to: CGPoint(x: rect.minX + CGFloat(p.0) * rect.width, y: rect.minY + CGFloat(p.1) * rect.height))
                        }
                    }
                }
                .stroke(.cyan, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            } else if shape == .circle && assay == .openField {
                let center = displayPoint(calibration.circleCenter, in: rect)
                let edge = displayPoint(calibration.circleEdge, in: rect)
                let radius = hypot(edge.x - center.x, edge.y - center.y) * CGFloat(config.centerFraction)
                Circle()
                    .stroke(.cyan, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
            }
        }
    }

    /// Zone outlines in arena-normalized coordinates for rectangular arenas.
    private func rectangleZoneLines(_ c: ZoneConfig) -> [[(Double, Double)]] {
        switch assay {
        case .openField:
            let a = (1 - c.centerFraction) / 2, b = (1 + c.centerFraction) / 2
            return [[(a, a), (b, a), (b, b), (a, b), (a, a)]]
        case .lightDark:
            let x = c.lightOnLeft ? c.lightFraction : 1 - c.lightFraction
            return x > 0.001 && x < 0.999 ? [[(x, 0), (x, 1)]] : []
        case .placePreference:
            if c.cppChambers >= 3 {
                let a = (1 - c.cppNeutralFraction) / 2, b = (1 + c.cppNeutralFraction) / 2
                return [[(a, 0), (a, 1)], [(b, 0), (b, 1)]]
            }
            return [[(c.cppDivider, 0), (c.cppDivider, 1)]]
        default:
            return []
        }
    }

    @ViewBuilder
    private func markerOverlay(in rect: CGRect) -> some View {
        switch assay {
        case .novelObject:
            markerHandle("A", point: calibration.markerA, in: rect) { calibration.markerA = $0 }
            markerHandle("B", point: calibration.markerB, in: rect) { calibration.markerB = $0 }
        case .morrisWaterMaze:
            if shape == .circle {
                quadrantLines(in: rect)
                markerHandle("P", point: calibration.markerTarget, in: rect) { calibration.markerTarget = $0 }
            }
        case .barnesMaze:
            if shape == .circle {
                holeRing(in: rect)
                markerHandle("T", point: calibration.markerTarget, in: rect) { calibration.markerTarget = $0 }
            }
        default:
            EmptyView()
        }
    }

    private func markerHandle(_ label: String, point: NormalizedPoint, in rect: CGRect, set: @escaping (NormalizedPoint) -> Void) -> some View {
        calibrationHandle(label: label, at: displayPoint(point, in: rect), color: .cyan)
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                set(normalizedPoint(from: value.location, in: rect))
            })
    }

    private func quadrantLines(in rect: CGRect) -> some View {
        let c = displayPoint(calibration.circleCenter, in: rect)
        let e = displayPoint(calibration.circleEdge, in: rect)
        let p = displayPoint(calibration.markerTarget, in: rect)
        let r = hypot(e.x - c.x, e.y - c.y)
        let a = atan2(Double(p.y - c.y), Double(p.x - c.x))
        return Path { path in
            for offset in [Double.pi / 4, -Double.pi / 4] {
                let dx = CGFloat(cos(a + offset)) * r
                let dy = CGFloat(sin(a + offset)) * r
                path.move(to: CGPoint(x: c.x - dx, y: c.y - dy))
                path.addLine(to: CGPoint(x: c.x + dx, y: c.y + dy))
            }
        }
        .stroke(.cyan.opacity(0.85), style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
    }

    private func holeRing(in rect: CGRect) -> some View {
        let c = displayPoint(calibration.circleCenter, in: rect)
        let p = displayPoint(calibration.markerTarget, in: rect)
        let ring = hypot(p.x - c.x, p.y - c.y)
        let a = atan2(Double(p.y - c.y), Double(p.x - c.x))
        let count = max(4, zoneConfig?.holeCount ?? 20)
        return Path { path in
            for k in 1..<count {
                let angle = a + 2 * Double.pi * Double(k) / Double(count)
                let center = CGPoint(x: c.x + CGFloat(cos(angle)) * ring, y: c.y + CGFloat(sin(angle)) * ring)
                path.addEllipse(in: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8))
            }
        }
        .stroke(.cyan.opacity(0.9), lineWidth: 1.2)
    }

    private func calibrationHandle(label: String, at point: CGPoint, color: Color = .yellow) -> some View {
        ZStack {
            Circle().fill(.black.opacity(0.65)).frame(width: handleSize, height: handleSize)
            Circle().stroke(color, lineWidth: 3).frame(width: handleSize - 4, height: handleSize - 4)
            Text(label)
                .font(.system(size: 10.5, weight: .bold))
                .foregroundStyle(.white)
        }
        .position(point)
    }

    private func displayPoint(_ point: NormalizedPoint, in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.minX + CGFloat(point.x) * rect.width, y: rect.minY + CGFloat(point.y) * rect.height)
    }

    private func normalizedPoint(from point: CGPoint, in rect: CGRect) -> NormalizedPoint {
        let nx = ((point.x - rect.minX) / rect.width).clamped(to: 0...1)
        let ny = ((point.y - rect.minY) / rect.height).clamped(to: 0...1)
        return NormalizedPoint(x: nx, y: ny)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
