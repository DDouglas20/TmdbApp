//
//  FavoritesView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @Environment(\.darkModeColor) private var color
    @StateObject var viewModel = FavoritesViewModel()
    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.sortedMovies, id: \.self) { movie in
                    NavigationLink(value: movie) {
                        FavoriteMovieView(
                            data: .init(
                                movieId: movie.id,
                                portaitPath: movie.portaitPath,
                                movieName: movie.movieName,
                                description: movie.overview,
                                director: movie.director?.name
                            )
                        )
                    }
                }
                .onDelete { indexSet in
                    // We will only allow one deletion at a time
                    if let index = indexSet.first, let movieId = viewModel.sortedMovies[index].id {
                        viewModel.manageFavorite(id: movieId, index: index)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.removeFavAlert, actions: {}, message: {
                Text("Could not remove favorite. Please try again later.")
            })
            .navigationDestination(for: MovieData.self) { movie in
                MovieDetailsView(viewModel: .init(movieObject: movie))
            }
            if viewModel.sortedMovies.isEmpty {
                Text("No Favorites")
                    .foregroundStyle(color)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            viewModel.getFavoriteMoviesArr()
        }
    }
}

private struct FavoriteMovieView: View {
    @Environment(\.darkModeColor) var color
    let data: FavoriteMovieData // We hold onto the whole object to allow Navigation to details
    
    struct FavoriteMovieData {
        var movieId: Int?
        var portaitPath: String?
        var movieName: String?
        var description: String?
        var director: String?
    }
    var body: some View {
        HStack {
            if let portaitPath = data.portaitPath, let url = URL(string: ApiClient.baseImageURL + portaitPath) {
                KFImage(url)
                    .resizable()
                    .placeholder { _ in
                        ProgressView()
                            .tint(color)
                    }
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(data.movieName ?? "Couldn't get Title")
                    .foregroundStyle(color)
                    .font(.system(size: 21))
                    .fontWeight(.semibold)
                if let desc = data.description {
                    Text(desc)
                        .foregroundStyle(color)
                        .font(.system(size: 17))
                        .lineLimit(2)
                }
                if let director = data.director {
                    Text(director.capitalized)
                        .foregroundStyle(color)
                        .font(.system(size: 15))
                        .underline()
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}
