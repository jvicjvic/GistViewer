//
//  GistRepository.swift
//  GistsApp
//
//  Created by jvic on 27/08/24.
//

import Foundation
import UIKit

protocol GistRepository {
    func fetchPublicGists(page: Int) async throws -> [Gist]
    func fetchGistData(_ gist: Gist) async throws -> Gist
    func fetchAvatarImage(_ gist: Gist) async throws -> UIImage?
    func fetchFileContent(_ gist: Gist) async throws -> String?
}
