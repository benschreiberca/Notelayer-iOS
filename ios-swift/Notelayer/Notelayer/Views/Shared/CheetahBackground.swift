import SwiftUI

/// Subtle procedural cheetah print (no image assets).
struct CheetahBackground: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 54
            var y: CGFloat = -step
            while y < size.height + step {
                var x: CGFloat = -step
                while x < size.width + step {
                    let jitterX = CGFloat(sin((x + y) / 37)) * 6
                    let jitterY = CGFloat(cos((x - y) / 41)) * 6
                    let center = CGPoint(x: x + step/2 + jitterX, y: y + step/2 + jitterY)

                    // Ring blob
                    let outer = CGRect(x: center.x - 12, y: center.y - 8, width: 24, height: 16)
                    let inner = CGRect(x: center.x - 6, y: center.y - 4, width: 12, height: 8)
                    var outerPath = Path(ellipseIn: outer)
                    outerPath.addEllipse(in: inner)

                    context.fill(
                        outerPath,
                        with: .color(Color.black.opacity(0.08)),
                        style: FillStyle(eoFill: true)
                    )

                    // Offset spot
                    let dot = CGRect(x: center.x + 8, y: center.y - 2, width: 6, height: 4)
                    context.fill(Path(ellipseIn: dot), with: .color(Color.black.opacity(0.06)))

                    x += step
                }
                y += step
            }
        }
    }
}

