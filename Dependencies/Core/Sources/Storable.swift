//
//  Storable.swift
//  Core
//
//  Created by jvic on 31/10/25.
//

import Foundation

public protocol Storable: AnyObject {
    // MARK: - Getters
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
    func data(forKey defaultName: String) -> Data?
    
    // MARK: - Setters
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Any?, forKey defaultName: String)
    
    // MARK: - Cleanup
    func removeObject(forKey defaultName: String)
}

// MARK: - UserDefaults Conformance

extension UserDefaults: Storable {
    // UserDefaults already implements all required methods with matching signatures
    // No additional implementation needed
}

