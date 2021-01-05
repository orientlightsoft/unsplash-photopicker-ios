//
//  UnsplashPhoto+DragAndDrop.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

extension UnsplashPhoto {
    private var _urls: [URLKind: WrapAssetURLBlock] {
        get {
            return self.urls.reduce([:]) { (ret, url) -> [URLKind: WrapAssetURLBlock] in
                var ret = ret
                ret[url.key] = { $0(url.value) }
                return ret
            }
        }
    }
    var wrap: WrapAsset<UnsplashPhoto> {
        get {
            return WrapAsset<UnsplashPhoto>(source: self,
                                        identifierKeyPath: \.identifier,
                                        nameKeyPath: \.user.displayName,
                                        colorKeyPath: \.color,
                                        heightKeyPath: \.height,
                                        widthKeyPath: \.width,
                                        urlsKeyPath: \._urls,
                                        trackingKeyPath: \.links[.downloadLocation],
                                        headersKeyPath: nil)
        }
    }
    var itemProvider: NSItemProvider {
        return NSItemProvider(object: UnsplashPhotoItemProvider(with: self))
    }
    
    var dragItem: UIDragItem {
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = self
        dragItem.previewProvider = {
            guard let photoView = PhotoView.view(with: self.wrap) else {
                return nil
            }
            
            photoView.userNameLabel.isHidden = true
            photoView.layer.cornerRadius = 12
            photoView.frame.size.width = 300
            photoView.frame.size.height = 300 * CGFloat(self.height) / CGFloat(self.width)
            photoView.layoutSubviews()
            
            let parameters = UIDragPreviewParameters()
            parameters.backgroundColor = .clear
            
            return UIDragPreview(view: photoView, parameters: parameters)
        }
        return dragItem
    }
}
