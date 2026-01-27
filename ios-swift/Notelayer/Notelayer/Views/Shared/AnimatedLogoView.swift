import SwiftUI

/// Animated logo with spin and confetti shatter effect.
/// Plays automatically on appear with a playful, under-1-second animation.
struct AnimatedLogoView: View {
    @State private var isAnimating = false
    @State private var particles: [ConfettiParticle] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let logoSize: CGFloat
    
    init(logoSize: CGFloat = 120) {
        self.logoSize = logoSize
    }
    
    var body: some View {
        ZStack {
            // Confetti particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.offset.width, y: particle.offset.height)
                    .opacity(particle.opacity)
            }
            
            // Logo (placeholder - replace with actual Notelayer logo)
            Image(systemName: "note.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize, height: logoSize)
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .scaleEffect(isAnimating ? 1.0 : 0.5)
        }
        .onAppear {
            if !reduceMotion {
                playAnimation()
            } else {
                // Skip animation for accessibility
                isAnimating = true
            }
        }
    }
    
    private func playAnimation() {
        // Spin and scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAnimating = true
        }
        
        // Trigger confetti after 0.3s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        var newParticles: [ConfettiParticle] = []
        
        // Generate 12 particles around the logo
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0)
            let distance: CGFloat = 80
            let radians = angle * .pi / 180
            
            let particle = ConfettiParticle(
                id: UUID(),
                offset: CGSize(
                    width: cos(radians) * distance,
                    height: sin(radians) * distance
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0
            )
            newParticles.append(particle)
        }
        
        particles = newParticles
        
        // Animate particles
        withAnimation(.easeOut(duration: 0.5)) {
            particles = particles.map { particle in
                var updated = particle
                updated.offset = CGSize(
                    width: particle.offset.width * 1.5,
                    height: particle.offset.height * 1.5
                )
                updated.opacity = 0
                return updated
            }
        }
        
        // Clean up particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles.removeAll()
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id: UUID
    var offset: CGSize
    let color: Color
    let size: CGFloat
    var opacity: Double
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        AnimatedLogoView(logoSize: 120)
    }
}
