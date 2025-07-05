//
//  FavoritesViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

class FavoritesViewModel: ObservableObject {
    // MARK: Properties
    @Published var sortedMovies: [MovieData] = []
    @Published var removeFavAlert: Bool = false
    
    // MARK: Init
    init() {
        getFavoriteMoviesArr()
    }
    
    // MARK: Functions
    func getFavoriteMoviesArr() {
        if let idArr = UserDefaults.standard.value(forKey: DataManager.favoritesKey) as? [Int] {
            var set: Set<MovieData> = [] // We use a set to avoid duplicates if a trending movie is in both Week and Day
            // Get the movies from the 2 lists we support
            for movie in DataManager.shared.popularMovies {
                if let movieId = movie.id, idArr.contains(movieId) {
                    set.insert(movie)
                }
            }
            for movie in DataManager.shared.trendingMoviesWeek {
                if let movieId = movie.id, idArr.contains(movieId) {
                    set.insert(movie)
                }
            }
            for movie in DataManager.shared.trendingMoviesDay {
                if let movieId = movie.id, idArr.contains(movieId) {
                    set.insert(movie)
                }
            }
            organizeSet(set: set)
        }
    }
    
    private func organizeSet(set: Set<MovieData>) {
        var favoritesArray: [MovieData] = Array(set)
        favoritesArray.sort(by: {$0.movieName ?? "" < $1.movieName ?? "" })
        sortedMovies = favoritesArray
    }
}

extension FavoritesViewModel: FavoriteManager {
    func manageFavorite(id: Int, index: Int) {
        var favoritesArr = favList
        if let favIndex = favoritesArr.firstIndex(of: id) {
            favoritesArr.remove(at: favIndex)
            UserDefaults.standard.set(favoritesArr, forKey: DataManager.favoritesKey)
            sortedMovies.remove(at: index)
            return
        }
    }
}
