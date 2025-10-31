//
//  MockGistRepository.swift
//  GistViewerTests
//
//  Created by jvic on 31/10/25.
//

import Foundation
import UIKit
@testable import GistViewer

/// Mock implementation of GistRepository for testing
final class MockGistRepository: GistRepository {
    
    // MARK: - Mock Configuration
    
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error occurred"])
    
    var mockGists: [Gist] = []
    var mockGistData: Gist?
    var mockAvatarImage: UIImage?
    var mockFileContent: String?
    
    // MARK: - Call Tracking
    
    var fetchPublicGistsCalled = false
    var fetchPublicGistsCallCount = 0
    var fetchPublicGistsPages: [Int] = []
    
    var fetchGistDataCalled = false
    var fetchGistDataCallCount = 0
    
    var fetchAvatarImageCalled = false
    var fetchAvatarImageCallCount = 0
    var fetchAvatarImageGists: [Gist] = []
    
    var fetchFileContentCalled = false
    var fetchFileContentCallCount = 0
    
    // MARK: - GistRepository Implementation
    
    func fetchPublicGists(page: Int) async throws -> [Gist] {
        fetchPublicGistsCalled = true
        fetchPublicGistsCallCount += 1
        fetchPublicGistsPages.append(page)
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockGists
    }
    
    func fetchGistData(_ gist: Gist) async throws -> Gist {
        fetchGistDataCalled = true
        fetchGistDataCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockGistData ?? gist
    }
    
    func fetchAvatarImage(_ gist: Gist) async throws -> UIImage? {
        fetchAvatarImageCalled = true
        fetchAvatarImageCallCount += 1
        fetchAvatarImageGists.append(gist)
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockAvatarImage
    }
    
    func fetchFileContent(_ gist: Gist) async throws -> String? {
        fetchFileContentCalled = true
        fetchFileContentCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockFileContent
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        shouldThrowError = false
        errorToThrow = NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error occurred"])
        
        mockGists = []
        mockGistData = nil
        mockAvatarImage = nil
        mockFileContent = nil
        
        fetchPublicGistsCalled = false
        fetchPublicGistsCallCount = 0
        fetchPublicGistsPages = []
        
        fetchGistDataCalled = false
        fetchGistDataCallCount = 0
        
        fetchAvatarImageCalled = false
        fetchAvatarImageCallCount = 0
        fetchAvatarImageGists = []
        
        fetchFileContentCalled = false
        fetchFileContentCallCount = 0
    }
}

