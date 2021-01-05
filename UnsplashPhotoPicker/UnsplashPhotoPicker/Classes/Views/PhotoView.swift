//
//  PhotoView.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-11-06.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit
import Photos

class PhotoView: UIView {

    static var nib: UINib { return UINib(nibName: "PhotoView", bundle: Bundle(for: PhotoView.self)) }

    private var imageDownloader = ImageDownloader()
    private var screenScale: CGFloat { return UIScreen.main.scale }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var overlayViews: [UIView]!

    var showsUsername = true {
        didSet {
            userNameLabel.alpha = showsUsername ? 1 : 0
            gradientView.alpha = showsUsername ? 1 : 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        accessibilityIgnoresInvertColors = true
        gradientView.setColors([
            GradientView.Color(color: .clear, location: 0),
            GradientView.Color(color: UIColor(white: 0, alpha: 0.5), location: 1)
        ])
    }

    func prepareForReuse() {
        userNameLabel.text = nil
        imageView.backgroundColor = .clear
        imageView.image = nil
        imageView.layer.removeAllAnimations()
        imageDownloader.cancel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let fontSize: CGFloat = traitCollection.horizontalSizeClass == .compact ? 10 : 13
        userNameLabel.font = UIFont.systemFont(ofSize: fontSize)
    }

    // MARK: - Setup

    func configure<Source>(with photo: WrapAsset<Source>, showsUsername: Bool = true) {
        self.showsUsername = showsUsername
        userNameLabel.text = photo.name
        imageView.backgroundColor = photo.color
        downloadImage(with: photo)
    }

    private func downloadImage<Source>(with photo: WrapAsset<Source>) {
        let maxSize = CGSize(width: frame.width * screenScale, height: frame.height * screenScale)
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            switch Source.self {
            case is PHAsset.Type:
                self.downloadImageAsset(with: photo, maxSize: maxSize)
            default:
                self.downloadImageURL(with: photo, maxSize: maxSize)
            }
        }
  
    }
    
    private func downloadImageAsset<Source>(with photo: WrapAsset<Source>, maxSize: CGSize) {
        if let asset = photo.source as? PHAsset {
            let targetSize = CGSize(width: maxSize.width, height: (CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)) * maxSize.width)
            unowned let weakSelf = self
            imageDownloader.downloadPhoto(with: asset, targetSize: targetSize, completion: weakSelf.showImage)
        }
    }
    
    private func downloadImageURL<Source>(with photo: WrapAsset<Source>, maxSize: CGSize) {
        unowned let weakSelf = self
        imageDownloader.downloadPhoto(with: photo, maxSize: maxSize, completion: weakSelf.showImage)
    }
    
    private func showImage(_ image: UIImage?, isCached: Bool) {
        guard self.imageDownloader.isCancelled == false else { return }
        if isCached {
            self.imageView.image = image
        } else {
            UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: { [weak self] in
                guard let self = self, self.imageDownloader.isCancelled == false else { return }
                self.imageView.image = image
            }, completion: nil)
        }
    }

    // MARK: - Utility

    class func view<Source>(with photo: WrapAsset<Source>) -> PhotoView? {
        guard let photoView = nib.instantiate(withOwner: nil, options: nil).first as? PhotoView else {
            return nil
        }

        photoView.configure(with: photo)

        return photoView
    }

}
