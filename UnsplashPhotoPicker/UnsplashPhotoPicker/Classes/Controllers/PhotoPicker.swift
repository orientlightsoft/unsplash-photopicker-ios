//
//  UnsplashPhotoPicker.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit
import Photos

/// A protocol describing an object that can be notified of events from UnsplashPhotoPicker.
public protocol PhotoPickerDelegate: class {
    
    /**
     Notifies the delegate that UnsplashPhotoPicker has selected photos.

     - parameter photoPicker: The `UnsplashPhotoPicker` instance responsible for selecting the photos.
     - parameter photos:      The selected photos.
     */
    func photoPicker<Source>(_ photoPicker: PhotoPicker<Source>, didSelectPhotos photos: [Asset])

    /**
     Notifies the delegate that UnsplashPhotoPicker has been canceled.

     - parameter photoPicker: The `UnsplashPhotoPicker` instance responsible for selecting the photos.
     */
    func photoPickerDidCancel<Source>(_ photoPicker: PhotoPicker<Source>)
}

/// `UnsplashPhotoPicker` is an object that can be used to select photos from Unsplash.
public class PhotoPicker<Source>: UINavigationController {

    // MARK: - Properties

    private let photoPickerViewController: PhotoPickerViewController<Source>

    /// A delegate that is notified of significant events.
    public weak var photoPickerDelegate: PhotoPickerDelegate?

    public var scrollView: UIScrollView {
        get {
            return photoPickerViewController.scrollView
        }
    }
    // MARK: - Lifetime

    /**
     Initializes an `UnsplashPhotoPicker` object with a configuration.

     - parameter configuration: The configuration struct that specifies how UnsplashPhotoPicker should be configured.
     */
    public init(configuration: PhotoPickerConfiguration, prefixQuery: String?) {
        Configuration.shared = configuration
        switch Source.self {
        case is UnsplashPhoto.Type:
            self.photoPickerViewController = UnsplashPhotoPickerViewController(prefixQuery: prefixQuery) as! PhotoPickerViewController<Source>
        case is Iconfinder.Type:
            self.photoPickerViewController = IconfinderPhotoPickerViewController(prefixQuery: prefixQuery) as! PhotoPickerViewController<Source>
        case is PHAsset.Type:
            self.photoPickerViewController = CameraRollPhotoPickerViewController(prefixQuery: prefixQuery) as! PhotoPickerViewController<Source>
        default:
            fatalError("Abstract method")
        }

        
        super.init(nibName: nil, bundle: nil)

        photoPickerViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [photoPickerViewController]
    }
}

// MARK: - UnsplashPhotoPickerViewControllerDelegate
extension PhotoPicker: PhotoPickerViewControllerDelegate {
    func photoPickerViewController<Source>(_ viewController: PhotoPickerViewController<Source>, didSelectPhotos photos: [WrapAsset<Source>]) {
        let group = DispatchGroup()
        var assets = [Asset]()
        photos.forEach { (photo) in
            group.enter()
            photo.preload { (url) in
                var asset = Asset.init(wrap: photo)
                if let url = url, asset.urls.isEmpty {
                    asset.urls = [.regular: url]
                }
                assets.append(asset)
                group.leave()
            }
        }
        group.notify(queue: .main) {[weak self] in
            guard let self = self else { return }
            self.photoPickerDelegate?.photoPicker(self, didSelectPhotos: assets)
        }
        
    }

    func photoPickerViewControllerDidCancel<Source>(_ viewController: PhotoPickerViewController<Source>) {
        photoPickerDelegate?.photoPickerDidCancel(self)
    }
}
