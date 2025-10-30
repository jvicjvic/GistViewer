//
//  GistCell.swift
//  GistsApp
//
//  Created by jvic on 28/08/24.
//

import CoreCommons
import NetworkService
import SnapKit
import UIKit

class FavoriteCell: UITableViewCell {
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CGFloat.spacing48 / 2.0
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        return label
    }()

    lazy var fileCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .right
        label.textColor = .lightGray
        return label
    }()

    lazy var contentStack: UIStackView = {
        let avatarContent = UIView()
        avatarContent.addSubview(avatarImageView)
        let stack = UIStackView(arrangedSubviews: [avatarContent, titleLabel, fileCountLabel])
        stack.spacing = .spacing8
        return stack
    }()

    static var placeholderImage: UIImage = ImageUtil.generatePlaceholderImage(size: CGSize(width: 50, height: 50))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentStack)
        remakeConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func remakeConstraints() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(CGFloat.spacing16)
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(CGFloat.spacing48)
            make.width.equalToSuperview()
        }
        fileCountLabel.snp.makeConstraints { make in
            make.width.equalTo(CGFloat.spacing80)
        }
    }

    func setPlaceholder() {
        avatarImageView.image = FavoriteCell.placeholderImage
    }
}
