//
//  MovieModels.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation
import UIKit

/// The model we will use to normalize all of the Popular json data
struct MovieData {
    let id: Int? // Movie id
    let isAdult: Bool? // If the movie is for adults only
    let movieName: String?
    let movieRating: Double?
    let reviewCount: Int?
    let releaseDate: String?
    let overview: String?
    let genreIds: [Int]?
    let portaitPath: String? // Use KF for all images
    let landscapePath: String?
    
    // Details we will need a second api call for
    var budget: Int?
    var revenue: Int?
    var runtime: Int?
    var productionCompanies: [ProductionCompanies]?
    var key: String? // The video key used in the youtube url
    var director: Director?
    var categories: [String]? = []
}

struct Director {
    var name: String
    var jobs: [String]
}
