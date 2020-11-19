//
//  CameraRollPhotoPickerViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/18/20.
//

import Foundation
import Photos

class CameraRollPhotoPickerViewController: PhotoPickerViewController<PHAsset>, PHPhotoLibraryChangeObserver {
    
    override init(prefixQuery: String?) {
        super.init(prefixQuery: prefixQuery)
    }
    override var searchPlaceHolder: String { return "search.camera.roll.placeholder".localized() }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    override func setSearchText(_ text: String?) {
        let prefix = self.prefixQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchVals = [prefix, text].compactMap( { $0 })
        let val = searchVals.joined(separator: "+")
        dataSource = CameraRollPhotoDataSourceFactory.search(query: val).dataSource
        searchText = text
    }
    
    override func setupSearchController() {
        
    }
    
    override func emptyViewStateForError(_ error: Error) -> EmptyViewState {
        switch error {
        case AssetRequest.RequestError.requiredPermission:
            return .other("Permissions", error.localizedDescription)
        default:
            return .other("Permissions", error.localizedDescription)
        }
        
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.refresh()
    }
    
    override func retry() {
        
        if let settings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settings) {
            UIApplication.shared.open(settings, options: [:], completionHandler: nil)
        }
    }
    
    
}
