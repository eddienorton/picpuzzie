//
//  FlipGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

class FlipGameState: ObservableObject {
    @Published var pieces: [[UIImage]] = []
    @Published var pieceFlipped: [[Bool]] = [] // true = flipped 180°, false = correct orientation
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0

    var gridSize: Int { level }

    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let slicedPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !slicedPieces.isEmpty else {
            print("FlipGameState: Failed to slice image into grid")
            return
        }

        pieces = slicedPieces
        pieceFlipped = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)

        // Shuffle the pieces
        shufflePieces()

        isSolved = false
        moveCount = 0
    }

    func shufflePieces() {
        // Randomly flip pieces
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                pieceFlipped[row][col] = Bool.random()
            }
        }

        // Make sure at least one piece is flipped
        var hasFlipped = false
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if pieceFlipped[row][col] {
                    hasFlipped = true
                    break
                }
            }
            if hasFlipped { break }
        }

        // If no pieces flipped, flip a random one
        if !hasFlipped {
            let randomRow = Int.random(in: 0..<gridSize)
            let randomCol = Int.random(in: 0..<gridSize)
            pieceFlipped[randomRow][randomCol] = true
        }

        moveCount = 0
    }

    // MARK: - Piece Flipping

    func flipPiece(row: Int, col: Int) {
        guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }

        // Toggle flip state
        pieceFlipped[row][col].toggle()

        moveCount += 1
        checkIfSolved()
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Check if all pieces are not flipped (false)
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if pieceFlipped[row][col] {
                    isSolved = false
                    return
                }
            }
        }

        // All pieces correctly oriented!
        isSolved = true
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        let newPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !newPieces.isEmpty else {
            print("FlipGameState: Failed to slice new image into grid")
            return
        }

        pieces = newPieces
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
