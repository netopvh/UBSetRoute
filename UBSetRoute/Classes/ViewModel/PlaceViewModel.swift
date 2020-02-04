//
//  PlaceModel.swift
//  UBSetRoute
//
//  Created by Usemobile on 22/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import Foundation
import CoreLocation

public class PlaceViewModel: NSObject {
    
    public enum Types {
        case address
        case selectAtMap
        case getCurrentLocation
    }
    
    public var type: Types
    
    public let objectId: String
    public var mainText: String
    public var secondaryText: String
    
    public var coordinates: CLLocationCoordinate2D?
    
    public var json: [String: Any]?
    
    public override var description: String {
        return """
        ObjectId: \(objectId)
        Main Text: \(mainText)
        Secondary Text: \(secondaryText)
        Coordinates: \(coordinates)
        JSON: \(json)
        """
    }
    
    public init(objectId: String = "", mainText: String = "", secondaryText: String = "", type: Types = .address) {
        self.type = type
        self.objectId = objectId
        switch type {
        case .address:
            self.mainText = mainText.abbreviateAddress
        case .selectAtMap:
            self.mainText = .selectAtMap
        case .getCurrentLocation:
            self.mainText = .currentLocation
        }
        self.secondaryText = secondaryText.abbreviateAddress
        super.init()
    }
    
    public convenience init(coordinates: CLLocationCoordinate2D?) {
        self.init(objectId: "", mainText: "", secondaryText: "")
        self.coordinates = coordinates
    }
    
}
