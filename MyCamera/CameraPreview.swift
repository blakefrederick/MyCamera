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
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupOverlayAndCorners()
        }
        
        private func setupOverlayAndCorners() {
            // Full-screen overlay view with transparent center
            overlayView = UIView()
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
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
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Set the overlay to fill the entire preview
            overlayView.frame = bounds
            
            // Define the square area in the center
            let squareSize = min(bounds.width, bounds.height) * 0.8
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
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
