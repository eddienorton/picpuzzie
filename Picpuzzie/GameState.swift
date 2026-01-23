//
//  GameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/19/26.
//

import SwiftUI

class GameState: ObservableObject {
    @Published var currentGrid: [[UIImage?]] = []
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0
    @Published var emptyRow: Int = 0
    @Published var emptyCol: Int = 0

    private var solvedGrid: [[UIImage?]] = []
    private var gridSize: Int { level }

    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let pieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        // Verify we got valid pieces
        guard !pieces.isEmpty && pieces.count == gridSize else {
            print("GameState: Failed to slice image into valid grid")
            return
        }

        // Convert to optional grid and make bottom-right empty
        var grid: [[UIImage?]] = pieces.map { $0.map { $0 as UIImage? } }
        grid[gridSize - 1][gridSize - 1] = nil
        emptyRow = gridSize - 1
        emptyCol = gridSize - 1

        solvedGrid = grid
        currentGrid = grid

        // Shuffle the grid
        shuffleGrid()

        isSolved = false
        moveCount = 0
    }

    func shuffleGrid() {
        // Perform random valid moves to shuffle
        let shuffleMoves = gridSize * gridSize * 10 // Plenty of moves to scramble

        for _ in 0..<shuffleMoves {
            // Get valid adjacent positions
            let adjacentPositions = getAdjacentPositions(row: emptyRow, col: emptyCol)

            // Pick random adjacent piece and swap with empty
            if let randomPos = adjacentPositions.randomElement() {
                swapWithEmpty(row: randomPos.row, col: randomPos.col, countMove: false)
            }
        }

        // Reset move count after shuffling
        moveCount = 0
    }

    // MARK: - Piece Movement

    func tapPiece(row: Int, col: Int) {
        // Check if this piece is adjacent to empty space
        guard isAdjacentToEmpty(row: row, col: col) else { return }

        // Swap with empty space
        swapWithEmpty(row: row, col: col, countMove: true)
    }

    func slidePieces(fromRow: Int, fromCol: Int, steps: Int) {
        // Slide pieces toward empty space
        if fromRow == emptyRow {
            // Horizontal slide
            let distance = abs(fromCol - emptyCol)
            let direction = fromCol < emptyCol ? 1 : -1

            // Move pieces one by one toward empty space
            for _ in 0..<min(steps, distance) {
                let pieceCol = emptyCol - direction
                swapWithEmpty(row: fromRow, col: pieceCol, countMove: true)
            }
        } else if fromCol == emptyCol {
            // Vertical slide
            let distance = abs(fromRow - emptyRow)
            let direction = fromRow < emptyRow ? 1 : -1

            // Move pieces one by one toward empty space
            for _ in 0..<min(steps, distance) {
                let pieceRow = emptyRow - direction
                swapWithEmpty(row: pieceRow, col: fromCol, countMove: true)
            }
        }
    }

    private func isAdjacentToEmpty(row: Int, col: Int) -> Bool {
        // Check if piece is horizontally or vertically adjacent to empty space
        let rowDiff = abs(row - emptyRow)
        let colDiff = abs(col - emptyCol)

        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }

    private func getAdjacentPositions(row: Int, col: Int) -> [(row: Int, col: Int)] {
        var positions: [(Int, Int)] = []

        // Up
        if row > 0 { positions.append((row - 1, col)) }
        // Down
        if row < gridSize - 1 { positions.append((row + 1, col)) }
        // Left
        if col > 0 { positions.append((row, col - 1)) }
        // Right
        if col < gridSize - 1 { positions.append((row, col + 1)) }

        return positions
    }

    private func swapWithEmpty(row: Int, col: Int, countMove: Bool) {
        // Swap piece with empty space
        currentGrid[emptyRow][emptyCol] = currentGrid[row][col]
        currentGrid[row][col] = nil

        // Update empty position
        emptyRow = row
        emptyCol = col

        if countMove {
            moveCount += 1
            checkIfSolved()
        }
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Compare current grid with solved grid
        guard solvedGrid.count == gridSize && currentGrid.count == gridSize else {
            isSolved = false
            return
        }

        for row in 0..<gridSize {
            guard row < currentGrid.count && row < solvedGrid.count else {
                isSolved = false
                return
            }
            guard currentGrid[row].count == gridSize && solvedGrid[row].count == gridSize else {
                isSolved = false
                return
            }

            for col in 0..<gridSize {
                let current = currentGrid[row][col]
                let solved = solvedGrid[row][col]

                // Both nil or same image
                if current == nil && solved == nil {
                    continue
                } else if let c = current, let s = solved, c === s {
                    continue
                } else {
                    isSolved = false
                    return
                }
            }
        }
        isSolved = true
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        // Slice the new image
        let newPieces = ImageSlicer.sliceImage(image, gridSize: gridSize)

        guard !newPieces.isEmpty && newPieces.count == gridSize else {
            print("GameState: Failed to slice new image")
            return
        }

        // Create a mapping of which solved position each current position contains
        var pieceMapping: [[Int?]] = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        for currentRow in 0..<gridSize {
            for currentCol in 0..<gridSize {
                if let currentPiece = currentGrid[currentRow][currentCol] {
                    // Find where this piece belongs in the solved grid
                    for solvedRow in 0..<gridSize {
                        for solvedCol in 0..<gridSize {
                            if let solvedPiece = solvedGrid[solvedRow][solvedCol],
                               currentPiece === solvedPiece {
                                pieceMapping[currentRow][currentCol] = solvedRow * gridSize + solvedCol
                                break
                            }
                        }
                    }
                }
            }
        }

        // Create new solved grid with new image pieces
        var newSolvedGrid: [[UIImage?]] = newPieces.map { $0.map { $0 as UIImage? } }
        newSolvedGrid[gridSize - 1][gridSize - 1] = nil

        // Create new current grid using the same arrangement
        var newCurrentGrid: [[UIImage?]] = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        for currentRow in 0..<gridSize {
            for currentCol in 0..<gridSize {
                if let pieceIndex = pieceMapping[currentRow][currentCol] {
                    let solvedRow = pieceIndex / gridSize
                    let solvedCol = pieceIndex % gridSize
                    newCurrentGrid[currentRow][currentCol] = newSolvedGrid[solvedRow][solvedCol]
                }
            }
        }

        // Update the grids
        solvedGrid = newSolvedGrid
        currentGrid = newCurrentGrid

        // Keep empty position, moveCount, and isSolved as they were
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
