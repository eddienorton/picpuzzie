//
//  RotationPuzzleGameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct RotationPuzzleGameView: View {
    @StateObject private var gameState: RotationPuzzleGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void
    let onShare: (() -> Void)?

    init(sourceImage: UIImage, startingLevel: Int = 3, currentLevel: Int, maxUnlockedLevel: Int, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void, onNextPuzzle: @escaping () -> Void, onShare: (() -> Void)? = nil) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        self.onShare = onShare
        _gameState = StateObject(wrappedValue: RotationPuzzleGameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Rotation Puzzle",
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
                gameState.shufflePieces()
            }
            ,
            onShare: onShare
        ) {
            if !gameState.pieces.isEmpty {
                RotationGridView(gameState: gameState)
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

struct RotationGridView: View {
    @ObservedObject var gameState: RotationPuzzleGameState

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let gridSize = gameState.gridSize
            let pieceSize = size / CGFloat(gridSize)

            VStack(spacing: 0) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            Image(uiImage: gameState.pieces[row][col])
                                .resizable()
                                .frame(width: pieceSize, height: pieceSize)
                                .rotationEffect(.degrees(gameState.pieceRotations[row][col]))
                                .clipped()
                                .border(Color.white.opacity(0.3), width: 1)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        gameState.rotatePiece(row: row, col: col)
                                    }
                                }
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
