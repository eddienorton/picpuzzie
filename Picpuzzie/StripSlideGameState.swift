//
//  StripSlideGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

class StripSlideGameState: ObservableObject {
    @Published var strips: [UIImage] = []
    @Published var stripOffsets: [Int] = [] // Offset in number of pieces for each strip
    @Published var orientation: StripSlicer.Orientation = .vertical
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0

    // Number of pieces each strip is divided into for wraparound
    let piecesPerStrip: Int = 10

    private var solvedOffsets: [Int] = []

    var numberOfStrips: Int { level }

    init(startingLevel: Int = 5) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        // Randomly choose orientation
        orientation = Bool.random() ? .vertical : .horizontal

        let slicedStrips = StripSlicer.sliceImageIntoStrips(image, numberOfStrips: numberOfStrips, orientation: orientation)

        guard !slicedStrips.isEmpty else {
            print("StripSlideGameState: Failed to slice image into strips")
            return
        }

        strips = slicedStrips
        solvedOffsets = Array(repeating: 0, count: slicedStrips.count)
        stripOffsets = Array(repeating: 0, count: slicedStrips.count)

        // Shuffle the strips
        shuffleStrips()

        isSolved = false
        moveCount = 0
    }

    func shuffleStrips() {
        // Randomly offset each strip
        for i in 0..<strips.count {
            stripOffsets[i] = Int.random(in: 1..<piecesPerStrip) // Don't use 0 (solved position)
        }
        moveCount = 0
    }

    // MARK: - Strip Movement

    func slideStrip(_ stripIndex: Int, direction: Int) {
        guard stripIndex >= 0 && stripIndex < stripOffsets.count else { return }

        // Move strip by direction amount
        stripOffsets[stripIndex] += direction

        // Wrap around
        while stripOffsets[stripIndex] < 0 {
            stripOffsets[stripIndex] += piecesPerStrip
        }
        while stripOffsets[stripIndex] >= piecesPerStrip {
            stripOffsets[stripIndex] -= piecesPerStrip
        }

        moveCount += 1
        checkIfSolved()
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Check if all strips are aligned RELATIVE to each other
        // They don't need to be at 0, just all at the same offset

        guard !stripOffsets.isEmpty else {
            isSolved = false
            return
        }

        // Check if all strips have the same offset
        let firstOffset = stripOffsets[0]

        for offset in stripOffsets {
            if offset != firstOffset {
                isSolved = false
                return
            }
        }

        // All strips aligned! Now animate to correct position (0)
        isSolved = true
        animateToCorrectPosition()
    }

    private func animateToCorrectPosition() {
        // If already at 0, don't animate
        guard stripOffsets[0] != 0 else { return }

        // Slowly shift all strips to offset 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                for i in 0..<self.stripOffsets.count {
                    self.stripOffsets[i] = 0
                }
            }
        }
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        // Re-slice the new image with the same orientation and number of strips
        let newStrips = StripSlicer.sliceImageIntoStrips(image, numberOfStrips: numberOfStrips, orientation: orientation)

        guard !newStrips.isEmpty else {
            print("StripSlideGameState: Failed to slice new image into strips")
            return
        }

        // Update strips with new image
        strips = newStrips

        // Keep stripOffsets, moveCount, and isSolved unchanged
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
