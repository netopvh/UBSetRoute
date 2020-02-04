//
//  ButtonsTableViewCell.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 24/01/20.
//

import UIKit


protocol ButtonsTableViewCellDelegate: class {
    func cancel()
    func confirm()
}

class ButtonsTableViewCell: UITableViewCell {
    
    lazy var btnCancel: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = SetRouteViewSettings.shared.fonts.stopViewButtons
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 27
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(self.btnCancelPressed), for: .touchUpInside)
        self.addSubview(button)
        return button
    }()
    
    lazy var btnConfirm: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.titleLabel?.font = SetRouteViewSettings.shared.fonts.stopViewButtons
        button.setTitleColor(SetRouteViewSettings.shared.colors.readyButtonTextColor, for: .normal)
        button.backgroundColor = SetRouteViewSettings.shared.colors.mainColor
        button.layer.cornerRadius = 27
        button.addTarget(self, action: #selector(self.btnConfirmPressed), for: .touchUpInside)
        self.addSubview(button)
        return button
    }()
    
    weak var delegate: ButtonsTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup() {
        self.setupConstraints()
    }
    
    func setupConstraints(){
        
        let constraintWidthCancel = NSLayoutConstraint(item: self.btnCancel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: -15 - 5)
        let constraintWidthConfirm = NSLayoutConstraint(item: self.btnConfirm, attribute: .width, relatedBy: .equal, toItem: self.btnCancel, attribute: .width, multiplier: 1, constant: 0)

        self.addConstraints([
            constraintWidthCancel,
            constraintWidthConfirm])

        self.btnCancel.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 25, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 55))

        self.btnConfirm.anchor(top: self.btnCancel.topAnchor, left: self.btnCancel.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 55))
            
    }
    
    //MARKS: OBJC FUNCTIONS
    
    @objc
    func btnCancelPressed(){
        self.delegate?.cancel()
    }
    
    @objc
    func btnConfirmPressed(){
        self.delegate?.confirm()
    }

}
