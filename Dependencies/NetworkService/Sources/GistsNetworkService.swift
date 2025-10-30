//
//  NetworkService.swift
//  GistsApp
//
//  Created by jvic on 27/08/24.
//

import Foundation

open class GistsNetworkService: GistsNetwork {
    private let baseUrl = URL(string: "https://api.github.com/gists")!

    public init() {}

    /// Obtem lista de Gists publicos. `page` a partir de 1.
    public func fetchPublicGists<T: Decodable>(page: Int, itemsPerPage: Int = 30) async throws -> [T] {
        let parameters = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(itemsPerPage))
        ]
        let url = baseUrl.appending(path: "public").appending(queryItems: parameters)

        return try await fetch(request: URLRequest(url: url))
    }

    /// Obtem detalhes do Gist por Id
    public func fetchGistDetails<T: Decodable>(id: String) async throws -> T {
        let url = baseUrl.appending(path: id)

        return try await fetch(request: URLRequest(url: url))
    }

    /// Obtem conteudo de uma URL
    public func fetchFileContent(url: String) async throws -> String {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8) ?? "Unable to decode file content"
    }

    /// Faz fetch de uma request
    private func fetch<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case httpError(Int)
    case decodingError
}
