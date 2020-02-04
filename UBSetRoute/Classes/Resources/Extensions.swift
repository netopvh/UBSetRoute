//
//  Extensions.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    public class func getFrom(nameResource: String, type: String) -> UIImage? {
        guard let bundle = Bundle.main.path(forResource: nameResource, ofType: type) else { return nil }
        let url = URL(fileURLWithPath: bundle)
        guard let data = try? Data(contentsOf: url) else { return nil }
        let image = UIImage(data: data)
        return image
    }
    
    public class func getFrom(customClass: AnyClass, nameResource: String) -> UIImage? {
        let frameworkBundle = Bundle(for: customClass)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("UBSetRoute.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let image = UIImage(named: nameResource, in: resourceBundle, compatibleWith: nil)
        return image
    }
}

extension UIView {
    
    func fillSuperview() {
        anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor)
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
            
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
            
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
            
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
            
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
    }
    
    func applyCircle() {
        self.setCorner(self.bounds.height/2)
    }
    
    func setCorner(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func applyLightShadowToCircle() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
    }
    
    func applyShadowToCircle() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
    }
    
    func removeShadow() {
        self.layer.shadowPath = nil
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
    }
    
    func setBottomShadow() {
        self.addshadow(top: false, left: false, bottom: true, right: false)
    }
    
    func addshadow(top: Bool,
                    left: Bool,
                    bottom: Bool,
                    right: Bool,
                    shadowRadius: CGFloat = 1.5) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.3
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    convenience init(string: String) {
        var chars = Array(string.hasPrefix("#") ? string.dropFirst() : Substring(string))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1
        switch chars.count {
        case 3:
            chars = [chars[0], chars[0], chars[1], chars[1], chars[2], chars[2]]
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            alpha = 0
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static let textFieldBackground = UIColor(string: "F4F0F0").withAlphaComponent(0.3)
    static let textFieldSelected = UIColor(string: "E5E5E5").withAlphaComponent(0.9)
    static let mainColor: UIColor = #colorLiteral(red: 0.08235294118, green: 0.4470588235, blue: 0.6196078431, alpha: 1)
    
}


extension UITextField {
    
    func setPlaceholderFont(_ text: String, _ font: UIFont, _ color: UIColor) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font
        ]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
    
}

extension UIDevice {
    
    static let isXFamily: Bool = {
        return UIScreen.main.bounds.size.height >= 895
    }()
    
}

extension Bundle {
    /// Create a new Bundle instance for 'Image.xcassets'.
    ///
    /// - Returns: a new bundle which contains 'Image.xcassets'.
    static func currentBundle() -> Bundle {
        let bundle = Bundle(for: MapView.self)
        if let path = bundle.path(forResource: "MapView", ofType: "bundle") {
            return Bundle(path: path)!
        } else {
            return bundle
        }
    }
}

public extension String {
    
    var abbreviateAddress: String {
        return self.replacingOccurrences(of: "Rua", with: "R.")
            .replacingOccurrences(of: "Street", with: "St.")
            .replacingOccurrences(of: "Avenida", with: "Av.")
            .replacingOccurrences(of: "Avenue", with: "Av.")
    }
    
}
