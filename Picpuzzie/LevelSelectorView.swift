//
//  LevelSelectorView.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import SwiftUI

struct LevelSelectorView: View {
    let currentLevel: Int
    let maxUnlockedLevel: Int
    let totalLevels: Int = 6
    let onLevelSelected: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...totalLevels, id: \.self) { level in
                Button {
                    if level <= maxUnlockedLevel {
                        onLevelSelected(level)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(backgroundColor(for: level))
                            .frame(width: 40, height: 40)
                        
                        // Add yellow border for current level
                        if level == currentLevel {
                            Circle()
                                .stroke(Color.yellow, lineWidth: 3)
                                .frame(width: 40, height: 40)
                        }

                        Text("\(level)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(textColor(for: level))
                    }
                }
                .disabled(level > maxUnlockedLevel)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(25)
    }

    private func backgroundColor(for level: Int) -> Color {
        if level > maxUnlockedLevel {
            // Locked - lighter gray for better visibility
            return Color.gray.opacity(0.9)
        } else if level < currentLevel {
            // Completed - green
            return Color.green.opacity(0.7)
        } else if level == currentLevel {
            // Current level - white background (yellow border added separately)
            return Color.white
        } else {
            // Unlocked but not current - blue
            return Color.blue.opacity(0.6)
        }
    }

    private func textColor(for level: Int) -> Color {
        if level > maxUnlockedLevel {
            // Locked - dark text on lighter gray for better contrast
            return Color.black
        } else if level == currentLevel {
            // Black text on white background for better contrast
            return Color.black
        } else {
            return Color.white
        }
    }
}
