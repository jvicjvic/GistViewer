//
//  NetworkError.swift
//  NetworkService
//
//  Created by jvic on 30/10/25.
//

import Foundation

/// Structured error types for network operations
public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case mockResponseInvalid
    case noData
    
    /// User-friendly error description
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .httpError(let statusCode, _):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .mockResponseInvalid:
            return "Mock response is invalid."
        case .noData:
            return "No data received from server."
        }
    }
    
    /// HTTP status code if available
    public var statusCode: Int? {
        if case .httpError(let code, _) = self {
            return code
        }
        return nil
    }
    
    /// Whether the error is a client error (4xx)
    public var isClientError: Bool {
        guard let code = statusCode else { return false }
        return (400..<500).contains(code)
    }
    
    /// Whether the error is a server error (5xx)
    public var isServerError: Bool {
        guard let code = statusCode else { return false }
        return (500..<600).contains(code)
    }
}

