//
//  ImageDownloader.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-15.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit
import Photos

class ImageDownloader {

    private var imageDataTask: URLSessionDataTask?
    private var token: PHImageRequestID?
    private let cache = ImageCache.cache
    private let phcache = ImageCache.phcache
    
    private(set) var isCancelled = false

    func downloadPhoto<Source>(with photo: WrapAsset<Source>, url: URL, completion: @escaping ((UIImage?, Bool) -> Void)) {
        guard imageDataTask == nil else { return }

        isCancelled = false
        if let cachedResponse = self.cache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            DispatchQueue.main.async {
                completion(image, false)
            }
            return
        }

        self.imageDataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            strongSelf.imageDataTask = nil

            guard let data = data, let response = response, let image = UIImage(data: data), error == nil else { return }
            if let path = photo.diskCachePath, !FileManager.default.fileExists(atPath: path) {
                let fileURL = URL(fileURLWithPath: path)
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("\(#function) fail to cache photo")
                }
                
            }
            let cachedResponse = CachedURLResponse(response: response, data: data)
            strongSelf.cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            
            DispatchQueue.main.async {
                completion(image, false)
            }
        }

        self.imageDataTask?.resume()
        
    }
    
    func downloadPhoto(with asset: PHAsset, targetSize: CGSize, completion: @escaping ((UIImage?, Bool) -> Void)) {
        isCancelled = false
        let opt = PHImageRequestOptions()
        opt.isSynchronous = true
        opt.deliveryMode = .opportunistic
        opt.resizeMode = .fast
        opt.isNetworkAccessAllowed = true
        self.token = self.phcache.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: opt) { (image, info) in
            DispatchQueue.main.async {
                completion(image, false)
            }
        }
 
    }

    func cancel() {
        if let token = self.token {
            self.phcache.cancelImageRequest(token)
        }
        imageDataTask?.cancel()
        
        isCancelled = true

    }

}
