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
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
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
