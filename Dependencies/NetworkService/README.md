# NetworkService

A lightweight, modular networking infrastructure layer inspired by WealthCore's Service pattern.

## Overview

NetworkService provides the **base infrastructure** for network communication. It does **not** contain feature-specific services or endpoints. Instead, each feature/flow implements its own service class that inherits from the base `Service` class.

## Architecture Philosophy

### WealthCore-Inspired Pattern

Following the WealthCore architecture:
- ✅ Each feature owns its service and endpoints
- ✅ Base infrastructure is reusable and generic
- ✅ Services inherit from a base `Service<E: Endpoint>` class
- ✅ Network client (URLSession) is injectable for testing
- ✅ Built-in mock support for development

### Separation of Concerns

```
NetworkService (Package)          ← Base infrastructure only
├── Service.swift                 ← Generic base service class
├── Endpoint protocol             ← Protocol for defining endpoints
├── NetworkRequestBuilder.swift   ← Request building utilities
├── NetworkError.swift            ← Error types
├── NetworkEnvironment.swift      ← Environment configuration
└── NetworkUtil.swift             ← Generic utilities

Feature Flows (e.g., GistsList)   ← Feature-specific services
└── GistsService.swift            ← Inherits Service<GistsService.Endpoints>
    └── Endpoints enum            ← Defines feature-specific endpoints
```

## Core Components

### 1. Service Base Class

Generic base class that all feature services inherit from:

```swift
open class Service<E: Endpoint> {
    public let session: URLSession
    public let baseURL: URL
    
    public init(
        baseURL: URL,
        configuration: NetworkConfiguration = .shared,
        session: URLSession = .shared
    )
    
    public func request<T: Decodable>(
        endpoint: E,
        responseType: T.Type,
        configure: ((NetworkRequestBuilder) -> Void)? = nil
    ) async throws -> T
}
```

### 2. Endpoint Protocol

Protocol that all endpoint enums must conform to:

```swift
public protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var mockResponse: String? { get }
    var isExternalURL: Bool { get }
}
```

### 3. NetworkRequestBuilder

Fluent builder for constructing HTTP requests:

```swift
NetworkRequestBuilder(url: baseURL)
    .setMethod(.post)
    .addHeader(key: "Authorization", value: "Bearer token")
    .setQueryItems([URLQueryItem(name: "page", value: "1")])
    .setBody(requestData)
    .build()
```

### 4. NetworkError

Structured error types with rich context:

```swift
public enum NetworkError: Error {
    case invalidURL
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)
    case noData
    // ... more
}
```

### 5. NetworkEnvironment

Configuration for different environments:

```swift
public enum NetworkEnvironment {
    case production
    case development
    
    public var baseURL: URL { ... }
}

public struct NetworkConfiguration {
    public let environment: NetworkEnvironment
    public let enableMocks: Bool
}
```

### 6. NetworkUtil

Generic utility functions for common network operations:

```swift
open class NetworkUtil {
    public static func fetchImage(from urlString: String) async throws -> UIImage?
    public static func fetchFileContent(from urlString: String) async throws -> String
}
```

## How to Create a Service for Your Feature

### Step 1: Define Your Service Class

Create a service in your feature's data layer:

```swift
// In: YourFeature/Data/YourFeatureService.swift

import Foundation
import NetworkService

final class GistsService: Service<GistsService.Endpoints> {
    
    // Define your endpoints
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
                [{ "id": "mock123", "description": "Mock" }]
                """
            case .gistDetail:
                return """
                { "id": "mock123", "description": "Mock Detail" }
                """
            }
        }
        #endif
    }
    
    // Convenience initializer
    convenience init() {
        self.init(
            baseURL: URL(string: "https://api.github.com")!,
            configuration: .shared,
            session: .shared
        )
    }
    
    // API methods
    func fetchPublicGists<T: Decodable>(page: Int, itemsPerPage: Int = 30) async throws -> [T] {
        try await request(
            endpoint: .publicGists(page: page, itemsPerPage: itemsPerPage),
            responseType: [T].self
        ) { builder in
            builder.addHeader(key: "Accept", value: "application/vnd.github+json")
        }
    }
    
    func fetchGistDetails<T: Decodable>(id: String) async throws -> T {
        try await request(
            endpoint: .gistDetail(id: id),
            responseType: T.self
        ) { builder in
            builder.addHeader(key: "Accept", value: "application/vnd.github+json")
        }
    }
}
```

### Step 2: Use in Your Repository

```swift
final class ProductionGistRepository: GistRepository {
    private let gistsService: GistsService
    
    init(gistsService: GistsService = GistsService()) {
        self.gistsService = gistsService
    }
    
    func fetchPublicGists(page: Int) async throws -> [Gist] {
        try await gistsService.fetchPublicGists(page: page, itemsPerPage: 30)
    }
}
```

## Configuration

### Global Configuration

Set up your network configuration at app startup:

```swift
// In AppDelegate or SceneDelegate
#if DEBUG
NetworkConfiguration.shared = NetworkConfiguration(
    environment: .development,
    enableMocks: true  // Use mocks in debug builds
)
#else
NetworkConfiguration.shared = NetworkConfiguration(
    environment: .production,
    enableMocks: false
)
#endif
```

### Per-Service Configuration

You can also configure individual services:

```swift
let customConfig = NetworkConfiguration(
    environment: .production,
    enableMocks: false
)

let service = GistsService(
    baseURL: URL(string: "https://api.github.com")!,
    configuration: customConfig,
    session: .shared
)
```

## Testing

### Mock Responses

Enable mocks in your test setup:

```swift
func testFetchGists() async throws {
    let config = NetworkConfiguration(
        environment: .development,
        enableMocks: true
    )
    
    let service = GistsService(
        baseURL: URL(string: "https://api.github.com")!,
        configuration: config,
        session: .shared
    )
    
    // Will return mock data from endpoint.mockResponse
    let gists: [Gist] = try await service.fetchPublicGists(page: 1)
    
    XCTAssertEqual(gists.first?.id, "mock123")
}
```

### Custom URLSession

Inject a custom URLSession for full control:

```swift
let config = URLSessionConfiguration.ephemeral
config.protocolClasses = [MockURLProtocol.self]
let testSession = URLSession(configuration: config)

let service = GistsService(
    baseURL: URL(string: "https://api.github.com")!,
    configuration: .shared,
    session: testSession
)
```

## Error Handling

```swift
do {
    let gists: [Gist] = try await service.fetchPublicGists(page: 1)
    
} catch let error as NetworkError {
    switch error {
    case .httpError(let statusCode, _):
        if error.isClientError {
            // Handle 4xx errors
        } else if error.isServerError {
            // Handle 5xx errors
        }
        
    case .decodingError(let underlyingError):
        // Handle JSON decoding issues
        
    case .networkError(let underlyingError):
        // Handle connectivity issues
        
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Benefits of This Architecture

### ✅ Modularity
- Each feature owns its service and endpoints
- Easy to add/remove features
- Clear boundaries between features

### ✅ Testability
- Injectable URLSession for testing
- Built-in mock support
- Easy to test in isolation

### ✅ Maintainability
- Generic base infrastructure
- Feature-specific logic in feature modules
- Clear separation of concerns

### ✅ Scalability
- Easy to add new services
- Reusable base components
- No tight coupling between features

### ✅ Type Safety
- Endpoint enums prevent typos
- Generic request/response handling
- Compile-time safety

## Comparison with WealthCore

| Feature | WealthCore | NetworkService |
|---------|------------|----------------|
| Base Service class | ✅ | ✅ |
| Endpoint protocol | ✅ | ✅ |
| Injectable client | ✅ (AsyncRepository) | ✅ (URLSession) |
| Mock support | ✅ | ✅ |
| Environment config | ✅ (plist-based) | ✅ (code-based) |
| Request builder | ✅ | ✅ |
| Feature-owned services | ✅ | ✅ |
| Dependencies | UalaNetwork, UalaCore | Foundation only |
| Complexity | High (enterprise) | Low (app-focused) |

## Migration from Old Pattern

If you're migrating from the old `GistsNetwork` protocol pattern:

1. ✅ Create your service class inheriting from `Service<E: Endpoint>`
2. ✅ Define your endpoints enum conforming to `Endpoint`
3. ✅ Update repositories to use the new service
4. ✅ Remove old protocol-based code

**No breaking changes to your repositories** - just change the dependency from `GistsNetwork` to `GistsService`.

## Future Features

Potential additions if needed:
- Request/response interceptors
- Retry logic with exponential backoff
- Request caching
- Certificate pinning
- Upload/download progress tracking
- Request cancellation

## License

Part of the GistViewer project.
