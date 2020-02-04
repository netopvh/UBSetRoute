//
//  Settings.swift
//  UBSetRoute
//
//  Created by Usemobile on 25/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import Foundation
import UIKit

public enum SetRouteLanguage: String {
    case en = "en-US"
    case pt = "pt-BR"
    case es = "es-BO"
}

var currentLanguage: SetRouteLanguage = .pt

public final class SetRouteViewSettings: NSObject {
    
    private override init() {}
    
    static let shared = SetRouteViewSettings()
    
    public var routeViewHeight: CGFloat = 72
    
    public var colors: SetRouteViewColors = .default
    public var fonts: SetRouteViewFonts = .default
    public var images: SetRouteViewImages = .default
    public var mapStyle: String? = nil
    public var prefferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    public var statusBarSizeAdjust: CGFloat {
        get {
            if #available(iOS 11, *) {
                return 2 * (UIApplication.shared.keyWindow?.subviews.first?.frame.origin.y ?? 0)
            } else {
                return 0
            }
        }
    }
    
    public var config: SetRouteViewConfiguration = .default {
        didSet {
            self.colors = self.config.colors
            self.fonts  = self.config.fonts
            self.images = self.config.images
            self.mapStyle = self.config.mapStyle
            self.prefferredStatusBarStyle = self.config.prefferredStatusBarStyle
        }
    }
}

public class SetRouteViewConfiguration {
    
    public var language: SetRouteLanguage = .pt {
        didSet {
            currentLanguage = language
        }
    }
    
    public var hasMultipleStops: Bool?
    public var isEditingStops: Bool?
    public var colors: SetRouteViewColors
    public var fonts: SetRouteViewFonts
    public var images: SetRouteViewImages
    public var mapStyle: String?
    public var prefferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    public static var `default`: SetRouteViewConfiguration {
        return SetRouteViewConfiguration(colors: .default,
                                         fonts: .default,
                                         images: .default)
    }
    
    public init(colors: SetRouteViewColors,
                fonts: SetRouteViewFonts,
                images: SetRouteViewImages,
                mapStyle: String? = nil) {
        self.colors = colors
        self.fonts = fonts
        self.images = images
        self.mapStyle = mapStyle
    }
    
}
