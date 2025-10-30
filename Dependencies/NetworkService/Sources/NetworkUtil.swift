//
//  File.swift
//
//
//  Created by jvic on 28/08/24.
//

import Foundation
import UIKit

open class NetworkUtil {
    public static func fetchImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    public static func fetchFileContent(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8) ?? "Unable to decode file content"
    }
}
