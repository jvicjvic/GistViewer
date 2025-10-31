//
//  TestHelpers.swift
//  GistViewerTests
//
//  Created by jvic on 31/10/25.
//

import Foundation
@testable import GistViewer

/// Helper functions for creating test data
enum TestHelpers {
    
    /// Creates a mock Gist for testing
    static func createMockGist(
        id: String = "test123",
        description: String? = "Test Gist",
        ownerLogin: String = "testuser",
        avatarUrl: String = "https://example.com/avatar.jpg",
        filename: String = "test.swift",
        fileContent: String? = "print(\"Hello\")",
        fileUrl: String? = "https://example.com/raw/test.swift"
    ) -> Gist {
        let owner = GistOwner(login: ownerLogin, avatarUrl: avatarUrl)
        let file = GistFile(filename: filename, content: fileContent, url: fileUrl)
        let files = [filename: file]
        
        return Gist(
            id: id,
            description: description,
            owner: owner,
            files: files
        )
    }
    
    /// Creates an array of mock Gists for testing
    static func createMockGists(count: Int, startingId: Int = 1) -> [Gist] {
        return (startingId..<(startingId + count)).map { index in
            createMockGist(
                id: "gist\(index)",
                description: "Test Gist \(index)",
                ownerLogin: "user\(index)",
                filename: "file\(index).swift"
            )
        }
    }
}

