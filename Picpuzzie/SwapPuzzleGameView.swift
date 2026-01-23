//
//  SwapPuzzleGameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

struct SwapPuzzleGameView: View {
    @StateObject private var gameState: SwapPuzzleGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void

    init(sourceImage: UIImage, startingLevel: Int = 3, currentLevel: Int, maxUnlockedLevel: Int, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void, onNextPuzzle: @escaping () -> Void) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        _gameState = StateObject(wrappedValue: SwapPuzzleGameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Swap",
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
                gameState.setupGame(with: sourceImage)
            }
        ) {
            if !gameState.pieces.isEmpty {
                SwapPuzzleGridView(gameState: gameState)
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

struct SwapPuzzleGridView: View {
    @ObservedObject var gameState: SwapPuzzleGameState

    var body: some View {
        GeometryReader { geometry in
            let gridSize = gameState.level
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(gridSize - 1)
            let pieceSize = (min(geometry.size.width, geometry.size.height) - totalSpacing) / CGFloat(gridSize)

            VStack(spacing: spacing) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            let piece = gameState.pieces[row][col]
                            let isSelected = gameState.selectedPiece?.row == row && gameState.selectedPiece?.col == col

                            Image(uiImage: piece)
                                .resizable()
                                .frame(width: pieceSize, height: pieceSize)
                                .overlay(
                                    Rectangle()
                                        .stroke(isSelected ? Color.yellow : Color.white.opacity(0.3), lineWidth: isSelected ? 4 : 1)
                                )
                                .scaleEffect(isSelected ? 1.05 : 1.0)
                                .shadow(color: isSelected ? .yellow.opacity(0.8) : .clear, radius: isSelected ? 10 : 0)
                                .zIndex(isSelected ? 1 : 0)
                                .animation(.spring(response: 0.3), value: isSelected)
                                .onTapGesture {
                                    gameState.tapPiece(row: row, col: col)
                                }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}
