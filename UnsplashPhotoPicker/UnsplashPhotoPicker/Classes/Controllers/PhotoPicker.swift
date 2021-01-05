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
    func photoPicker<Source>(_ photoPicker: PhotoPicker<Source>, sender: AnyObject?, didSelectPhotos photos: [Asset])

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
    
    public class func unsplash(prefixQuery: String?) -> PhotoPickerViewController<Source> {
        return UnsplashPhotoPickerViewController(prefixQuery: prefixQuery) as! PhotoPickerViewController<Source>
    }
    
    public class func iconfinder(prefixQuery: String?) -> PhotoPickerViewController<Source> {
        return IconfinderPhotoPickerViewController(prefixQuery: prefixQuery) as! PhotoPickerViewController<Source>
    }
    // MARK: - Lifetime
    /**
     Initializes an `UnsplashPhotoPicker` object with a configuration.

     - parameter configuration: The configuration struct that specifies how UnsplashPhotoPicker should be configured.
     */
    
    public init(configuration: PhotoPickerConfiguration, controller: PhotoPickerViewController<Source>) {
        Configuration.shared = configuration
        self.photoPickerViewController = controller
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
    
    public func deselectSelectedItems() {
        photoPickerViewController.deselectSelectedItems()
    }
}

// MARK: - UnsplashPhotoPickerViewControllerDelegate
extension PhotoPicker: PhotoPickerViewControllerDelegate {
    
    func photoPickerViewController<Source>(_ viewController: PhotoPickerViewController<Source>, sender: AnyObject?, didSelectPhotos photos: [WrapAsset<Source>]) {
        let group = DispatchGroup()
        var assets = [Asset]()
        photos.forEach { (photo) in
            group.enter()
            photo.preload { (url) in
                DispatchQueue.global(qos: .background).async {
                    var asset = Asset.init(wrap: photo)
                    if let url = url, asset.urls.isEmpty {
                        asset.urls = [.regular: { $0(url) }, .thumb: { $0(url) }]
                    }
                    assets.append(asset)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {[weak self] in
            guard let self = self else { return }
            self.photoPickerDelegate?.photoPicker(self, sender: sender, didSelectPhotos: assets)
        }
        
    }

    func photoPickerViewControllerDidCancel<Source>(_ viewController: PhotoPickerViewController<Source>) {
        photoPickerDelegate?.photoPickerDidCancel(self)
    }
}
