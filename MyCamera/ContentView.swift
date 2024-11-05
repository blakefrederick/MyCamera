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
    @State private var showFlash = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Full-screen Camera Preview
                    ZStack {
                        CameraPreview(camera: cameraModel)
                            .clipped()
                        
                        // Overlay with transparent center square
                        Color.black.opacity(0.25)
                            .mask(
                                Rectangle()
                                    .fill(Color.black.opacity(0.25))
                                    .overlay(
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                                    )
                            )
                        
                        // L-shaped corners around the central square
                        LShapedCornersOverlay(width: geometry.size.width * 0.8)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            
            // Shutter Button and Flash Effect
            VStack {
                Spacer()
                Button(action: {
                    cameraModel.takePhoto()
                    triggerFlash()
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
            
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
        }
    }
    
    // Flash Effect Function
    private func triggerFlash() {
        withAnimation(.easeInOut(duration: 0.1)) {
            showFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                showFlash = false
            }
        }
    }
}

