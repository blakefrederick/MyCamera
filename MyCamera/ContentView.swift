//
//  ContentView.swift
//  MyCamera
//
//  Created by Blake Frederick on 2024-11-04.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct ContentView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: cameraModel)
                .ignoresSafeArea()
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .clear, .clear, .black.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                )
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        .padding(20)
                )
            
            VStack {
                Spacer()
                Button(action: {
                    cameraModel.takePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
        }
    }
}

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
        
        self.savePhotoToLibrary(uiImage: uiImage)
    }
    
    private func savePhotoToLibrary(uiImage: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
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
