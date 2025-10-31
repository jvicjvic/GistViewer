//
//  GistDetailVM.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Core
import CoreCommons
import FavoriteGists
import Foundation
import CoreNetwork
import os
import UIKit

@MainActor
final class GistDetailVM: CoreViewModel {
    @Published private(set) var gist: Gist
    @Published private(set) var fileContent: String?
    @Published var errorMessage: String?
    @Published var avatarImage: UIImage?
    @Published var isFavorite: Bool?
    @Published var isLoading = false

    private let favoritesRepository: FavoritesRepository
    private let repository: GistRepository

    var title: String {
        gist.filename
    }

    var headerTitle: String {
        return "\(gist.owner.login) / \(gist.filename)"
    }

    init(gist: Gist, repository: GistRepository = ProductionGistRepository(),
         favoritesRepository: FavoritesRepository = ProductionFavoritesRepository()) {
        self.gist = gist
        self.repository = repository
        self.favoritesRepository = favoritesRepository
    }

    func connect() {
        performFetchGist()
    }

    private func performFetchGist() {
        Task {
            isLoading = true
            await fetchGist()
            isLoading = false
        }
    }

    private func fetchGist() async {
        do {
            isFavorite = favoritesRepository.isFavorite(item: gist)

            // obtem info e imagem
            async let data = try repository.fetchGistData(gist)
            async let image = try repository.fetchAvatarImage(gist)
            let (fetchedGistItem, fetchedAvatarImage) = try await (data, image)
            gist = fetchedGistItem
            avatarImage = fetchedAvatarImage

            // obtem conteudo do arquivo
            fileContent = try await repository.fetchFileContent(gist)
        } catch {
            Logger.network.error("Ocorreu um erro: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    /// Marca um item como favorito
    func didTapFavorite() {
        var newStatus = isFavorite ?? false
        newStatus.toggle()
        favoritesRepository.setFavorite(item: gist, isFavorite: newStatus)
        isFavorite = newStatus
    }
}
