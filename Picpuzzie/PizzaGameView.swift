//
//  PizzaGameView.swift
//  Picpuzzie
//
//  Created by Claude on 2/14/26.
//

import SwiftUI

struct PizzaGameView: View {
    @StateObject private var gameState: PizzaGameState
    @State private var showingCelebration = false
    let sourceImage: UIImage
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextLevel: () -> Void
    let onLevelSelected: (Int) -> Void
    let onNextPuzzle: () -> Void
    let onShare: (() -> Void)?
    
    init(sourceImage: UIImage, startingLevel: Int = 3, currentLevel: Int, maxUnlockedLevel: Int = 3, onNewPhoto: @escaping () -> Void, onPhotoSelected: @escaping (UIImage) -> Void, onNextLevel: @escaping () -> Void, onLevelSelected: @escaping (Int) -> Void = { _ in }, onNextPuzzle: @escaping () -> Void, onShare: (() -> Void)? = nil) {
        self.sourceImage = sourceImage
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextLevel = onNextLevel
        self.onLevelSelected = onLevelSelected
        self.onNextPuzzle = onNextPuzzle
        self.onShare = onShare
        _gameState = StateObject(wrappedValue: PizzaGameState(startingLevel: startingLevel))
    }
    
    var body: some View {
        PuzzleContainerView(
            title: "Pizza",
            levelText: "Slices: \(gameState.numberOfSlices)",
            moveCount: gameState.moveCount,
            isSolved: gameState.isSolved,
            currentLevel: currentLevel,
            maxUnlockedLevel: maxUnlockedLevel,
            showingCelebration: $showingCelebration,
            onLevelSelected: onLevelSelected,
            onNextLevel: onNextLevel,
            onNewPhoto: {
                onNewPhoto()
            },
            onPhotoSelected: onPhotoSelected,
            onNextPuzzle: onNextPuzzle,
            onShuffle: {
                gameState.shuffleSlices()
            },
            onShare: onShare
        ) {
            if !gameState.slices.isEmpty {
                PizzaSlicesView(gameState: gameState)
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

struct PizzaSlicesView: View {
    @ObservedObject var gameState: PizzaGameState
    @State private var draggedSlicePosition: Int? = nil
    @State private var dragAngle: Double = 0
    @State private var dragStartPosition: Int? = nil
    @State private var hoverPosition: Int? = nil  // Which position is the dragged slice hovering over
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let sliceCount = gameState.numberOfSlices
            let anglePerSlice = 360.0 / Double(sliceCount)
            
            ZStack {
                // Black background
                Circle()
                    .fill(Color.black)
                    .frame(width: size, height: size)
                
                // Draw all slices manually
                drawSlices(size: size, sliceCount: sliceCount, anglePerSlice: anglePerSlice)
            }
            .frame(width: size, height: size)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        handleDragChanged(value: value, center: center, size: size, anglePerSlice: anglePerSlice)
                    }
                    .onEnded { value in
                        handleDragEnded(value: value, center: center, size: size, anglePerSlice: anglePerSlice)
                    }
            )
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    @ViewBuilder
    private func drawSlices(size: CGFloat, sliceCount: Int, anglePerSlice: Double) -> some View {
        Group {
            if sliceCount > 0 { drawSlice(position: 0, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 1 { drawSlice(position: 1, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 2 { drawSlice(position: 2, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 3 { drawSlice(position: 3, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 4 { drawSlice(position: 4, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 5 { drawSlice(position: 5, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 6 { drawSlice(position: 6, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 7 { drawSlice(position: 7, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 8 { drawSlice(position: 8, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 9 { drawSlice(position: 9, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 10 { drawSlice(position: 10, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 11 { drawSlice(position: 11, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 12 { drawSlice(position: 12, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 13 { drawSlice(position: 13, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 14 { drawSlice(position: 14, size: size, anglePerSlice: anglePerSlice) }
            if sliceCount > 15 { drawSlice(position: 15, size: size, anglePerSlice: anglePerSlice) }
        }
    }
    
    @ViewBuilder
    private func drawSlice(position: Int, size: CGFloat, anglePerSlice: Double) -> some View {
        if position < gameState.slices.count {
            let sliceIndex = gameState.sliceAt(position: position)
            let slice = gameState.slices[sliceIndex]
            let isDragged = draggedSlicePosition == position
            
            let displayPosition = calculateDisplayPosition(
                originalPosition: position,
                draggedFrom: dragStartPosition,
                hoveringAt: hoverPosition
            )
            
            let totalRotation = calculateRotation(
                isDragged: isDragged,
                displayPosition: displayPosition,
                anglePerSlice: anglePerSlice
            )
            
            Image(uiImage: slice.image)
                .resizable()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(totalRotation))
                .zIndex(isDragged ? 1000 : Double(position))
                .opacity(isDragged ? 0.85 : 1.0)
                .animation(.easeOut(duration: 0.2), value: displayPosition)
                .animation(.easeInOut(duration: 1.5), value: gameState.solveRotationOffset)
        }
    }
    
    private func calculateRotation(isDragged: Bool, displayPosition: Int, anglePerSlice: Double) -> Double {
        // Apply solve rotation offset to all slices
        let rotatedPosition = (displayPosition - gameState.solveRotationOffset + gameState.numberOfSlices) % gameState.numberOfSlices
        
        if isDragged, let startPos = dragStartPosition {
            return Double(startPos) * anglePerSlice + dragAngle
        } else {
            return Double(rotatedPosition) * anglePerSlice
        }
    }
    
    // Calculate where a slice should be displayed, accounting for the drag operation
    private func calculateDisplayPosition(originalPosition: Int, draggedFrom: Int?, hoveringAt: Int?) -> Int {
        // First, find where this position's slice actually is in slicePositions
        // (This handles the solve animation which updates slicePositions)
        let actualPosition = findActualPosition(originalPosition: originalPosition)
        
        // Then apply any drag-based shifts
        guard let draggedFrom = draggedFrom, let hoveringAt = hoveringAt else {
            return actualPosition  // No drag in progress, use actual position
        }
        
        // If this is the dragged slice, it stays at its hover position
        if actualPosition == draggedFrom {
            return hoveringAt
        }
        
        // Calculate shift: slices between draggedFrom and hoveringAt need to shift
        if draggedFrom < hoveringAt {
            // Dragging forward (clockwise)
            // Slices from draggedFrom+1 to hoveringAt shift backward (counter-clockwise)
            if actualPosition > draggedFrom && actualPosition <= hoveringAt {
                return actualPosition - 1
            }
        } else if draggedFrom > hoveringAt {
            // Dragging backward (counter-clockwise)
            // Slices from hoveringAt to draggedFrom-1 shift forward (clockwise)
            if actualPosition >= hoveringAt && actualPosition < draggedFrom {
                return actualPosition + 1
            }
        }
        
        return actualPosition
    }
    
    // Find what position a given original position is actually at
    // This accounts for solve animations that rearrange slicePositions
    private func findActualPosition(originalPosition: Int) -> Int {
        // During solve animation, slicePositions changes
        // We need to find where the slice that started at originalPosition is now
        // But we're iterating by position, not by slice...
        // Actually, originalPosition IS the position, and we show the slice at that position
        // The rotation should be based on position, not slice identity
        return originalPosition
    }
    
    private func handleDragChanged(value: DragGesture.Value, center: CGPoint, size: CGFloat, anglePerSlice: Double) {
        // If this is the start of a drag, determine which slice was touched
        if draggedSlicePosition == nil {
            let touchPoint = value.startLocation
            
            if let position = getSlicePosition(at: touchPoint, center: center, size: size, anglePerSlice: anglePerSlice) {
                draggedSlicePosition = position
                dragStartPosition = position
                hoverPosition = position  // Start hovering at same position
                dragAngle = 0
            } else {
            }
            return
        }
        
        // Calculate how much the slice has rotated based on drag
        let currentPoint = value.location
        let currentAngle = calculateAngle(point: currentPoint, center: center)
        let startAngle = calculateAngle(point: value.startLocation, center: center)
        
        // Calculate delta angle
        var delta = currentAngle - startAngle
        
        // Normalize to -180 to 180
        while delta > 180 { delta -= 360 }
        while delta < -180 { delta += 360 }
        
        dragAngle = delta
        
        // Update hover position based on current drag angle
        if let startPos = dragStartPosition {
            let positionsMoved = Int(round(delta / anglePerSlice))
            var newHoverPos = startPos + positionsMoved
            
            // Wrap around
            while newHoverPos < 0 { newHoverPos += gameState.numberOfSlices }
            while newHoverPos >= gameState.numberOfSlices { newHoverPos -= gameState.numberOfSlices }
            
            if newHoverPos != hoverPosition {
                hoverPosition = newHoverPos
            }
        }
    }
    
    private func handleDragEnded(value: DragGesture.Value, center: CGPoint, size: CGFloat, anglePerSlice: Double) {
        guard let startPos = dragStartPosition, let endPos = hoverPosition else {
            resetDrag()
            return
        }
        
        if endPos != startPos {
            // Move the slice to the new position
            withAnimation(.easeOut(duration: 0.2)) {
                gameState.moveSlice(fromPosition: startPos, toPosition: endPos)
                resetDrag()
            }
        } else {
            // Snap back to original position
            withAnimation(.easeOut(duration: 0.2)) {
                resetDrag()
            }
        }
    }
    
    private func resetDrag() {
        draggedSlicePosition = nil
        dragStartPosition = nil
        hoverPosition = nil
        dragAngle = 0
    }
    
    private func calculateAngle(point: CGPoint, center: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        
        // Convert to 0-360 range
        if angle < 0 { angle += 360 }
        
        return angle
    }
    
    private func getSlicePosition(at point: CGPoint, center: CGPoint, size: CGFloat, anglePerSlice: Double) -> Int? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let radius = size / 2
        
        
        // Check if point is within the circle (but not too close to center)
        guard distance < radius && distance > 20 else {
            return nil
        }
        
        // Calculate angle from center to touch point in standard math coordinates
        // atan2(dy, dx) gives: 0° = right, 90° = down (because +y is down in iOS)
        var angle = atan2(dy, dx) * 180 / .pi
        
        // Convert to 0-360 range
        if angle < 0 { angle += 360 }
        
        
        // In our PizzaSlicer, we create slices with this rotation:
        // startRadians = (startAngle - 90) * π/180
        // This means slice 0 (startAngle=0°) is drawn from -90° to -54° (which is 270° to 306° in 0-360)
        // In screen coordinates that's: up to upper-right
        
        // But then we rotate each slice by position * anglePerSlice
        // Position 0: rotated 0°, so slice 0's wedge is at -90° to -54° → 270° to 306° (top)
        // Position 1: rotated 36°, so slice 0's wedge is at -54° to -18° → 306° to 342° (top-right)
        // etc.
        
        // So to find which position, we need:
        // 1. What wedge angle is this in the ORIGINAL coordinate system? 
        //    Original: 0° = top, clockwise
        //    Screen: 0° = right, clockwise (because +y is down)
        //    Offset: -90° (top in original = right-90° = up in screen = 270°)
        
        // Convert screen angle to slice angle (where 0° = top of screen)
        var sliceAngle = angle + 90  // Rotate so top (270° in screen) becomes 0°
        if sliceAngle >= 360 { sliceAngle -= 360 }
        
        
        // Which position is this?
        let position = Int(sliceAngle / anglePerSlice) % gameState.numberOfSlices
        
        return position
    }
}
