//
//  SnakeGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

class SnakeGameState: ObservableObject {
    @Published var pieces: [[UIImage]] = [] // Original grid slicing (for reference)
    @Published var snakeOffset: Int = 0 // Current starting position in the snake
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0

    var flatPieces: [UIImage] = [] // Linear array of pieces in snake order (public for live drag)

    var gridSize: Int { level }
    var totalPieces: Int { gridSize * gridSize }

    init(startingLevel: Int = 3) { // Start at 3x3 for clarity
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let slicedPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !slicedPieces.isEmpty else {
            print("SnakeGameState: Failed to slice image into grid")
            return
        }

        pieces = slicedPieces

        // Flatten into zigzag snake order
        flatPieces = []
        for (rowIndex, row) in slicedPieces.enumerated() {
            if rowIndex % 2 == 0 {
                // Even rows: left to right
                flatPieces.append(contentsOf: row)
            } else {
                // Odd rows: right to left (zigzag)
                flatPieces.append(contentsOf: row.reversed())
            }
        }

        // Randomize starting position
        shuffleSnake()

        isSolved = false
        moveCount = 0
    }

    func shuffleSnake() {
        // Start at a random offset (not 0, since that would be solved)
        snakeOffset = Int.random(in: 1..<totalPieces)
        moveCount = 0
    }

    // MARK: - Snake Movement

    func advanceSnake(steps: Int) {
        snakeOffset += steps

        // Wrap around
        while snakeOffset < 0 {
            snakeOffset += totalPieces
        }
        while snakeOffset >= totalPieces {
            snakeOffset -= totalPieces
        }

        moveCount += 1
        checkIfSolved()
    }

    // Get the piece at a grid position
    func getPieceAt(row: Int, col: Int) -> UIImage {
        let gridIndex = row * gridSize + col
        let snakeIndex = (snakeOffset + gridIndex) % totalPieces
        return flatPieces[snakeIndex]
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Solved when offset is 0 (piece #1 in top-left)
        isSolved = (snakeOffset == 0)
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        let newPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !newPieces.isEmpty else {
            print("SnakeGameState: Failed to slice new image into grid")
            return
        }

        pieces = newPieces

        // Flatten into zigzag snake order
        flatPieces = []
        for (rowIndex, row) in newPieces.enumerated() {
            if rowIndex % 2 == 0 {
                // Even rows: left to right
                flatPieces.append(contentsOf: row)
            } else {
                // Odd rows: right to left (zigzag)
                flatPieces.append(contentsOf: row.reversed())
            }
        }

        checkIfSolved()
    }

    // MARK: - Level Progression

    func nextLevel(with image: UIImage) {
        level += 1
        setupGame(with: image)
    }

    func resetLevel(with image: UIImage) {
        setupGame(with: image)
    }
}
