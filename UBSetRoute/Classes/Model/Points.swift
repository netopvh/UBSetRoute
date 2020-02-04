//
//  Points.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 02/01/20.
//

import Foundation

enum EditTableViewCellType{
    case stop
    case buttons
}

protocol EditRouteTableViewCell{
    var cellType: EditTableViewCellType{get}
}

public class Points: NSObject, EditRouteTableViewCell{
    var cellType: EditTableViewCellType{
        return .stop
    }
    
    public var visited: Bool?
    public var address: Address?
    public var type: String?
    
    public init(visited: Bool, address: Address, type: String) {
        self.visited = visited
        self.address = address
        self.type = type
    }
}

public class Address: NSObject{
    public var placeId: String?
    public var city: String?
    public var neighborhood: String?
    public var number: String?
    public var state: String?
    public var zip: String?
    public var text: String?
    public var location: Location?
    
    
    public init(placeId: String, city: String = "", neighborhood: String = "", state: String = "", zip: String = "",text: String, location: Location?, number: String? = "") {
        self.placeId = placeId
        self.city = city
        self.neighborhood = neighborhood
        self.state = state
        self.zip = zip
        self.text = text
        self.location = location
        self.number = number
    }
}

public class Location: NSObject{
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}

public class ButtonsCell: EditRouteTableViewCell{
    var cellType: EditTableViewCellType{
        return .buttons
    }
    
    
}
