//
//  LShapedCornersOverlay.swift
//  MyCamera
//
//  Created by Blake Frederick on 2024-11-04.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct LShapedCornersOverlay: View {
    var width: CGFloat
    
    var body: some View {
        ZStack {
            // Top-left L shape
            VStack {
                Rectangle()
                    .frame(width: 30, height: 2)
                Spacer()
            }
            .frame(width: 30, height: 30)
            .offset(x: -(width / 2) + 15, y: -(width / 2) + 15)
            
            HStack {
                Rectangle()
                    .frame(width: 2, height: 30)
                Spacer()
            }
            .frame(width: 30, height: 30)
            .offset(x: -(width / 2) + 15, y: -(width / 2) + 15)

            // Top-right L shape
            VStack {
                Rectangle()
                    .frame(width: 30, height: 2)
                Spacer()
            }
            .frame(width: 30, height: 30)
            .offset(x: (width / 2) - 15, y: -(width / 2) + 15)
            
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 2, height: 30)
            }
            .frame(width: 30, height: 30)
            .offset(x: (width / 2) - 15, y: -(width / 2) + 15)
            
            // Bottom-left L shape
            VStack {
                Spacer()
                Rectangle()
                    .frame(width: 30, height: 2)
            }
            .frame(width: 30, height: 30)
            .offset(x: -(width / 2) + 15, y: (width / 2) - 15)
            
            HStack {
                Rectangle()
                    .frame(width: 2, height: 30)
                Spacer()
            }
            .frame(width: 30, height: 30)
            .offset(x: -(width / 2) + 15, y: (width / 2) - 15)

            // Bottom-right L shape
            VStack {
                Spacer()
                Rectangle()
                    .frame(width: 30, height: 2)
            }
            .frame(width: 30, height: 30)
            .offset(x: (width / 2) - 15, y: (width / 2) - 15)
            
            HStack {
                Spacer()
                Rectangle()
                    .frame(width: 2, height: 30)
            }
            .frame(width: 30, height: 30)
            .offset(x: (width / 2) - 15, y: (width / 2) - 15)
        }
        .foregroundColor(.white.opacity(0.7))
    }
}
