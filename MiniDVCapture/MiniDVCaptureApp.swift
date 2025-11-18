//
//  MiniDVCaptureApp.swift
//  MiniDVCapture
//
//  Created by JP on 11/17/25.
//

import SwiftUI

@main
struct MiniDVCaptureApp: App {
    @StateObject private var controller = DVCaptureController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller)
        }
    }
}

