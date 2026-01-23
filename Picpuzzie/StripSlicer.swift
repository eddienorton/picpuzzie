//
//  StripSlicer.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import UIKit

struct StripSlicer {

    enum Orientation {
        case horizontal
        case vertical
    }

    static func sliceImageIntoStrips(_ image: UIImage, numberOfStrips: Int, orientation: Orientation) -> [UIImage] {
        guard let cgImage = image.cgImage else {
            print("StripSlicer: Failed to get cgImage from UIImage")
            return []
        }
        guard numberOfStrips > 0 else {
            print("StripSlicer: Invalid number of strips")
            return []
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        var strips: [UIImage] = []

        switch orientation {
        case .horizontal:
            // Slice into horizontal strips (each strip is full width, partial height)
            let stripHeight = height / CGFloat(numberOfStrips)

            for i in 0..<numberOfStrips {
                let y = CGFloat(i) * stripHeight
                let rect = CGRect(x: 0, y: y, width: width, height: stripHeight)

                if let croppedCGImage = cgImage.cropping(to: rect) {
                    let strip = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
                    strips.append(strip)
                } else {
                    print("StripSlicer: Failed to crop horizontal strip \(i)")
                    return []
                }
            }

        case .vertical:
            // Slice into vertical strips (each strip is partial width, full height)
            let stripWidth = width / CGFloat(numberOfStrips)

            for i in 0..<numberOfStrips {
                let x = CGFloat(i) * stripWidth
                let rect = CGRect(x: x, y: 0, width: stripWidth, height: height)

                if let croppedCGImage = cgImage.cropping(to: rect) {
                    let strip = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
                    strips.append(strip)
                } else {
                    print("StripSlicer: Failed to crop vertical strip \(i)")
                    return []
                }
            }
        }

        return strips
    }
}
