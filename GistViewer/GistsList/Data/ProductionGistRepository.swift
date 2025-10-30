//
//  ProductionGistRepository.swift
//  GistsApp
//
//  Created by jvic on 27/08/24.
//

import Foundation
import NetworkService
import UIKit

final class ProductionGistRepository: GistRepository {
    private let networkService: GistsNetwork

    init(networkService: GistsNetwork = GistsNetworkService()) {
        self.networkService = networkService
    }

    func fetchPublicGists(page: Int) async throws -> [Gist] {
        try await networkService.fetchPublicGists(page: page, itemsPerPage: 30)
    }

    func fetchGistData(_ gist: Gist) async throws -> Gist {
        try await networkService.fetchGistDetails(id: gist.id)
    }

    func fetchAvatarImage(_ gist: Gist) async throws -> UIImage? {
        try await NetworkUtil.fetchImage(from: gist.owner.avatarUrl)
    }

    func fetchFileContent(_ gist: Gist) async throws -> String? {
        guard let gistFile = gist.files.first?.value,
              let fileUrl = gistFile.url
        else {
            return nil
        }

        return try await NetworkUtil.fetchFileContent(from: fileUrl)
    }
}
