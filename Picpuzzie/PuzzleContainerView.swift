//
//  PuzzleContainerView.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI
import PhotosUI

struct PuzzleContainerView<Content: View>: View {
    let title: String
    let levelText: String
    let moveCount: Int
    let isSolved: Bool
    let currentLevel: Int
    let maxUnlockedLevel: Int
    
    let onLevelSelected: (Int) -> Void
    let onNextLevel: () -> Void
    let onNewPhoto: () -> Void
    let onPhotoSelected: (UIImage) -> Void
    let onNextPuzzle: () -> Void
    let onShuffle: (() -> Void)?
    
    @Binding var showingCelebration: Bool
    let content: Content
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(
        title: String,
        levelText: String,
        moveCount: Int,
        isSolved: Bool,
        currentLevel: Int,
        maxUnlockedLevel: Int,
        showingCelebration: Binding<Bool>,
        onLevelSelected: @escaping (Int) -> Void,
        onNextLevel: @escaping () -> Void,
        onNewPhoto: @escaping () -> Void,
        onPhotoSelected: @escaping (UIImage) -> Void,
        onNextPuzzle: @escaping () -> Void,
        onShuffle: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.levelText = levelText
        self.moveCount = moveCount
        self.isSolved = isSolved
        self.currentLevel = currentLevel
        self.maxUnlockedLevel = maxUnlockedLevel
        self.onLevelSelected = onLevelSelected
        self.onNextLevel = onNextLevel
        self.onNewPhoto = onNewPhoto
        self.onPhotoSelected = onPhotoSelected
        self.onNextPuzzle = onNextPuzzle
        self.onShuffle = onShuffle
        self._showingCelebration = showingCelebration
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Header space
                    Color.clear
                        .frame(height: 100)  // Reduced from 120 to 100 to match header
                    
                    // Puzzle content area - centered square
                    ZStack {
                        content
                            .frame(width: geometry.size.width - 8, height: geometry.size.width - 8)
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Spacer to push controls to bottom
                    Spacer()
                    
                    // Controls - fixed position above level selector
                    VStack(spacing: 8) {  // Reduced from 12 to 8
                        if isSolved {
                            VStack(spacing: 8) {  // Reduced from 15 to 8
                                Text("🎉 Solved! 🎉")
                                    .font(.system(size: 24, weight: .bold))  // Reduced from 28 to 24
                                
                                Button("Next Level") {
                                    onNextLevel()
                                }
                                .font(.system(size: 20, weight: .bold))  // Reduced from 22 to 20
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)  // Reduced from 15 to 12
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .strokeBorder(Color.yellow, lineWidth: 4)
                                )
                                .shadow(color: .yellow.opacity(0.6), radius: 10, x: 0, y: 0)
                            }
                        }
                        
                        // Top row: Shuffle and New Photo side by side
                        HStack(spacing: 15) {
                            if let shuffle = onShuffle {
                                Button("Shuffle") {
                                    shuffle()
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button("New Photo") {
                                onNewPhoto()
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        showPhotoPicker = true
                                    }
                            )
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // Bottom row: Next Puzzle - same height and aligned with buttons above
                        Button("Next Puzzle") {
                            onNextPuzzle()
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)  // Reduced from 12 to 8
                    
                    // Level Selector at bottom
                    LevelSelectorView(
                        currentLevel: currentLevel,
                        maxUnlockedLevel: maxUnlockedLevel,
                        onLevelSelected: onLevelSelected
                    )
                    .padding(.bottom, 10)  // Reduced from 20 to 10
                }
                
                // Header section - bigger text
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.9))
                            .frame(height: 100)  // Reduced from 120 to 100
                        
                        VStack(spacing: 8) {  // Reduced from 10 to 8
                            Text(title)
                                .font(.system(size: 26, weight: .bold))  // Reduced from 28 to 26
                                .foregroundColor(.white)
                            
                            HStack(spacing: 20) {
                                Text(levelText)
                                    .font(.system(size: 18, weight: .semibold))  // Reduced from 20 to 18
                                    .foregroundColor(.white)
                                
                                Text("Moves: \(moveCount)")
                                    .font(.system(size: 18, weight: .semibold))  // Reduced from 20 to 18
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 10)  // Reduced from 20 to 10
                    }
                    
                    Spacer()
                }
                .allowsHitTesting(false)
                .zIndex(100)
                
                CelebrationOverlay(isShowing: $showingCelebration)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                VStack(spacing: 20) {
                    Text("Select a Photo")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Choose from your photo library")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(40)
            }
            .photosPickerStyle(.inline)
            .presentationDetents([.medium, .large])
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onPhotoSelected(image)
                    showPhotoPicker = false
                }
            }
        }
    }
}
