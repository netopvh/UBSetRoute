//
//  LocationButton.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

class LocationButton: UIView {
    
    // MARK: UI Components
    
    private var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = SetRouteViewSettings.shared.images.currentLocationIcon ?? UIImage.getFrom(customClass: LocationButton.self, nameResource: "target")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(self.btnPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Properties
    
    var action: (() -> Void)?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        self.applyLightShadowToCircle()
        self.addSubview(self.button)
        self.button.fillSuperview()
        self.button.backgroundColor = UIColor(string: "FEFFFA")
        DispatchQueue.main.async {
            self.button.applyCircle()
        }
    }
    
    @objc private func btnPressed(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.action?()
        DispatchQueue.main.async {
            sender.isUserInteractionEnabled = true
        }
    }
    
}



public struct ImagesHelper {
    private static var podsBundle: Bundle? {
        let bundle = Bundle(for: LocationButton.self)
        if let url = bundle.url(forResource: "LocationButton",
                                withExtension: "bundle") {
            
            return Bundle(url: url)
        }
        return nil
    }
    
    private static func imageFor(name imageName: String) -> UIImage? {
        if let bundle = podsBundle {
            return UIImage.init(named: imageName, in: bundle, compatibleWith: nil)
        }
        return nil
    }
    
    public static var myImage: UIImage? {
        return imageFor(name: "target")
    }
}
