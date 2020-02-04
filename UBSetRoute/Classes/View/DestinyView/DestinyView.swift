//
//  DestinView.swift
//  UBSetRoute
//
//  Created by Usemobile on 22/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import Foundation
import UIKit

class DestinyView: UIView {
    
    // MARK: UI Components
    
    private var viewCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        let image = SetRouteViewSettings.shared.images.mainPinIcon ?? UIImage.getFrom(customClass: DestinyView.self, nameResource: "pin")
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(string: "b9b9b9")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var lblDestiny: UILabel = {
        let label = UILabel()
        label.text = self.destiny
        label.font = SetRouteViewSettings.shared.fonts.destinyTxfText
        label.textColor = SetRouteViewSettings.shared.colors.destinyTxfTextColor
        label.textAlignment = .left
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.7
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.lblTapped(_:))))
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var lblNumberStops: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = SetRouteViewSettings.shared.fonts.destinyTxfText
        label.textColor = SetRouteViewSettings.shared.colors.mainColor
        return label
    }()
    
    // MARK: Properties
    
    var destiny: String = .whereTo {
        didSet {
            self.lblDestiny.text = self.destiny
        }
    }
    
    private var superView: UIView!
    
    private var cnstTopAnchor = NSLayoutConstraint()
    
    var viewTapped: ((String) -> Void)?
    var viewTappedStop: ((String) -> Void)?
    
    var hasStops: Bool = false
    
    // MARK: Init
    
    required init(superView: UIView, hasStops: Bool) {
        super.init(frame: .zero)
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.superView = superView
        self.hasStops = hasStops
        self.setup()
        DispatchQueue.main.async {
            self.applyShadowToCircle()
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        self.superView.addSubview(self)
        self.setupConstraints()
        self.setupViewCircle()
        self.setupImageView()
        self.setupLblDestiny()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        //            self.present()
        //        }
    }
    
    private func initialState() {
        let topConstant: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        self.cnstTopAnchor.constant = topConstant
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.isHidden = true
        self.superView.layoutIfNeeded()
    }
    
    fileprivate func setupConstraints() {
        let spacing: CGFloat = 16
        let topPadding: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        self.cnstTopAnchor = self.topAnchor.constraint(equalTo: self.superView.topAnchor, constant: topPadding)
        self.cnstTopAnchor.isActive = true
        self.anchor(top: nil, left: self.superView.leftAnchor, bottom: nil, right: self.superView.rightAnchor, padding: .init(top: 0, left: spacing, bottom: 0, right: spacing), size: .init(width: 0, height: 50))
    }
    
    fileprivate func setupViewCircle() {
        self.addSubview(self.viewCircle)
        self.viewCircle.fillSuperview()
        self.viewCircle.setCorner(25)
    }
    
    fileprivate func setupImageView() {
        self.viewCircle.addSubview(self.imageView)
        self.imageView.anchor(top: nil, left: self.viewCircle.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 18, bottom: 0, right: 0), size: .init(width: 16, height: 20))
        self.imageView.centerYAnchor.constraint(equalTo: self.viewCircle.centerYAnchor).isActive = true
    }
    
    fileprivate func setupLblDestiny() {
        self.viewCircle.addSubview(self.lblDestiny)
        self.viewCircle.addSubview(self.lblNumberStops)
        
        if !hasStops{
            self.lblDestiny.anchor(top: self.viewCircle.topAnchor, left: self.imageView.rightAnchor, bottom: self.viewCircle.bottomAnchor, right: self.viewCircle.rightAnchor, padding: .init(top: 0, left: 18, bottom: 0, right: 18), size: .zero)
            self.lblNumberStops.isHidden = true
        }else{
            self.lblDestiny.anchor(top: self.viewCircle.topAnchor, left: self.imageView.rightAnchor, bottom: self.viewCircle.bottomAnchor, right: self.viewCircle.rightAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 34), size: .zero)
            self.lblNumberStops.anchor(top: self.topAnchor, left: self.lblDestiny.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
        }
        
    }
    
    func present(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            let topConstant = navBarSize + 16 - SetRouteViewSettings.shared.statusBarSizeAdjust
            self.cnstTopAnchor.constant = topConstant
            self.transform = .identity
            self.isHidden = false
            self.superView.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
    func hide(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.initialState()
            completion?()
        }
        
    }
    
    @objc private func lblTapped(_ tapGesture: UITapGestureRecognizer) {
        tapGesture.isEnabled = false
        
        if self.hasStops {
            if self.lblDestiny.text != .whereTo && self.lblNumberStops.text != "" {
                self.viewTappedStop?(self.lblDestiny.text ?? "")
            }else{
                self.viewTapped?(self.lblDestiny.text ?? "")
            }
        }else{
            self.viewTapped?(self.lblDestiny.text ?? "")
        }
        
        DispatchQueue.main.async {
            tapGesture.isEnabled = true
        }
    }
}
