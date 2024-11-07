//
//  CameraPreview.swift
//  MyCamera
//
//  Created by Blake Frederick on 2024-11-04.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class PreviewView: UIView {
        var cameraModel: CameraModel?
        private var overlayView: UIView!
        private var topLeftCorner: UIView!
        private var topRightCorner: UIView!
        private var bottomLeftCorner: UIView!
        private var bottomRightCorner: UIView!
        
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupOverlayAndCorners()
            setupTapGestureRecognizer() 
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupOverlayAndCorners()
            setupTapGestureRecognizer() 
        }
        
        private func setupOverlayAndCorners() {
            // Full-screen overlay view with transparent center
            overlayView = UIView()
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.925)
            overlayView.isUserInteractionEnabled = false // Ensure overlay doesn’t block interactions
            addSubview(overlayView)
            
            // Corners
            topLeftCorner = createCornerView()
            topRightCorner = createCornerView()
            bottomLeftCorner = createCornerView()
            bottomRightCorner = createCornerView()
            
            addSubview(topLeftCorner)
            addSubview(topRightCorner)
            addSubview(bottomLeftCorner)
            addSubview(bottomRightCorner)
        }
        
        private func createCornerView() -> UIView {
            let cornerView = UIView()
            cornerView.backgroundColor = .clear
            cornerView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
            cornerView.layer.borderWidth = 2
            return cornerView
        }
        
        private func setupTapGestureRecognizer() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            self.addGestureRecognizer(tapGesture)
        }
        
        @objc private func handleTap(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: self)
            print("Screen tapped")
            print("Tapped at x: \(location.x), y: \(location.y)")

            // Convert the tap location to a focus point in the camera's coordinate space
            if let cameraModel = cameraModel {
                let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: location)
                cameraModel.focus(at: focusPoint)
            }

            // iconic yellow focus square
            showFocusSquare(at: location)
        }


        private func showFocusSquare(at point: CGPoint) {
            let focusSquareSize: CGFloat = 80
            let focusSquare = UIView(frame: CGRect(x: 0, y: 0, width: focusSquareSize, height: focusSquareSize))
            focusSquare.center = point
            focusSquare.layer.borderColor = UIColor.yellow.cgColor
            focusSquare.layer.borderWidth = 1.0
            focusSquare.backgroundColor = UIColor.clear
            addSubview(focusSquare)

            focusSquare.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            focusSquare.alpha = 0.0

            // iconic yellow focus square animation
            UIView.animate(withDuration: 0.15, animations: {
                focusSquare.transform = CGAffineTransform.identity
                focusSquare.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                    focusSquare.alpha = 0.0
                }) { _ in
                    focusSquare.removeFromSuperview()
                }
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Set the overlay to fill the entire preview
            overlayView.frame = bounds
            
            // Define the square area in the center
            let squareSize = min(bounds.width, bounds.height) * 1.0
            let centerX = (bounds.width - squareSize) / 2
            let centerY = (bounds.height - squareSize) / 2
            
            // Make the center of overlay transparent
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: bounds)
            path.append(UIBezierPath(rect: CGRect(x: centerX, y: centerY, width: squareSize, height: squareSize)).reversing())
            maskLayer.path = path.cgPath
            overlayView.layer.mask = maskLayer
            
            // Set up L-shaped corner views
            let cornerLength: CGFloat = 30
            let lineWidth: CGFloat = 2
            
            // Position each corner view at the corners of the central square
            // Top-left corner
            topLeftCorner.frame = CGRect(x: centerX, y: centerY, width: cornerLength, height: lineWidth) // Horizontal part
            topLeftCorner.addSubview(createVerticalLine(x: 0, y: 0, height: cornerLength))
            
            // Top-right corner
            topRightCorner.frame = CGRect(x: centerX + squareSize - cornerLength, y: centerY, width: cornerLength, height: lineWidth)
            topRightCorner.addSubview(createVerticalLine(x: cornerLength - lineWidth, y: 0, height: cornerLength))
            
            // Bottom-left corner
            bottomLeftCorner.frame = CGRect(x: centerX, y: centerY + squareSize - lineWidth, width: cornerLength, height: lineWidth)
            bottomLeftCorner.addSubview(createVerticalLine(x: 0, y: -cornerLength + lineWidth, height: cornerLength))
            
            // Bottom-right corner
            bottomRightCorner.frame = CGRect(x: centerX + squareSize - cornerLength, y: centerY + squareSize - lineWidth, width: cornerLength, height: lineWidth)
            bottomRightCorner.addSubview(createVerticalLine(x: cornerLength - lineWidth, y: -cornerLength + lineWidth, height: cornerLength))
        }
        
        private func createVerticalLine(x: CGFloat, y: CGFloat, height: CGFloat) -> UIView {
            let verticalLine = UIView()
            verticalLine.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            verticalLine.frame = CGRect(x: x, y: y, width: 2, height: height)
            return verticalLine
        }
    }
    
    var camera: CameraModel
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = camera.session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.cameraModel = camera 
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
