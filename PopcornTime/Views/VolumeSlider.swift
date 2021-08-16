//
//  VolumeSlider.swift
//  VolumeSlider
//
//  Created by Alexandru Tudose on 14.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeButtonSlider: View {
    @State var previousValue: Float = -1
    @State var volume: Float = 0
    
    var body: some View {
        HStack {
            Button {
                let value = volume
                volume = previousValue != 0 ? 0 : previousValue
                previousValue = value
            } label: {
                Color.clear.overlay {
                    Image(volume > 0 ? "Volume Maximum" : "Volume Minimum")
                        .padding(.leading, maskValue)
                        .mask(Rectangle().padding(.trailing, maskValue))
                }
                .clipped()
            }
            .frame(width: 41)
            
            VolumeSlider(volume: $volume)
                .padding(.top, 14)
                .padding(.trailing, 10)
        }
    }
    
    var maskValue: CGFloat {
        switch volume {
        case 0:
            return 0
        case 0..<0.4:
            return 11
        case 0.4..<0.7:
            return 6
        default:
            return 0
        }
    }
}

struct VolumeSlider: UIViewRepresentable {
    @State var volumeObservation: NSKeyValueObservation?
    @Binding var volume: Float
    
    
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        if let slider = volumeView.subviews.compactMap({$0 as? UISlider}).first {
            context.coordinator.addObservers(slider: slider)
        }
        return volumeView
    }
    
    func updateUIView(_ view: MPVolumeView, context: Context) {}
    
    func makeCoordinator() -> VolumeSliderCoordinator {
        return VolumeSliderCoordinator(binding: $volume)
    }
    
    class VolumeSliderCoordinator {
        var binding: Binding<Float>
        
        init(binding: Binding<Float>) {
            self.binding = binding
        }
        
        func addObservers(slider: UISlider) {
            slider.addTarget(self, action: #selector(volumeChanged(slider:)), for: .valueChanged)
        }
        
        @objc func volumeChanged(slider: UISlider) {
            binding.wrappedValue = slider.value
        }
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        VolumeButtonSlider()
            .frame(width: 200, height: 41)
            .preferredColorScheme(.dark)
//            .previewLayout(.fixed(width: 150, height: 46))
    }
}


