//
//  CoreViewModel.swift
//  Core
//
//  Created by jvic on 31/10/25.
//

import Foundation

/// Protocol that defines the basic contract for ViewModels in the application.
/// ViewModels conforming to this protocol must implement a connect() method
/// that is called when the view is ready to start loading data or performing initial setup.
@MainActor
public protocol CoreViewModel: AnyObject {
    /// Called when the view is ready to connect and start loading data.
    /// This method should be called from the view controller's viewDidLoad or similar lifecycle method.
    func connect()
}

