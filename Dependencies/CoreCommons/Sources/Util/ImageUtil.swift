//
//  ImageUtil.swift
//  GistsApp
//
//  Created by jvic on 29/08/24.
//

import Foundation
import UIKit

open class ImageUtil {
    public static func generatePlaceholderImage(size: CGSize, backgroundColor: UIColor = UIColor(white: 0.9, alpha: 1.0), text: String? = nil) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Preencher o fundo com a cor especificada
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            if let text = text {
                // Configurar o estilo do texto
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 30),
                    .foregroundColor: UIColor.white
                ]
                let textSize = text.size(withAttributes: attributes)
                let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                      y: (size.height - textSize.height) / 2,
                                      width: textSize.width,
                                      height: textSize.height)
                text.draw(in: textRect, withAttributes: attributes)
            }
        }

        return image
    }
}
