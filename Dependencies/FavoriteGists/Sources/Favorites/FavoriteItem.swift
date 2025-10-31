//
//  File.swift
//
//
//  Created by jvic on 30/08/24.
//

import Foundation

public protocol FavoriteItem: Codable {
    var id: String { get }
    var avatarUrl: String { get }
    var favoriteTitle: String { get }
    var favoriteSubtitle: String { get }
}
