//
//  GistsVM.swift
//  GistsApp
//
//  Created by jvic on 28/08/24.
//

import Core
import CoreCommons
import Foundation
import CoreNetwork
import OSLog
import UIKit

@MainActor
final class GistsListVM: CoreViewModel {
    @Published private(set) var gists: [Gist] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let title = "Gists"

    private var currentPage = 1
    private let repository: GistRepository
    private weak var router: GistListRouter?

    init(router: GistListRouter, repository: GistRepository = ProductionGistRepository()) {
        self.router = router
        self.repository = repository
    }

    func connect() {
        performFetchGists()
    }

    private func performFetchGists() {
        Task {
            isLoading = true
            await fetchGists()
            isLoading = false
        }
    }

    private func fetchGists() async {
        do {
            let newGists = try await repository.fetchPublicGists(page: currentPage)
            gists.append(contentsOf: newGists)
        } catch {
            Logger.network.error("Ocorreu um erro: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func loadAvatar(gist: Gist) async -> UIImage? {
        do {
            return try await repository.fetchAvatarImage(gist)
        } catch {
            Logger.network.error("Ocorreu um erro: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        return nil
    }

    func didReachEnd() {
        // carrega mais
        currentPage += 1
        performFetchGists()
    }

    func didSelect(index: Int) {
        let gist = gists[index]
        router?.navigateTo(.gistDetail(gist))
    }
}
