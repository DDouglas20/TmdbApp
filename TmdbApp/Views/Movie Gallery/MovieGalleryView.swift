//
//  ContentView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI
import Kingfisher

struct MovieGalleryView: View {
    @StateObject var viewModel = MovieGalleryViewModel()
    @State var isLoading: Bool = false
    var body: some View {
        if viewModel.isLoading {
            // TODO: Shimmer view maybe?
            ProgressView()
                .tint(.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    Task {
                        await viewModel.loadMovies()
                    }
                }
        } else {
            TabView {
                Tab("Home", systemImage: "house", content: {
                    NavigationStack {
                        MovieGallerySubview(data: viewModel.returnMovieSubviewData(), titleString: viewModel.galleryTitleString)
                    }
                })
                Tab("Favorites", systemImage: "heart.fill", content: {
                    FavoritesView()
                })
            }
            
        }
    }
}

private struct MovieGallerySubview: View {
    let data: [MovieGalleryViewModel.MovieSubviewData]
    let titleString: String
    let columns = 3
    
    private var gridItems: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 100, maximum: 100), spacing: 16), count: columns)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                ForEach(data.indices, id: \.self) { index in
                    NavigationLink(value: data[index]) {
                        MoviePosterView(data: data[index])
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(titleString)
        .navigationBarTitleDisplayMode(.automatic)
        .navigationDestination(for: MovieGalleryViewModel.MovieSubviewData.self) { movie in
            MovieDetailsView()
        }
    }
    
    private func numberOfRows() -> Int {
        print("number of rows: \((data.count + columns - 1) / columns)")
        return (data.count + columns - 1) / columns
    }
}

private struct MoviePosterView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var darkModeColor: Color {
        return colorScheme == .light ? .black : .white
    }
    let data: MovieGalleryViewModel.MovieSubviewData
    var body: some View {
        VStack(alignment: .leading) {
            if let urlString = data.imageUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
                    .shadow(color: darkModeColor.opacity(0.4), radius: 6.0, x: 0, y: 4)
            } else {
                Image(systemName: "photo.fill")
                    .frame(width: 100, height: 150)
                    .border(darkModeColor)
            }
            if let movieName = data.title {
                Text(movieName)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(darkModeColor)
            }
            if let movieRating = data.rating {
                HStack(spacing: 4) {
                    Image(systemName: getRatingImageName(for: movieRating))
                        .resizable()
                        .foregroundStyle(.yellow)
                        .frame(width: 10, height: 10)
                    Text(String(format: "%.1f", movieRating))
                        .font(.system(size: 10))
                        .foregroundStyle(darkModeColor)
                }
            }
            Spacer()
        }
        .frame(width: 100, height: 225)
    }
    
    private func getRatingImageName(for rating: Double) -> String {
        if rating >= 4.0 {
            return "star.fill"
        } else if rating >= 2.0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

//#Preview {
//    MovieGalleryView()
//}
