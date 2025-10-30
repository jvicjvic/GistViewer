//
//  NetworkEnvironment.swift
//  NetworkService
//
//  Created by jvic on 30/10/25.
//

import Foundation

/// Configuration for different network environments
public enum NetworkEnvironment {
    case production
    case development
    
    public var baseURL: URL {
        switch self {
        case .production:
            return URL(string: "https://api.github.com")!
        case .development:
            // Could point to a mock server or staging environment
            return URL(string: "https://api.github.com")!
        }
    }
}

/// Global configuration for the network layer
public struct NetworkConfiguration {
    public let environment: NetworkEnvironment
    public let enableMocks: Bool
    
    public init(environment: NetworkEnvironment = .production, enableMocks: Bool = false) {
        self.environment = environment
        self.enableMocks = enableMocks
    }
    
    /// Shared configuration instance
    public static var shared = NetworkConfiguration()
}

