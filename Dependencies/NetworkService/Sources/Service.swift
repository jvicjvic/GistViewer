//
//  Service.swift
//  NetworkService
//
//  Created by jvic on 30/10/25.
//

import Foundation

// MARK: - Endpoint Protocol

/// Protocol that all service endpoints must conform to
public protocol Endpoint {
    /// The path component for the endpoint
    var path: String { get }
    
    /// Query parameters for the endpoint
    var queryItems: [URLQueryItem]? { get }
    
    /// Mock response for testing/development (optional)
    var mockResponse: String? { get }
    
    /// Whether this endpoint uses an external URL (not relative to base URL)
    var isExternalURL: Bool { get }
}

// Default implementations
public extension Endpoint {
    var queryItems: [URLQueryItem]? { nil }
    var mockResponse: String? { nil }
    var isExternalURL: Bool { false }
}

// MARK: - Base Service

/// Base service class that all feature services inherit from
/// Inspired by WealthCore's Service pattern
open class Service<E: Endpoint> {
    
    // MARK: - Error Types
    
    public enum ServiceError: Error {
        case mockResponseInvalid
        case mockResponseDecodingError(Error)
    }
    
    // MARK: - Properties
    
    public typealias Endpoints = E
    
    /// The URL session used for network requests (injectable for testing)
    public let session: URLSession
    
    /// Configuration for the service
    private let configuration: NetworkConfiguration
    
    /// Base URL for the service
    public let baseURL: URL
    
    // MARK: - Initialization
    
    /// Initialize with configuration and session
    /// - Parameters:
    ///   - baseURL: Base URL for the service's API
    ///   - configuration: Network configuration (defaults to shared)
    ///   - session: URLSession to use (defaults to shared, injectable for testing)
    public init(
        baseURL: URL,
        configuration: NetworkConfiguration = .shared,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.configuration = configuration
        self.session = session
    }
    
    // MARK: - Request Method
    
    /// Make a request to an endpoint and decode the response
    /// - Parameters:
    ///   - endpoint: The endpoint to request
    ///   - responseType: The type to decode the response to
    ///   - configure: Optional closure to configure the request builder
    /// - Returns: Decoded response of type T
    @discardableResult
    public func request<T: Decodable>(
        endpoint: E,
        responseType: T.Type,
        configure: ((NetworkRequestBuilder) -> Void)? = nil
    ) async throws -> T {
        // Check for mock response first (if enabled)
        if configuration.enableMocks, let mockResponse = endpoint.mockResponse {
            return try decodeMockResponse(mockResponse)
        }
        
        // Build URL
        let url = endpoint.isExternalURL
            ? URL(string: endpoint.path)!
            : baseURL.appending(path: endpoint.path)
        
        // Build request using builder
        let requestBuilder = NetworkRequestBuilder(url: url)
            .setMethod(.get)
        
        // Add query items if present
        if let queryItems = endpoint.queryItems {
            requestBuilder.setQueryItems(queryItems)
        }
        
        // Allow custom configuration
        configure?(requestBuilder)
        
        let request = requestBuilder.build()
        
        // Execute request
        return try await execute(request: request)
    }
    
    // MARK: - Helper Methods
    
    /// Build an API request for an endpoint
    /// - Parameter endpoint: The endpoint to build a request for
    /// - Returns: Request builder for further configuration
    public func buildAPIRequest(endpoint: E) -> NetworkRequestBuilder {
        let url = endpoint.isExternalURL
            ? URL(string: endpoint.path)!
            : baseURL.appending(path: endpoint.path)
        
        let builder = NetworkRequestBuilder(url: url)
        
        if let queryItems = endpoint.queryItems {
            builder.setQueryItems(queryItems)
        }
        
        return builder
    }
    
    // MARK: - Private Methods
    
    /// Execute a URLRequest and decode the response
    private func execute<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        return try decode(data: data)
    }
    
    /// Decode data into the expected type
    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Decode mock response string into expected type
    private func decodeMockResponse<T: Decodable>(_ mockResponse: String) throws -> T {
        guard let data = mockResponse.data(using: .utf8) else {
            throw ServiceError.mockResponseInvalid
        }
        
        do {
            return try decode(data: data)
        } catch {
            throw ServiceError.mockResponseDecodingError(error)
        }
    }
}

