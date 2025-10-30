//
//  File.swift
//
//
//  Created by jvic on 30/08/24.
//

import Foundation

public protocol GistsNetwork {
    func fetchPublicGists<T: Decodable>(page: Int, itemsPerPage: Int) async throws -> [T]
    func fetchGistDetails<T: Decodable>(id: String) async throws -> T
    func fetchFileContent(url: String) async throws -> String
}
