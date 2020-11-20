//
//  Asset.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation
import Photos

public struct Asset {
    public let identifier: String
    public let size: CGSize
    public let name: String
    public let color: UIColor?
    public var urls: [URLKind: URL]
    public let headers: [String: String]
    
    init<Source>(wrap asset: WrapAsset<Source>) {
        self.identifier = asset.identifier
        self.size = asset.size
        self.name = asset.name
        self.color = asset.color
        self.urls = asset.urls
        self.headers = asset.headers
    }
}

public struct WrapAsset<Source> {
    internal let source: Source
    internal let identifierKeyPath: KeyPath<Source, String>
    internal let nameKeyPath: KeyPath<Source, String>?
    internal let colorKeyPath: KeyPath<Source, UIColor?>?
    internal let heightKeyPath: KeyPath<Source, Int>
    internal let widthKeyPath: KeyPath<Source, Int>
    internal let urlsKeyPath: KeyPath<Source, [URLKind: URL]>
    internal let trackingKeyPath: KeyPath<Source, URL?>?
    internal let headersKeyPath: KeyPath<Source, [String:String]>?
    
    public init(source: Source, identifierKeyPath: KeyPath<Source, String>, nameKeyPath: KeyPath<Source, String>? = nil, colorKeyPath: KeyPath<Source, UIColor?>? = nil, heightKeyPath: KeyPath<Source, Int>, widthKeyPath: KeyPath<Source, Int>, urlsKeyPath: KeyPath<Source, [URLKind: URL]>, trackingKeyPath: KeyPath<Source, URL?>? = nil, headersKeyPath: KeyPath<Source, [String:String]>? = nil) {
        self.source = source
        self.identifierKeyPath = identifierKeyPath
        self.nameKeyPath = nameKeyPath
        self.colorKeyPath = colorKeyPath
        self.heightKeyPath = heightKeyPath
        self.widthKeyPath = widthKeyPath
        self.urlsKeyPath = urlsKeyPath
        self.trackingKeyPath = trackingKeyPath
        self.headersKeyPath = headersKeyPath
    }
    internal var identifier: String {
        get {
            return self.source[keyPath: identifierKeyPath]
        }
    }
    internal var size: CGSize {
        get {
            return CGSize(width: self.source[keyPath: widthKeyPath], height: self.source[keyPath: heightKeyPath])
        }
    }
    internal var name: String {
        get {
            guard let nameKeyPath = nameKeyPath else { return "" }
            return self.source[keyPath: nameKeyPath]
        }
    }
    internal var color: UIColor? {
        get {
            guard let colorKeyPath = colorKeyPath else { return nil }
            return self.source[keyPath: colorKeyPath]
        }
    }
    internal var urls: [URLKind: URL] {
        get {
            return self.source[keyPath: urlsKeyPath]
        }
    }
    internal var tracking: URL? {
        get {
            guard let trackingKeyPath = trackingKeyPath else { return nil }
            return self.source[keyPath: trackingKeyPath]
        }
    }
    internal var headers: [String: String] {
        get {
            guard let headersKeyPath = headersKeyPath else { return [:] }
            return self.source[keyPath: headersKeyPath]
        }
    }
    
    internal func preload(on completion: @escaping ((_ responseURL : URL?) -> Void)) {
        guard let asset = self.source as? PHAsset else {
            completion(nil)
            return
        }
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        asset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
            completion(contentEditingInput?.fullSizeImageURL)
        })
        
    }
    
}
