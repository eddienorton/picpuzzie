//
//  PizzaGameState.swift
//  Picpuzzie
//
//  Created by Claude on 2/14/26.
//

import SwiftUI

class PizzaGameState: ObservableObject {
    @Published var slices: [PizzaSlicer.Slice] = []
    @Published var slicePositions: [Int] = [] // Which slice is currently in each position
    @Published var level: Int
    @Published var isSolved: Bool = false
    @Published var moveCount: Int = 0
    @Published var solveRotationOffset: Int = 0  // How many positions to rotate for solve animation
    
    var numberOfSlices: Int {
        // Level 1 = 4 slices, Level 2 = 6, Level 3 = 8, Level 4 = 10, Level 5 = 12, Level 6 = 14
        // Formula: 2 + (level * 2)
        return 2 + (level * 2)
    }
    
    init(startingLevel: Int = 3) {
        self.level = startingLevel
    }
    
    func setupGame(with image: UIImage) {
        let slicedPizza = PizzaSlicer.sliceImageIntoPizza(image, numberOfSlices: numberOfSlices)
        
        guard !slicedPizza.isEmpty else {
            print("PizzaGameState: Failed to slice image into pizza")
            return
        }
        
        slices = slicedPizza
        
        // Initialize positions (slice i is at position i)
        slicePositions = Array(0..<slices.count)
        
        // Shuffle the pizza
        shuffleSlices()
        
        isSolved = false
        moveCount = 0
    }
    
    func shuffleSlices() {
        // Scramble which slice is in which position
        slicePositions.shuffle()
        moveCount = 0
        checkIfSolved()
    }
    
    // MARK: - Slice Movement
    
    func moveSlice(fromPosition: Int, toPosition: Int) {
        guard fromPosition >= 0 && fromPosition < slicePositions.count &&
              toPosition >= 0 && toPosition < slicePositions.count &&
              fromPosition != toPosition else { return }
        
        // Remove slice from old position and insert at new position
        let sliceToMove = slicePositions[fromPosition]
        slicePositions.remove(at: fromPosition)
        slicePositions.insert(sliceToMove, at: toPosition)
        
        moveCount += 1
        checkIfSolved()
    }
    
    // Get the slice index that's currently at a given position
    func sliceAt(position: Int) -> Int {
        guard position >= 0 && position < slicePositions.count else { return 0 }
        return slicePositions[position]
    }
    
    // MARK: - Solution Checking
    
    private func checkIfSolved() {
        // Check if slices are in the correct ORDER (sequence), not position
        // Example: if slices go 2,3,4,5,0,1 that's correct order (just rotated)
        
        guard !slicePositions.isEmpty else {
            isSolved = false
            return
        }
        
        // Get the first slice's position to establish the offset
        let firstSliceIndex = slicePositions[0]
        
        // Check if all subsequent slices follow in sequence
        for position in 0..<slicePositions.count {
            let expectedSliceIndex = (firstSliceIndex + position) % slicePositions.count
            if slicePositions[position] != expectedSliceIndex {
                isSolved = false
                return
            }
        }
        
        // Slices are in correct order! Animate to upright
        isSolved = true
        animateToUpright()
    }
    
    private func animateToUpright() {
        // Find how many positions we need to rotate to get slice 0 to position 0
        guard let slice0Position = slicePositions.firstIndex(of: 0) else {
            return
        }
        
        
        // If slice 0 is already at position 0, we're done
        if slice0Position == 0 {
            return
        }
        
        
        // First animate the rotation offset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                // Animate the visual rotation
                self.solveRotationOffset = slice0Position
            }
            
            // After animation completes, actually rearrange the array and reset offset
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let rotateAmount = slice0Position
                var newPositions = self.slicePositions
                
                // Rotate the array to match the visual rotation
                for i in 0..<self.slicePositions.count {
                    let newIndex = (i - rotateAmount + self.slicePositions.count) % self.slicePositions.count
                    newPositions[newIndex] = self.slicePositions[i]
                }
                
                
                self.slicePositions = newPositions
                self.solveRotationOffset = 0  // Reset offset
            }
        }
    }
    
    // MARK: - Image Replacement
    
    func replaceImage(with image: UIImage) {
        let newSlices = PizzaSlicer.sliceImageIntoPizza(image, numberOfSlices: numberOfSlices)
        
        guard !newSlices.isEmpty else {
            print("PizzaGameState: Failed to slice new image")
            return
        }
        
        slices = newSlices
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
