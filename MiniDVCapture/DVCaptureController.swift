//
//  DVCaptureController.swift
//  MiniDVCapture
//
//  Created by JP on 11/17/25.
//

import Foundation
import AVFoundation
import Combine

final class DVCaptureController: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    
    @Published var devices: [AVCaptureDevice] = []
    @Published var selectedDevice: AVCaptureDevice?
    @Published var isRecording: Bool = false
    @Published var statusText: String = "Ready"
    
    //Creating a capture session + output
    
    let captureSession = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    override init() {
        super.init()
        refreshDevices() //function to discover devices - NOT YET ADDED
    }
    
    
    
    
    
}
