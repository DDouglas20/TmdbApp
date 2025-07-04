//
//  MovieDetailsModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

struct MovieDetails: Codable {
    var budget: Int?
    var revenue: Int?
    var runtime: Int?
    var productionCompanies: [ProductionCompanies]?
    
    private enum CodingKeys: String, CodingKey {
        case budget
        case revenue
        case runtime
        case productionCompanies = "production_companies"
    }
}

struct ProductionCompanies: Codable, Hashable {
    var logoPath: String?
    var name: String?
    
    private enum CodingKeys: String, CodingKey {
        case logoPath = "logo_path"
        case name
    }
}
