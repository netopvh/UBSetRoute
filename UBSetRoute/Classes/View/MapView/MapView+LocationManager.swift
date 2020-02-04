//
//  MapView+LocationManager.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MapViewLocationManager: NSObject, CLLocationManagerDelegate {
    
    typealias UpdatedLocation = ((CLLocation) -> Void)
    var didUpdateLocation: UpdatedLocation?
    let locationManager = CLLocationManager()
    
    required override init() {
        super.init()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
    }
    
    func updateLocation() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.didUpdateLocation?(location)
        //        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse)  {
            self.startUpdatingLocation()
        }
    }
    
    
}
