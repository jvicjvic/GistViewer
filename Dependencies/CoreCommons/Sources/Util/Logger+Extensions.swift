//
//  Logger+Extensions.swift
//
//
//  Created by jvic on 30/08/24.
//

import OSLog

public extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let network = Logger(subsystem: subsystem, category: "network")
    static let view = Logger(subsystem: subsystem, category: "view")
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
