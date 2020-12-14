//
//  IconfinderPhotoPickerViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class IconfinderPhotoPickerViewController: PhotoPickerViewController<Iconfinder> {
    
    private let defaultDataSource = IconfinderPhotosDataSourceFactory.default.dataSource
    
    override init(prefixQuery: String?) {
        super.init(prefixQuery: prefixQuery)
    }
    override var searchPlaceHolder: String { return "search.icons.placeholder".localized() }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSearchText(_ text: String?) {
        let prefix = self.prefixQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchVals = [prefix, text].compactMap( { $0 })
        let val = searchVals.joined(separator: "+")
        dataSource = IconfinderPhotosDataSourceFactory.search(query: val).dataSource
        searchText = text
        if let query = text, !query.isEmpty {
            Configuration.shared.analyticsBlock?("search", ["query": query, "akind": "iconfinder"])
        }
    }
}
