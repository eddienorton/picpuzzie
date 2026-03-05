//
//  PizzaSlicer.swift
//  Picpuzzie
//
//  Created by Claude on 2/14/26.
//

import UIKit

struct PizzaSlicer {
    struct Slice {
        let image: UIImage
        let startAngle: Double  // In degrees, 0 = right, 90 = bottom
        let endAngle: Double
        let correctPosition: Int  // Which position this slice belongs in (0, 1, 2, etc.)
    }
    
    static func sliceImageIntoPizza(_ image: UIImage, numberOfSlices: Int) -> [Slice] {
        guard numberOfSlices > 0 else { return [] }
        
        
        // First, crop the image to a square
        let squareImage = cropToSquare(image)
        
        // Use the actual CGImage size for slicing
        guard let cgImage = squareImage.cgImage else {
            return []
        }
        let size = CGFloat(cgImage.width)
        
        let anglePerSlice = 360.0 / Double(numberOfSlices)
        
        var slices: [Slice] = []
        
        for i in 0..<numberOfSlices {
            
            if let sliceImage = createSliceImage(from: squareImage,
                                                wedgeAngle: anglePerSlice,
                                                sliceIndex: i,
                                                size: size) {
                let slice = Slice(
                    image: sliceImage,
                    startAngle: Double(i) * anglePerSlice,
                    endAngle: Double(i) * anglePerSlice + anglePerSlice,
                    correctPosition: i
                )
                slices.append(slice)
            } else {
            }
        }
        
        return slices
    }
    
    private static func cropToSquare(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // If already square, return as-is
        if width == height {
            return image
        }
        
        let minDimension = min(width, height)
        
        
        // Create crop rect in pixel coordinates - use floor to ensure integer pixels
        let cropRect = CGRect(
            x: floor((width - minDimension) / 2),
            y: floor((height - minDimension) / 2),
            width: minDimension,
            height: minDimension
        )
        
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return image
        }
        
        let result = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        // Return with same scale and orientation
        return result
    }
    
    private static func createSliceImage(from image: UIImage, 
                                        wedgeAngle: Double,
                                        sliceIndex: Int,
                                        size: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size, height: size)
        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = size / 2
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // First, rotate the entire context by sliceIndex * wedgeAngle
        // This rotates the source image so the correct part appears in our fixed wedge
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: -Double(sliceIndex) * wedgeAngle * .pi / 180)
        context.translateBy(x: -center.x, y: -center.y)
        
        // Draw the image (now rotated)
        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        
        context.restoreGState()
        
        // Now clip to a wedge that always points UP (from -90° to -90°+wedgeAngle)
        let path = UIBezierPath()
        path.move(to: center)
        
        // Create wedge from top going clockwise
        let startRadians = -(Double.pi / 2)  // -90° = top
        let endRadians = startRadians + (wedgeAngle * Double.pi / 180)
        
        path.addArc(withCenter: center, 
                   radius: radius, 
                   startAngle: startRadians, 
                   endAngle: endRadians, 
                   clockwise: true)
        
        path.addLine(to: center)
        path.close()
        
        // Clip and redraw
        let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Now create a new context and draw only the clipped part
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        _ = UIGraphicsGetCurrentContext()  // Create context but don't need to use it
        
        path.addClip()
        clippedImage?.draw(in: CGRect(origin: .zero, size: canvasSize))
        
        let sliceImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return sliceImage
    }
}
