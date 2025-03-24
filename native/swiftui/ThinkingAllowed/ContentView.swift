//
//  ContentView.swift
//  ThinkingAllowed
//

import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm
import AVFoundation

struct ContentView: View {
    var body: some View {
        #LiveView(
            .automatic(
                // development: .localhost(path: "/"),
                development: .localhost(port: 4010, path: "/"),
                production: URL(string: "https://example.com")!
            ),
            addons: [
               .liveForm
            ]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
        .onAppear {
            requestMicrophonePermission()
        }
    }
}

func requestMicrophonePermission() {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
        if granted {
            print("Microphone permission granted.")
        } else {
            print("Microphone permission denied.")
        }
    }
}
