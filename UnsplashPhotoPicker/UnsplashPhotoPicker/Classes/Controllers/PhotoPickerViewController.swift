//
//  UnsplashPhotoPickerViewController.swift
//  UnsplashPhotoPicker
//
//  Created by Bichon, Nicolas on 2018-10-09.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

protocol PhotoPickerViewControllerDelegate: class {
    func photoPickerViewController<Source>(_ viewController: PhotoPickerViewController<Source>, sender: AnyObject?, didSelectPhotos photos: [WrapAsset<Source>])
    func photoPickerViewControllerDidCancel<Source>(_ viewController: PhotoPickerViewController<Source>)
}

open class PhotoPickerViewController<Source>: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate, UIViewControllerPreviewingDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, WaterfallLayoutDelegate {

    // MARK: - Properties

    internal var scrollView: UIScrollView {
        get { return self.collectionView }
    }
    
    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelBarButtonTapped(sender:))
        )
    }()

    private lazy var doneBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneBarButtonTapped(sender:))
        )
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UnsplashSearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = self.searchPlaceHolder
        searchController.searchBar.autocapitalizationType = .none
        return searchController
    }()

    open var searchPlaceHolder: String { return "search.photos.placeholder".localized() }
    
    private lazy var layout = WaterfallLayout(with: self)

    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell<Source>.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.register(PagingView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingView.reuseIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        collectionView.backgroundColor = UIColor.photoPicker.background
        collectionView.allowsMultipleSelection = Configuration.shared.allowsMultipleSelection
        return collectionView
    }()

    private let spinner: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.hidesWhenStopped = true
            return spinner
        } else {
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.hidesWhenStopped = true
            return spinner
        }
    }()

    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var dataSource: PagedDataSource<Source>? {
        didSet {
            oldValue?.cancelFetch()
            dataSource?.delegate = self
        }
    }

    var numberOfSelectedPhotos: Int {
        return collectionView.indexPathsForSelectedItems?.count ?? 0
    }

    private var previewingContext: UIViewControllerPreviewing?
    public var searchText: String?
    public let prefixQuery: String?
    weak var delegate: PhotoPickerViewControllerDelegate?

    // MARK: - Lifetime
    
    public convenience init(configuration: PhotoPickerConfiguration, prefixQuery: String?) {
        Configuration.shared = configuration
        self.init(prefixQuery: prefixQuery)
        
    }
    public init(prefixQuery: String?) {
        self.prefixQuery = prefixQuery
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.photoPicker.background
        setupNotifications()
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupSpinner()
        setupPeekAndPop()
        
        setupEmptyView()
        
        let trimmedQuery = Configuration.shared.unsplash.query?.trimmingCharacters(in: .whitespacesAndNewlines)
        setSearchText(trimmedQuery)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let dataSource = dataSource, dataSource.items.count == 0 {
            refresh()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Fix to avoid a retain issue
        searchController.dismiss(animated: true, completion: nil)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_) in
            self.layout.invalidateLayout()
        })
    }

    // MARK: - Setup

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupNavigationBar() {
        updateTitle()
        
        if Configuration.shared.allowCancelSelection {
            navigationItem.leftBarButtonItem = cancelBarButtonItem
        }
        

        if Configuration.shared.allowsMultipleSelection {
            doneBarButtonItem.isEnabled = false
            navigationItem.rightBarButtonItem = doneBarButtonItem
        }
    }

    open func setupSearchController() {
        let trimmedQuery = Configuration.shared.unsplash.query?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let query = trimmedQuery, query.isEmpty == false { return }

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func setupSpinner() {
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    private func setupPeekAndPop() {
        previewingContext = registerForPreviewing(with: self, sourceView: collectionView)
    }
    
    private func setupEmptyView() {
        self.emptyView.onRetryCallback = {[weak self] _ in
            self?.retry()
        }
    }
    open func emptyViewStateForError(_ error: Error) -> EmptyViewState {
        return (error as NSError).isNoInternetConnectionError() ? .noInternetConnection : .serverError
    }

    private func showEmptyView(with state: EmptyViewState) {
        emptyView.state = state

        guard emptyView.superview == nil else { return }

        spinner.stopAnimating()

        view.addSubview(emptyView)

        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                emptyView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 0),
                emptyView.leftAnchor.constraint(equalTo: view.leftAnchor),
                emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                emptyView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        } else {
            fatalError("Not supported")
        }
        
    }

    private func hideEmptyView() {
        emptyView.removeFromSuperview()
    }

    func updateTitle() {
        if Configuration.shared.showNavigationTitle {
            title = String.localizedStringWithFormat("title".localized(), numberOfSelectedPhotos)
        }
       
    }

    func updateDoneButtonState() {
        doneBarButtonItem.isEnabled = numberOfSelectedPhotos > 0
    }

    // MARK: - Actions

    @objc private func cancelBarButtonTapped(sender: AnyObject?) {
        searchController.searchBar.resignFirstResponder()

        delegate?.photoPickerViewControllerDidCancel(self)
    }

    @objc private func doneBarButtonTapped(sender: AnyObject?) {
        searchController.searchBar.resignFirstResponder()

        let selectedPhotos = collectionView.indexPathsForSelectedItems?.reduce([], { (photos, indexPath) -> [WrapAsset<Source>] in
            var mutablePhotos = photos
            if let dataSource = dataSource, let photo = dataSource.item(at: indexPath.item) {
                mutablePhotos.append(photo)
            }
            return mutablePhotos
        })

        delegate?.photoPickerViewController(self, sender: sender, didSelectPhotos: selectedPhotos ?? [WrapAsset<Source>]())
        self.trackDownloads(for: selectedPhotos ?? [WrapAsset<Source>]())
    }

    private func scrollToTop() {
        let contentOffset = CGPoint(x: 0, y: -collectionView.safeAreaInsets.top)
        collectionView.setContentOffset(contentOffset, animated: false)
    }

    // MARK: - Data

    open func setSearchText(_ text: String?) {
       fatalError("Abstract method")
    }

    @objc public func refresh(force: Bool = false) {
        guard let dataSource = dataSource, force || dataSource.items.isEmpty else { return }

        if dataSource.isFetching == false && (force || dataSource.items.count == 0) {
            dataSource.reset()
            reloadData()
            fetchNextItems()
        }
    }

    func reloadData() {
        collectionView.reloadData()
    }
    
    open func retry() {
        refresh()
    }

    func fetchNextItems() {
        guard let dataSource = dataSource else { return }
        dataSource.fetchNextPage()
    }

    private func fetchNextItemsIfNeeded() {
        if let dataSource = dataSource, dataSource.items.count == 0 {
            fetchNextItems()
        }
    }
    
    func deselectSelectedItems() {
        self.collectionView.indexPathsForSelectedItems?.forEach { (indexPath) in
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
        
    }
    // MARK: - Download tracking
    func trackDownloads(for photos: [WrapAsset<Source>]) {
        
    }

    // MARK: - Notifications
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
        }

        let bottomInset = keyboardSize.height - view.safeAreaInsets.bottom
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)

        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = contentInsets
            self?.collectionView.scrollIndicatorInsets = contentInsets
        }
    }

    @objc func keyboardWillHideNotification(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        UIView.animate(withDuration: duration) { [weak self] in
            self?.collectionView.contentInset = .zero
            self?.collectionView.scrollIndicatorInsets = .zero
        }
    }
    
    // MARK: - UISearchControllerDelegate
    public func didPresentSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            unregisterForPreviewing(withContext: context)
            previewingContext = searchController.registerForPreviewing(with: self, sourceView: collectionView)
        }
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            searchController.unregisterForPreviewing(withContext: context)
            previewingContext = registerForPreviewing(with: self, sourceView: collectionView)
        }
    }
    // MARK: - UISearchBarDelegate
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }

        setSearchText(text)
        refresh()
        scrollToTop()
        hideEmptyView()
        updateTitle()
        updateDoneButtonState()
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard self.searchText != nil && searchText.isEmpty else { return }

        setSearchText(nil)
        refresh()
        reloadData()
        scrollToTop()
        hideEmptyView()
        updateTitle()
        updateDoneButtonState()
    }
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchController.searchBar.isFirstResponder {
            searchController.searchBar.resignFirstResponder()
        }
    }
    // MARK: - UIViewControllerPreviewingDelegate
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: location),
            let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath),
            let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell<Source>,
            let image = cell.photoView.imageView.image else {
                return nil
        }

        previewingContext.sourceRect = cellAttributes.frame

        return PhotoPickerPreviewViewController(image: image)
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PagingView.reuseIdentifier, for: indexPath)

        guard let dataSource = dataSource, let pagingView = view as? PagingView else { return view }

        pagingView.isLoading = dataSource.isFetching

        return pagingView
    }
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if  let dataSource = dataSource, let photoCell = cell as? PhotoCell<Source>, let photo = dataSource.item(at: indexPath.item) {
            photoCell.configure(with: photo)
        }
       
        
        let prefetchCount = 19
        if let dataSource = dataSource, indexPath.item == dataSource.items.count - prefetchCount {
            fetchNextItems()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource, let photo = dataSource.item(at: indexPath.item), collectionView.hasActiveDrag == false else { return }

        if Configuration.shared.allowsMultipleSelection {
            updateTitle()
            updateDoneButtonState()
        } else {
            delegate?.photoPickerViewController(self, sender: collectionView.cellForItem(at: indexPath),didSelectPhotos: [photo])
            self.trackDownloads(for: [photo])
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if Configuration.shared.allowsMultipleSelection {
            updateTitle()
            updateDoneButtonState()
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource, let photo = dataSource.item(at: indexPath.item) else { return .zero }

        let width = collectionView.frame.width
        let size = photo.size
        let height = size.height * width / size.width
        return CGSize(width: width, height: height)
    }
    // MARK: - WaterfallLayoutDelegate
    public func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource, let photo = dataSource.item(at: indexPath.item) else { return .zero }

        return photo.size
    }
}
// MARK: - PagedDataSourceDelegate
extension PhotoPickerViewController: PagedDataSourceDelegate {
    func dataSourceWillStartFetching<Source>(_ dataSource: PagedDataSource<Source>) {
        if dataSource.items.count == 0 {
            spinner.startAnimating()
        }
    }

    func dataSource<Source>(_ dataSource: PagedDataSource<Source>, didFetch items: [WrapAsset<Source>]) {
        guard dataSource.items.count > 0 else {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.showEmptyView(with: .noResults)
            }

            return
        }
        
        let newPhotosCount = items.count
        let startIndex = (self.dataSource?.items.count ?? 0) - newPhotosCount
        let endIndex = startIndex + newPhotosCount
        var newIndexPaths = [IndexPath]()
        for index in startIndex..<endIndex {
            newIndexPaths.append(IndexPath(item: index, section: 0))
        }

        DispatchQueue.main.async { [unowned self] in
            self.spinner.stopAnimating()
            self.hideEmptyView()

            let hasWindow = self.collectionView.window != nil
            let collectionViewItemCount = self.collectionView.numberOfItems(inSection: 0)
            if hasWindow && collectionViewItemCount < dataSource.items.count {
                self.collectionView.insertItems(at: newIndexPaths)
            } else {
                self.reloadData()
            }
        }
    }

    func dataSource<Source>(_ dataSource: PagedDataSource<Source>, fetchDidFailWithError error: Error) {
        let state = self.emptyViewStateForError(error)

        DispatchQueue.main.async {
            self.showEmptyView(with: state)
        }
    }
}
