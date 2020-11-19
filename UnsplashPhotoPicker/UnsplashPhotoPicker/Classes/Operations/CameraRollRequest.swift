//
//  CameraRollRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/18/20.
//

import Foundation
import Photos

class CameraRollRequest: AssetPagedRequest {
    
    static func cursor(with query: String, page: Int = 1, perPage: Int = 10) -> PagedCursor {
        let parameters: [String : Any] = ["query": query]
        return PagedCursor(page: page, perPage: perPage, parameters: parameters)
    }

    convenience init(with query: String, page: Int = 1, perPage: Int = 10) {
        let cursor = CameraRollRequest.cursor(with: query, page: page, perPage: perPage)
        self.init(with: cursor)
    }
    // TODO: move fetch result in to cursor then listen library change
    override func prepareFetchResult() throws -> PHFetchResult<PHAsset>? {
        let opt = PHFetchOptions()
        opt.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        opt.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        return PHAsset.fetchAssets(with: .image, options: opt)
    }
}
