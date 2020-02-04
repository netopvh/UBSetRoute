//
//  UBMapViewController.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit
import UBSetRoute
import GoogleMaps

class UBMapViewController: UIViewController {
    
    var mockPoints: [Points] = [Points(visited: true, address: Address(placeId: "", city: "Ouro Preto", neighborhood: "Bauxita", state: "MG", zip: "35400-000", text: "Rua Professor Francisco Pignataro", location: Location(latitude: 0.0, longitude: 0.0), number: "151"), type: "origin"),
                                Points(visited: false, address: Address(placeId: "", city: "Ouro Preto", neighborhood: "Bauxita", state: "MG", zip: "35400-000", text: "Rua Manoel Francisco Gomes", location: Location(latitude: 0.0, longitude: 0.0), number: "15"), type: "point"),
                                Points(visited: false, address: Address(placeId: "", city: "Ouro Preto", neighborhood: "Bauxita", state: "MG", zip: "35400-000", text: "Rua Jose Moringa", location: Location(latitude: 0.0, longitude: 0.0), number: "2"), type: "destiny")]
    
    
    private lazy var mapView: MapView = {
        let config = SetRouteViewConfiguration.default
        config.colors.mainColor = .purple
        config.hasMultipleStops = true
        config.isEditingStops = false
        config.language = .es
        let mapView = MapView(controller: self, config: config)
        if config.isEditingStops ?? false{
            for i in 0..<self.mockPoints.count{

                mapView.setPoints(visited: self.mockPoints[i].visited ?? false,
                                       city: self.mockPoints[i].address?.city ?? "",
                                       neighborhood: self.mockPoints[i].address?.neighborhood ?? "",
                                       state: self.mockPoints[i].address?.state ?? "",
                                       zip: self.mockPoints[i].address?.zip ?? "",
                                       text: "ENDERECO" ,
                                       lat: self.mockPoints[i].address?.location?.latitude ?? 0.0,
                                       long: self.mockPoints[i].address?.location?.longitude ?? 0.0,
                                       type: self.mockPoints[i].type ?? "",
                                       number: self.mockPoints[i].address?.number ?? "")
                
                
            }
            mapView.editStopsFlow("Comum")
        }
        mapView.delegate = self
        return mapView
    }()
    
    var count = 0
    
    var button = UIButton()
    
    override func loadView() {
        self.view = self.mapView
        
        let width = UIScreen.main.bounds.width * 0.8
        let x = UIScreen.main.bounds.width * 0.1
        let y = UIScreen.main.bounds.height - 66 - 64
        self.button.frame = CGRect(x: x, y: y, width: width, height: 50)
        self.button.addTarget(self, action: #selector(self.bPressed), for: .touchUpInside)
        self.button.isHidden = true
        self.button.backgroundColor = .black
        self.button.setTitle("Pedir Corrida", for: .normal)
        self.button.setTitleColor(.white, for: .normal)
        self.view.addSubview(self.button)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 ) {
            self.mapView.present()
        }
        
    }
    
    @objc func bPressed() {
        self.mapView.reset()
        self.button.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Solicitação"
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .red
    }
    
    func getRouteWithStops(places: [Points], setRoute: @escaping(RouteViewModelStops) -> Void){
        
        let originCoord = CLLocationCoordinate2D(latitude: -20.400559697586537, longitude: -43.511084626138135)
        let destinyCoord = CLLocationCoordinate2D(latitude: -20.40080090473393, longitude: -43.509652353823185)
                
        let _polyline = "zmo{BjfqhG}@r@q@t@gA_AIQZe@z@{@p@e@nBeAb@S"
        
        var markers: [USE_Marker] = []
        var _polylines : [String] = []
        
        for i in 0...places.count{
            if i == 0{
                let marker = USE_Marker(coordinates: destinyCoord, type: .user, icon: UIImage(named: "pin-user"))
                markers.append(marker)
            }else{
                let marker = USE_Marker(coordinates: destinyCoord, type: .flag, icon: UIImage(named: "pin-flag"))
                markers.append(marker)
            }
            _polylines.append(_polyline)
        }
        
        let routeModel = RouteViewModelStops(polylinePoints: [_polyline], markers: markers, distance: 2.3, time: 5.21, value: 32.75, image: UIImageView(image: UIImage(named: "ride-vip")), categoryCar: "VIP")
        setRoute(routeModel)
    }
    
    
    func test() -> RouteViewModel {
        let originCoord = CLLocationCoordinate2D(latitude: -20.400559697586537, longitude: -43.511084626138135)
        let destinyCoord = CLLocationCoordinate2D(latitude: -20.40080090473393, longitude: -43.509652353823185)
        let originMarker = USE_Marker(coordinates: originCoord, type: .user, icon: UIImage(named: "pin-user"))
        let destinyMarker = USE_Marker(coordinates: destinyCoord, type: .flag, icon: UIImage(named: "pin-flag"))
        
        let routeViewModel = RouteViewModel(polylinePoints: "zmo{BjfqhG}@r@q@t@gA_AIQZe@z@{@p@e@nBeAb@S", originMarker: originMarker, destinyMarker: destinyMarker)
//        self.mapView.drawRoute(onMap: routeViewModel)
        return routeViewModel
    }
    
    func testStops(countStops: Int) -> RouteViewModelStops {
            let originCoord = CLLocationCoordinate2D(latitude: -20.400559697586537, longitude: -43.511084626138135)
            let destinyCoord = CLLocationCoordinate2D(latitude: -20.40080090473393, longitude: -43.509652353823185)
//            let originMarker = USE_Marker(coordinates: originCoord, type: .user, icon: UIImage(named: "pin-user"))
//            let destinyMarker = USE_Marker(coordinates: destinyCoord, type: .flag, icon: UIImage(named: "pin-flag"))
        
        let _polyline = "zmo{BjfqhG}@r@q@t@gA_AIQZe@z@{@p@e@nBeAb@S"
        
        var markers: [USE_Marker] = []
        var _polylines : [String] = []
        
        for i in 0...countStops{
            
            if i == 0{
                let marker = USE_Marker(coordinates: destinyCoord, type: .user, icon: UIImage(named: "pin-user"))
                markers.append(marker)
            }else{
                let marker = USE_Marker(coordinates: destinyCoord, type: .flag, icon: UIImage(named: "pin-flag"))
                markers.append(marker)
            }
            _polylines.append(_polyline)
        }
        
        let routeViewModelStops = RouteViewModelStops(polylinePoints: _polylines, markers: markers)
        
        return routeViewModelStops
    }
    
}

extension UBMapViewController: MapViewDelegate {
    func editRouteWithStopsSet(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void) {
        self.getRouteWithStops(places: places, setRoute: setRoute)
    }
    
    func finishedEditRoute(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void) {
        
        let originCoord = CLLocationCoordinate2D(latitude: -20.400559697586537, longitude: -43.511084626138135)
        let destinyCoord = CLLocationCoordinate2D(latitude: -20.40080090473393, longitude: -43.509652353823185)
                
        let _polyline = "zmo{BjfqhG}@r@q@t@gA_AIQZe@z@{@p@e@nBeAb@S"
        
        var markers: [USE_Marker] = []
        var _polylines : [String] = []
        
        for i in 0...places.count{
            if i == 0{
                let marker = USE_Marker(coordinates: destinyCoord, type: .user, icon: UIImage(named: "pin-user"))
                markers.append(marker)
            }else{
                let marker = USE_Marker(coordinates: destinyCoord, type: .flag, icon: UIImage(named: "pin-flag"))
                markers.append(marker)
            }
            _polylines.append(_polyline)
        }
        
        let routeModel = RouteViewModelStops(polylinePoints: [_polyline], markers: markers, distance: 2.3, time: 5.21, value: 32.75, image: UIImageView(image: UIImage(named: "ride-vip")), categoryCar: "VIP")
        
        setRoute(routeModel)
    }
    
    func removedTravelOptions() {
        //
    }
    
    func editStops(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void) {
        print("Editando")
    }
    
    func finishedRouteWithStopsSet(_ mapView: MapView, places: [Points], setRoute: @escaping (RouteViewModelStops) -> Void) {
//        let message = "Origem:\n" + (places.first.address?.text) + "\n\nDestino:\n" + (places.last.address?.text)
        
        
        let message = "Origem:\n \(String(describing: places.first?.address?.text)) + \n\nDestino:\n + \(String(describing: places.last?.address?.text))"
        
        self.showAlertCommon(title: "Seleção finalizada", message: message, handler: { _ in
            self.count = 0
            //            self.test()
            setRoute(self.testStops(countStops: places.count))
            self.button.isHidden = false
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            //                self.mapView.present()
            //            })
        })
    }
    

    func mapView(_ mapView: MapView, didSelectSmallRouteFor completion: @escaping (Bool) -> Void) {
        self.showAlertDoubleButton(title: "", message: "Os endereços de origem e destino informados são próximos.\nDeseja realizar o pedido da corrida?", btnLTitle: "Não", btnRTitle: "Sim", btnLAction: { _ in
            completion(false)
        }) { _ in
            completion(true)
        }
    }
    
    func textDidChangeEmpty(_ mapView: MapView, setPlaceList: @escaping (([PlaceViewModel]) -> Void)) {
        let places: [PlaceViewModel] = [PlaceViewModel(objectId: "", mainText: "Local 1", secondaryText: "Endereço 1"),
                                        PlaceViewModel(objectId: "", mainText: "Local 2", secondaryText: "Endereço 2"),
                                        PlaceViewModel(objectId: "", mainText: "Local 3", secondaryText: "Endereço 3")]
        setPlaceList(places)
    }
    
    func mapView(_ mapView: MapView, currentLocationUpdatedFor location: CLLocation, didGetPlace: @escaping (PlaceViewModel) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarkArr, error) in
            if let _error = error {
                self.showAlertCommon(title: "Ops!", message: _error.localizedDescription, handler: nil)
            } else if let _placemarkArr = placemarkArr {
                if !_placemarkArr.isEmpty, let first = _placemarkArr.first {
                    print(first.description)
                    let placeViewModel = PlaceViewModel(placeMark: first, location: location)
                    didGetPlace(placeViewModel)
                } else {
                    self.showAlertCommon(title: "Ops!", message: "Não há endereços correspondentes as coordenadas informadas", handler: nil)
                }
            } else {
                self.showAlertCommon(title: "Ops!", message: "Ocorreu um erro desconhecido", handler: nil)
            }
        }
    }
    
    func idleAt(_ mapView: MapView, position: GMSCameraPosition, setText: @escaping (PlaceViewModel) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let model = PlaceViewModel(objectId: "X", mainText: "Origem X", secondaryText: "Bairro X")
            setText(model)
        })
    }
    
    func idleAtDestiny(_ mapView: MapView, position: GMSCameraPosition, setText: @escaping (PlaceViewModel) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let model = PlaceViewModel(objectId: "Y", mainText: "Destino Y", secondaryText: "Bairro Y")
            setText(model)
        })
    }
    
    func finishedRouteSet(_ mapView: MapView, placeOrigin: PlaceViewModel, destinyPlace: PlaceViewModel, setRoute: @escaping (RouteViewModel) -> Void) {
        let message = "Origem:\n" + placeOrigin.description + "\n\nDestino:\n" + destinyPlace.description
        self.showAlertCommon(title: "Seleção finalizada", message: message, handler: { _ in
            self.count = 0
            //            self.test()
            setRoute(self.test())
            self.button.isHidden = false
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            //                self.mapView.present()
            //            })
        })
    }
    
    func textDidChange(_ mapView: MapView, text: String, setPlaceList: @escaping (([PlaceViewModel]) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            let multiplier = self.count * 5
            setPlaceList([
                PlaceViewModel(objectId: "\(multiplier+1)", mainText: "Endereço \(multiplier+1)", secondaryText: "Bairro \(multiplier+1)"),
                PlaceViewModel(objectId: "\(multiplier+2)", mainText: "Endereço \(multiplier+2)", secondaryText: "Bairro \(multiplier+2)"),
                PlaceViewModel(objectId: "\(multiplier+3)", mainText: "Endereço \(multiplier+3)", secondaryText: "Bairro \(multiplier+3)"),
                PlaceViewModel(objectId: "\(multiplier+4)", mainText: "Endereço \(multiplier+4)", secondaryText: "Bairro \(multiplier+4)"),
                PlaceViewModel(objectId: "\(multiplier+5)", mainText: "Endereço \(multiplier+5)", secondaryText: "Bairro \(multiplier+5)")
                ])
            self.count += 1
        })
    }
    
    func didSelectPlaceModel(_ mapView: MapView, model: PlaceViewModel) {
        print(model.mainText)
    }
    
    func shouldEditRoute(_ mapView: MapView) {
        self.button.isHidden = true
    }
    
    func cancelRouteEdit(_ mapView: MapView) {
        self.button.isHidden = false
    }
    
    func shouldReset(_ mapView: MapView) {
        
    }
    
    func shouldReset() {
        
    }
    
    func shouldEditRoutePoints(_ mapView: MapView) {
    }
    
    func mapViewDidCancelPointsEdit(_ mapView: MapView) {
    }
    
}


extension UIViewController {
    func showAlertCommon(title: String, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnOk = UIAlertAction(title: "Ok", style: .default, handler: handler)
        alert.addAction(btnOk)
        OperationQueue.main.addOperation {
            self.view.endEditing(true)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertDoubleButton(title: String, message: String?, btnLTitle: String, btnRTitle: String, btnLAction: ((UIAlertAction) -> Void)?, btnRAction: ((UIAlertAction) -> Void)?) {
        let alert       = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let btnLeft     = UIAlertAction(title: btnLTitle, style: .cancel, handler: btnLAction)
        let btnRight    = UIAlertAction(title: btnRTitle, style: .default, handler: btnRAction)
        alert.addAction(btnLeft)
        alert.addAction(btnRight)
        self.present(alert, animated: true, completion: nil)
    }
}

extension PlaceViewModel {
    
    convenience init(placeMark: CLPlacemark, location: CLLocation) {
        self.init(coordinates: location.coordinate)
        let street = placeMark.addressDictionary?["Street"] as? String ?? ""
        let number = placeMark.addressDictionary?["SubThoroughfare"] as? String ?? ""
        let address = (placeMark.addressDictionary?["Thoroughfare"] as? String ?? "").replacingOccurrences(of: "Rua", with: "R.").replacingOccurrences(of: "Street", with: "St.")
        let neighborhood = placeMark.addressDictionary?["SubLocality"] as? String ?? ""
        let city = placeMark.addressDictionary?["City"] as? String ?? ""
        
        let mainText = street.isEmpty ? (number.isEmpty ? address : address + ", " + number) : street
        let secondaryText = neighborhood.isEmpty ? city : (city.isEmpty ? neighborhood : (neighborhood + " - " + city))
        self.mainText = mainText
        self.secondaryText = secondaryText
        self.json = placeMark.getJSON(location: location)
    }
    
}


extension CLPlacemark {
    
    func getJSON(location: CLLocation) -> [String: Any] {
        var json = [String: String]()
        
        let address          = (self.addressDictionary?["Thoroughfare"] as? String)?.replacingOccurrences(of: "Rua", with: "R.").replacingOccurrences(of: "Street", with: "St")
        let number          = self.addressDictionary?["SubThoroughfare"] as? String
        let neighborhood    = self.addressDictionary?["SubLocality"] as? String
        let zip             = self.addressDictionary?["ZIP"] as? String
        let city            = self.addressDictionary?["City"] as? String
        let state           = self.addressDictionary?["State"] as? String
        
        if address != nil { json["address"] = address }
        if number != nil { json["number"] = number }
        if neighborhood != nil { json["neighborhood"] = neighborhood }
        if zip != nil { json["zip"] = zip?.westernArabicNumeralsOnly }
        if city != nil { json["city"] = city }
        if state != nil { json["state"] = state }
        
        json["latitude"] = String(describing: location.coordinate.latitude)
        json["longitude"] = String(describing: location.coordinate.longitude)
        
        return json
    }
    
}

extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .compactMap { pattern ~= $0 ? Character($0) : nil })
    }
}
