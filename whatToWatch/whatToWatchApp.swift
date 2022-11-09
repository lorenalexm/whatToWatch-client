//
//  whatToWatchApp.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/2/22.
//

import SwiftUI
import SwiftUIRouter

@main
struct whatToWatchApp: App {
    // MARK: - View declaration.
    var body: some Scene {
        WindowGroup {
            Router {
                RootView()
            }
        }
    }
}
