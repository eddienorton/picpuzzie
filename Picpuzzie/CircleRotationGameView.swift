//
//  CircleRotationGameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct CircleRotationGameView: View {
    @StateObject private var gameState: CircleRotationGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void

    init(sourceImage: UIImage, startingLevel: Int = 5, currentLevel: Int, maxUnlockedLevel: Int = 5, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void = { _ in }, onNextPuzzle: @escaping () -> Void) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        _gameState = StateObject(wrappedValue: CircleRotationGameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Circle Rotation",
            levelText: "Rings: \(gameState.level)",
            moveCount: gameState.moveCount,
            isSolved: gameState.isSolved,
            currentLevel: currentLevel,
            maxUnlockedLevel: maxUnlockedLevel,
            showingCelebration: $showingCelebration,
            onLevelSelected: onLevelSelected,
            onNextLevel: onNextLevel,
            onNewPhoto: {
                // Call parent's onNewPhoto to update background image in ContentView
                onNewPhoto()
            },
            onPhotoSelected: onPhotoSelected,
            onNextPuzzle: onNextPuzzle,
            onShuffle: {
                gameState.shuffleRings()
            }
        ) {
            if !gameState.rings.isEmpty {
                RotatingRingsView(gameState: gameState)
                    .aspectRatio(1, contentMode: .fit)
                  
            }
        }
        .onAppear {
            gameState.setupGame(with: sourceImage)
        }
        .onChange(of: gameState.isSolved) { _, solved in
            if solved {
                showingCelebration = true
            }
        }
    }
}

struct RotatingRingsView: View {
    @ObservedObject var gameState: CircleRotationGameState
    @State private var draggedRingIndex: Int? = nil
    @State private var lastAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)

            ZStack {
                // Draw all rings from outermost to innermost
                ForEach(0..<gameState.rings.count, id: \.self) { index in
                    Image(uiImage: gameState.rings[index].image)
                        .resizable()
                        .frame(width: size, height: size)
                        .rotationEffect(.degrees(gameState.ringRotations[index]))
                }
            }
            .frame(width: size, height: size)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        handleDragChanged(value: value, center: center, maxRadius: size / 2)
                    }
                    .onEnded { _ in
                        handleDragEnded()
                    }
            )
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func handleDragChanged(value: DragGesture.Value, center: CGPoint, maxRadius: CGFloat) {
        // Calculate angle from center
        let dx = value.location.x - center.x
        let dy = value.location.y - center.y
        let angle = atan2(dy, dx) * 180 / .pi

        // If this is the first touch, determine which ring and lock it
        if draggedRingIndex == nil {
            let distance = sqrt(dx * dx + dy * dy)
            let ringThickness = maxRadius / CGFloat(gameState.rings.count)
            let ringIndex = Int((maxRadius - distance) / ringThickness)

            // Clamp to valid range
            guard ringIndex >= 0 && ringIndex < gameState.rings.count else { return }

            // Lock this ring for the entire drag
            draggedRingIndex = ringIndex
            lastAngle = angle
            return
        }

        // Continue dragging the locked ring
        if let ringIndex = draggedRingIndex {
            // Calculate delta from last angle
            var delta = angle - lastAngle

            // Handle wraparound
            if delta > 180 { delta -= 360 }
            if delta < -180 { delta += 360 }

            gameState.updateRingRotation(ringIndex: ringIndex, delta: delta)
            lastAngle = angle
        }
    }

    private func handleDragEnded() {
        if let ringIndex = draggedRingIndex {
            withAnimation(.easeOut(duration: 0.2)) {
                gameState.snapRingToNearestPosition(ringIndex: ringIndex)
            }
        }
        draggedRingIndex = nil
        lastAngle = 0
    }
}
