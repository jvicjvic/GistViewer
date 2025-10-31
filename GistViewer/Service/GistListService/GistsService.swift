//
//  GistsService.swift
//  GistsApp
//
//  Created by jvic on 30/10/25.
//

import Foundation
import CoreNetwork

/// Service for GitHub Gists API
final class GistsService: Service<GistsService.Endpoints> {
    
    // MARK: - Endpoints
    
    enum Endpoints: Endpoint {
        case publicGists(page: Int, itemsPerPage: Int)
        case gistDetail(id: String)
        
        var path: String {
            switch self {
            case .publicGists:
                return "/gists/public"
            case .gistDetail(let id):
                return "/gists/\(id)"
            }
        }
        
        var queryItems: [URLQueryItem]? {
            switch self {
            case .publicGists(let page, let itemsPerPage):
                return [
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "per_page", value: String(itemsPerPage))
                ]
            case .gistDetail:
                return nil
            }
        }
        
        #if DEBUG
        var mockResponse: String? {
            switch self {
            case .publicGists:
                return """
                [
                    {
                        "id": "mock123",
                        "description": "Mock Gist",
                        "html_url": "https://gist.github.com/mock123",
                        "created_at": "2025-10-30T12:00:00Z",
                        "updated_at": "2025-10-30T12:00:00Z",
                        "owner": {
                            "login": "mockuser",
                            "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4"
                        },
                        "files": {
                            "mock.swift": {
                                "filename": "mock.swift",
                                "type": "application/x-swift",
                                "language": "Swift",
                                "raw_url": "https://gist.githubusercontent.com/mockuser/mock123/raw/mock.swift",
                                "size": 100
                            }
                        }
                    }
                ]
                """
            case .gistDetail:
                return """
                {
                    "id": "mock123",
                    "description": "Mock Gist Detail",
                    "html_url": "https://gist.github.com/mock123",
                    "created_at": "2025-10-30T12:00:00Z",
                    "updated_at": "2025-10-30T12:00:00Z",
                    "owner": {
                        "login": "mockuser",
                        "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4"
                    },
                    "files": {
                        "mock.swift": {
                            "filename": "mock.swift",
                            "type": "application/x-swift",
                            "language": "Swift",
                            "raw_url": "https://gist.githubusercontent.com/mockuser/mock123/raw/mock.swift",
                            "size": 100,
                            "content": "// Mock file content\\nprint(\\"Hello, World!\\")"
                        }
                    }
                }
                """
            }
        }
        #endif
    }
    
    // MARK: - Initialization
    
    /// Initialize with default GitHub API base URL
    convenience init() {
        self.init(
            baseURL: URL(string: "https://api.github.com")!,
            configuration: .shared,
            session: .shared
        )
    }
    
    // MARK: - API Methods
    
    /// Fetch public gists
    /// - Parameters:
    ///   - page: Page number (starting from 1)
    ///   - itemsPerPage: Number of items per page
    /// - Returns: Array of gists
    func fetchPublicGists<T: Decodable>(page: Int, itemsPerPage: Int = 30) async throws -> [T] {
        try await request(
            endpoint: .publicGists(page: page, itemsPerPage: itemsPerPage),
            responseType: [T].self
        ) { builder in
            builder.addHeader(key: "Accept", value: "application/vnd.github+json")
        }
    }
    
    /// Fetch gist details by ID
    /// - Parameter id: Gist ID
    /// - Returns: Gist detail
    func fetchGistDetails<T: Decodable>(id: String) async throws -> T {
        try await request(
            endpoint: .gistDetail(id: id),
            responseType: T.self
        ) { builder in
            builder.addHeader(key: "Accept", value: "application/vnd.github+json")
        }
    }
}

