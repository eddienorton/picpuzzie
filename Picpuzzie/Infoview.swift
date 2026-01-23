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
