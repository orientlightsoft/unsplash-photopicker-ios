//
//  UnsplashGetCollectionPhotosRequest.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-09-28.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import Foundation

class UnsplashGetCollectionPhotosRequest: UnsplashPagedRequest {

    static func cursor(with collectionId: String, page: Int = 1, perPage: Int = 10) -> PagedCursor {
        let parameters: [String: Any] = ["id": collectionId]
        return PagedCursor(page: page, perPage: perPage, parameters: parameters)
    }

    convenience init(for collectionId: String, page: Int = 1, perPage: Int = 10) {
        let cursor = UnsplashGetCollectionPhotosRequest.cursor(with: collectionId, page: page, perPage: perPage)
        self.init(with: cursor)
    }

    required init(with cursor: PagedCursor) {
        if let parameters = cursor.parameters {
            if let collectionId = parameters["id"] as? String {
                self.collectionId = collectionId
            } else {
                self.collectionId = ""
            }
        } else {
            self.collectionId = ""
        }
        super.init(with: cursor)
    }

    private let collectionId: String

    // MARK: - Prepare the request

    override var endpoint: String {
        return "/collections/\(collectionId)/photos"
    }

    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters()
        parameters?["id"] = nil
        return parameters
    }

    // MARK: - Process the response

    override func processResponseData(_ data: Data?) {
        if let photos = photosFromResponseData(data) {
            self.items = photos
            completeOperation()
        }
        super.processResponseData(data)
    }

    func photosFromResponseData(_ data: Data?) -> [WrapAsset<UnsplashPhoto>]? {
        guard let data = data else { return nil }

        do {
            let photos = try JSONDecoder().decode([UnsplashPhoto].self, from: data)
            return photos.map { $0.wrap }
        } catch {
            self.error = error
            return nil
        }
    }

}
