//
//  CoreCoordinator.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Foundation

public protocol CoreCoordinator {
    @MainActor func start()
}
