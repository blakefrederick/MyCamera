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
        let settings = AVCapturePhotoSettings()
        self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
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
        // Create a UIView with the same size as the image
        let imageSize = uiImage.size
        let view = UIView(frame: CGRect(origin: .zero, size: imageSize))
        
        // Create an UIImageView with the image
        let imageView = UIImageView(image: uiImage)
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        view.addSubview(imageView)
        
        // Create the overlay as in ContentView.swift
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.925)
        
        // Create the transparent center 
        let centerRectWidth = imageSize.width * 1.0 
        let centerRectHeight = imageSize.width * 0.8 
        let centerRectX = (imageSize.width - centerRectWidth) / 2
        let centerRectY = (imageSize.height - centerRectHeight) / 2
        let centerRect = CGRect(x: centerRectX, y: centerRectY, width: centerRectWidth, height: centerRectHeight)
        
        // Create a mask layer to make the center transparent
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(rect: centerRect).reversing())
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
        view.addSubview(overlayView)
        
        addLShapedCorners(to: view, centerRect: centerRect)
        
        // Render the view to an image
        UIGraphicsBeginImageContextWithOptions(imageSize, false, uiImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to create graphics context.")
            return uiImage
        }
        view.layer.render(in: context)
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return processedImage ?? uiImage
    }
    
    func addLShapedCorners(to view: UIView, centerRect: CGRect) {
        let lineWidth: CGFloat = 2.0
        let cornerLength: CGFloat = 30.0
        let strokeColor = UIColor.white.withAlphaComponent(0.7)
        
        // Top-left corner
        let topLeftCorner = UIView(frame: CGRect(x: centerRect.minX, y: centerRect.minY, width: cornerLength, height: lineWidth))
        topLeftCorner.backgroundColor = strokeColor
        let topLeftVertical = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: cornerLength))
        topLeftVertical.backgroundColor = strokeColor
        topLeftCorner.addSubview(topLeftVertical)
        view.addSubview(topLeftCorner)
        
        // Top-right corner
        let topRightCorner = UIView(frame: CGRect(x: centerRect.maxX - cornerLength, y: centerRect.minY, width: cornerLength, height: lineWidth))
        topRightCorner.backgroundColor = strokeColor
        let topRightVertical = UIView(frame: CGRect(x: cornerLength - lineWidth, y: 0, width: lineWidth, height: cornerLength))
        topRightVertical.backgroundColor = strokeColor
        topRightCorner.addSubview(topRightVertical)
        view.addSubview(topRightCorner)
        
        // Bottom-left corner
        let bottomLeftCorner = UIView(frame: CGRect(x: centerRect.minX, y: centerRect.maxY - lineWidth, width: cornerLength, height: lineWidth))
        bottomLeftCorner.backgroundColor = strokeColor
        let bottomLeftVertical = UIView(frame: CGRect(x: 0, y: -cornerLength + lineWidth, width: lineWidth, height: cornerLength))
        bottomLeftVertical.backgroundColor = strokeColor
        bottomLeftCorner.addSubview(bottomLeftVertical)
        view.addSubview(bottomLeftCorner)
        
        // Bottom-right corner
        let bottomRightCorner = UIView(frame: CGRect(x: centerRect.maxX - cornerLength, y: centerRect.maxY - lineWidth, width: cornerLength, height: lineWidth))
        bottomRightCorner.backgroundColor = strokeColor
        let bottomRightVertical = UIView(frame: CGRect(x: cornerLength - lineWidth, y: -cornerLength + lineWidth, width: lineWidth, height: cornerLength))
        bottomRightVertical.backgroundColor = strokeColor
        bottomRightCorner.addSubview(bottomRightVertical)
        view.addSubview(bottomRightCorner)
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
