//
//  AssetPagedRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/19/20.
//

import Foundation
import Photos

class AssetPagedRequest: AssetRequest, PagedRequest {

    let cursor: PagedCursor

    var items = [Any]()

    required init(with cursor: PagedCursor) {
        self.cursor = cursor
        super.init()
    }

    func nextCursor() -> PagedCursor {
        return PagedCursor(page: cursor.page + 1, perPage: cursor.perPage, parameters: cursor.parameters)
    }
    
    override func processFetchResult(_ fetch: PHFetchResult<PHAsset>) {
        let offset = (cursor.page - 1) * cursor.perPage
        for idx in 0..<cursor.perPage {
            if offset + idx < fetch.count {
                self.items.append(fetch[offset + idx].wrap)
            } else {
                break
            }
        }
        completeOperation()
    }
}
