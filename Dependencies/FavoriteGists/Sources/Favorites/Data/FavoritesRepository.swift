//
//  FavoriteRepository.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation
import UIKit

public protocol FavoritesRepository {
    func fetchFavorites<T: FavoriteItem>() -> [T]
    func setFavorite<T: FavoriteItem>(item: T, isFavorite: Bool)
    func isFavorite<T: FavoriteItem>(item: T) -> Bool
    func fetchAvatarImage<T: FavoriteItem>(_ item: T) async throws -> UIImage?
}
