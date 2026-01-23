//
//  ImageSlicer.swift
//  Picpuzzie
//
//  Created by Claude on 1/19/26.
//

import UIKit

struct ImageSlicer {
    static func sliceImage(_ image: UIImage, gridSize: Int) -> [[UIImage]] {
        guard let cgImage = image.cgImage else {
            print("ImageSlicer: Failed to get cgImage from UIImage")
            return []
        }
        guard gridSize > 0 else {
            print("ImageSlicer: Invalid grid size: \(gridSize)")
            return []
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let pieceWidth = width / CGFloat(gridSize)
        let pieceHeight = height / CGFloat(gridSize)

        var pieces: [[UIImage]] = []

        for row in 0..<gridSize {
            var rowPieces: [UIImage] = []
            for col in 0..<gridSize {
                let x = CGFloat(col) * pieceWidth
                let y = CGFloat(row) * pieceHeight
                let rect = CGRect(x: x, y: y, width: pieceWidth, height: pieceHeight)

                if let croppedCGImage = cgImage.cropping(to: rect) {
                    let piece = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
                    rowPieces.append(piece)
                } else {
                    print("ImageSlicer: Failed to crop image at row:\(row) col:\(col)")
                    // Return empty if any piece fails - ensures valid grid
                    return []
                }
            }

            // Verify row has correct number of pieces
            guard rowPieces.count == gridSize else {
                print("ImageSlicer: Row \(row) has \(rowPieces.count) pieces, expected \(gridSize)")
                return []
            }

            pieces.append(rowPieces)
        }

        // Final verification
        guard pieces.count == gridSize else {
            print("ImageSlicer: Grid has \(pieces.count) rows, expected \(gridSize)")
            return []
        }

        return pieces
    }
}
