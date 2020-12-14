//
//  UnsplashPhotoPickerConfiguration.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import Foundation

public struct IconfinderConfiguration {
    
    public var apiKey: String = ""
    /// A search query. When set, hides the search bar and shows results instead of the editorial photos.
    public var query: String?
    
    let apiURL = "https://api.iconfinder.com/"
    
    public init(apiKey: String = "", query: String? = nil) {
        self.apiKey = apiKey
        self.query = query
    }
}

public struct UnsplashConfiguration {
    /// Your application’s access key.
    public var accessKey: String = ""

    /// Your application’s secret key.
    public var secretKey: String = ""
    
    /// A search query. When set, hides the search bar and shows results instead of the editorial photos.
    public var query: String?
    
    /// The Unsplash API url.
    let apiURL = "https://api.unsplash.com/"

    /// The Unsplash editorial collection id.
    let editorialCollectionId = "317099"

    public init(accessKey: String = "", secretKey: String = "", query: String? = nil) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.query = query
    }
}
public typealias PhotoPickerAnalyticsBlock = (String, [String: Any]) -> Void
/// Encapsulates configuration information for the behavior of UnsplashPhotoPicker.
public struct PhotoPickerConfiguration {

    public var unsplash = UnsplashConfiguration()
    
    public var iconfinder = IconfinderConfiguration()
  
    /// Controls whether the picker allows multiple or single selection.
    public var allowsMultipleSelection = false
    
    public var allowCancelSelection = true
    
    public var showNavigationTitle = true
    
    public var analyticsBlock: PhotoPickerAnalyticsBlock?
    
    /// Checkmark image
    public var checkmarkTintColor: UIColor?
    

    /// The memory capacity used by the cache.
    public var memoryCapacity = defaultMemoryCapacity

    /// The disk capacity used by the cache.
    public var diskCapacity = defaultDiskCapacity

    /// The default memory capacity used by the cache.
    public static let defaultMemoryCapacity: Int = ImageCache.memoryCapacity

    /// The default disk capacity used by the cache.
    public static let defaultDiskCapacity: Int = ImageCache.diskCapacity

   
    /**
     Initializes an `UnsplashPhotoPickerConfiguration` object with optionally customizable behaviors.

     - parameter accessKey:               Your application’s access key.
     - parameter secretKey:               Your application’s secret key.
     - parameter query:                   A search query.
     - parameter allowsMultipleSelection: Controls whether the picker allows multiple or single selection.
     - parameter memoryCapacity:          The memory capacity used by the cache.
     - parameter diskCapacity:            The disk capacity used by the cache.
     */
    public init(unsplash: UnsplashConfiguration,
                iconfinder: IconfinderConfiguration,
                analyticsBlock: PhotoPickerAnalyticsBlock? = nil,
                allowsMultipleSelection: Bool = false,
                allowCancelSelection: Bool = true,
                showNavigationTitle: Bool = true,
                memoryCapacity: Int = defaultMemoryCapacity,
                diskCapacity: Int = defaultDiskCapacity) {
        self.unsplash = unsplash
        self.iconfinder = iconfinder
        self.analyticsBlock = analyticsBlock
        self.allowsMultipleSelection = allowsMultipleSelection
        self.allowCancelSelection = allowCancelSelection
        self.showNavigationTitle = showNavigationTitle
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
    }

    init() {}

}
