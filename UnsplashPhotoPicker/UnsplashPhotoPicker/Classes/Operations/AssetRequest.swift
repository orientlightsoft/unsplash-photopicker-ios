//
//  AssetRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/19/20.
//

import Foundation
import Photos

class AssetRequest: ConcurrentOperation {
    
    enum RequestError: Error, LocalizedError {
        case invalidFetchResult
        case requiredPermission
        var errorDescription: String? {
            switch self {
            case .invalidFetchResult:
                return "Invalid fetch result."
            case .requiredPermission:
                return "Required permissions to access photos."
            }
        }
    }
    

    func prepareFetchResult() throws -> PHFetchResult<PHAsset>? {
        return nil
    }
    
    override func main() {

        PHPhotoLibrary.requestAuthorization {[weak self] (status) in
            guard let self = self else { return }
            var canFetchAsset = false
            if #available(iOS 14, *) {
                canFetchAsset = status == .limited || status == .authorized
            } else {
                // Fallback on earlier versions
                canFetchAsset = status == .authorized
            }
            if canFetchAsset {
                guard let fetch = try? self.prepareFetchResult() else {
                    self.completeWithError(RequestError.invalidFetchResult)
                    return
                }
                
                self.processFetchResult(fetch)
                
            } else {
                self.completeWithError(RequestError.requiredPermission)
            }
        }
    }
    
    func processFetchResult(_ fetch: PHFetchResult<PHAsset>) {
        
    }
}
