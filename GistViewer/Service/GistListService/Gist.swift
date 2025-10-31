//
//  Gist.swift
//  GistsApp
//
//  Created by jvic on 27/08/24.
//

import FavoriteGists
import Foundation

struct Gist: Codable, Identifiable, FavoriteItem, Equatable {
    let id: String
    let description: String?
    let owner: GistOwner
    let files: [String: GistFile]

    var fileCount: Int {
        return files.count
    }

    var filename: String {
        files.count > 0 ? files.first!.value.filename : ""
    }

    var avatarUrl: String {
        owner.avatarUrl
    }

    var favoriteTitle: String {
        "\(owner.login) / \(filename)"
    }

    var favoriteSubtitle: String {
        "\(fileCount) arquivo(s)"
    }
}

struct GistOwner: Codable, Equatable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}

struct GistFile: Codable, Equatable {
    let filename: String
    let content: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case filename
        case content
        case url = "raw_url"
    }
}
