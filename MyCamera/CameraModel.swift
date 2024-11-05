//
//  CameraModel.swift
//  MyCamera
//
//  Created by Blake Frederick on 2024-11-04.
//

import Foundation
import SwiftUI
import AVFoundation
import Photos
import UIKit

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    
    override init() {
        super.init()
    }
    
    func setupCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            } catch {
                print("Error creating device input: \(error.localizedDescription)")
                return
            }
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func takePhoto() {
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("Failed to process photo data.")
            return
        }
        
        // Process the image to apply overlays and borders
        let processedImage = processImage(uiImage: uiImage)

        savePhotoToLibrary(uiImage: processedImage)
    }
    
func processImage(uiImage: UIImage) -> UIImage {
    let imageSize = uiImage.size
    let squareLength = min(imageSize.width, imageSize.height)
    let x = (imageSize.width - squareLength) / 2
    let y = (imageSize.height - squareLength) / 2
    let cropRect = CGRect(x: x, y: y, width: squareLength, height: squareLength)
    
    guard let cgImage = uiImage.cgImage?.cropping(to: cropRect) else {
        print("Failed to crop image.")
        return uiImage
    }
    
    let croppedImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
    
    // Create a new image context to draw  the corners and transparent overlay
    UIGraphicsBeginImageContextWithOptions(croppedImage.size, false, uiImage.scale)
    guard let context = UIGraphicsGetCurrentContext() else {
        print("Failed to create graphics context.")
        return croppedImage
    }
    
    // Draw the cropped image
    croppedImage.draw(at: CGPoint.zero)
    
    let overlayColor = UIColor.black.withAlphaComponent(0.25)
    let imageWidth = croppedImage.size.width
    let imageHeight = croppedImage.size.height
    
    // Draw top and bottom overlays (25% of the image height)
    let overlayHeight = imageHeight * 0.25
    context.setFillColor(overlayColor.cgColor)
    context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: overlayHeight))
    context.fill(CGRect(x: 0, y: imageHeight - overlayHeight, width: imageWidth, height: overlayHeight))
    
    // Get the processed image
    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return processedImage ?? croppedImage
}

    
    private func savePhotoToLibrary(uiImage: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("Photo Library access denied.")
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
            } completionHandler: { success, error in
                if !success {
                    print("Error saving photo: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCamera()
                }
            }
        case .authorized:
            setupCamera()
        default:
            break
        }
    }
}
