//
//  FavoritesManager.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation
import Core

class FavoritesManager {
    private let favoritesKey = "FavoriteGists"
    private let storage: Storable
    
    init(storage: Storable = UserDefaults.standard) {
        self.storage = storage
    }

    func saveFavorite<T: FavoriteItem>(_ item: T) {
        var favorites: [T] = fetchFavorite()
        favorites.append(item)
        if let encoded = try? JSONEncoder().encode(favorites) {
            storage.set(encoded, forKey: favoritesKey)
        }
    }

    func fetchFavorite<T: FavoriteItem>() -> [T] {
        if let savedData = storage.data(forKey: favoritesKey),
           let savedItems = try? JSONDecoder().decode([T].self, from: savedData) {
            return savedItems
        }
        return []
    }

    func removeFavorite<T: FavoriteItem>(_ item: T) {
        var favorites: [T] = fetchFavorite()
        favorites.removeAll { $0.id == item.id }
        if let encoded = try? JSONEncoder().encode(favorites) {
            storage.set(encoded, forKey: favoritesKey)
        }
    }

    func isFavorite<T: FavoriteItem>(_ item: T) -> Bool {
        let favorites: [T] = fetchFavorite()
        return favorites.contains { $0.id == item.id }
    }
}
