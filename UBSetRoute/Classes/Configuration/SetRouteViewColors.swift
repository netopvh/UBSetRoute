//
//  SetRouteViewColors.swift
//  UBSetRoute
//
//  Created by Usemobile on 28/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

public class SetRouteViewColors {
    
    // TextFields
    public var originTxfTextColor: UIColor
    public var originTxfPlaceHolderColor: UIColor
    public var destinyTxfTextColor: UIColor
    public var destinyTxfPlaceHolderColor: UIColor
    public var txfSelectedColor: UIColor
    public var txfUnselectedColor: UIColor
    
    // Labels
    public var placeTitleTextColor: UIColor
    public var placeSubTitleTextColor: UIColor
    public var lastPlacesTextColor: UIColor
    
    // Images
    public var mainPinTintColor: UIColor
    public var cellPinTintColor: UIColor
    
    // Buttons
    public var readyButtonTextColor: UIColor
    public var readyButtonBackgroundColor: UIColor
    public var mapViewBackButton: UIColor
    
    // General
    public var mainColor: UIColor
    
    public static var `default`: SetRouteViewColors {
        return SetRouteViewColors(originTxfTextColor: .mainColor,
                                  originTxfPlaceHolderColor: .gray,
                                  destinyTxfTextColor: .black,
                                  destinyTxfPlaceHolderColor: .gray,
                                  txfSelectedColor: .textFieldSelected,
                                  txfUnselectedColor: .textFieldBackground,
                                  placeTitleTextColor: .black,
                                  lastPlacesTextColor: #colorLiteral(red: 0.5882352941, green: 0.5882352941, blue: 0.5882352941, alpha: 1),
                                  placeSubTitleTextColor: UIColor(string: "cccccc"),
                                  mainPinTintColor: UIColor(string: "b9b9b9"),
                                  cellPinTintColor: UIColor(string: "b9b9b9"),
                                  readyButtonTextColor: .white,
                                  readyButtonBackgroundColor: .black,
                                  mapViewBackButton: .white,
                                  mainColor: .mainColor)
    }
    
    public init(originTxfTextColor: UIColor,
                originTxfPlaceHolderColor: UIColor,
                destinyTxfTextColor: UIColor,
                destinyTxfPlaceHolderColor: UIColor,
                txfSelectedColor: UIColor,
                txfUnselectedColor: UIColor,
                placeTitleTextColor: UIColor,
                lastPlacesTextColor: UIColor,
                placeSubTitleTextColor: UIColor,
                mainPinTintColor: UIColor,
                cellPinTintColor: UIColor,
                readyButtonTextColor: UIColor,
                readyButtonBackgroundColor: UIColor,
                mapViewBackButton: UIColor,
                mainColor: UIColor) {
        self.originTxfTextColor = originTxfTextColor
        self.originTxfPlaceHolderColor = originTxfPlaceHolderColor
        self.destinyTxfTextColor = destinyTxfTextColor
        self.destinyTxfPlaceHolderColor = destinyTxfPlaceHolderColor
        self.txfSelectedColor = txfSelectedColor
        self.txfUnselectedColor = txfUnselectedColor
        
        self.placeTitleTextColor = placeTitleTextColor
        self.placeSubTitleTextColor = placeSubTitleTextColor
        self.lastPlacesTextColor = lastPlacesTextColor
        
        self.mainPinTintColor = mainPinTintColor
        self.cellPinTintColor = cellPinTintColor
        
        self.readyButtonTextColor = readyButtonTextColor
        self.readyButtonBackgroundColor = readyButtonBackgroundColor
        self.mapViewBackButton = mapViewBackButton
        
        self.mainColor = mainColor
    }
    
}
