//
//  ServerSelectionView.swift.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI
import PlexKit
import AlertToast

struct ServerSelectionView: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    @State private var servers: [PlexResource]?
    @State private var toastShowing = false
    @State private var toastSubTitle = ""
    
    // MARK: - View Declaration.
    var body: some View {
        VStack {
            if servers == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Loading..")
                    .font(.caption)
                    .padding(.top)
            } else {
                Text("Please choose the server that you intend to watch from.")
                    .padding(.bottom, 30)
                ForEach(servers!, id: \.name) { server in
                    RoundedButtonView(title: server.name) {
                        print("Button clicked")
                    }
                }
            }
        }
        .navigationTitle("Server Selection")
        .padding(.horizontal, 40)
        .onAppear() {
            plexClient.listServers() { result in
                switch result {
                case .success(let servers):
                    self.servers = servers
                case .failure(let error):
                    toastSubTitle = error.localizedDescription
                    toastShowing = true
                }
            }
        }
        .toast(isPresenting: $toastShowing, duration: 2.0, alert: {
            AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "Error!", subTitle: toastSubTitle)
        })
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView()
    }
}
