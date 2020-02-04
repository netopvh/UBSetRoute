//
//  CustomButton.swift
//  UBSetRoute
//
//  Created by Usemobile on 29/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? SetRouteViewSettings.shared.colors.readyButtonBackgroundColor : UIColor(string: "A2A2A2")
        }
    }
    
}
