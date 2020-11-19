//
//  EmptyView.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-21.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

enum EmptyViewState {
    case noResults
    case noInternetConnection
    case serverError
    case other(String, String)

    var title: String {
        switch self {
        case .noResults:
            return "error.noResults.title".localized()
        case .noInternetConnection:
            return "error.noInternetConnection.title".localized()
        case .serverError:
            return "error.serverError.title".localized()
        case .other(let val, _):
            return val
        }
    }

    var description: String {
        switch self {
        case .noResults:
            return "error.noResults.description".localized()
        case .noInternetConnection:
            return "error.noInternetConnection.description".localized()
        case .serverError:
            return "error.serverError.description".localized()
        case .other(_, let val):
            return val
        }
    }
}

class EmptyView: UIView {

    // MARK: - Properties
    typealias Callback = (EmptyViewState) -> Void
    var onRetryCallback: Callback?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var retryButton: UIButton = { [weak self] in
        let view = UIButton(type: UIButton.ButtonType.system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        view.setTitle("retry.title".localized(), for: .normal)
        view.addTarget(self, action: #selector(onRetry), for: .touchUpInside)
        return view
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.photoPicker.titleLabel
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.photoPicker.subtitleLabel
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.numberOfLines = 0
        return label
    }()

    var state: EmptyViewState? {
        didSet {
            setupState()
        }
    }

    // MARK: - Lifetime

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor.photoPicker.background
        setupContainerView()
        setupTitleLabel()
        setupDescriptionLabel()
        setupRetryButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupContainerView() {
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupTitleLabel() {
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.margin),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.margin)
        ])
    }

    private func setupDescriptionLabel() {
        containerView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.padding),
            descriptionLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.margin),
            descriptionLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.margin)
        ])
    }
    
    private func setupRetryButton() {
        containerView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            retryButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            retryButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Constants.margin),
            retryButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.margin),
            retryButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Constants.margin)
        ])
    }

    private func setupState() {
        titleLabel.text = state?.title
        descriptionLabel.text = state?.description
        switch self.state {
        case .noInternetConnection, .serverError, .other:
            self.retryButton.isHidden = false
        default:
            self.retryButton.isHidden = true
        }
    }
    
    @objc func onRetry() {
        guard let `state` = self.state else {
            return
        }
        self.onRetryCallback?(state)
    }
}

// MARK: - Constants
private extension EmptyView {
    struct Constants {
        static let margin: CGFloat = 20.0
        static let padding: CGFloat = 10.0
    }
}
