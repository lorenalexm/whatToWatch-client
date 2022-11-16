//
//  RootSelectionView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/9/22.
//

import SwiftUI

struct RootSelectionView: View {
    // MARK: - Properties
    @EnvironmentObject private var plexClient: PlexClient
    
    // MARK: - View declaration.
    var body: some View {
        NavigationStack {
            ServerSelectionView()
        }
    }
}

struct RootSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RootSelectionView()
    }
}
