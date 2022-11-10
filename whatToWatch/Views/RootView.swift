//
//  RootView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/8/22.
//

import SwiftUI
import SwiftUIRouter

struct RootView: View {
    // MARK: - Properties.
    @EnvironmentObject private var navigator: Navigator
    private let plexClient = PlexClient()
    
    // MARK: - View declaration.
    var body: some View {
        SwitchRoutes {
            Route("movies") {
                if plexClient.selectedLibrary == nil {
                    Navigate(to: "selections", replace: true)
                } else {
                    MovieView(library: plexClient.selectedLibrary!)
                        .environmentObject(plexClient)
                }
            }
            Route("selections") {
                RootSelectionView()
                    .environmentObject(plexClient)
            }
            Route {
                SignInView()
                    .environmentObject(plexClient)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
