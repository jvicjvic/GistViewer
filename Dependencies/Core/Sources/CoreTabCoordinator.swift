//
//  CoreTabCoordinator.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Foundation
import UIKit

public protocol CoreTabCoordinator: CoreCoordinator {
    var rootViewController: UITabBarController { get set }
    var childCoordinators: [CoreCoordinator] { get set }
}
