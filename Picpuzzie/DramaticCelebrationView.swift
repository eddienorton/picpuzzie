//
//  DramaticCelebrationView.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

struct DramaticCelebrationView: View {
    @Binding var isShowing: Bool
    @State private var phase: AnimationPhase = .idle
    @State private var particles: [CelebrationParticle] = []

    enum AnimationPhase {
        case idle
        case flash
        case explode
        case snapBack
        case glow
        case done
    }

    var body: some View {
        ZStack {
            // White flash
            if phase == .flash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            // Explosion particles
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [particle.color, particle.color.opacity(0.3)],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }

            // Golden border glow
            if phase == .glow || phase == .done {
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.yellow, .orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: phase == .glow ? 8 : 4
                    )
                    .ignoresSafeArea()
                    .shadow(color: .yellow.opacity(0.8), radius: phase == .glow ? 20 : 10)
            }
        }
        .onChange(of: isShowing) { _, showing in
            if showing {
                startCelebration()
            }
        }
        .onAppear {
            if isShowing {
                startCelebration()
            }
        }
    }

    private func startCelebration() {
        // Trigger haptics
        triggerHaptics()

        // Phase 1: Flash (0.1s)
        phase = .flash

        // Phase 2: Explode particles (0.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                phase = .explode
                createParticles()
            }
        }

        // Phase 3: Snap back (0.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                phase = .snapBack
                snapParticlesBack()
            }
        }

        // Phase 4: Golden glow (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .glow
            }
        }

        // Phase 5: Done - fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                phase = .done
            }
        }

        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isShowing = false
            phase = .idle
            particles = []
        }
    }

    private func createParticles() {
        particles = []
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2

        // Create 60 particles
        for _ in 0..<60 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 200...400)
            let x = centerX + cos(angle) * distance
            let y = centerY + sin(angle) * distance

            let colors: [Color] = [.yellow, .orange, .red, .pink, .purple, .blue, .cyan]

            particles.append(CelebrationParticle(
                position: CGPoint(x: x, y: y),
                originalPosition: CGPoint(x: centerX, y: centerY),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...20),
                opacity: 1.0
            ))
        }
    }

    private func snapParticlesBack() {
        for i in particles.indices {
            particles[i].position = particles[i].originalPosition
            particles[i].opacity = 0.0
        }
    }

    private func triggerHaptics() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()

        // Explosion haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact.impactOccurred()
        }

        // Snap back haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            impact.impactOccurred(intensity: 0.8)
        }
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let originalPosition: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

struct DramaticCelebrationOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            DramaticCelebrationView(isShowing: $isShowing)
        }
    }
}
