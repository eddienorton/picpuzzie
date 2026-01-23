//
//  PhotoLibraryService.swift
//  Picpuzzie
//
//  Created by Claude on 1/19/26.
//

import UIKit
import Photos
import AVFoundation

class PhotoLibraryService {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        // If already authorized, return immediately
        if currentStatus == .authorized || currentStatus == .limited {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }

        // Request permission
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }

    static func fetchRandomPhoto(completion: @escaping (UIImage?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        guard status == .authorized || status == .limited else {
            print("Photo library access denied. Status: \(status.rawValue)")
            completion(nil)
            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        // Fetch both photos AND videos
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)

        guard fetchResult.count > 0 else {
            completion(nil)
            return
        }

        // Get random index
        let randomIndex = Int.random(in: 0..<fetchResult.count)
        let asset = fetchResult.object(at: randomIndex)

        // Check if it's a video or photo
        if asset.mediaType == .video {
            // Extract frame from video
            extractFrameFromVideo(asset: asset, completion: completion)
        } else {
            // Load photo normally
            fetchImageFromAsset(asset: asset, completion: completion)
        }
    }

    private static func fetchImageFromAsset(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: requestOptions
        ) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    completion(centerCropToSquare(image: image))
                } else {
                    completion(nil)
                }
            }
        }
    }

    private static func extractFrameFromVideo(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHVideoRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat

        imageManager.requestAVAsset(forVideo: asset, options: requestOptions) { avAsset, _, _ in
            guard let avAsset = avAsset else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let imageGenerator = AVAssetImageGenerator(asset: avAsset)
            imageGenerator.appliesPreferredTrackTransform = true

            // Extract frame from middle of video
            Task {
                do {
                    let duration = try await avAsset.load(.duration)
                    let midpoint = CMTime(seconds: duration.seconds / 2.0, preferredTimescale: 600)
                    let cgImage = try await imageGenerator.image(at: midpoint).image
                    let image = UIImage(cgImage: cgImage)

                    DispatchQueue.main.async {
                        completion(centerCropToSquare(image: image))
                    }
                } catch {
                    print("Failed to extract frame from video: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }

    private static func centerCropToSquare(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // Already square, return as-is
        if width == height {
            return image
        }

        // Calculate crop size (the smaller dimension)
        let cropSize = min(width, height)

        // Calculate crop origin (centered)
        let xOffset = (width - cropSize) / 2
        let yOffset = (height - cropSize) / 2

        // Create crop rectangle
        let cropRect = CGRect(x: xOffset, y: yOffset, width: cropSize, height: cropSize)

        // Crop the image
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }

        // Fallback: return original if cropping fails
        return image
    }
}
