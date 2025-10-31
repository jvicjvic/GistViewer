//
//  NetworkRequestBuilder.swift
//  CoreNetwork
//
//  Created by jvic on 30/10/25.
//

import Foundation

/// HTTP methods supported by the network layer
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// Builder for constructing network requests with a fluent API
public class NetworkRequestBuilder {
    private var url: URL
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var queryItems: [URLQueryItem]?
    private var body: Data?
    private var timeoutInterval: TimeInterval = 60
    
    public init(url: URL) {
        self.url = url
    }
    
    /// Set the HTTP method
    @discardableResult
    public func setMethod(_ method: HTTPMethod) -> NetworkRequestBuilder {
        self.method = method
        return self
    }
    
    /// Add a header field
    @discardableResult
    public func addHeader(key: String, value: String) -> NetworkRequestBuilder {
        headers[key] = value
        return self
    }
    
    /// Set multiple headers
    @discardableResult
    public func setHeaders(_ headers: [String: String]) -> NetworkRequestBuilder {
        self.headers = headers
        return self
    }
    
    /// Set query parameters
    @discardableResult
    public func setQueryItems(_ queryItems: [URLQueryItem]) -> NetworkRequestBuilder {
        self.queryItems = queryItems
        return self
    }
    
    /// Set request body from encodable object
    @discardableResult
    public func setBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws -> NetworkRequestBuilder {
        self.body = try encoder.encode(body)
        addHeader(key: "Content-Type", value: "application/json")
        return self
    }
    
    /// Set raw body data
    @discardableResult
    public func setBodyData(_ data: Data) -> NetworkRequestBuilder {
        self.body = data
        return self
    }
    
    /// Set timeout interval
    @discardableResult
    public func setTimeout(_ interval: TimeInterval) -> NetworkRequestBuilder {
        self.timeoutInterval = interval
        return self
    }
    
    /// Build the final URLRequest
    public func build() -> URLRequest {
        // Add query items if present
        var finalURL = url
        if let queryItems = queryItems, !queryItems.isEmpty {
            finalURL = url.appending(queryItems: queryItems)
        }
        
        // Create request
        var request = URLRequest(url: finalURL, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        
        // Add headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body
        request.httpBody = body
        
        return request
    }
}

