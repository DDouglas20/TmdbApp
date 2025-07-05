//
//  HomeViewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    // MARK: Properties
    @Published var isLoading: Bool = true
    
    // MARK: Functions
    func loadMovies(dataState: DataManager.DataState = .popular) async {
        Task {
            await ApiClient.shared.loadPopularMovies()
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Done getting api data")
        }
    }
}
