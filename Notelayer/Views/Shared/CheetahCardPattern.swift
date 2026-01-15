import SwiftUI

/// Denser, subtler cheetah pattern intended for groups / items (distinct from screen background).
struct CheetahCardPattern: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 36
            var y: CGFloat = -step
            while y < size.height + step {
                var x: CGFloat = -step
                while x < size.width + step {
                    let jitterX = CGFloat(sin((x + y) / 29)) * 4
                    let jitterY = CGFloat(cos((x - y) / 31)) * 4
                    let center = CGPoint(x: x + step/2 + jitterX, y: y + step/2 + jitterY)

                    // Smaller ring blob
                    let outer = CGRect(x: center.x - 8, y: center.y - 5, width: 16, height: 10)
                    let inner = CGRect(x: center.x - 4, y: center.y - 2.5, width: 8, height: 5)
                    var outerPath = Path(ellipseIn: outer)
                    outerPath.addEllipse(in: inner)

                    context.fill(
                        outerPath,
                        with: .color(Color.black.opacity(0.06)),
                        style: FillStyle(eoFill: true)
                    )

                    x += step
                }
                y += step
            }
        }
    }
}

