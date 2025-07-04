//
//  CrewModel.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import Foundation

struct CrewModel: Codable {
    let crew: [Crew]?
    
    private enum CodingKeys: String, CodingKey {
        case crew
    }
}

struct Crew: Codable {
    var id: Int? // The person's id
    var name: String?
    var department: String?
    var job: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case department
        case job
    }
}
