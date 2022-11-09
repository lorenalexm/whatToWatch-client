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
                Text("There must be a load of movies somewhere. Time to pick what library you want to watch from.")
                    .padding(.bottom, 30)
                ForEach(libraries!, id: \.title!) { library in
                    NavigationLink(destination: MovieSwipeView(library: library)) {
                        RoundedButton(title: library.title ?? "Unnamed Library")
                    }
                }
            }
        }
        .navigationTitle("Library Selection")
        .padding(.horizontal, 40)
        .onAppear() {
            plexClient.listLibraries() { result in
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
        LibrarySelectionView()
    }
}
