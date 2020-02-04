//
//  PlacesTableView.swift
//  UBSetRoute
//
//  Created by Usemobile on 22/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

class PlacesTableView: UITableView {
    
    // MARK: UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.superView.addSubview(imageView)
        imageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, padding: .zero, size: .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - SetRouteViewSettings.shared.routeViewHeight - navBarSize))
        return imageView
    }()
    
    // MARK: Properties
    
    enum TableStates {
        case full
        case medium
        case closed
    }
    
    private let defaultOptions = [PlaceViewModel(type: .getCurrentLocation),
                                  PlaceViewModel(type: .selectAtMap)]
    private var placeList: [PlaceViewModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    public var lastPlaces: [PlaceViewModel] = [] {
        didSet {
            if self.hasLastPlaces {
                self.reloadData()
            }
        }
    }
    
    private var superView: MapView!
    var controller: UIViewController!
    //    private lazy var hasNavigation: Bool = {
    //        return self.controller.navigationController != nil
    //    }()
    
    lazy var allowUpdateTableInsets: Bool = {
        let isAnimating = self.superView.isAnimating
        let isRoutePresented = !self.superView.routeView.isHidden
        return isAnimating || isRoutePresented
    }()
    
    private var cnstTableTop = NSLayoutConstraint()
    private var allowVelocityHide = true
    private var updateConstraintsByScroll = true
    
    var isAnimating = false
    
    private var currentState: TableStates = .closed
    
    var didSelectPlace: ((PlaceViewModel) -> Void)?
    
    private var hasLastPlaces: Bool = true
    public var isMapSelectionEnabled: Bool {
        //        print("STATE: ", self.currentState)
        return self.currentState == .closed
    }
    
    // MARK: Init
    
    required init(superView: MapView, controller: UIViewController) {
        super.init(frame: .zero, style: .plain)
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superView = superView
        self.controller = controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func handleKeyboard(notification: Notification) {
        guard self.allowUpdateTableInsets else { return }
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let superViewHeight = self.superView.frame.height
                let routeViewHeight = SetRouteViewSettings.shared.routeViewHeight + navBarSize
                let keyboardHeight = keyboardFrame.height
                let tableHeight = superViewHeight - routeViewHeight - keyboardHeight
                let bottomInset = self.bounds.height - tableHeight
                self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    public func setup() {
        self.superView.addSubview(self)
        self.setupTableConstraints()
        self.backgroundColor = .white
        self.separatorStyle = .none
        self.estimatedRowHeight = 70
        self.rowHeight = UITableView.automaticDimension
        self.register(PlacesCell.self, forCellReuseIdentifier: "PlacesCell")
        self.delegate = self
        self.dataSource = self
        self.keyboardDismissMode = .interactive
        self.placeList = self.defaultOptions
    }
    
    fileprivate func setupTableConstraints() {
        let topPadding: CGFloat = SetRouteViewSettings.shared.routeViewHeight + navBarSize - SetRouteViewSettings.shared.statusBarSizeAdjust
        self.cnstTableTop = self.topAnchor.constraint(equalTo: self.superView.topAnchor, constant: topPadding)
        let height = UIScreen.main.bounds.height - SetRouteViewSettings.shared.routeViewHeight - navBarSize
        self.anchor(top: nil, left: self.superView.leftAnchor, bottom: nil, right: self.superView.rightAnchor, padding: .zero, size: .init(width: 0, height: height))
        self.cnstTableTop.isActive = true
        self.cnstTableTop.constant = UIScreen.main.bounds.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let statusBarSizeAdjust: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        guard self.updateConstraintsByScroll else {
            return
        }
        self.superView.buttonEnabled = false
        if self.currentState == .medium {
            
        } else {
            if offsetY < 0 {
                self.imageView.isHidden = false
                self.cnstTableTop.constant = SetRouteViewSettings.shared.routeViewHeight + navBarSize + 2*(-offsetY) + statusBarSizeAdjust
            } else {
                self.imageView.isHidden = true
                self.cnstTableTop.constant = SetRouteViewSettings.shared.routeViewHeight + navBarSize + statusBarSizeAdjust
            }
        }
        self.superView.layoutIfNeeded()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.allowVelocityHide = scrollView.contentOffset.y < 20
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.superView.buttonEnabled = true
        if self.currentState == .full && !self.isAnimating {
            self.superView.setFirstResponder()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.allowVelocityHide = scrollView.contentOffset.y < 20
        let velocityDrag = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        let percentDrag: CGFloat = scrollView.contentOffset.y/scrollView.bounds.height
        if -percentDrag > 0.2 || (velocityDrag > 200 && self.allowVelocityHide) {
            self.updateConstraintsByScroll = false
            self.setMediumState()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateConstraintsByScroll = true
            }
        }
        if self.currentState == .full, scrollView.contentOffset.y > 0, !self.isAnimating {
            self.superView.buttonEnabled = true
        }
    }
    
    func present(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        guard !self.isAnimating && self.currentState != .full else { return }
        self.isAnimating = true
        self.isScrollEnabled = false
        let statusBarSizeAdjust: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        UIView.animate(withDuration: duration, animations: {
            self.superView.dragView.isHidden = true
            self.isHidden = false
            self.cnstTableTop.constant = SetRouteViewSettings.shared.routeViewHeight + navBarSize + statusBarSizeAdjust
            self.superView.layoutIfNeeded()
            self.superView.hideConfirm()
        }) { (finished) in
            self.isScrollEnabled = true
            self.imageView.isHidden = true
            self.imageView.image = self.printTable()
            self.currentState = .full
            self.isAnimating = false
            self.superView.buttonEnabled = true
            if finished {
                completion?()
            }
        }
    }
    
    func hide(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        guard !self.isAnimating && self.currentState != .closed else { return }
        self.isAnimating = true
        self.isScrollEnabled = false
        UIView.animate(withDuration: duration, animations: {
            self.isHidden = false
            self.superView.dragView.isHidden = true
            self.cnstTableTop.constant = UIScreen.main.bounds.height
            self.superView.layoutIfNeeded()
        }) { (finished) in
            self.isScrollEnabled = true
            self.imageView.isHidden = true
            self.currentState = .closed
            self.isAnimating = false
            self.superView.hideKeyboard()
            if finished {
                completion?()
            }
        }
    }
    
    func setMediumState(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        guard !self.isAnimating else { return }
        self.isAnimating = true
        self.isScrollEnabled = false
        UIView.animate(withDuration: duration, animations: {
            self.isHidden = false
            self.superView.dragView.isHidden = false
            self.cnstTableTop.constant = UIScreen.main.bounds.height - 120
            self.superView.layoutIfNeeded()
            self.superView.hideConfirm()
        }) { (finished) in
            self.isScrollEnabled = true
            self.imageView.isHidden = true
            self.currentState = .medium
            self.isAnimating = false
            self.superView.hideKeyboard()
            self.superView.buttonEnabled = true
            if finished {
                completion?()
            }
        }
    }
    
    func updateTablePosition(_ positionY: CGFloat) {
        let minimunValue = SetRouteViewSettings.shared.routeViewHeight + navBarSize
        let value = UIScreen.main.bounds.height - 120 + positionY
        let updateValue = value >= minimunValue ? value : minimunValue
        self.cnstTableTop.constant = updateValue
        self.superView.layoutIfNeeded()
    }
    
    func handleGestureEnded(_ beginY: CGFloat, endY: CGFloat) {
        self.superView.dragView.isUserInteractionEnabled = false
        let range = beginY - endY
        let maxRange = UIScreen.main.bounds.height - 120 - SetRouteViewSettings.shared.routeViewHeight - navBarSize
        let percent = range / maxRange
        if percent >= 0.35 {
            self.present(duration: 0.4 * TimeInterval(1-percent), completion: {
                self.superView.setFirstResponder()
                self.superView.dragView.isUserInteractionEnabled = true
            })
        } else {
            self.setMediumState(duration: 0.4 * TimeInterval(1+percent), completion: {
                self.superView.dragView.isUserInteractionEnabled = true
            })
        }
        
    }
    
    private func printTable() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func reloadData() {
        super.reloadData()
        DispatchQueue.main.async {
            self.imageView.image = self.printTable()
        }
    }
    
    public func setPlaces(_ placeList: [PlaceViewModel]) {
        self.hasLastPlaces = placeList.isEmpty
        if placeList.isEmpty {
            self.placeList = self.defaultOptions
        } else {
            self.placeList = placeList
        }
    }
    
    public func setLastPlaces(_ placeList: [PlaceViewModel]) {
        self.hasLastPlaces = true
        self.lastPlaces = placeList
        self.placeList = self.defaultOptions
    }
    
    public func clearPlaces() {
        self.setPlaces([])
    }
}


extension PlacesTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let selectedPlace = section == 0 ? self.placeList[row] : self.lastPlaces[row]
        if let cell = tableView.cellForRow(at: indexPath) as? PlacesCell { 
            cell.select()
            self.didSelectPlace?(selectedPlace)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                cell.isSelected = false
                cell.deselect()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PlacesCell {
            cell.deselect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PlacesTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        default:
            if self.hasLastPlaces && !self.lastPlaces.isEmpty {
                let view = HeaderView()
                return view
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        return CGFloat(section * 40)
        return section != 0 && self.hasLastPlaces && !self.lastPlaces.isEmpty ? 40 : 0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.hasLastPlaces && !self.lastPlaces.isEmpty ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.placeList.count : self.lastPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCell", for: indexPath) as! PlacesCell
        switch section {
        case 0:
            cell.placeModel = self.placeList[row]
        default:
            cell.placeModel = self.lastPlaces[row]
        }
        return cell
    }
    
}
