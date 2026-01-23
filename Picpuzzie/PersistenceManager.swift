//
//  PersistenceManager.swift
//  Picpuzzie
//
//  Created by Claude on 1/21/26.
//

import UIKit
import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard
    private let imageDirectory: URL

    // Keys
    private let currentPuzzleTypeKey = "currentPuzzleType"
    private let currentImagePathKey = "currentImagePath"

    init() {
        // Create images directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imageDirectory = documentsPath.appendingPathComponent("SavedImages", isDirectory: true)

        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Current State

    func saveCurrentPuzzleType(_ puzzleType: String) {
        defaults.set(puzzleType, forKey: currentPuzzleTypeKey)
    }

    func loadCurrentPuzzleType() -> String? {
        return defaults.string(forKey: currentPuzzleTypeKey)
    }

    // MARK: - Image Persistence

    func saveCurrentImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        let filename = "current_\(Date().timeIntervalSince1970).jpg"
        let fileURL = imageDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            defaults.set(filename, forKey: currentImagePathKey)

            // Clean up old images
            cleanupOldImages(keepingCurrent: filename)

            return filename
        } catch {
            print("PersistenceManager: Failed to save image - \(error)")
            return nil
        }
    }

    func loadCurrentImage() -> UIImage? {
        guard let filename = defaults.string(forKey: currentImagePathKey) else { return nil }

        let fileURL = imageDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        return UIImage(data: data)
    }

    private func cleanupOldImages(keepingCurrent currentFilename: String) {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
            for fileURL in files {
                if fileURL.lastPathComponent != currentFilename {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("PersistenceManager: Failed to cleanup old images - \(error)")
        }
    }

    // MARK: - Puzzle Levels

    func saveLevel(_ level: Int, forPuzzle puzzleType: String) {
        defaults.set(level, forKey: "level_\(puzzleType)")
    }

    func loadLevel(forPuzzle puzzleType: String) -> Int? {
        let key = "level_\(puzzleType)"
        if defaults.object(forKey: key) != nil {
            return defaults.integer(forKey: key)
        }
        return nil
    }

    // MARK: - Puzzle State (generic dictionary for flexibility)

    func savePuzzleState(_ state: [String: Any], forPuzzle puzzleType: String) {
        defaults.set(state, forKey: "state_\(puzzleType)")
    }

    func loadPuzzleState(forPuzzle puzzleType: String) -> [String: Any]? {
        return defaults.dictionary(forKey: "state_\(puzzleType)")
    }

    func clearPuzzleState(forPuzzle puzzleType: String) {
        defaults.removeObject(forKey: "state_\(puzzleType)")
    }
    
    // MARK: - Time Tracking
    
    func saveTime(_ seconds: TimeInterval, forPuzzle puzzleType: String) {
        defaults.set(seconds, forKey: "time_\(puzzleType)")
    }
    
    func loadTime(forPuzzle puzzleType: String) -> TimeInterval {
        return defaults.double(forKey: "time_\(puzzleType)")
    }
    
    func addTime(_ additionalSeconds: TimeInterval, forPuzzle puzzleType: String) {
        let currentTime = loadTime(forPuzzle: puzzleType)
        saveTime(currentTime + additionalSeconds, forPuzzle: puzzleType)
    }
}
