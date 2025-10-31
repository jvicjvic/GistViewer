//
//  ProductionFavoritesRepository.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation
import CoreNetwork
import Core
import UIKit

public final class ProductionFavoritesRepository: FavoritesRepository {
    private let favoritesManager: FavoritesManager
    
    public init(storage: Storable = UserDefaults.standard) {
        self.favoritesManager = FavoritesManager(storage: storage)
    }

    public func fetchFavorites<T: FavoriteItem>() -> [T] {
        favoritesManager.fetchFavorite()
    }

    public func setFavorite<T: FavoriteItem>(item: T, isFavorite: Bool) {
        if isFavorite {
            favoritesManager.saveFavorite(item)
        } else {
            favoritesManager.removeFavorite(item)
        }
    }

    public func isFavorite<T: FavoriteItem>(item: T) -> Bool {
        favoritesManager.isFavorite(item)
    }

    public func fetchAvatarImage<T: FavoriteItem>(_ item: T) async throws -> UIImage? {
        try await NetworkUtil.fetchImage(from: item.avatarUrl)
    }
}
