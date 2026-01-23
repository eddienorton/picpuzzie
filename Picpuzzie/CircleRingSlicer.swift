//
//  CircleRingSlicer.swift
//  Picpuzzie
//
//  Created by Claude on 1/20/26.
//

import UIKit
import CoreGraphics

struct CircleRingSlicer {

    struct Ring {
        let image: UIImage
        let innerRadius: CGFloat
        let outerRadius: CGFloat
    }

    static func sliceImageIntoRings(_ image: UIImage, numberOfRings: Int) -> [Ring] {
        guard let cgImage = image.cgImage else {
            print("CircleRingSlicer: Failed to get cgImage")
            return []
        }
        guard numberOfRings > 0 else {
            print("CircleRingSlicer: Invalid number of rings")
            return []
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let size = min(width, height)
        let maxRadius = size / 2.0

        // Calculate ring thickness
        let ringThickness = maxRadius / CGFloat(numberOfRings)

        var rings: [Ring] = []

        // Create each ring from outside to inside
        for i in 0..<numberOfRings {
            let outerRadius = maxRadius - (CGFloat(i) * ringThickness)
            let innerRadius = (i == numberOfRings - 1) ? 0 : outerRadius - ringThickness

            if let ringImage = extractRing(from: cgImage,
                                          size: CGSize(width: width, height: height),
                                          innerRadius: innerRadius,
                                          outerRadius: outerRadius,
                                          scale: image.scale,
                                          orientation: image.imageOrientation) {
                rings.append(Ring(image: ringImage, innerRadius: innerRadius, outerRadius: outerRadius))
            }
        }

        return rings
    }

    private static func extractRing(from cgImage: CGImage,
                                   size: CGSize,
                                   innerRadius: CGFloat,
                                   outerRadius: CGFloat,
                                   scale: CGFloat,
                                   orientation: UIImage.Orientation) -> UIImage? {

        let squareSize = Int(min(size.width, size.height))

        // Create a bitmap context
        guard let context = CGContext(data: nil,
                                     width: squareSize,
                                     height: squareSize,
                                     bitsPerComponent: 8,
                                     bytesPerRow: 0,
                                     space: CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }

        // Draw the full image
        let drawRect = CGRect(x: (CGFloat(squareSize) - size.width) / 2,
                            y: (CGFloat(squareSize) - size.height) / 2,
                            width: size.width,
                            height: size.height)
        context.draw(cgImage, in: drawRect)

        // Create annular mask (ring-shaped)
        let maskCenter = CGPoint(x: CGFloat(squareSize) / 2, y: CGFloat(squareSize) / 2)

        // Create the mask path
        let path = CGMutablePath()

        // Add outer circle
        path.addArc(center: maskCenter,
                   radius: outerRadius,
                   startAngle: 0,
                   endAngle: 2 * .pi,
                   clockwise: false)

        // If there's an inner radius, subtract inner circle
        if innerRadius > 0 {
            path.addArc(center: maskCenter,
                       radius: innerRadius,
                       startAngle: 0,
                       endAngle: 2 * .pi,
                       clockwise: true)
        }

        // Clip to the ring shape
        context.clear(CGRect(x: 0, y: 0, width: squareSize, height: squareSize))
        context.addPath(path)
        context.clip(using: .evenOdd)
        context.draw(cgImage, in: drawRect)

        // Get the masked image
        guard let maskedImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: maskedImage, scale: scale, orientation: orientation)
    }
}
