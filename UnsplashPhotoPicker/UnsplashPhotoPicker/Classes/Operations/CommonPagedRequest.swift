//
//  CommonPagedRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class CommonPagedRequest: CommonRequest, PagedRequest {
    
    let cursor: PagedCursor

    var items = [Any]()

    required init(with cursor: PagedCursor) {
        self.cursor = cursor
        super.init()
    }

    func nextCursor() -> PagedCursor {
        return PagedCursor(page: cursor.page + 1, perPage: cursor.perPage, parameters: cursor.parameters)
    }
}
