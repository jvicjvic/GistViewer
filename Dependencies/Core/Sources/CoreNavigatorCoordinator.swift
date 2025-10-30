//
//  NavigatorCoordinator.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Foundation
import UIKit

public protocol CoreNavigatorCoordinator: CoreCoordinator {
    var rootViewController: UINavigationController { get set }
    var childCoordinators: [CoreCoordinator] { get set }
}
