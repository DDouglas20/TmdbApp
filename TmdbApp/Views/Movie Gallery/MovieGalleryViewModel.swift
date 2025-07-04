//
//  MovieGalleryViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

class MovieGalleryViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published var isLoading: Bool = true
    
    @Published var movies: [MovieData] = []
    
    var viewState: ViewState = .popular
    
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    struct MovieSubviewData: Hashable {
        let id = UUID().uuidString
        let imageUrl: String?
        let title: String?
        let rating: Double?
    }
    
    var galleryTitleString: String {
        return viewState == .popular ? "Most Popular Movies" : "Top Rated Movies"
    }
    
    
    // MARK: Functions
    func loadMovies(dataState: DataManager.DataState = .popular) async {
        Task {
            await ApiClient.shared.loadPopularMovies(state: dataState)
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Done getting api data")
        }
    }
    
    func returnMovieSubviewData() -> [MovieSubviewData] {
        var movieArray = [MovieSubviewData]()
        for movie in DataManager.shared.popularMovies {
            movieArray.append(
                .init(
                    imageUrl: baseImageURL + (movie.portaitPath ?? ""),
                    title: movie.movieName,
                    rating: movie.movieRating
                )
            )
        }
        return movieArray
    }
    
    enum ViewState {
        case popular
        case topRated
    }
    
}
