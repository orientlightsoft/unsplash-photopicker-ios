//
//  IconfinderSearchPhotosRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class IconfinderSearchPhotosRequest: IconfinderPagedRequest {

    static func cursor(with query: String, page: Int = 1, perPage: Int = 10) -> PagedCursor {
        let parameters: [String : AnyHashable] = ["query": query, "premium": 0, "vector": 1]
        return PagedCursor(page: page, perPage: perPage, parameters: parameters)
    }

    convenience init(with query: String, page: Int = 1, perPage: Int = 10) {
        let cursor = IconfinderSearchPhotosRequest.cursor(with: query, page: page, perPage: perPage)
        self.init(with: cursor)
    }

    // MARK: - Prepare the request

    override var endpoint: String { return "/v4/icons/search" }

    // MARK: - Process the response

    override func processJSONResponse() {
        if let photos = photosFromJSONResponse() {
            self.items = photos
        }
        super.processJSONResponse()
    }

    func photosFromJSONResponse() -> [WrapAsset<Iconfinder>]? {
        guard let jsonResponse = jsonResponse as? [String: Any],
            let results = jsonResponse["icons"] as? [Any] else {
            return nil
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: results, options: [])
            let photos = try JSONDecoder().decode([Iconfinder].self, from: data)
            return photos.map { $0.wrap }
        } catch {
            self.error = error
        }
        return nil
    }

}
