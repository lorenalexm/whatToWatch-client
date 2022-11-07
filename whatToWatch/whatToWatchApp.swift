//
//  whatToWatchApp.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import SwiftUI

@main
struct whatToWatchApp: App {
    // MARK: - Properties.
    private let plexClient = PlexClient()
    
    // MARK: - View declaration.
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(plexClient)
        }
    }
}
