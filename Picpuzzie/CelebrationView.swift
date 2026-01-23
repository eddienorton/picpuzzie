//
//  CelebrationView.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct CelebrationView: View {
    @State private var isAnimating = false
    @State private var colorIndex = 0

    let emojis = ["⭐️", "✨", "🌟", "💫"]
    let particleCount = 120
    let colors = [
        Color.red,
        Color.orange,
        Color.yellow,
        Color.green,
        Color.blue,
        Color.purple
    ]

    var body: some View {
        ZStack {
            // Full screen color fade background
            Rectangle()
                .fill(colors[colorIndex].opacity(0.3))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: colorIndex)

            // Emoji particles
            ForEach(0..<particleCount, id: \.self) { index in
                Text(emojis[index % emojis.count])
                    .font(.system(size: randomSize()))
                    .offset(x: isAnimating ? randomOffset() : 0,
                           y: isAnimating ? randomOffset() : 0)
                    .opacity(isAnimating ? 0 : 1)
                    .scaleEffect(isAnimating ? 2.5 : 0.5)
                    .animation(
                        .easeOut(duration: 1.8)
                        .delay(Double(index) * 0.02),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true

            // Cycle through colors quickly
            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                    colorIndex = i % colors.count
                }
            }
        }
    }

    private func randomOffset() -> CGFloat {
        CGFloat.random(in: -250...250)
    }

    private func randomSize() -> CGFloat {
        CGFloat.random(in: 30...50)
    }
}

struct CelebrationOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            CelebrationView()
                .onAppear {
                    // Trigger haptic feedback
                    triggerHaptics()

                    // Hide after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isShowing = false
                    }
                }
        }
    }

    private func triggerHaptics() {
        // Initial strong notification
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        // Follow up with additional vibrations
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.prepare()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            impact.impactOccurred()
        }
    }
}
