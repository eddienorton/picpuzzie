//
//  CircleRotationGameState.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import SwiftUI

class CircleRotationGameState: ObservableObject {
    @Published var rings: [CircleRingSlicer.Ring] = []
    @Published var ringRotations: [Double] = [] // Rotation in degrees for each ring
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0

    private var solvedRotations: [Double] = [] // All should be 0
    private let angleStep: Double = 36.0 // 10 positions per ring (360/10 = 36 degrees)

    var numberOfRings: Int { level }

    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }

    func setupGame(with image: UIImage) {
        let slicedRings = CircleRingSlicer.sliceImageIntoRings(image, numberOfRings: numberOfRings)

        guard !slicedRings.isEmpty else {
            print("CircleRotationGameState: Failed to slice image into rings")
            return
        }

        rings = slicedRings
        solvedRotations = Array(repeating: 0.0, count: slicedRings.count)
        ringRotations = Array(repeating: 0.0, count: slicedRings.count)

        // Shuffle the rings
        shuffleRings()

        isSolved = false
        moveCount = 0
    }

    func shuffleRings() {
        // Randomly rotate each ring to a discrete position
        for i in 0..<rings.count {
            let randomSteps = Int.random(in: 1...9) // Don't use 0 or 10 (which would be solved)
            ringRotations[i] = Double(randomSteps) * angleStep
        }
        moveCount = 0
    }

    // MARK: - Ring Rotation

    func updateRingRotation(ringIndex: Int, delta: Double) {
        guard ringIndex >= 0 && ringIndex < ringRotations.count else { return }

        // Add delta and normalize to 0-360
        var newRotation = ringRotations[ringIndex] + delta
        while newRotation < 0 { newRotation += 360 }
        while newRotation >= 360 { newRotation -= 360 }

        ringRotations[ringIndex] = newRotation
    }

    func snapRingToNearestPosition(ringIndex: Int) {
        guard ringIndex >= 0 && ringIndex < ringRotations.count else { return }

        // Snap to nearest discrete position
        let currentRotation = ringRotations[ringIndex]
        let snappedRotation = round(currentRotation / angleStep) * angleStep

        // Calculate the shortest delta to snap position
        var delta = snappedRotation - currentRotation

        // Normalize delta to -180 to 180 (ensures shortest path)
        while delta > 180 { delta -= 360 }
        while delta < -180 { delta += 360 }

        // Apply the shortest rotation
        ringRotations[ringIndex] = currentRotation + delta

        moveCount += 1
        checkIfSolved()
    }

    // MARK: - Solution Checking

    private func checkIfSolved() {
        // Check if all rings are aligned RELATIVE to each other
        // They don't need to be at 0, just all at the same angle

        guard !ringRotations.isEmpty else {
            isSolved = false
            return
        }

        // Normalize all rotations to 0-360
        let normalizedRotations = ringRotations.map { rotation -> Double in
            var normalized = rotation.truncatingRemainder(dividingBy: 360)
            if normalized < 0 { normalized += 360 }
            return normalized
        }

        // Check if all rings are at the same angle (within tolerance)
        let firstAngle = normalizedRotations[0]
        let tolerance = 1.0 // 1 degree tolerance

        for rotation in normalizedRotations {
            let diff = abs(rotation - firstAngle)
            // Account for wraparound (e.g., 359 and 1 are close)
            let wrappedDiff = min(diff, 360 - diff)
            if wrappedDiff > tolerance {
                isSolved = false
                return
            }
        }

        // All rings aligned! Now animate to upright (0 degrees)
        isSolved = true
        animateToUpright()
    }

    private func animateToUpright() {
        // Slowly rotate all rings to 0 degrees using shortest path
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                for i in 0..<self.ringRotations.count {
                    let currentRotation = self.ringRotations[i]

                    // Calculate shortest delta to 0
                    var delta = 0 - currentRotation

                    // Normalize delta to -180 to 180 (ensures shortest path)
                    while delta > 180 { delta -= 360 }
                    while delta < -180 { delta += 360 }

                    // Apply the shortest rotation
                    self.ringRotations[i] = currentRotation + delta
                }
            }
        }
    }

    // MARK: - Image Replacement

    func replaceImage(with image: UIImage) {
        // Re-slice the new image into rings with the same number of rings
        let newRings = CircleRingSlicer.sliceImageIntoRings(image, numberOfRings: numberOfRings)

        guard !newRings.isEmpty else {
            print("CircleRotationGameState: Failed to slice new image into rings")
            return
        }

        // Update rings with new image
        rings = newRings

        // Keep ringRotations, moveCount, and isSolved unchanged
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
