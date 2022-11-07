//
//  ServerSelectionView.swift.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI
import PlexKit

struct ServerSelectionView: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    @State private var servers: [PlexResource]?
    
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
                    print("Failed with the error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView()
    }
}
