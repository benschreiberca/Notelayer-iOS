import SwiftUI
import UIKit

struct ThemeBackground: View {
    @EnvironmentObject private var theme: ThemeManager
    let configuration: ThemeConfiguration
    var tokens: DesignTokens? = nil
    var ignoresSafeArea: Bool = true

    var body: some View {
        let resolvedTokens = tokens ?? theme.tokens
        let wallpaperVariant = resolvedTokens.wallpaper
        let content = ZStack {
            resolvedTokens.screenBackground

            switch configuration.wallpaper.kind {
            case .gradient:
                if let gradient = wallpaperVariant.gradient {
                    renderGradient(gradient)
                        .opacity(gradientOpacity)
                        .blur(radius: 16)
                }

            case .pattern:
                if let pattern = wallpaperVariant.pattern {
                    PatternWallpaper(
                        patternId: pattern.id,
                        background: Color(hex: pattern.backgroundHex) ?? resolvedTokens.screenBackground,
                        foreground: Color(hex: pattern.foregroundHex) ?? resolvedTokens.textPrimary,
                        intensity: configuration.intensity
                    )
                }

            case .designer:
                if let designer = wallpaperVariant.designer {
                    DesignerWallpaper(
                        background: Color(hex: designer.backgroundHex) ?? resolvedTokens.screenBackground,
                        foreground: Color(hex: designer.foregroundHex) ?? resolvedTokens.textPrimary,
                        intensity: configuration.intensity,
                        id: designer.id
                    )
                }

            case .image:
                if let resolved = resolvedImageWallpaper() {
                    ImageWallpaper(url: resolved.url, mode: resolved.mode)
                        .opacity(imageOpacity)
                }
            }
        }

        if ignoresSafeArea {
            content.ignoresSafeArea()
        } else {
            content
        }
    }

    private var gradientOpacity: Double {
        0.2 + (ThemeConfiguration.clampedIntensity(configuration.intensity) * 0.6)
    }

    private var imageOpacity: Double {
        0.4 + (ThemeConfiguration.clampedIntensity(configuration.intensity) * 0.5)
    }

    private func resolvedImageWallpaper() -> (url: URL, mode: ImageWallpaperMode)? {
        let matched = theme.userWallpapers.first { $0.id == configuration.wallpaper.id }
        let filename = configuration.wallpaper.imageFilename ?? matched?.filename
        let mode = configuration.wallpaper.imageMode ?? matched?.mode ?? .fill
        guard let filename, let url = theme.imageURL(for: filename) else { return nil }
        return (url, mode)
    }

    @ViewBuilder
    private func renderGradient(_ gradient: GradientVariant) -> some View {
        let colors = gradient.colors.compactMap { Color(hex: $0) }
        let resolved = colors.isEmpty ? [Color(.systemBackground)] : colors
        switch gradient.configuration.type {
        case .linear:
            LinearGradient(colors: resolved, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .radial:
            RadialGradient(colors: resolved, center: .center, startRadius: 0, endRadius: 240)
        case .angular:
            AngularGradient(colors: resolved, center: .center)
        }
    }
}

private struct PatternWallpaper: View {
    let patternId: String
    let background: Color
    let foreground: Color
    let intensity: Double

    var body: some View {
        ZStack {
            background
            switch patternId {
            case "cheetah":
                CheetahBackground(color: foreground)
                    .opacity(0.2 + (ThemeConfiguration.clampedIntensity(intensity) * 0.5))
            default:
                DotPattern(color: foreground)
                    .opacity(0.15 + (ThemeConfiguration.clampedIntensity(intensity) * 0.4))
            }
        }
    }
}

private struct DesignerWallpaper: View {
    let background: Color
    let foreground: Color
    let intensity: Double
    let id: String

    var body: some View {
        ZStack {
            background
            if id == "gucci-monogram" {
                MonogramPattern(color: foreground)
                    .opacity(0.2 + (ThemeConfiguration.clampedIntensity(intensity) * 0.4))
            } else {
                DiagonalWeavePattern(color: foreground)
                    .opacity(0.15 + (ThemeConfiguration.clampedIntensity(intensity) * 0.35))
            }
        }
    }
}

private struct ImageWallpaper: View {
    let url: URL
    let mode: ImageWallpaperMode

    var body: some View {
        switch mode {
        case .fill:
            GeometryReader { geo in
                if let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            }
        case .tile:
            if let uiImage = UIImage(contentsOfFile: url.path) {
                Rectangle()
                    .fill(
                        ImagePaint(image: Image(uiImage: uiImage), scale: 0.4)
                    )
            }
        }
    }
}

private struct DotPattern: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 40
            var y: CGFloat = 0
            while y < size.height + step {
                var x: CGFloat = 0
                while x < size.width + step {
                    let dot = CGRect(x: x, y: y, width: 6, height: 6)
                    context.fill(Path(ellipseIn: dot), with: .color(color))
                    x += step
                }
                y += step
            }
        }
    }
}

private struct MonogramPattern: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 80
            var y: CGFloat = 0
            let resolvedText = context.resolve(
                Text("GG")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(color)
            )
            while y < size.height + step {
                var x: CGFloat = 0
                while x < size.width + step {
                    context.draw(resolvedText, at: CGPoint(x: x + 24, y: y + 20))
                    context.draw(resolvedText, at: CGPoint(x: x + 56, y: y + 50))
                    x += step
                }
                y += step
            }
        }
    }
}

private struct DiagonalWeavePattern: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 30
            var x: CGFloat = -size.height
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 3)
                x += step
            }
        }
    }
}
