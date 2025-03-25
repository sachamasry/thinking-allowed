//
//  ContentView.swift
//  ThinkingAllowed
//

import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm
import AVFoundation
import OSLog

let logger = Logger(subsystem: "com.yourapp.bundleid", category: "LiveViewNative")

struct ContentView: View {
    var body: some View {
        #LiveView(
            .automatic(
                // development: .localhost(path: "/"),
                //development: .localhost(port: 4010, path: "/"),
                development: URL(string: "http://127.0.0.1:4010")!,
                //.connect(url: URL(string: "http://127.0.0.1:4010")!, transport: .webSocket),
                production: URL(string: "https://example.com")!
            ),
            addons: [
               .liveForm
            ]
            /*
            logger: { message in
                logger.log("\(message)")
            }
             */
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            //logger.error("LiveViewNative Error: \(error.localizedDescription)")
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
