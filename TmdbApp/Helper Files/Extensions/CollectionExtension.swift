//
//  CollectionExtension.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/4/25.
//

import Foundation

extension Collection {
    /// Allows safe accessing of indices without needing to create bounds
    subscript(safe index: Index) -> Element? {
        guard index >= startIndex && index < endIndex else {
            return nil
        }
        return self[index]
    }
}
