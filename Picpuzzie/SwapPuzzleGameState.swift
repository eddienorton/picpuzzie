//
//  SwapPuzzleGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

class SwapPuzzleGameState: ObservableObject {
    @Published var pieces: [[UIImage]] = []
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0
    @Published var selectedPiece: (row: Int, col: Int)? = nil

    private var solvedPieces: [[UIImage]] = []
    private var gridSize: Int { level }

    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let slicedPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !slicedPieces.isEmpty else {
            print("SwapPuzzleGameState: Failed to slice image into grid")
            return
        }

        solvedPieces = slicedPieces
        pieces = slicedPieces

        // Shuffle the grid
        shufflePieces()

        isSolved = false
        moveCount = 0
        selectedPiece = nil
    }

    private func shufflePieces() {
        // Flatten, shuffle, and rebuild grid
        var flatPieces = pieces.flatMap { $0 }
        flatPieces.shuffle()

        // Rebuild into grid
        pieces = []
        for row in 0..<gridSize {
            var rowPieces: [UIImage] = []
            for col in 0..<gridSize {
                let index = row * gridSize + col
                rowPieces.append(flatPieces[index])
            }
            pieces.append(rowPieces)
        }

        // Make sure it's not already solved
        checkIfSolved()
        if isSolved {
            shufflePieces() // Shuffle again if accidentally solved
        }
    }

    func tapPiece(row: Int, col: Int) {
        if let selected = selectedPiece {
            // Second tap - swap with selected piece
            if selected.row == row && selected.col == col {
                // Tapped same piece - deselect
                selectedPiece = nil
            } else {
                // Swap pieces
                let temp = pieces[selected.row][selected.col]
                pieces[selected.row][selected.col] = pieces[row][col]
                pieces[row][col] = temp

                selectedPiece = nil
                moveCount += 1
                checkIfSolved()
            }
        } else {
            // First tap - select piece
            selectedPiece = (row, col)
        }
    }

    private func checkIfSolved() {
        guard pieces.count == gridSize && solvedPieces.count == gridSize else {
            isSolved = false
            return
        }

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if pieces[row][col] !== solvedPieces[row][col] {
                    isSolved = false
                    return
                }
            }
        }

        isSolved = true
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        let newPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !newPieces.isEmpty else {
            print("SwapPuzzleGameState: Failed to slice new image")
            return
        }

        // Create mapping of current positions
        var pieceMapping: [[Int?]] = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        for currentRow in 0..<gridSize {
            for currentCol in 0..<gridSize {
                let currentPiece = pieces[currentRow][currentCol]
                // Find where this piece belongs in solved grid
                for solvedRow in 0..<gridSize {
                    for solvedCol in 0..<gridSize {
                        if currentPiece === solvedPieces[solvedRow][solvedCol] {
                            pieceMapping[currentRow][currentCol] = solvedRow * gridSize + solvedCol
                            break
                        }
                    }
                }
            }
        }

        // Update to new image pieces
        solvedPieces = newPieces
        var newCurrentPieces: [[UIImage]] = Array(repeating: Array(repeating: UIImage(), count: gridSize), count: gridSize)

        for currentRow in 0..<gridSize {
            for currentCol in 0..<gridSize {
                if let pieceIndex = pieceMapping[currentRow][currentCol] {
                    let solvedRow = pieceIndex / gridSize
                    let solvedCol = pieceIndex % gridSize
                    newCurrentPieces[currentRow][currentCol] = newPieces[solvedRow][solvedCol]
                }
            }
        }

        pieces = newCurrentPieces
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
