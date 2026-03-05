//
//  InfoView.swift
//  Picpuzzie
//
//  Created by Claude on 1/22/26.
//

import SwiftUI

struct PuzzleStats {
    let puzzleType: PuzzleType
    let name: String
    let emoji: String
    let currentLevel: Int
    let timeSpent: TimeInterval // in seconds
}

struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var puzzleStats: [PuzzleStats]
    let currentPuzzle: PuzzleType
    let onPuzzleSelected: (PuzzleType) -> Void
    let onResetAll: () -> Void
    let getUpdatedStats: () -> [PuzzleStats]
    
    @State private var showResetConfirmation = false
    
    init(puzzleStats: [PuzzleStats], currentPuzzle: PuzzleType, onPuzzleSelected: @escaping (PuzzleType) -> Void, onResetAll: @escaping () -> Void, getUpdatedStats: @escaping () -> [PuzzleStats]) {
        self._puzzleStats = State(initialValue: puzzleStats)
        self.currentPuzzle = currentPuzzle
        self.onPuzzleSelected = onPuzzleSelected
        self.onResetAll = onResetAll
        self.getUpdatedStats = getUpdatedStats
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App icon logo
                        VStack(spacing: 10) {
                            Image("AppIconImage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                            
                            Text("Picpuzzie")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Puzzle stats - now tappable
                        VStack(spacing: 15) {
                            ForEach(puzzleStats.indices, id: \.self) { index in
                                let stat = puzzleStats[index]
                                
                                Button {
                                    onPuzzleSelected(stat.puzzleType)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text(stat.emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 50)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(stat.name)
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            HStack(spacing: 20) {
                                                Text("Level \(stat.currentLevel)")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.gray)
                                                
                                                Text(formatTime(stat.timeSpent))
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Current puzzle indicator
                                        if stat.puzzleType == currentPuzzle {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        stat.puzzleType == currentPuzzle
                                            ? Color.white.opacity(0.2)
                                            : Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // More Puzzie Family Apps section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("More Puzzie Family Apps")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                // Picpuzzie Cubes
                                PaidAppButton(
                                    appName: "Picpuzzie Cubes",
                                    description: "3D Photo Cube Puzzles",
                                    price: "$1.99",
                                    imageName: "CubesAppIcon",
                                    appStoreURL: "https://apps.apple.com/us/app/picpuzzie-cubes/id6758316548"
                                )
                                
                                // Word Puzzie
                                PaidAppButton(
                                    appName: "Word Puzzie",
                                    description: "Letter-Based Puzzle Games",
                                    price: "$2.99",
                                    imageName: "WordPuzzieAppIcon",
                                    appStoreURL: "https://apps.apple.com/us/app/word-puzzie/id6758675506"
                                )
                                
                                // Pipe Puzzie
                                PaidAppButton(
                                    appName: "Pipe Puzzie",
                                    description: "Connect the Pipe Puzzles",
                                    price: "$1.99",
                                    imageName: "PipePuzzieAppIcon",
                                    appStoreURL: "https://apps.apple.com/us/app/pipe-puzzie/id6759010827"
                                )
                                
                                // Canned Fruit
                                PaidAppButton(
                                    appName: "Canned Fruit",
                                    description: "Spin the cans and match the fruit",
                                    price: "$1.99",
                                    imageName: "CannedFruitAppIcon",
                                    appStoreURL: "https://apps.apple.com/app/canned-fruit/id6759359149"
                                                    
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            Text("One price. No ads. Ever.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                                .padding(.top, 5)
                        }
                        .padding(.top, 30)
                        
                        // Total time
                        VStack(spacing: 8) {
                            Text("Total Time")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text(formatTime(puzzleStats.reduce(0) { $0 + $1.timeSpent }))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .onLongPressGesture(minimumDuration: 1.0) {
                            showResetConfirmation = true
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                }
            }
            .alert("Reset All Progress?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    onResetAll()
                    // Refresh the stats to show reset values
                    puzzleStats = getUpdatedStats()
                    // Don't dismiss - stay on menu to see the reset
                }
            } message: {
                Text("This will reset all puzzle levels to 1 and clear all time tracking. This cannot be undone.")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }
}

// MARK: - Paid App Button Component
struct PaidAppButton: View {
    let appName: String
    let description: String
    let price: String
    let imageName: String
    let appStoreURL: String
    
    var body: some View {
        Button {
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 15) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
