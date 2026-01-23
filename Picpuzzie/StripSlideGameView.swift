//
//  StripSlideGameView.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

struct StripSlideGameView: View {
    @StateObject private var gameState: StripSlideGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void

    init(sourceImage: UIImage, startingLevel: Int = 5, currentLevel: Int, maxUnlockedLevel: Int, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void, onNextPuzzle: @escaping () -> Void) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        _gameState = StateObject(wrappedValue: StripSlideGameState(startingLevel: startingLevel))
    }

    var body: some View {
        PuzzleContainerView(
            title: "Strip Sliding",
            levelText: "\(gameState.level) strips (\(gameState.orientation == .vertical ? "Vertical" : "Horizontal"))",
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
                gameState.shuffleStrips()
            }
        ) {
            if !gameState.strips.isEmpty {
                StripsPuzzleView(gameState: gameState)
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

struct StripsPuzzleView: View {
    @ObservedObject var gameState: StripSlideGameState
    @State private var dragOffset: CGFloat = 0
    @State private var draggedStripIndex: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let isVertical = gameState.orientation == .vertical
            let stripCount = gameState.strips.count
            let stripSize = size / CGFloat(stripCount)
            let pieceSize = size / CGFloat(gameState.piecesPerStrip)

            ZStack {
                if isVertical {
                    // Vertical strips
                    HStack(spacing: 0) {
                        ForEach(0..<stripCount, id: \.self) { index in
                            renderVerticalStrip(index: index, stripSize: stripSize, totalHeight: size, pieceSize: pieceSize)
                        }
                    }
                } else {
                    // Horizontal strips
                    VStack(spacing: 0) {
                        ForEach(0..<stripCount, id: \.self) { index in
                            renderHorizontalStrip(index: index, stripSize: stripSize, totalWidth: size, pieceSize: pieceSize)
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .clipped()
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    @ViewBuilder
    private func renderVerticalStrip(index: Int, stripSize: CGFloat, totalHeight: CGFloat, pieceSize: CGFloat) -> some View {
        let offset = gameState.stripOffsets[index]
        let pixelOffset = CGFloat(offset) * pieceSize
        let isDragging = draggedStripIndex == index

        ZStack {
            // Main strip
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: stripSize, height: totalHeight)
                .offset(y: isDragging ? dragOffset + pixelOffset : pixelOffset)

            // Wraparound copy (top)
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: stripSize, height: totalHeight)
                .offset(y: isDragging ? dragOffset + pixelOffset - totalHeight : pixelOffset - totalHeight)

            // Wraparound copy (bottom)
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: stripSize, height: totalHeight)
                .offset(y: isDragging ? dragOffset + pixelOffset + totalHeight : pixelOffset + totalHeight)
        }
        .frame(width: stripSize, height: totalHeight)
        .clipped()
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    draggedStripIndex = index
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    handleDragEnd(stripIndex: index, translation: value.translation.height, pieceSize: pieceSize)
                }
        )
    }

    @ViewBuilder
    private func renderHorizontalStrip(index: Int, stripSize: CGFloat, totalWidth: CGFloat, pieceSize: CGFloat) -> some View {
        let offset = gameState.stripOffsets[index]
        let pixelOffset = CGFloat(offset) * pieceSize
        let isDragging = draggedStripIndex == index

        ZStack {
            // Main strip
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: totalWidth, height: stripSize)
                .offset(x: isDragging ? dragOffset + pixelOffset : pixelOffset)

            // Wraparound copy (left)
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: totalWidth, height: stripSize)
                .offset(x: isDragging ? dragOffset + pixelOffset - totalWidth : pixelOffset - totalWidth)

            // Wraparound copy (right)
            Image(uiImage: gameState.strips[index])
                .resizable()
                .frame(width: totalWidth, height: stripSize)
                .offset(x: isDragging ? dragOffset + pixelOffset + totalWidth : pixelOffset + totalWidth)
        }
        .frame(width: totalWidth, height: stripSize)
        .clipped()
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    draggedStripIndex = index
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    handleDragEnd(stripIndex: index, translation: value.translation.width, pieceSize: pieceSize)
                }
        )
    }

    private func handleDragEnd(stripIndex: Int, translation: CGFloat, pieceSize: CGFloat) {
        let threshold = pieceSize / 2
        let numPositions = Int((abs(translation) + threshold) / pieceSize)

        if numPositions > 0 {
            let direction = translation > 0 ? numPositions : -numPositions
            gameState.slideStrip(stripIndex, direction: direction)
        }

        dragOffset = 0
        draggedStripIndex = nil
    }
}
