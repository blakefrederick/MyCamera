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
                    Spacer()
                    ZStack {
                        // Camera Preview
                        CameraPreview(camera: cameraModel)
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                        
                        // White Rounded Border at Corners
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                            .padding(20)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    Spacer()
                }
                .background(Color.black)
                
                // Top and Bottom Dark Overlays
                VStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(height: (geometry.size.height - geometry.size.width) / 2)
                    Spacer()
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(height: (geometry.size.height - geometry.size.width) / 2)
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
