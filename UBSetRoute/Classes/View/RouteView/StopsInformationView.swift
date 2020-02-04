//
//  StopsInformationView.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 05/12/19.
//

import UIKit

protocol StopsInformationViewDelegate: class {
    func didConfirmTap(view: StopsInformationView)
}

class StopsInformationView: UIView {
    
    //MARK: Components

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
//        self.addSubview(button)
        return button
    }()
    
    lazy var btnConfirm: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Adicionar", for: .normal)
        button.titleLabel?.font = SetRouteViewSettings.shared.fonts.stopViewButtons
        button.setTitleColor(SetRouteViewSettings.shared.colors.readyButtonTextColor, for: .normal)
        button.backgroundColor = SetRouteViewSettings.shared.colors.readyButtonBackgroundColor
        button.layer.cornerRadius = 27
        button.addTarget(self, action: #selector(self.btnConfirmPressed), for: .touchUpInside)
//        self.addSubview(button)
        return button
    }()
    
    lazy var lblTitle: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Adicione paradas:"
        label.font = SetRouteViewSettings.shared.fonts.stopTitle
//        self.addSubview(label)
        return label
    }()
    
    lazy var lblMessage: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Em consideração com o tempo do seu motorista, faça até 3 paradas de no máximo 5 minutos. Para cada parada, uma taxa extra será aplicada no valor da corrida. O mesmo ocorrerá em caso de tempo excedido."
        label.numberOfLines = .zero
        label.font = SetRouteViewSettings.shared.fonts.stopText
//        self.addSubview(label)
        return label
    }()

    lazy var informView: UIView = {
        let image = UIView()
        image.backgroundColor = .white
        image.layer.cornerRadius = 15
        image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image)
        return image
    }()
    
    lazy var imageClock: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage.getFrom(customClass: StopsInformationView.self, nameResource: "information-stops")
//        self.addSubview(imageView)
        return imageView
    }()
    
    //MARK: Vars
    
    var controller: UIViewController!
    private var superView: UIView!
    
    weak var delegate: StopsInformationViewDelegate?
    
    required init(superView: UIView, controller: UIViewController) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.superView = superView
        self.controller = controller
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.superView.addSubview(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: local functions
    
    func setup(){
        self.informView.addSubview(self.lblTitle)
        self.informView.addSubview(self.lblMessage)
        self.informView.addSubview(self.imageClock)
        self.informView.addSubview(self.btnCancel)
        self.informView.addSubview(self.btnConfirm)
        self.setupConstraints()
    }
    
    func hideComponents(isHide: Bool){
        self.informView.isHidden = isHide
        self.lblTitle.isHidden = isHide
        self.lblMessage.isHidden = isHide
        self.btnCancel.isHidden = isHide
        self.btnConfirm.isHidden = isHide
    }
    
    func setupConstraints(){
        
        self.informView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: -290, right: 0), size: .init(width: 0, height: 290))

        self.imageClock.anchor(top: self.informView.topAnchor, left: self.informView.leftAnchor, bottom: nil, right: nil, padding: .init(top: 50, left: 15, bottom: 0, right: 0), size: .init(width: 60, height: 60))
        
        self.lblTitle.anchor(top: self.imageClock.topAnchor, left: self.informView.leftAnchor, bottom: nil, right: nil, padding: .init(top: -30 , left: 90, bottom: 0, right: 0))
        
        self.lblMessage.anchor(top: self.lblTitle.bottomAnchor, left: self.lblTitle.leftAnchor, bottom: nil, right: self.informView.rightAnchor, padding: .init(top: 5, left: 0, bottom: 0 , right: 25))
        
        
        let constraintWidthCancel = NSLayoutConstraint(item: self.btnCancel, attribute: .width, relatedBy: .equal, toItem: self.informView, attribute: .width, multiplier: 0.5, constant: -15 - 5)
        let constraintWidthConfirm = NSLayoutConstraint(item: self.btnConfirm, attribute: .width, relatedBy: .equal, toItem: self.btnCancel, attribute: .width, multiplier: 1, constant: 0)
        
        self.addConstraints([
            constraintWidthCancel,
            constraintWidthConfirm])
        
        self.btnCancel.anchor(top: self.lblMessage.bottomAnchor, left: self.informView.leftAnchor, bottom: nil, right: nil, padding: .init(top: 25, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 55))

        self.btnConfirm.anchor(top: self.btnCancel.topAnchor, left: self.btnCancel.rightAnchor, bottom: nil, right: self.informView.rightAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 55))
        
    }
    
    func preparePresent(){
        self.hideComponents(isHide: true)
        self.setup()
        
    }
    
    func present() {
        
       self.hideComponents(isHide: true)
        UIView.animate(withDuration: 0) {
             self.informView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: -290, right: 0), size: .init(width: 0, height: 290))
            
            self.layoutIfNeeded()
        }
        

        UIView.animate(withDuration: 0.5) {
            self.hideComponents(isHide: false)
            self.informView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: -10, right: 0), size: .init(width: 0, height: 290))
            self.layoutIfNeeded()
        }
        
    }
    
    
    //MARK: objc functions
    
    @objc
    func btnCancelPressed(_ sender: UIButton){
        self.removeFromSuperview()
    }
    
    @objc
    func btnConfirmPressed(_ sender: UIButton){
        self.removeFromSuperview()
        self.delegate?.didConfirmTap(view: self)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
}
