//
//  RouteViewModel.swift
//  Pods-UBSetRoute_Example
//
//  Created by Usemobile on 31/01/19.
//

import Foundation
import CoreLocation
import UIKit

public class RouteViewModel: NSObject {
    
    var polylinePoints: String
    var originMarker: USE_Marker
    var destinyMarker: USE_Marker
    
    public init(polylinePoints: String, originMarker: USE_Marker, destinyMarker: USE_Marker) {
        self.polylinePoints = polylinePoints
        self.originMarker = originMarker
        self.destinyMarker = destinyMarker
        super.init()
    }
    
}

public class RouteViewModelStops: NSObject {
    
    var polylinePoints: [String]
    var markers: [USE_Marker]
    var distance: Double?
    var time: Double?
    var value: Double?
    var imageCar: UIImageView?
    var categoryCar: String?
    
    public init(polylinePoints: [String], markers: [USE_Marker], distance: Double = 0.0, time: Double = 0.0, value: Double = 0.0, image: UIImageView = UIImageView(), categoryCar: String = "") {
        self.polylinePoints = polylinePoints
        self.markers = markers
        self.distance = distance
        self.time = time
        self.value = value
        self.imageCar = image
        self.categoryCar = categoryCar
        super.init()
    }
    
}

public class USE_Marker: NSObject {
    var coordinates: CLLocationCoordinate2D
    var type: Marker_Types
    
    var icon: UIImage?
    
    public required init(coordinates: CLLocationCoordinate2D, type: Marker_Types, icon: UIImage? = nil) {
        self.coordinates = coordinates
        self.type = type
        self.icon = icon ?? UIImage(named: "pin-" + type.rawValue)
        super.init()
    }
}

public enum Marker_Types: String {
    case user
    case car
    case flag
}
