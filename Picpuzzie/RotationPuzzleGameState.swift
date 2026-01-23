//
//  RotationPuzzleGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

class RotationPuzzleGameState: ObservableObject {
    @Published var pieces: [[UIImage]] = []
    @Published var pieceRotations: [[Double]] = [] // Rotation in degrees for each piece (0, 90, 180, 270)
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0

    private var solvedRotations: [[Double]] = [] // All should be 0

    var gridSize: Int { level }

    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let slicedPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !slicedPieces.isEmpty else {
            print("RotationPuzzleGameState: Failed to slice image into grid")
            return
        }

        pieces = slicedPieces
        solvedRotations = Array(repeating: Array(repeating: 0.0, count: gridSize), count: gridSize)
        pieceRotations = Array(repeating: Array(repeating: 0.0, count: gridSize), count: gridSize)

        // Shuffle the pieces
        shufflePieces()

        isSolved = false
        moveCount = 0
    }

    func shufflePieces() {
        // Randomly rotate each piece to 0°, 90°, 180°, or 270°
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let randomRotation = [0.0, 90.0, 180.0, 270.0].randomElement() ?? 0.0
                pieceRotations[row][col] = randomRotation
            }
        }

        // Make sure at least one piece is NOT at 0° (otherwise might start solved)
        var hasNonZeroRotation = false
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if pieceRotations[row][col] != 0.0 {
                    hasNonZeroRotation = true
                    break
                }
            }
            if hasNonZeroRotation { break }
        }

        // If all pieces happened to be 0°, rotate a random piece
        if !hasNonZeroRotation {
            let randomRow = Int.random(in: 0..<gridSize)
            let randomCol = Int.random(in: 0..<gridSize)
            pieceRotations[randomRow][randomCol] = [90.0, 180.0, 270.0].randomElement() ?? 90.0
        }

        moveCount = 0
    }

    // MARK: - Piece Rotation

    func rotatePiece(row: Int, col: Int) {
        guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }

        // Rotate by 90 degrees clockwise
        // Don't normalize - let it accumulate so animation always goes forward
        pieceRotations[row][col] += 90.0

        moveCount += 1
        checkIfSolved()
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Check if all pieces are at 0° rotation (modulo 360)
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let normalizedRotation = pieceRotations[row][col].truncatingRemainder(dividingBy: 360)
                if normalizedRotation != 0.0 {
                    isSolved = false
                    return
                }
            }
        }

        // All pieces at 0° (or multiples of 360°)!
        isSolved = true
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        // Re-slice the new image into a grid with the same gridSize
        let newPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !newPieces.isEmpty else {
            print("RotationPuzzleGameState: Failed to slice new image into grid")
            return
        }

        // Update pieces with new image
        pieces = newPieces

        // Keep pieceRotations, moveCount, and isSolved unchanged
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
