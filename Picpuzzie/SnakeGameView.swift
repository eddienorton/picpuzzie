//
//  SnakeGameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

struct SnakeGameView: View {
    @StateObject private var gameState: SnakeGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void

    init(sourceImage: UIImage, startingLevel: Int = 10, currentLevel: Int, maxUnlockedLevel: Int, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void, onNextPuzzle: @escaping () -> Void) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        _gameState = StateObject(wrappedValue: SnakeGameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Snake",
            levelText: "Level: \(gameState.level)x\(gameState.level)",
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
                gameState.shuffleSnake()
            }
        ) {
            if !gameState.pieces.isEmpty {
                SnakeGridView(gameState: gameState)
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

struct SnakeGridView: View {
    @ObservedObject var gameState: SnakeGameState
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let gridSize = gameState.gridSize
            let pieceSize = size / CGFloat(gridSize)

            // Calculate stepped offset for piece selection and continuous offset for smooth sliding
            let continuousDrag = isDragging ? -dragOffset / pieceSize : 0
            let dragSteps = Int(continuousDrag)
            let fractional = continuousDrag - CGFloat(dragSteps)
            let visualOffset = fractional * pieceSize

            let currentOffset = (gameState.snakeOffset + dragSteps + gameState.totalPieces) % gameState.totalPieces

            VStack(spacing: 0) {
                ForEach(0..<gridSize, id: \.self) { row in
                    // Zigzag: odd rows shift opposite direction
                    let rowOffset = row % 2 == 0 ? -visualOffset : visualOffset

                    HStack(spacing: 0) {
                        // Render extra pieces for wrapping (before and after visible range)
                        ForEach(-1..<gridSize+1, id: \.self) { col in
                            let actualCol = (col + gridSize) % gridSize

                            // Zigzag grid indexing: even rows L→R, odd rows R→L
                            let gridIndex = row % 2 == 0
                                ? row * gridSize + actualCol
                                : row * gridSize + (gridSize - 1 - actualCol)

                            let snakeIndex = (currentOffset + gridIndex) % gameState.totalPieces
                            let piece = gameState.flatPieces[snakeIndex]

                            Image(uiImage: piece)
                                .resizable()
                                .frame(width: pieceSize, height: pieceSize)
                                .border(Color.white.opacity(0.2), width: 0.5)
                        }
                    }
                    .offset(x: rowOffset)
                    .frame(width: size, height: pieceSize)
                    .clipped()
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        handleDragEnded(translation: value.translation.width, pieceSize: pieceSize)
                    }
            )
        }
    }

    private func handleDragEnded(translation: CGFloat, pieceSize: CGFloat) {
        // Calculate how many steps to move based on drag distance (negate for correct direction)
        let steps = -Int(round(translation / pieceSize))

        if steps != 0 {
            // Animate to snapped position
            let snappedOffset = -CGFloat(steps) * pieceSize

            withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = snappedOffset
            }

            // Update state after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                gameState.advanceSnake(steps: steps)
                isDragging = false
                dragOffset = 0
            }
        } else {
            // No movement - just snap back
            withAnimation(.easeOut(duration: 0.2)) {
                isDragging = false
                dragOffset = 0
            }
        }
    }
}
