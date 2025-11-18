//
//  PreviewView.swift
//  MiniDVCapture
//
//  Created by JP on 11/18/25.
//

import SwiftUI
import AVFoundation

struct PreviewView: NSViewRepresentable {
    @EnvironmentObject var controller: DVCaptureController
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: controller.session)
        previewLayer.videoGravity = .resizeAspect
        view.layer = previewLayer
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Ensure the preview layer uses the current session
        if let previewLayer = nsView.layer as? AVCaptureVideoPreviewLayer {
            previewLayer.session = controller.session
        }
    }
}
