//
//  MovieGalleryViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation
import SwiftUI

class MovieGalleryViewModel: ObservableObject {
    
    // MARK: Properties
    
    @Published var isLoading: Bool = true
    
    @Published var movies: [MovieData] = []
    
    @Published var viewState: ViewState = .popular
    
    @Published var dataState: DataManager.DataState = .popular
    
    var movieArray: [MovieData] {
        switch dataState {
        case .popular:
            return DataManager.shared.popularMovies
        case .trendWeek:
            return DataManager.shared.trendingMoviesWeek
        case .trendDay:
            return DataManager.shared.trendingMoviesDay
        }
    }
    
    @Published var trendingState: TrendingState = .week
    
    @Published var movieData: [MovieSubviewData] = []
    
    @Published var removeFavAlert: Bool = false
    
    struct MovieSubviewData: Hashable {
        let id = UUID().uuidString
        let movieId: Int?
        let imageUrl: String?
        let title: String?
        let rating: Double?
        var isFavorited: Bool
    }
    
    var stateTitle: String {
        return viewState == .popular ? "Popular" : "Trending"
    }
    
    var trendingStateTitle: String {
        return trendingState == .week ? "Week" : "Day"
    }
    
    var galleryTitleString: String {
        return viewState == .popular ? "Most Popular Movies" : "Trending Movies"
    }
  
    // MARK: Functions
    func getMovieSubviewData() {
        var movieArr = [MovieSubviewData]()
        for movie in movieArray {
            movieArr.append(
                .init(
                    movieId: movie.id,
                    imageUrl: ApiClient.baseImageURL + (movie.portaitPath ?? ""),
                    title: movie.movieName,
                    rating: movie.movieRating,
                    isFavorited: favList.contains(movie.id ?? -1)
                )
            )
        }
        movieData = movieArr
    }
    
    func popularSelected() {
        viewState = .popular
        dataState = .popular
        getMovieSubviewData()
    }
    
    func trendingSelected() {
        viewState = .trending
        dataState = trendingState == .week ? .trendWeek : .trendDay
        getMovieSubviewData()
    }
    
    func trendingTimeChanged(time: TrendingState) {
        trendingState = time
        dataState = time == .week ? .trendWeek : .trendDay
        getMovieSubviewData()
    }
    
    enum ViewState {
        case popular
        case trending
    }
    
    enum TrendingState {
        case day
        case week
    }
    
}

extension MovieGalleryViewModel: FavoriteManager {
    func manageFavorite(id: Int, index: Int) {
        var favoritesArr = Set(favList)
        var isSelected = favoritesArr.contains(id)
        print("isSelected: \(isSelected)")
        if isSelected {
            if favoritesArr.contains(id) { // Check to see if it exists for error reporting
                favoritesArr.remove(id)
                UserDefaults.standard.set(Array(favoritesArr), forKey: DataManager.favoritesKey)
                withAnimation(.bouncy(duration: 0.2)) {
                    movieData[index].isFavorited = false
                }
                return
            }
            removeFavAlert = true
        } else {
            favoritesArr.insert(id)
            UserDefaults.standard.set(Array(favoritesArr), forKey: DataManager.favoritesKey)
            withAnimation(.bouncy(duration: 0.2)) {
                movieData[index].isFavorited = true
            }
        }
    }
}
