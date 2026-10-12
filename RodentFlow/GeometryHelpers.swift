import SwiftUI

func aspectFitRect(aspectRatio: CGFloat, in container: CGRect) -> CGRect {
    guard aspectRatio > 0, container.width > 0, container.height > 0 else { return container }
    let containerAspect = container.width / container.height
    if containerAspect > aspectRatio {
        let height = container.height
        let width = height * aspectRatio
        return CGRect(x: container.midX - width / 2, y: container.minY, width: width, height: height)
    } else {
        let width = container.width
        let height = width / aspectRatio
        return CGRect(x: container.minX, y: container.midY - height / 2, width: width, height: height)
    }
}

extension Double {
    var minuteSecondString: String {
        let total = max(0, Int(self.rounded()))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
