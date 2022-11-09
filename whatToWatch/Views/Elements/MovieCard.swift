//
//  MovieCard.swift
//  whatToWatch
//
//  Created by Alex Loren on 11/7/22.
//

import SwiftUI
import PlexKit

struct MovieCard: View {
    // MARK: - Properties.
    @EnvironmentObject private var plexClient: PlexClient
    @State private var cover: UIImage?
    let movie: PlexMediaItem?
    
    // MARK: - View declaration.
    var body: some View {
        Group {
            if cover == nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 300, height: 400)
                        .foregroundColor(.white)
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Loading..")
                            .font(.caption)
                            .padding(.top)
                    }
                }
            } else {
                Image(uiImage: cover!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .onAppear() {
            guard let movie else {
                return
            }
            plexClient.fetchImage(path: movie.thumb!) { result in
                switch result {
                case .success(let data):
                    cover = UIImage(data: data)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct MovieCard_Previews: PreviewProvider {
    static var previews: some View {
        MovieCard(movie: nil)
    }
}
