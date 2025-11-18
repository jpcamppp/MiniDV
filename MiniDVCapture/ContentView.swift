//
//  ContentView.swift
//  MiniDVCapture
//
//  Created by JP on 11/17/25.
//

import SwiftUI
import Foundation
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var controller: DVCaptureController
    
    var body: some View {
        VStack(spacing: 16) {
            Text("MiniDV Capture")
                .font(.largeTitle)
                .bold()
            
            // Device selection + refresh
            HStack(spacing: 12) {
                Picker("Device:", selection: Binding(
                    get: {
                        controller.selectedDevice
                    },
                    set: { newValue in
                        controller.selectedDevice = newValue
                    }
                )) {
                    if controller.devices.isEmpty {
                        Text("No devices").tag(Optional<AVCaptureDevice>.none)
                    } else {
                        ForEach(controller.devices, id: \.uniqueID) { device in
                            Text(device.localizedName)
                                .tag(Optional(device))
                        }
                    }
                }
                .frame(minWidth: 260)
                
                Button("Refresh Devices") {
                    controller.refreshDevices()
                }
            }
            
            // Status text
            Text(controller.statusText)
                .font(.callout)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Preview
            ZStack {
                PreviewView()
                    .environmentObject(controller)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                if !controller.session.isRunning {
                    Text("Start capture and press PLAY on your camcorder.\nVideo will appear here.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                }
            }
            .frame(minHeight: 320)
            
            // Controls
            HStack(spacing: 16) {
                Button(action: {
                    controller.startCapture()
                }) {
                    Label("Start Capture", systemImage: "record.circle")
                }
                .disabled(controller.isRecording || controller.selectedDevice == nil)
                
                Button(action: {
                    controller.stopCapture()
                }) {
                    Label("Stop Capture", systemImage: "stop.circle")
                }
                .disabled(!controller.isRecording)
                
                Spacer()
            }
            
        }
        .padding(20)
        .frame(minWidth: 700, minHeight: 500)
    }
}


#Preview {
    ContentView()
}
