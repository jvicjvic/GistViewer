//
//  MockGistListRouter.swift
//  GistViewerTests
//
//  Created by jvic on 31/10/25.
//

import Foundation
import UIKit
@testable import GistViewer

/// Mock implementation of GistListRouter for testing
final class MockGistListRouter: GistListRouter {
    
    // MARK: - Call Tracking
    
    var navigateToCalled = false
    var navigateToCallCount = 0
    var navigateToDestinations: [GistListDestination] = []
    var lastNavigatedGist: Gist?
    
    // MARK: - Initialization
    
    init() {
        super.init(navigationController: UINavigationController())
    }
    
    // MARK: - Override Navigation
    
    override func navigateTo(_ destination: GistListDestination) {
        navigateToCalled = true
        navigateToCallCount += 1
        navigateToDestinations.append(destination)
        
        switch destination {
        case .gistDetail(let gist):
            lastNavigatedGist = gist
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        navigateToCalled = false
        navigateToCallCount = 0
        navigateToDestinations = []
        lastNavigatedGist = nil
    }
}

// MARK: - GistListDestination Equatable Extension for Testing

extension GistListDestination: Equatable {
    public static func == (lhs: GistListDestination, rhs: GistListDestination) -> Bool {
        switch (lhs, rhs) {
        case (.gistDetail(let lhsGist), .gistDetail(let rhsGist)):
            return lhsGist.id == rhsGist.id
        }
    }
}

