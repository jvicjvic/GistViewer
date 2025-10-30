//
//  FavoriteGistsListVM.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation
import NetworkService
import UIKit

@MainActor
open class FavoritesListVM<T: FavoriteItem> {
    @Published private(set) var items: [T] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    @Published public var selectedItem: T?

    let title = "Favoritos"

    private var currentPage = 1

    private let repository: FavoritesRepository

    public init(repository: FavoritesRepository = ProductionFavoritesRepository()) {
        self.repository = repository
    }

    func connect() {
        fetchItems()
    }

    private func fetchItems() {
        items = repository.fetchFavorites()
    }

    func loadUserAvatar(item: T) async -> UIImage? {
        do {
            return try await repository.fetchAvatarImage(item)
        } catch {
            errorMessage = error.localizedDescription
        }

        return nil
    }

    func didSelect(index: Int) {
        selectedItem = items[index]
    }
}
