//
//  MapView.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit
import GoogleMaps

public protocol MapViewDelegate: class {
    func idleAt(_ mapView: MapView, position: GMSCameraPosition, setText: @escaping(PlaceViewModel) -> Void)
    func idleAtDestiny(_ mapView: MapView, position: GMSCameraPosition, setText: @escaping(PlaceViewModel) -> Void)
    func finishedRouteSet(_ mapView: MapView, placeOrigin: PlaceViewModel, destinyPlace: PlaceViewModel, setRoute: @escaping(RouteViewModel) -> Void)
    func finishedRouteWithStopsSet(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void)
    func editRouteWithStopsSet(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void)
    func finishedEditRoute(_ mapView: MapView ,places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void)
    func textDidChange(_ mapView: MapView, text: String, setPlaceList: @escaping (([PlaceViewModel]) -> Void))
    func textDidChangeEmpty(_ mapView: MapView, setPlaceList: @escaping (([PlaceViewModel]) -> Void))
    func shouldEditRoute(_ mapView: MapView)
    func cancelRouteEdit(_ mapView: MapView)
    func shouldReset(_ mapView: MapView)
    func mapView(_ mapView: MapView, currentLocationUpdatedFor location: CLLocation, didGetPlace: @escaping(PlaceViewModel) -> Void)
    func mapView(_ mapView: MapView, didSelectSmallRouteFor completion: @escaping (Bool) -> Void)
    func removedTravelOptions()
    func shouldEditRoutePoints(_ mapView: MapView)
    func mapViewDidCancelPointsEdit(_ mapView: MapView)
}

public class MapView: UIView {
    
    // MARK: UI Components
    
    lazy var imvPin: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        let image = SetRouteViewSettings.shared.images.mapPinIcon ?? UIImage.getFrom(customClass: MapView.self, nameResource: "map-pin")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var btnConfirm: CustomButton = {
        let button = CustomButton()
        button.isHidden = true
        button.setTitle(self.confirmTitle, for: .normal)
        button.setTitleColor(SetRouteViewSettings.shared.colors.readyButtonTextColor, for: .normal)
        button.backgroundColor = SetRouteViewSettings.shared.colors.readyButtonBackgroundColor
        button.addTarget(self, action: #selector(confirmPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var dragView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.isHidden = true
        return view
    }()
    
    public lazy var mapView: GMSMapView = {
        let viewMap = GMSMapView()
        viewMap.delegate = self
        viewMap.isMyLocationEnabled = true
        viewMap.settings.myLocationButton = false
        viewMap.translatesAutoresizingMaskIntoConstraints = false
        return viewMap
    }()
    
    private lazy var btnLocation: LocationButton = {
        let btnLocation = LocationButton(frame: .zero)
        btnLocation.translatesAutoresizingMaskIntoConstraints = false
        return btnLocation
    }()
    
    // MARK: Properties
    
    var confirmTitle: String = .ready {
        didSet {
            self.btnConfirm.setTitle(self.confirmTitle, for: .normal)
        }
    }
    
    private var tableView: PlacesTableView!
    var routeView: RouteView!
    private var destinyView: DestinyView!
    private var state: State = .finished
    
    private var mapViewLocationManager = MapViewLocationManager()
    private var controller: UIViewController!
    
    private var point: CGFloat = 0
    
    var originPlace: PlaceViewModel? {
        didSet {
            if let model = self.originPlace {
                self.routeView.txfOrigin.editingChangedBlocker = true
                self.routeView.origin = model.mainText
                self.routeView.txfOrigin.placeHolder = .origin
                DispatchQueue.main.async {
                    self.routeView.txfOrigin.editingChangedBlocker = false
                }
            }
        }
    }
    
    var destinyPlace: PlaceViewModel? {
        didSet {
            if let model = self.destinyPlace {
                self.routeView.txfDestiny.editingChangedBlocker = true
                self.routeView.destiny = model.mainText
                DispatchQueue.main.async {
                    self.routeView.txfDestiny.editingChangedBlocker = false
                }
            }
        }
    }
    
    var isAnimating = false {
        didSet {
            self.controller.navigationController?.navigationBar.isUserInteractionEnabled = !self.isAnimating
            self.routeView.isUserInteractionEnabled = !self.isAnimating
            self.destinyView.isUserInteractionEnabled = !self.isAnimating
        }
    }
    
    var buttonEnabled = true {
        didSet {
            self.routeView.btnBack.isEnabled = self.buttonEnabled
        }
    }
    
    private lazy var hasNavigation: Bool = {
        return self.controller.navigationController != nil
    }()
    
    
    public var currentLocation = CLLocationCoordinate2D()
    public weak var delegate: MapViewDelegate?
    public var mapPadding: CGFloat = 220 {
        didSet {
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: mapPadding, right: 0)
        }
    }
    
    var hasMultiplesStops: Bool = false
    var isEditingStops = false
    
    private var didBeginEdit = false
    
    private var currentRoute: RouteViewModel?
    private var currentRouteStops: RouteViewModelStops?
    
    private var allowWillMove = true
    
    private var markers = [GMSMarker]()
    
    public var backButton: UIButton? {
        willSet {
            if newValue == nil {
                self.backButton?.removeFromSuperview()
            }
        }
    }
    
    var newPoints: [Points] = []
    
    public var recentAddress = [PlaceViewModel]()
    
    // MARK: Init
    
    public required init(controller: UIViewController, config: SetRouteViewConfiguration = .default) {
        super.init(frame: .zero)
        self.controller = controller
        SetRouteViewSettings.shared.config = config
        self.hasMultiplesStops = config.hasMultipleStops ?? false
        self.isEditingStops = config.isEditingStops ?? false
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: Setup
    
    func setup() {
        self.addSubview(self.mapView)
        setupMapConstraints()
        self.addImvPin()
        self.setupBtnConfirm()
        self.addDragView()
        self.setupLocationButton()
        self.setupTable()
        self.setupLocationManager()
        self.setupRouteView()
        self.destinyView = DestinyView(superView: self, hasStops: self.hasMultiplesStops)
        self.destinyView.viewTapped = { (text) in
                self.beginEdit()
        }
        
        self.destinyView.viewTappedStop = { (text) in
            self.beginEditTwo()
            self.editStops(places: [""])
        }
        
        self.bringSubviewToFront(self.routeView)
        self.bringSubviewToFront(self.dragView)
        self.dragView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dragGesture(_:))))
        self.dragView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture(_:))))
        
        if let mapStyle = SetRouteViewSettings.shared.mapStyle {
            do {
                if let styleURL = Bundle.main.url(forResource: mapStyle, withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
    }
    
//    func editStops(places: [String]){
////        self.endEditing(true)
//        self.delegate?.removedTravelOptions()
//        let nextVC = MultiplesStopsViewController(superView: self.routeView, controller: self.controller)
//        nextVC.isEditingStops = false
////        nextVC.delegate = self
////        self.isHidden = true
//        self.controller.navigationController?.pushViewController(nextVC, animated: true)
//    }
    
    public func editStopsFlow(_ category: String){
        self.editStopsTwo(places: self.newPoints, category: category)
    }
    
    public func removeAllPoints(){
        self.newPoints.removeAll()
    }
    
    public func setPoints(visited: Bool? = false, city: String? = "", neighborhood: String? = "", state: String? = "", zip: String? = "", text: String? = "", lat: Double? = 0.0 , long: Double? = 0.0 ,type: String? = "", number: String? = ""){
        let _address = Address(placeId: "", city: city ?? "", neighborhood: neighborhood ?? "", state: state ?? "", zip: zip ?? "", text: text ?? "", location: Location(latitude: lat ?? 0.0, longitude: long ?? 0.0), number: number)
        self.newPoints.append(Points(visited: visited ?? false, address: _address, type: type ?? ""))
    }
    
    func applyBackButton() {
        guard self.backButton == nil else { return }
        let statusBarSizeAdjust: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        let image: UIImage? = UIImage.getFrom(customClass: MapView.self, nameResource: "arrow-left")?.withRenderingMode(.alwaysTemplate)
        let origin = CGPoint(x: 0, y: statusBarHeight + statusBarSizeAdjust)
        let button = UIButton(frame: CGRect(origin: origin, size: .init(width: 44, height: 44)))
        button.setImage(image, for: .normal)
        button.tintColor = SetRouteViewSettings.shared.colors.mapViewBackButton
        button.addTarget(self, action: #selector(btnBackPressed), for: .touchUpInside)
        let view = self.controller.navigationController?.view ?? self
        view.addSubview(button)
        self.backButton = button
    }
    
    @objc func btnBackPressed() {
        self.delegate?.shouldReset(self)
        self.mapView.padding = .zero
        self.hideConfirm()
        self.clearData()
        self.backButton = nil
    }
    
    public func setRecentAddress(_ address: [PlaceViewModel]) {
        self.tableView.lastPlaces = address
    }
    
    public func center(at coordinates: CLLocationCoordinate2D) {
        self.mapView.animate(to: GMSCameraPosition(target: coordinates, zoom: 17, bearing: 0, viewingAngle: 0))
    }
    
    public func reset() {
        self.btnBackPressed()
    }
    
    public func travelRequested() {
        self.backButton = nil
        guard self.state != .finished else { return }
        self.updateContents(to: .finished)
    }
    
    public func beginEdit() {
        self.backButton?.isHidden = true
        self.updateContents(to: .open)
        self.delegate?.shouldEditRoute(self)
        if let route = self.currentRoute {
            self.mapView.clear()
            self.mapView.padding = UIEdgeInsets.zero
            self.mapView.animate(to: GMSCameraPosition(target: route.destinyMarker.coordinates, zoom: 17, bearing: 0, viewingAngle: 0))
        } else {
            self.didBeginEdit = true
            self.mapViewLocationManager.updateLocation()
            if self.currentRoute == nil {
                self.routeView.txfOrigin.text = ""
                self.routeView.txfOrigin.placeHolder = .loading
            }
        }
    }
    
    public func beginEditTwo() {
        self.backButton?.isHidden = true
        
        self.backButton?.isHidden = true
        self.updateContents(to: .open)
        self.delegate?.shouldEditRoute(self)
        if let route = self.currentRoute {
            self.mapView.clear()
            self.mapView.padding = UIEdgeInsets.zero
            self.mapView.animate(to: GMSCameraPosition(target: route.destinyMarker.coordinates, zoom: 17, bearing: 0, viewingAngle: 0))
        } else {
            self.didBeginEdit = true
            self.mapViewLocationManager.updateLocation()
            if self.currentRoute == nil {
                self.routeView.txfOrigin.text = ""
                self.routeView.txfOrigin.placeHolder = .loading
            }
        }
        
    }
    
    fileprivate func finishRouteSelection() {
        let _originPlace = self.originPlace ?? PlaceViewModel(coordinates: self.currentLocation)
        guard let _destinyPlace = self.destinyPlace else { return }
        let completionBlock: () -> Void = {
            self.delegate?.finishedRouteSet(self, placeOrigin: _originPlace, destinyPlace: _destinyPlace, setRoute: { (routeModel) in
                self.currentRoute = routeModel
                self.draw(route: routeModel, hide: true, padding: self.mapPadding)
            })
            self.applyBackButton()
            self.destinyView.destiny = self.destinyPlace?.mainText ?? .whereTo
            self.updateContents(to: .closed)
            self.backButton?.isHidden = false
            self.tableView.hide()
            self.routeView.hide()
            self.imvPin.isHidden = true
        }
        if let locationOrigin = _originPlace.coordinates,
            let locationDestiny = _destinyPlace.coordinates,
            CLLocation(latitude: locationOrigin.latitude,
                       longitude: locationOrigin.longitude).distance(from: CLLocation(latitude: locationDestiny.latitude,
                                                                                      longitude: locationDestiny.longitude)) < 10 {
            self.delegate?.mapView(self, didSelectSmallRouteFor: { (setRoute) in
                if setRoute {
                    completionBlock()
                }
            })
        } else {
            completionBlock()
        }
    }
    
    fileprivate func finishRouteSelectionWithStops(places: [Points]){
        self.delegate?.finishedRouteWithStopsSet(self, places: places, setRoute: { (routeModel) in
            self.newPoints = places
            self.currentRouteStops = routeModel
            self.drawStops(route: routeModel, hide: true, padding: self.mapPadding)
        })
           self.applyBackButton()
           self.destinyView.destiny = places.last?.address?.text ?? .whereTo

           self.destinyView.lblNumberStops.text = places.count > 2 ? "+\(places.count - 2)" : ""
           self.updateContents(to: .closed)
           self.backButton?.isHidden = false
           self.tableView.hide()
           self.routeView.hide()
           self.imvPin.isHidden = true
    }
    
    private func clearData() {
        self.didTapLocationButton = false
        self.getOriginFromDrag = false
        self.getLoctionFromWillMove = false
        self.destinyPlace = nil
        self.originPlace = nil
        self.routeView.clear()
        self.destinyView.destiny = .whereTo
        self.destinyView.lblNumberStops.text = ""
        self.currentRoute = nil
        self.mapView.clear()
        self.tableView.clearPlaces()
        self.mapView.padding = UIEdgeInsets.zero
        self.mapViewLocationManager.updateLocation()
    }
    
    var didPressCurrentLocationCell: Bool = false
    
    fileprivate func setupTable() {
        self.tableView = PlacesTableView(superView: self, controller: self.controller)
        self.tableView.setup()
        self.tableView.didSelectPlace = { (placeModel) in
            switch placeModel.type {
            case .address:
                if self.routeView.isOrigin(self.routeView.lastFirstResponder) {
                    self.originPlace = placeModel
                    if self.destinyPlace != nil {
                        self.finishRouteSelection()
                    } else {
                        let _ = self.routeView.txfDestiny.becomeFirstResponder()
                        self.tableView.clearPlaces()
                    }
                } else {
                    self.destinyPlace = placeModel
                    self.finishRouteSelection()
                }
            case .selectAtMap:
                self.endEditing(false)
                self.tableView.setMediumState()
            case .getCurrentLocation:
                self.didPressCurrentLocationCell = true
                self.routeView.lastFirstResponder?.placeHolder = .loading
                self.routeView.lastFirstResponder?.text = ""
                self.mapViewLocationManager.updateLocation()
            }
        }
    }
    
    fileprivate func addDragView() {
        self.addSubview(self.dragView)
        self.dragView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .zero, size: .init(width: 0, height: 120))
    }
    
    fileprivate func setupBtnConfirm() {
        self.addSubview(self.btnConfirm)
        let padding: CGFloat = UIDevice.isXFamily ? 32 : 16
        self.btnConfirm.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: padding, bottom: padding, right: padding), size: .init(width: 0, height: 50))
        DispatchQueue.main.async {
            self.btnConfirm.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }
    
    fileprivate func addImvPin() {
        self.addSubview(self.imvPin)
        var centerYConstant: CGFloat = self.hasNavigation ? 22 : 0
        if UIDevice.isXFamily { centerYConstant -= 4 }
        self.addConstraints([
            self.imvPin.heightAnchor.constraint(equalToConstant: 30),
            self.imvPin.widthAnchor.constraint(equalTo: self.imvPin.heightAnchor),
            self.imvPin.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imvPin.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: centerYConstant)
            ])
    }
    
    fileprivate func setupMapConstraints() {
        self.mapView.fillSuperview()
    }
    
    private func setupLocationButton() {
        self.addSubview(self.btnLocation)
        let navBarH = UIApplication.shared.statusBarFrame.size.height + 44
        let topPadding = navBarH + 94
        self.btnLocation.anchor(top: self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, padding: .init(top: topPadding, left: 0, bottom: 0, right: 16), size: .init(width: 44, height: 44))
        self.btnLocation.action = {
            self.routeView.setLoading()
            self.getOriginFromDrag = false
            self.didTapLocationButton = true
            self.mapViewLocationManager.updateLocation()
            if !self.routeView.isHidden {
                self.presentConfirm()
                self.tableView.hide()
            }
        }
    }
    
    private var didUpdateLocation: Bool = false
    private var isMapSelectionEnabled: Bool {
        return self.tableView.isMapSelectionEnabled && !self.routeView.isPresented && self.currentRoute == nil
    }
    
    private var allowMapEvents: Bool {
        return !self.didBeginEdit && !self.didTapLocationButton && !self.didPressCurrentLocationCell
    }
    
    private var didRequestLocationForUser = false
    
    fileprivate func setupLocationManager() {
        self.mapViewLocationManager.startUpdatingLocation()
        self.mapViewLocationManager.didUpdateLocation = { (location) in
            let userRequestedLocation = self.didTapLocationButton || self.didPressCurrentLocationCell
            guard self.isMapSelectionEnabled || self.didBeginEdit || userRequestedLocation else { return }
            guard !self.didRequestLocationForUser else { return }
            if userRequestedLocation {
                self.didRequestLocationForUser = true
            }
            self.didUpdateLocation = true
            self.currentLocation = location.coordinate
            var lastResponder: RouteTextField?
            if self.didTapLocationButton {
                lastResponder = self.routeView.lastFirstResponder
            }
            self.mapView.animate(to: GMSCameraPosition(target: location.coordinate, zoom: 17, bearing: 0, viewingAngle: 0))
            if self.didBeginEdit || self.didTapLocationButton || self.didPressCurrentLocationCell {
                self.delegate?.mapView(self, currentLocationUpdatedFor: location) { [weak self] (place: PlaceViewModel) in
                    guard let self = self else { return }
                    self.didRequestLocationForUser = false
                    self.didBeginEdit = false
                    self.currentPlaceViewModel = place
                    if self.didPressCurrentLocationCell {
                        self.didPressCurrentLocationCell = false
                        
                        if self.routeView.isOrigin(self.routeView.lastFirstResponder) {
                            self.originPlace = self.currentPlaceViewModel
                            if self.destinyPlace != nil && self.destinyPlace != nil {
                                self.finishRouteSelection()
                            } else {
                                let _ = self.routeView.txfDestiny.becomeFirstResponder()
                            }
                        } else {
                            self.destinyPlace = self.currentPlaceViewModel
                            if self.destinyPlace != nil && self.destinyPlace != nil {
                                self.finishRouteSelection()
                            } else {
                                let _ = self.routeView.txfOrigin.becomeFirstResponder()
                            }
                        }
                    } else {
                        guard !self.getOriginFromDrag else { return }
                        if self.didTapLocationButton {
                            self.didTapLocationButton = false
                            if lastResponder == self.routeView.txfOrigin {
                                self.originPlace = place
                            } else {
                                self.destinyPlace = place
                            }
                        }
                        self.routeView.setCurrentLocation(viewModel: place, for: lastResponder)
                    }
                }
            }
        }
    }
    
    private var currentPlaceViewModel: PlaceViewModel?
    private var didTapLocationButton = false
    private var getOriginFromDrag = false
    private var getLoctionFromWillMove = false
    
    private func handleIdleAt(_ origin: Bool, position: GMSCameraPosition) {
        if !self.routeView.isHidden {
            self.presentConfirm()
            self.btnConfirm.isEnabled = false
            if origin {
                self.getOriginFromDrag = true
                self.routeView.txfOrigin.editingChangedBlocker = true
                self.routeView.origin = .loading
                self.routeView.txfOrigin.editingChangedBlocker = false
                self.delegate?.idleAt(self, position: position, setText: { model in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        guard self.getOriginFromDrag else { return }
                        model.coordinates = position.target
                        self.originPlace = model
                        self.btnConfirm.isEnabled = true
                    }
                })
            } else {
                self.routeView.txfDestiny.editingChangedBlocker = true
                self.routeView.destiny = .loading
                self.routeView.txfDestiny.editingChangedBlocker = false
                self.delegate?.idleAtDestiny(self, position: position, setText: { model in
                    
                    DispatchQueue.main.async {
                        model.coordinates = position.target
                        self.destinyPlace = model
                        self.btnConfirm.isEnabled = true
                    }
                })
            }
            
        } else {
            self.hideConfirm()
        }
    }
    
    fileprivate func setupRouteView() {
        self.routeView = RouteView(superView: self, controller: self.controller, hasStops: self.hasMultiplesStops)
        self.routeView.hasMultiples = self.hasMultiplesStops
        self.routeView.delegate = self
        self.routeView.didConfirmTap = { [weak self] in
            guard let self = self else { return }
            let nextVC = MultiplesStopsViewController(superView: self)
            nextVC.isEditingStops = false
            nextVC.delegate = self
            self.controller.navigationController?.pushViewController(nextVC, animated: true)
        }
        self.routeView.closedPressed = {
            self.backButton?.isHidden = self.currentRoute == nil
            self.delegate?.cancelRouteEdit(self)
            if let route = self.currentRoute {
                self.draw(route: route, hide: true, padding: self.mapPadding)
            }
            self.updateContents(to: .closed)
        }
        self.routeView.hasBecomeFirstResponder = {
            if !self.routeView.isHidden {
                self.tableView.present()
            }
            
            if let route = self.currentRoute {
                self.allowWillMove = false
                let marker = self.routeView.isOrigin() ? route.originMarker : route.destinyMarker
                self.mapView.clear()
                self.mapView.padding = UIEdgeInsets.zero
                self.mapView.animate(to: GMSCameraPosition(target: marker.coordinates, zoom: 17, bearing: 0, viewingAngle: 0))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    
                    self.allowWillMove = true
                })
                
            }
        }
        self.routeView.textDidChange = { (text) in
            self.startProgress()
            if text.isEmpty {
                self.delegate?.textDidChangeEmpty(self, setPlaceList: { placeList in
                    self.stopProgress()
                    DispatchQueue.main.async {
                        self.tableView.setLastPlaces(placeList)
                    }
                })
            } else {
                self.delegate?.textDidChange(self, text: text, setPlaceList: { placeList in
                    self.stopProgress()
                    DispatchQueue.main.async {
                        self.tableView.setPlaces(placeList)
                    }
                })
            }
        }
    }
    
    public func draw(route: RouteViewModel, hide: Bool = false, padding: CGFloat = 0) {
        self.draw(polylinePoints: route.polylinePoints, padding: padding)
        self.apply(markers: [route.originMarker, route.destinyMarker])
        if hide {
            self.updateContents(to: .closed)
        }
    }
    
    public func drawStops(route: RouteViewModelStops, hide: Bool = false, padding: CGFloat = 0) {
        self.drawTwo(points: route.markers,padding: padding, polylines: route.polylinePoints)
        self.apply(markers: route.markers)
        if hide {
            self.updateContents(to: .closed)
        }
    }
    
    private func drawTwo(points: [USE_Marker], padding: CGFloat = 0, polylines: [String]) {
        self.mapView.clear()
        let paths = GMSMutablePath()
        var _polyline: [GMSPolyline] = []
        for i in 0..<points.count-1{
            _polyline.append(GMSPolyline())
            let _path = GMSPath(fromEncodedPath: polylines[i])
            _polyline[i].path = _path
            _polyline[i].strokeWidth = 3.0
        }
        
        let bounds = GMSCoordinateBounds(path: paths)
        let zoom = GMSCameraUpdate.fit(bounds, withPadding: 120)
        self.mapView.animate(with: zoom)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
        let polyline = GMSPolyline()
        let gradient = GMSStrokeStyle.gradient(from: SetRouteViewSettings.shared.colors.mainColor, to: .black)
        polyline.map = self.mapView
        
        _polyline.forEach({$0.spans = [GMSStyleSpan(style: gradient)]})
        _polyline.forEach({$0.map = self.mapView})
    }
    
    public func apply(markers: [USE_Marker]) {
        self.markers.forEach { $0.map = nil }
        self.markers.removeAll()
        markers.forEach { self.applyMarker(marker: $0) }
    }
    
    private func draw(polylinePoints: String, padding: CGFloat = 0) {
        self.mapView.clear()
        
        guard let path = GMSPath(fromEncodedPath: polylinePoints) else { return }
        let bounds = GMSCoordinateBounds(path: path)
        //        let padding CGFloat
        let zoom = GMSCameraUpdate.fit(bounds, withPadding: 120)
        self.mapView.animate(with: zoom)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
        let polyline = GMSPolyline()
        polyline.path = path
        polyline.strokeWidth = 3.0
        let gradient = GMSStrokeStyle.gradient(from: SetRouteViewSettings.shared.colors.mainColor, to: .black)
        polyline.spans = [GMSStyleSpan(style: gradient)]
        polyline.map = self.mapView
    }
    
    public func applyMarker(marker: USE_Marker) {
        let gmsMarker = GMSMarker(position: marker.coordinates)
        gmsMarker.icon = marker.icon
        gmsMarker.map = self.mapView
        self.markers.append(gmsMarker)
    }
    
    public func present() {
        let delay: TimeInterval = self.state == .finished ? 0.05 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.updateContents(to: .closed)
            self.mapView.clear()
            self.routeView.clear()
            self.tableView.clearPlaces()
            self.backButton = nil
            self.clearData()
            self.mapViewLocationManager.updateLocation()
        }
    }
    
    func updateContents(to state: State) {
        guard self.state != state else { return }
        guard !self.isAnimating else { return }
        self.isAnimating = true
        self.state = state
        var routeAnimationEnded = false
        var destinyAnimationEnded = false
        switch self.state {
        case .open:
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
            self.routeView.present(duration: 0.4) {
                routeAnimationEnded = true
                if destinyAnimationEnded {
                    self.isAnimating = false
                }
                self.imvPin.isHidden = false
            }
            self.destinyView.hide(duration: 0.4) {
                destinyAnimationEnded = true
                if routeAnimationEnded {
                    self.isAnimating = false
                }
            }
            self.tableView.present()
        case .closed:
            UIApplication.shared.setStatusBarStyle(SetRouteViewSettings.shared.prefferredStatusBarStyle, animated: true)
            self.routeView.hide(duration: 0.4) {
                routeAnimationEnded = true
                if destinyAnimationEnded {
                    self.isAnimating = false
                }
                self.imvPin.isHidden = true
            }
            self.destinyView.present(duration: 0.4) {
                destinyAnimationEnded = true
                if routeAnimationEnded {
                    self.isAnimating = false
                }
            }
            self.hideConfirm()
            self.tableView.hide()
        case .finished:
            UIApplication.shared.setStatusBarStyle(SetRouteViewSettings.shared.prefferredStatusBarStyle, animated: true)
            self.routeView.hide(duration: 0.4) {
                routeAnimationEnded = true
                if destinyAnimationEnded {
                    self.isAnimating = false
                }
                self.imvPin.isHidden = true
            }
            self.destinyView.hide(duration: 0.4) {
                destinyAnimationEnded = true
                if routeAnimationEnded {
                    self.isAnimating = false
                }
            }
            self.hideConfirm()
            self.tableView.hide()
            self.backButton?.isHidden = true
        }
    }
    
    func hideKeyboard() {
        self.routeView.hideKeyboard()
    }
    
    func setFirstResponder() {
        self.routeView.setFirstResponder()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self.dragView)
        self.point = position.y
    }
    
    @objc private func dragGesture(_ gesture: UIPanGestureRecognizer) {
        let gesturePosition = gesture.location(in: self.dragView).y
        guard self.dragView.isUserInteractionEnabled else { return }
        switch gesture.state {
        case .changed:
            self.routeView.btnBack.isEnabled = false
            self.tableView.updateTablePosition(gesturePosition - self.point)
        case .ended:
            self.tableView.handleGestureEnded(self.point, endY: gesture.location(in: self.dragView).y)
        case .cancelled, .failed:
            self.tableView.setMediumState()
        case .began:
            if gesture.velocity(in: self.dragView).y <= -400 {
                self.dragView.isUserInteractionEnabled = false
                self.tableView.present(duration: 0.4) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        self.dragView.isUserInteractionEnabled = true
                    })
                }
            }
        default:
            break
        }
    }
    
    @objc private func tapGesture(_ gesture: UITapGestureRecognizer) {
        self.dragView.isUserInteractionEnabled = false
        self.tableView.present(duration: 0.4) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.dragView.isUserInteractionEnabled = true
            })
        }
    }
    
    @objc private func confirmPressed(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.finishRouteSelection()
        DispatchQueue.main.async {
            sender.isUserInteractionEnabled = true
        }
    }
    
    func presentConfirm() {
        UIView.animate(withDuration: 0.15, animations: {
            self.btnConfirm.isHidden = false
            self.btnConfirm.transform = .identity
        }) { _ in
        }
    }
    
    func hideConfirm() {
        UIView.animate(withDuration: 0.15, animations: {
            self.btnConfirm.isHidden = true
        }) { _ in
            self.btnConfirm.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
    }
    
    public func setOrigin(viewModel: PlaceViewModel) {
        self.originPlace = viewModel
    }
}

extension MapView: GMSMapViewDelegate {
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        guard self.allowMapEvents else { return }
        self.getLoctionFromWillMove = true
        self.hideConfirm()
        if !self.routeView.isHidden {
            self.tableView.hide()
        }
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard self.allowMapEvents else { return }
        guard self.allowWillMove else { return }
        guard self.getLoctionFromWillMove else { return }
        self.getLoctionFromWillMove = false
        let isOrigin: Bool = self.routeView.isOrigin(self.routeView.lastFirstResponder)
        self.handleIdleAt(isOrigin, position: position)
    }
    
    func startProgress() {
        self.routeView.startProgress()
    }
    
    func stopProgress() {
        self.routeView.stopProgress()
    }
    
    func editStops(places: [String]){
        self.delegate?.shouldEditRoutePoints(self)
        let nextVC = MultiplesStopsViewController(superView: self)
        nextVC.isEditingStops = false
        nextVC.delegate = self
        nextVC.editStopBeforeTravelBegin = true
        self.controller.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func editStopsTwo(places: [Points], category: String){
        self.routeView.categoryForEdit = category
        let nextVC = MultiplesStopsViewController(superView: self)
        nextVC.isEditingStops = true
        nextVC.setEditPoints(places)
        nextVC.delegate = self
        self.isHidden = true
        self.controller.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func editStopsTwo(places: [Points]){
        let nextVC = MultiplesStopsViewController(superView: self)
        nextVC.isEditingStops = true
        nextVC.setEditPoints(places)
        nextVC.delegate = self
        self.controller.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

extension MapView: RouteViewDelegate {
    func removedTravelOptions() {
        self.delegate?.removedTravelOptions()
    }
    
    func finishEdit(editPoints countStops: Int, places: [Points], view: RouteView) {
        self.delegate?.finishedEditRoute(self, places: places, setRoute: { (route) in
            view.multiplesStopsViewController?.btnBackPressed() 
        })
    }
}


extension MapView: MultiplesStopsViewControllerDelegate{
    func editStopViewControllerDidCancel(_ viewController: MultiplesStopsViewController) {
        self.delegate?.mapViewDidCancelPointsEdit(self)
    }
    
    func editStopViewController(dismiss viewController: MultiplesStopsViewController) {
        
        self.backButton?.isHidden = true
        
        
        UIApplication.shared.setStatusBarStyle(SetRouteViewSettings.shared.prefferredStatusBarStyle, animated: true)
        self.routeView.hide(duration: 0.4) {
            self.imvPin.isHidden = true
        }
        self.destinyView.present(duration: 0.4) {
        }
        self.tableView.hide()
        self.routeView.hide()
        self.destinyView.present()
        
    }
    
    func editStopViewController(editStops countStops: Int, places: [Points]){
        self.endEditing(true)
        
        self.delegate?.editRouteWithStopsSet(self, places: places, setRoute: { (routes) in
            self.routeView.confirmEditPoins(places: places, imageCar: routes.imageCar, value: routes.value ?? 0.0, categoryCar: routes.categoryCar ?? "")
        })
    }
    
    func editStopViewController(callDriver countStops: Int, places: [Points]) {
        self.finishRouteSelectionWithStops(places: places)
    }
    
    func editStopViewController(_ viewController: EditStopViewController, didChange text: String) {
        self.delegate?.textDidChange(self, text: text, setPlaceList: { (placeList) in
            DispatchQueue.main.async { [weak viewController] in
                guard let viewController = viewController else { return }
                viewController.newView.stopProgress()
                viewController.newView.tableView?.setPlaces(placeList)
            }
        })
    }
    
    func editStopViewController(didLoad viewController: EditStopViewController) {
        self.delegate?.textDidChangeEmpty(self, setPlaceList: { (placeList) in
            DispatchQueue.main.async { [weak viewController] in
                guard let viewController = viewController else { return }
                viewController.newView.tableView?.setLastPlaces(placeList)
                viewController.newView.stopProgress()
            }
        })
    }
}
