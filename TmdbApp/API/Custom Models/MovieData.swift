//
//  MovieModels.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation
import UIKit

/// The model we will use to normalize all of the Popular json data
struct MovieData: Hashable {
    var id: Int? // Movie id
    var isAdult: Bool? // If the movie is for adults only
    var movieName: String?
    var movieRating: Double?
    var reviewCount: Int?
    var releaseDate: String?
    var overview: String?
    var genreIds: [Int]?
    var portaitPath: String? // Use KF for all images
    var landscapePath: String?
    
    // Details we will need another api call for
    var budget: Int?
    var revenue: Int?
    var runtime: Int?
    var productionCompanies: [ProductionCompanies]?
    var youtubeId: String? // The video key used in the youtube url
    var director: Director?
    var categories: [String]? = []
    var certification: String?
    
}

struct Director: Hashable {
    var id: Int
    var name: String
    var jobs: [String]
}
