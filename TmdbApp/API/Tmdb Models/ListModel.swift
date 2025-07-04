//
//  ListModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import Foundation

struct ListModel: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int // The id of the genre
    let name: String // The name of the genre
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        // Create the genre map
        DataManager.shared.genreMap[id] = name
    }
}
