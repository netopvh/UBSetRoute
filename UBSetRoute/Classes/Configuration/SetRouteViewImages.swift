//
//  SetRouteViewImages.swift
//  UBSetRoute
//
//  Created by Usemobile on 28/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

public class SetRouteViewImages {
    
    public var mainPinIcon: UIImage?
    public var cellPinIcon: UIImage?
    public var backBtnIcon: UIImage?
    public var mapPinIcon: UIImage?
    public var currentLocationIcon: UIImage?
    
    public var routeOrigin: UIImage?
    public var routeOriginVisited: UIImage?
    public var routeDots: UIImage?
    public var routeDestiny: UIImage?
    public var routeSwap: UIImage?
    
    public var stopsClock: UIImage?
    
    public static var `default`: SetRouteViewImages {
        return SetRouteViewImages(mainPinIcon: nil,
                                  cellPinIcon: nil,
                                  backBtnIcon: nil,
                                  mapPinIcon: nil,
                                  currentLocationIcon: nil,
                                  routeOrigin: nil,
                                  routeOriginVisited: nil,
                                  routeDots: nil,
                                  routeDestiny: nil,
                                  stopsClock: nil,
                                  routeSwap: nil)
    }
    
    public init(mainPinIcon: UIImage?,
                cellPinIcon: UIImage?,
                backBtnIcon: UIImage?,
                mapPinIcon: UIImage?,
                currentLocationIcon: UIImage?,
                routeOrigin: UIImage?,
                routeOriginVisited: UIImage?,
                routeDots: UIImage?,
                routeDestiny: UIImage?,
                stopsClock: UIImage?,
                routeSwap: UIImage?) {
        self.mainPinIcon = mainPinIcon
        self.cellPinIcon = cellPinIcon
        self.backBtnIcon = backBtnIcon
        self.mapPinIcon = mapPinIcon
        self.currentLocationIcon = currentLocationIcon
        self.routeOrigin = routeOrigin
        self.routeOriginVisited = routeOriginVisited
        self.routeDots = routeDots
        self.routeDestiny = routeDestiny
        self.routeSwap = routeSwap
        self.stopsClock = stopsClock
    }
    
}
