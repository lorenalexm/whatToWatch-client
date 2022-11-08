//
//  LibrarySelectionView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI
import PlexKit
import AlertToast

struct LibrarySelectionView: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    @State private var libraries: [PlexLibrary]?
    @State private var toastShowing = false
    @State private var toastSubTitle = ""
    let server: PlexResource?
    
    // MARK: - View Declaration.
    var body: some View {
        VStack {
            if libraries == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Loading..")
                    .font(.caption)
                    .padding(.top)
            } else {
                Text("Please choose the library that you intend to watch from.")
                    .padding(.bottom, 30)
                ForEach(libraries!, id: \.title!) { library in
                    Text(library.title!)
                }
            }
        }
        .navigationTitle("Library Selection")
        .padding(.horizontal, 40)
        .onAppear() {
            guard let server else {
                return
            }
            
            plexClient.listLibraries(from: server) { result in
                switch result {
                case .success(let libraries):
                    self.libraries = libraries
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

struct LibrarySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        LibrarySelectionView(server: nil)
    }
}