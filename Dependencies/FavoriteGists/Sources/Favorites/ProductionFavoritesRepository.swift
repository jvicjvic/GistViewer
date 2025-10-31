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
    private let favoritesStore: FavoritesStore
    
    public init(storage: Storable = UserDefaults.standard) {
        self.favoritesStore = FavoritesStore(storage: storage)
    }

    public func fetchFavorites<T: FavoriteItem>() -> [T] {
        favoritesStore.fetchFavorite()
    }

    public func setFavorite<T: FavoriteItem>(item: T, isFavorite: Bool) {
        if isFavorite {
            favoritesStore.saveFavorite(item)
        } else {
            favoritesStore.removeFavorite(item)
        }
    }

    public func isFavorite<T: FavoriteItem>(item: T) -> Bool {
        favoritesStore.isFavorite(item)
    }

    public func fetchAvatarImage<T: FavoriteItem>(_ item: T) async throws -> UIImage? {
        try await NetworkUtil.fetchImage(from: item.avatarUrl)
    }
}
