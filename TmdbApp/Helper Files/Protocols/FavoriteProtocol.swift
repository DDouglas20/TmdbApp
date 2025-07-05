//
//  FavoriteProtocol.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import Foundation


protocol FavoriteManager {
    var favList: [Int] { get }
    func manageFavorite(id: Int, index: Int)
}

extension FavoriteManager {
    var favList: [Int] {
        return UserDefaults.standard.value(forKey: DataManager.favoritesKey) as? [Int] ?? []
    }
    
}
