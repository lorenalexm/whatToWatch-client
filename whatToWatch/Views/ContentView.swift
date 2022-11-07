//
//  ContentView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    
    // MARK: - View declaration.
    var body: some View {
        NavigationStack {
            if plexClient.user == nil {
                SignInView()
            } else {
                ServerSelectionView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
