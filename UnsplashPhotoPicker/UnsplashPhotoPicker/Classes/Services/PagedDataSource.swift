//
//  PagedDataSource.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-10-10.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

public protocol PagedDataSourceFactory {
    func initialCursor() -> PagedCursor
    func request(with cursor: PagedCursor) -> ConcurrentOperation & PagedRequest
}

public struct PagedCursor {
    public let page: Int
    public let perPage: Int
    public let parameters: [String: AnyHashable]?
    public init( page: Int, perPage: Int, parameters: [String: AnyHashable]?) {
        self.page = page
        self.perPage = perPage
        self.parameters = parameters
    }
}

extension PagedCursor: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(page)
        hasher.combine(perPage)
        hasher.combine(parameters)
    }
}
public protocol PagedRequest {
    var cursor: PagedCursor { get }
    
    var items: [Any] { get set }
    
    init(with cursor: PagedCursor)
    
    func nextCursor() -> PagedCursor
}
extension PagedRequest {
    
    init(with page: Int = 1, perPage: Int = 10) {
        self.init(with: PagedCursor(page: page, perPage: perPage, parameters: nil))
    }
}

protocol PagedDataSourceDelegate: AnyObject {
    func dataSourceWillStartFetching<Source>(_ dataSource: PagedDataSource<Source>)
    func dataSource<Source>(_ dataSource: PagedDataSource<Source>, didFetch items: [WrapAsset<Source>])
    func dataSource<Source>(_ dataSource: PagedDataSource<Source>, fetchDidFailWithError error: Error)
}

public class PagedDataSource<Source> {
    enum DataSourceError: Error {
        case dataSourceIsFetching
        case wrongItemsType(Any)
        
        var localizedDescription: String {
            switch self {
            case .dataSourceIsFetching:
                return "The data source is already fetching."
            case .wrongItemsType(let returnedItems):
                return "The request return the wrong item type. Expecting \([UnsplashPhoto].self), got \(returnedItems.self)."
            }
        }
    }
    
    private(set) var items = [WrapAsset<Source>]()
    private(set) var error: Error?
    private let factory: PagedDataSourceFactory
    private var cursor: PagedCursor
    private(set) var isFetching = false
    private var canFetchMore = true
    private lazy var operationQueue = OperationQueue(with: "com.unsplash.pagedDataSource")
    
    weak var delegate: PagedDataSourceDelegate?
    
    public init(with factory: PagedDataSourceFactory) {
        self.factory = factory
        self.cursor = factory.initialCursor()
    }
    
    func reset() {
        operationQueue.cancelAllOperations()
        items.removeAll()
        isFetching = false
        canFetchMore = true
        cursor = factory.initialCursor()
        error = nil
    }
    
    func fetchNextPage() {
        if isFetching {
            fetchDidComplete(withItems: nil, error: DataSourceError.dataSourceIsFetching)
            return
        }
        
        if canFetchMore == false {
            fetchDidComplete(withItems: [], error: nil)
            return
        }
        
        delegate?.dataSourceWillStartFetching(self)
        
        isFetching = true
        
        let request = factory.request(with: cursor)
        request.completionBlock = {
            if let error = request.error {
                self.isFetching = false
                self.fetchDidComplete(withItems: nil, error: error)
                return
            }
            
            guard let items = request.items as? [WrapAsset<Source>] else {
                self.isFetching = false
                self.fetchDidComplete(withItems: nil, error: DataSourceError.wrongItemsType(request.items))
                return
            }
            
            if items.count < self.cursor.perPage {
                self.canFetchMore = false
            } else {
                self.cursor = request.nextCursor()
            }
            
            self.items.append(contentsOf: items)
            
            self.isFetching = false
            self.fetchDidComplete(withItems: items, error: nil)
        }
        
        operationQueue.addOperationWithDependencies(request)
    }
    
    func cancelFetch() {
        operationQueue.cancelAllOperations()
        isFetching = false
    }
    
    func item(at index: Int) -> WrapAsset<Source>? {
        guard index < items.count else {
            return nil
        }
        
        return items[index]
    }
    
    // MARK: - Private
    
    private func fetchDidComplete(withItems items: [WrapAsset<Source>]?, error: Error?) {
        self.error = error
        
        if let error = error {
            delegate?.dataSource(self, fetchDidFailWithError: error)
        } else {
            let items = items ?? []
            delegate?.dataSource(self, didFetch: items)
        }
    }
    
}
