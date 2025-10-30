//
//  FavoritesManager.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation

class FavoritesManager {
    private let favoritesKey = "FavoriteGists"

    func saveFavorite<T: FavoriteItem>(_ item: T) {
        var favorites: [T] = fetchFavorite()
        favorites.append(item)
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    func fetchFavorite<T: FavoriteItem>() -> [T] {
        if let savedData = UserDefaults.standard.data(forKey: favoritesKey),
           let savedItems = try? JSONDecoder().decode([T].self, from: savedData) {
            return savedItems
        }
        return []
    }

    func removeFavorite<T: FavoriteItem>(_ item: T) {
        var favorites: [T] = fetchFavorite()
        favorites.removeAll { $0.id == item.id }
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    func isFavorite<T: FavoriteItem>(_ item: T) -> Bool {
        let favorites: [T] = fetchFavorite()
        return favorites.contains { $0.id == item.id }
    }
}
