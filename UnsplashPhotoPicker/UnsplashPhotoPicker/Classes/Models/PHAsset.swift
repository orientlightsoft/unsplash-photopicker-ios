//
//  PHAsset.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/19/20.
//

import Foundation
import Photos

extension PHAsset {

    private var displayName: String {
        return ""
    }
    
    private var urls: [URLKind: URL] {
        get { return  [:] }
    }
    
    var wrap: WrapAsset<PHAsset> {
        get {
            return WrapAsset(source: self,
                             identifierKeyPath: \.localIdentifier,
                             nameKeyPath: \.displayName,
                             colorKeyPath: nil,
                             heightKeyPath: \.pixelHeight,
                             widthKeyPath: \.pixelWidth,
                             urlsKeyPath: \.urls,
                             trackingKeyPath: nil,
                             headersKeyPath: nil)
        }
    }
}
