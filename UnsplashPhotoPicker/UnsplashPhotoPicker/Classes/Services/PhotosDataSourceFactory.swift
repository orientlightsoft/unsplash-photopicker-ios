//
//  PhotosDataSourceFactory.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-10-10.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit
import Photos

enum IconfinderPhotosDataSourceFactory: PagedDataSourceFactory {
    
    case `default`
    case search(query: String)
    
    var dataSource: PagedDataSource<Iconfinder> {
        return PagedDataSource(with: self)
    }
    func initialCursor() -> PagedCursor {
        switch self {
        case .search(let query):
            return IconfinderSearchPhotosRequest.cursor(with: query, page: 1, perPage: 30)
        default:
            return PagedCursor(page: 1, perPage: 0, parameters: nil)
        }
       
    }
    
    func request(with cursor: PagedCursor) -> ConcurrentOperation & PagedRequest {
        switch self {
        case .search(let query):
            return IconfinderSearchPhotosRequest(with: query, page: cursor.page, perPage: cursor.perPage)
        default:
            return CommonPagedRequest(with: cursor)
        }
    }

}


enum UnsplashPhotosDataSourceFactory: PagedDataSourceFactory {
    case search(query: String)
    case collection(identifier: String)

    var dataSource: PagedDataSource<UnsplashPhoto> {
        return PagedDataSource(with: self)
    }

    func initialCursor() -> PagedCursor {
        switch self {
        case .search(let query):
            return UnsplashSearchPhotosRequest.cursor(with: query, page: 1, perPage: 30)
        case .collection(let identifier):
            let perPage = 30
            return UnsplashGetCollectionPhotosRequest.cursor(with: identifier, page: 1, perPage: perPage)
        }
    }

    func request(with cursor: PagedCursor) -> ConcurrentOperation & PagedRequest {
        switch self {
        case .search(let query):
            return UnsplashSearchPhotosRequest(with: query, page: cursor.page, perPage: cursor.perPage)
        case .collection(let identifier):
            return UnsplashGetCollectionPhotosRequest(for: identifier, page: cursor.page, perPage: cursor.perPage)
        }
    }
}
