//
//  GameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/19/26.
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameState: GameState
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
        _gameState = StateObject(wrappedValue: GameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Classic Sliding",
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
                gameState.shuffleGrid()
            }
        ) {
            if !gameState.currentGrid.isEmpty {
                PuzzleGridView(gameState: gameState)
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

struct PuzzleGridView: View {
    @ObservedObject var gameState: GameState
    @State private var draggedPiece: (row: Int, col: Int)? = nil
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let gridSize = gameState.level
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(gridSize - 1)
            let pieceSize = (min(geometry.size.width, geometry.size.height) - totalSpacing) / CGFloat(gridSize)

            ZStack {
                // Render grid
                VStack(spacing: spacing) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                if row < gameState.currentGrid.count && col < gameState.currentGrid[row].count {
                                    if let image = gameState.currentGrid[row][col] {
                                        // Calculate if this piece should be offset during drag
                                        let offset = getOffset(for: row, col: col, pieceSize: pieceSize, spacing: spacing)

                                        // Puzzle piece
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: pieceSize, height: pieceSize)
                                            .offset(offset)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                handleTap(row: row, col: col)
                                            }
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        handleDragChanged(row: row, col: col, translation: value.translation)
                                                    }
                                                    .onEnded { value in
                                                        handleDragEnded(row: row, col: col, translation: value.translation, pieceSize: pieceSize)
                                                    }
                                            )
                                    } else {
                                        // Empty space
                                        Rectangle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: pieceSize, height: pieceSize)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func handleTap(row: Int, col: Int) {
        let emptyRow = gameState.emptyRow
        let emptyCol = gameState.emptyCol

        // Check if tapped piece is in same row or column as empty
        if row == emptyRow {
            // Same row - slide horizontally
            let distance = abs(col - emptyCol)
            if distance > 0 {
                withAnimation(.easeOut(duration: 0.25)) {
                    gameState.slidePieces(fromRow: row, fromCol: col, steps: distance)
                }
            }
        } else if col == emptyCol {
            // Same column - slide vertically
            let distance = abs(row - emptyRow)
            if distance > 0 {
                withAnimation(.easeOut(duration: 0.25)) {
                    gameState.slidePieces(fromRow: row, fromCol: col, steps: distance)
                }
            }
        }
    }

    private func getOffset(for row: Int, col: Int, pieceSize: CGFloat, spacing: CGFloat) -> CGSize {
        guard let dragged = draggedPiece else { return .zero }

        let emptyRow = gameState.emptyRow
        let emptyCol = gameState.emptyCol

        // Check if in same row or column as empty
        if row == emptyRow && row == dragged.row {
            // Horizontal movement - include all pieces from dragged to empty (excluding empty)
            let shouldMove: Bool
            if dragged.col < emptyCol {
                shouldMove = col >= dragged.col && col < emptyCol
            } else {
                shouldMove = col > emptyCol && col <= dragged.col
            }

            if shouldMove {
                // Visual offset matches drag direction
                return CGSize(width: dragOffset.width, height: 0)
            }
        } else if col == emptyCol && col == dragged.col {
            // Vertical movement - include all pieces from dragged to empty (excluding empty)
            let shouldMove: Bool
            if dragged.row < emptyRow {
                shouldMove = row >= dragged.row && row < emptyRow
            } else {
                shouldMove = row > emptyRow && row <= dragged.row
            }

            if shouldMove {
                // Visual offset matches drag direction
                return CGSize(width: 0, height: dragOffset.height)
            }
        }

        return .zero
    }

    private func handleDragChanged(row: Int, col: Int, translation: CGSize) {
        let emptyRow = gameState.emptyRow
        let emptyCol = gameState.emptyCol

        // Only allow drag if in same row or column as empty
        if row == emptyRow || col == emptyCol {
            draggedPiece = (row, col)
            dragOffset = translation
        }
    }

    private func handleDragEnded(row: Int, col: Int, translation: CGSize, pieceSize: CGFloat) {
        let emptyRow = gameState.emptyRow
        let emptyCol = gameState.emptyCol

        // Calculate if we should snap
        if row == emptyRow {
            // Horizontal drag
            let threshold = pieceSize / 2
            let distance = abs(col - emptyCol)

            if abs(translation.width) > threshold && distance > 0 {
                // Snap - move ALL pieces between dragged piece and empty
                withAnimation(.easeOut(duration: 0.25)) {
                    gameState.slidePieces(fromRow: row, fromCol: col, steps: distance)
                }
            }
        } else if col == emptyCol {
            // Vertical drag
            let threshold = pieceSize / 2
            let distance = abs(row - emptyRow)

            if abs(translation.height) > threshold && distance > 0 {
                // Snap - move ALL pieces between dragged piece and empty
                withAnimation(.easeOut(duration: 0.25)) {
                    gameState.slidePieces(fromRow: row, fromCol: col, steps: distance)
                }
            }
        }

        // Reset drag state
        draggedPiece = nil
        dragOffset = .zero
    }
}
