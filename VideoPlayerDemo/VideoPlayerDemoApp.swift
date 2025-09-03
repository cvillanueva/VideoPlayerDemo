//
//  VideoPlayerDemoApp.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 30-08-25.
//

import SwiftUI

@main
struct VideoPlayerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            VideosListView(networkManager: NetworkManagerImpl())
                .preferredColorScheme(.light) 
        }
    }
}
