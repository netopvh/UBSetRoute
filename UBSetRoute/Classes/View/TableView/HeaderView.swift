//
//  HeaderView.swift
//  UBSetRoute
//
//  Created by Usemobile on 05/09/19.
//

import UIKit

class HeaderView: UIView {
    
    lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.textColor = SetRouteViewSettings.shared.colors.lastPlacesTextColor
        label.font = SetRouteViewSettings.shared.fonts.lastPlaces
        label.text = .lastPlaces
        label.textAlignment = .left
        self.addSubview(label)
        return label
    }()
    
    private let paddingX: CGFloat = 14

    init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        self.lblTitle.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 18, left: self.paddingX, bottom: 5, right: self.paddingX))
    }
    
}
