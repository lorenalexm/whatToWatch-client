//
//  MovieView.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI
import PlexKit
import CardStack

struct MovieView: View {
    // MARK: - Properties
    @EnvironmentObject private var plexClient: PlexClient
    @State private var movies: [PlexMediaItem]?
    let library: PlexLibrary?
    
    // MARK: - View declaration.
    var body: some View {
        VStack {
            if movies == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Loading..")
                    .font(.caption)
                    .padding(.top)
            } else {
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("🚀")
                                .font(.system(size: 64))
                                .padding(.trailing, 10)
                            Text("Ready? GO!")
                                .font(.largeTitle)
                        }.padding(.bottom)
                        Text("The time has come, start swiping! You know the drill. Once there has been a match with everyone else, we will let you know which movie was chosen!")
                            .padding(.bottom, 30)
                    }
                    
                    CardStack(direction: LeftRight.direction, data: movies!, id: \.key, onSwipe: { movie, direction in
                        print("Swiped \(movie.title!) to \(direction)")
                    }, content: { movie, _, _ in
                        MovieCard(movie: movie)
                    })
                    .environment(\.cardStackConfiguration, CardStackConfiguration(maxVisibleCards: 2, swipeThreshold: 0.35, animation: .easeInOut))
                }
            }
        }
        .navigationTitle("Movie Selection")
        .padding(.horizontal, 40)
        .onAppear() {
            guard let library else {
                print("No library received!")
                return
            }
            
            plexClient.listMovies(from: library) { result in
                switch result {
                case .success(let response):
                    movies = response.shuffled()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct MovieSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView(library: nil)
    }
}
