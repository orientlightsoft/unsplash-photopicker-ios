//
//  UnsplashPhotoPickerViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class UnsplashPhotoPickerViewController: PhotoPickerViewController<UnsplashPhoto> {
    private let editorialDataSource = UnsplashPhotosDataSourceFactory.collection(identifier: Configuration.shared.unsplash.editorialCollectionId).dataSource
    
    override init(prefixQuery: String?) {
        super.init(prefixQuery: prefixQuery)
        self.dataSource = editorialDataSource
    }
    
    override var searchPlaceHolder: String { return "search.photos.placeholder".localized() }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSearchText(_ text: String?) {
        let prefix = self.prefixQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchVals = [prefix, text].compactMap( { $0 })
        if !searchVals.isEmpty {
            let val = searchVals.joined(separator: "+")
            dataSource = UnsplashPhotosDataSourceFactory.search(query: val).dataSource
            searchText = text
        } else {
            dataSource = editorialDataSource
            searchText = nil
        }
    }
    
    override func trackDownloads(for photos: [WrapAsset<UnsplashPhoto>]) {
        for photo in photos {
            if let downloadLocationURL = photo.tracking?.appending(queryItems: [URLQueryItem(name: "client_id", value: Configuration.shared.unsplash.accessKey)]) {
                URLSession.shared.dataTask(with: downloadLocationURL).resume()
            }
        }
    }
}
