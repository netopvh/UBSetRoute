//
//  RouteTextField.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

class RouteTextField: UIView {
    
    private lazy var dragBtn: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "drag"), for: .normal)
       return button
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = self.font
        textField.textColor = self.textColor
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = self.autocapitalizationType
        textField.returnKeyType = self.returnKeyType
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.delegate = self
        return textField
    }()
    
    var autocapitalizationType : UITextAutocapitalizationType = .words {
        didSet {
            self.textField.autocapitalizationType = self.autocapitalizationType
        }
    }
    
    var returnKeyType: UIReturnKeyType = UIReturnKeyType.done {
        didSet {
            self.textField.returnKeyType = returnKeyType
        }
    }
    
    var font: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.textField.font = self.font
        }
    }
    
    var text: String = "" {
        didSet {
            self.textField.text = self.text
        }
    }
    
    var textColor: UIColor = .black {
        didSet {
            self.textField.textColor = self.textColor
        }
    }
    
    var placeHolderFont: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.setPlaceHolderFont()
        }
    }
    
    var placeHolder: String = "" {
        didSet {
            self.setPlaceHolderFont()
        }
    }
    
    var placeHolderColor: UIColor = .gray {
        didSet {
            self.setPlaceHolderFont()
        }
    }
    
    typealias ReturnPressed = (String) -> Void
    var returnPressed: ReturnPressed?
    var editingChanged: ReturnPressed?
    var shouldBeginEdit: ReturnPressed?
    
    var editingChangedBlocker = false
    var hasStop = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .textFieldBackground
        self.addSubview(self.textField)
        self.setupConstraints()
        self.textField.addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
    }
    
    fileprivate func setupConstraints() {
        
        if self.hasStop{
             self.textField.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 54), size: .zero)
        }else{
             self.textField.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 0), size: .zero)
        }
    }
    
    private func setPlaceHolderFont() {
        self.textField.setPlaceholderFont(self.placeHolder, self.placeHolderFont, self.placeHolderColor)
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return self.textField.resignFirstResponder()
    }
    
    @objc func editingChanged(_ textField: UITextField) {
            guard !self.editingChangedBlocker else { return }
            guard let currentText = textField.text else { return }
            self.editingChanged?(currentText)
    }
    
}

extension RouteTextField: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.returnPressed?(textField.text ?? "")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.shouldBeginEdit?(textField.text ?? "")
        return true
    }
}
