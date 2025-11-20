//
//  DVCaptureController.swift
//  MiniDVCapture
//
//  Created by JP on 11/17/25.
//

import Foundation
import AVFoundation
import UserNotifications
import Combine

final class DVCaptureController: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var devices: [AVCaptureDevice] = []
    @Published var selectedDevice: AVCaptureDevice?
    @Published var isRecording: Bool = false
    @Published var statusText: String = "Ready"
    @Published var lastDeviceCount = 0
    
    //Creating a capture session + output
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            self.refreshDevices()
        }
    }
    
    //Notification Helpers
    private func sendDeviceConnectedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "DV Device Connected"
        content.body = "A MiniDV camcorder is now available."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // deliver immediately
        )
            
            UNUserNotificationCenter.current().add(request)
    }

    private func sendDeviceDisconnectedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "DV Device Disconnected"
        content.body = "The MiniDV camcorder was unplugged or turned off."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

            UNUserNotificationCenter.current().add(request)
    }

    
    func refreshDevices() {

        // MiniDV cameras only appear as MUXED media devices under .externalUnknown
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.externalUnknown],
            mediaType: .muxed,
            position: .unspecified
        )

        let allDevices = discovery.devices

        // Filter for real DV devices (Sony, Canon, Panasonic, etc.)
        let dvDevices = allDevices.filter { device in
            device.hasMediaType(.muxed) && (
                device.modelID.uppercased().contains("DV") ||
                device.localizedName.uppercased().contains("DV") ||
                device.localizedName.uppercased().contains("DVCAM") ||
                device.localizedName.uppercased().contains("MINIDV") ||
                device.manufacturer.uppercased().contains("SONY") == true
            )
        }

        // Debug output: helps you confirm what macOS is actually detecting
        print("----- MINI-DV DEVICE SCAN -----")
        if allDevices.isEmpty {
            print("No .muxed devices detected at all")
        } else {
            for d in allDevices {
                print("Name:      \(d.localizedName)")
                print("ModelID:   \(d.modelID)")
                print("Vendor:    \(d.manufacturer)")
                print("UniqueID:  \(d.uniqueID)")
                print("Has MUXED: \(d.hasMediaType(.muxed))")
                print("-------------------------------")
            }
        }

        DispatchQueue.main.async {
            self.devices = dvDevices
            self.selectedDevice = dvDevices.first

            if dvDevices.isEmpty {
                self.statusText = "No MiniDV device detected. Ensure it is ON and in PLAY mode."
            } else {
                self.statusText = "Found \(dvDevices.count) MiniDV device(s)."
            }
        }
    }

    
    
    
    private func configureSession(for device: AVCaptureDevice) throws {
        
        session.beginConfiguration()
        
        for input in session.inputs {
            session.removeInput(input)
        }
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        if session.canSetSessionPreset(.high){
            session.sessionPreset = .high
        }
        
        let input = try AVCaptureDeviceInput(device: device)
        
        //set dv device to capture input
        guard session.canAddInput(input) else {
            throw NSError(domain: "MiniDVCapture", code: -1, userInfo: [NSLocalizedDescriptionKey: "Can't add input"])
        }
        session.addInput(input)
        
        //creates .mov file
        guard session.canAddOutput(movieOutput) else {
            throw NSError(domain: "MiniDVCapture", code: -2, userInfo: [NSLocalizedDescriptionKey: "Can't add output"])
        }
        session.addOutput(movieOutput)
        
        //continuous dv stream
        movieOutput.movieFragmentInterval = .invalid
        
        session.commitConfiguration()
            
    }
    
    //capture function
    func startCapture(){
        guard !isRecording else { return } //prevent multiple captures
        guard let device = selectedDevice else {
            statusText = "No device selected"
            return
        }//is the device there or nah
        
        do{
            try configureSession(for: device)
        }catch{
            statusText = "Session error: \(error.localizedDescription)"
            return
        }//create session
        
        if !session.isRunning {
            session.startRunning()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        let documents = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Documents")
        
        let outputURL = documents.appendingPathComponent("MiniDV-\(timestamp).mov")
        
        statusText = "Recording to  \(outputURL.lastPathComponent)..."
        isRecording = true
        
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    //end capture
    func stopCapture(){
        guard isRecording else { return }
        movieOutput.stopRecording()
        statusText = "Stopped Recording"
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: (any Error)?) {
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.session.stopRunning()
        }
        if let error = error{
            self.statusText = "Recording failed: \(error.localizedDescription)"
        }else{
            self.statusText = "Recording finished: \(outputFileURL.lastPathComponent)"
        }
    }
}
