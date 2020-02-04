//
//  SetRouteViewFonts.swift
//  UBSetRoute
//
//  Created by Usemobile on 28/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

public class SetRouteViewFonts {
    
    // Route View
    public var originTxfText: UIFont
    public var destinyTxfText: UIFont
    public var originTxfPlaceholder: UIFont
    public var destinyTxfPlaceholder: UIFont
    
    // Places Cell
    public var placeTitle: UIFont
    public var placeSubTitle: UIFont
    
    // General
    public var readyButton: UIFont
    public var addressCell: UIFont
    public var lastPlaces: UIFont
    public var stopViewButtons: UIFont
    public var stopTitle: UIFont
    public var stopText: UIFont
    
    public static var `default`: SetRouteViewFonts {
        return SetRouteViewFonts(originTxfText: UIFont.systemFont(ofSize: 18),
                                 destinyTxfText: UIFont.systemFont(ofSize: 18),
                                 originTxfPlaceholder: UIFont.systemFont(ofSize: 18),
                                 destinyTxfPlaceholder: UIFont.systemFont(ofSize: 18),
                                 placeTitle: UIFont.systemFont(ofSize: 18),
                                 placeSubTitle: UIFont.systemFont(ofSize: 14),
                                 readyButton: UIFont.systemFont(ofSize: 18),
                                 addressCell: UIFont.systemFont(ofSize: 10, weight: .semibold),
                                 lastPlaces: UIFont.systemFont(ofSize: 14, weight: .regular),
                                 stopViewButtons: UIFont.systemFont(ofSize: 20, weight: .bold),
                                 stopTitle: UIFont.systemFont(ofSize: 16, weight: .bold),
                                 stopText: UIFont.systemFont(ofSize: 14, weight: .regular))
    }
    
    public init(originTxfText: UIFont,
                destinyTxfText: UIFont,
                originTxfPlaceholder: UIFont,
                destinyTxfPlaceholder: UIFont,
                placeTitle: UIFont,
                placeSubTitle: UIFont,
                readyButton: UIFont,
                addressCell: UIFont,
                lastPlaces: UIFont,
                stopViewButtons: UIFont,
                stopTitle: UIFont,
                stopText: UIFont) {
        self.originTxfText = originTxfText
        self.destinyTxfText = destinyTxfText
        self.originTxfPlaceholder = originTxfPlaceholder
        self.destinyTxfPlaceholder = destinyTxfPlaceholder
        self.placeTitle = placeTitle
        self.placeSubTitle = placeSubTitle
        self.readyButton = readyButton
        self.addressCell = addressCell
        self.lastPlaces = lastPlaces
        self.stopViewButtons = stopViewButtons
        self.stopTitle = stopTitle
        self.stopText = stopText
    }
    
}
