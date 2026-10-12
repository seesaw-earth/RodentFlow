import SwiftUI

struct TrackingOverlayView: View {
    let points: [TrackingPoint]
    let relativeTime: Double
    let videoAspectRatio: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let rect = aspectFitRect(
                aspectRatio: videoAspectRatio,
                in: CGRect(origin: .zero, size: geometry.size)
            )
            let visible = points.filter {
                $0.clipTimeSeconds <= relativeTime &&
                $0.clipTimeSeconds >= max(0, relativeTime - 2.5)
            }
            let current = nearestPoint(to: relativeTime)

            ZStack {
                if visible.count > 1 {
                    Path { path in
                        guard let first = visible.first else { return }
                        path.move(to: displayPoint(first, in: rect))
                        for point in visible.dropFirst() {
                            path.addLine(to: displayPoint(point, in: rect))
                        }
                    }
                    .stroke(.orange.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }

                if let current {
                    let p = displayPoint(current, in: rect)
                    Circle()
                        .fill(current.interpolated ? Color.yellow : Color.mint)
                        .frame(width: 13, height: 13)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .shadow(radius: 3)
                        .position(p)

                    Text(current.zone == "arena"
                         ? String(format: "%.0f%%", current.confidence * 100)
                         : "\(loc(current.zone)) · \(String(format: "%.0f%%", current.confidence * 100))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.65), in: Capsule())
                        .foregroundStyle(.white)
                        .position(x: min(rect.maxX - 42, p.x + 42), y: max(rect.minY + 14, p.y - 22))
                }

                VStack {
                    HStack {
                        Label("TRACKING", systemImage: "scope")
                            .font(.system(size: 11.5, weight: .bold))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.68), in: Capsule())
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(9)
            }
            .allowsHitTesting(false)
        }
    }

    private func nearestPoint(to time: Double) -> TrackingPoint? {
        guard !points.isEmpty else { return nil }
        return points.min(by: {
            abs($0.clipTimeSeconds - time) < abs($1.clipTimeSeconds - time)
        })
    }

    private func displayPoint(_ point: TrackingPoint, in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + CGFloat(point.imageXNormalized) * rect.width,
            y: rect.minY + CGFloat(point.imageYNormalized) * rect.height
        )
    }
}
