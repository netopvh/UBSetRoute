//
//  PlacesCell.swift
//  UBSetRoute
//
//  Created by Usemobile on 22/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

class PlacesCell: UITableViewCell {
    
    // MARK: UI Components
    
    private lazy var imvPin: UIImageView = {
        let imageView = UIImageView()
        let image = SetRouteViewSettings.shared.images.cellPinIcon ?? UIImage.getFrom(customClass: PlacesCell.self, nameResource: "pin")
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = SetRouteViewSettings.shared.colors.cellPinTintColor
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0), size: .init(width: 20, height: 20))
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        return imageView
    }()
    
    private lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.text = self.title
        label.font = SetRouteViewSettings.shared.fonts.placeTitle
        label.textColor = SetRouteViewSettings.shared.colors.placeTitleTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.anchor(top: self.topAnchor, left: self.imvPin.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 8, left: 10, bottom: 0, right: 10), size: .zero)
        return label
    }()
    
    private lazy var lblSubtitle: UILabel = {
        let label = UILabel()
        label.text = self.subtitle
        label.font = SetRouteViewSettings.shared.fonts.placeSubTitle
        label.textColor = SetRouteViewSettings.shared.colors.placeSubTitleTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.anchor(top: self.lblTitle.bottomAnchor, left: self.imvPin.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 2, left: 10, bottom: 8, right: 10), size: .zero)
        return label
    }()
    
    private lazy var viewBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(string: "EFECEC")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: Properties
    
    var placeModel: PlaceViewModel? {
        didSet {
            self.title = self.placeModel?.mainText
            self.subtitle = self.placeModel?.secondaryText
            switch self.placeModel?.type {
            case .address?:
                let image = SetRouteViewSettings.shared.images.cellPinIcon ?? UIImage.getFrom(customClass: PlacesCell.self, nameResource: "pin")
                self.imvPin.image = image?.withRenderingMode(.alwaysTemplate)
            case .selectAtMap?:
                let image = UIImage.getFrom(customClass: PlacesCell.self, nameResource: "icon-map")
                self.imvPin.image = image?.withRenderingMode(.alwaysTemplate)
            case .getCurrentLocation?:
                let image = UIImage.getFrom(customClass: PlacesCell.self, nameResource: "pin-userlocation")
                self.imvPin.image = image?.withRenderingMode(.alwaysTemplate)
            default:
                break
            }
        }
    }
    
    var title: String? {
        didSet {
            self.lblTitle.text = self.title
        }
    }
    
    var subtitle: String? {
        didSet {
            self.lblSubtitle.text = self.subtitle
        }
    }
    
    var selectedBackgroundColor: UIColor = SetRouteViewSettings.shared.colors.mainColor
    var selecetedContentsColor: UIColor = .white
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.select()
        } else {
            self.deselect()
        }
    }
    
    private func setup() {
        self.addSubview(viewBorder)
        viewBorder.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .zero, size: .init(width: 0, height: 1))
    }
    
    func select() {
        self.backgroundColor = self.selectedBackgroundColor
        self.lblTitle.textColor = self.selecetedContentsColor
        self.lblSubtitle.textColor = self.selecetedContentsColor
        self.imvPin.tintColor = self.selecetedContentsColor
    }
    
    func deselect() {
        self.backgroundColor = .white
        self.lblTitle.textColor = self.placeModel?.type == .address ? SetRouteViewSettings.shared.colors.placeTitleTextColor : SetRouteViewSettings.shared.colors.mainColor
        self.lblSubtitle.textColor = SetRouteViewSettings.shared.colors.placeSubTitleTextColor
        self.imvPin.tintColor = self.placeModel?.type == .address ? SetRouteViewSettings.shared.colors.cellPinTintColor : SetRouteViewSettings.shared.colors.mainColor
    }
}
