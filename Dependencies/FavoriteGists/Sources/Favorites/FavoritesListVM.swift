//
//  FavoriteGistsListVM.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Core
import Foundation
import CoreNetwork
import UIKit

@MainActor
open class FavoritesListVM<T: FavoriteItem>: CoreViewModel {
    @Published private(set) var items: [T] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    let title = "Favoritos"

    private var currentPage = 1
    private let repository: FavoritesRepository
    private var onItemSelected: ((T) -> Void)?

    public init(repository: FavoritesRepository = ProductionFavoritesRepository(), onItemSelected: ((T) -> Void)? = nil) {
        self.repository = repository
        self.onItemSelected = onItemSelected
    }
    
    public func setItemSelectedHandler(_ handler: @escaping (T) -> Void) {
        self.onItemSelected = handler
    }

    public func connect() {
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
        let item = items[index]
        onItemSelected?(item)
    }
}
