//
//  EditingRouteView.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 27/01/20.
//

import UIKit

protocol EditingRouteViewDelegate: class {
    func confirmTravel(_ places: [Points])
}

enum OptionTypesCar: String {
    case comum
    case vip
    case moto
    case truck
    case taxi
    case women
    case plus
}

class EditingRouteView: UIView {
    
    lazy var scrollView: UIScrollView = {
      let view = UIScrollView()
      view.alwaysBounceVertical = true
      view.flashScrollIndicators()
      view.indicatorStyle = .black
      view.backgroundColor = .white
      view.translatesAutoresizingMaskIntoConstraints = false
      view.layer.cornerRadius = 15
      self.informView.addSubview(view)
      return view
    }()
    
    private lazy var btnClose: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setImage(UIImage.getFrom(customClass: EditingRouteView.self, nameResource: "close"), for: .normal)
        btn.addTarget(self, action: #selector(btnClosePressed), for: .touchUpInside)
        self.scrollView.addSubview(btn)
        return btn
    }()
     
    lazy var labelTitle: UILabel = {
      let label = UILabel()
      label.text = "Confirmar nova viagem para:"
      label.textAlignment = .center
      label.translatesAutoresizingMaskIntoConstraints = false
      self.scrollView.addSubview(label)
      return label
    }()
    
    lazy var imageCar: UIImageView = {
       let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        self.scrollView.addSubview(imv)
        return imv
    }()
    
    lazy var lblTypeCar: UILabel = {
       let lbl = UILabel()
        lbl.textAlignment = .center
        self.scrollView.addSubview(lbl)
        return lbl
    }()
    
    lazy var lblValue: UILabel = {
       let lbl = UILabel()
        lbl.textAlignment = .center
        self.scrollView.addSubview(lbl)
        return lbl
    }()
     
    lazy var stackView: UIStackView = {
      let view = UIStackView()
      view.backgroundColor = .orange
      view.translatesAutoresizingMaskIntoConstraints = false
      self.scrollView.addSubview(view)
      return view
    }()
    
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
        self.scrollView.addSubview(button)
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
        self.scrollView.addSubview(button)
        return button
    }()
    
    lazy var informView: UIView = {
        let image = UIView()
        image.backgroundColor = .white
        image.layer.cornerRadius = 15
        image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image)
        return image
    }()
    
    var heigh: Int = 470
    var newPoints: [Points]
    var categoryDriver = ""
    weak var delegate: EditingRouteViewDelegate?
    
    required init(places: [Points]) {
        self.newPoints = places
        let _heigh = ((self.newPoints.count * 95) + 350)
        self.heigh = _heigh > Int(UIScreen.main.bounds.size.height) ? Int(UIScreen.main.bounds.size.height) : _heigh
        super.init(frame: .zero)
        self.informView.layer.cornerRadius = _heigh > Int(UIScreen.main.bounds.size.height) ? 0 : 15
        self.scrollView.isScrollEnabled = _heigh > Int(UIScreen.main.bounds.size.height) ? true : false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.setupConstraints()
        self.setup()
        self.setupCategoryDriver()
    }
     
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        
        self.informView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: -290, right: 0), size: .init(width: 0, height: heigh))

        self.scrollView.anchor(top: nil, left: self.informView.leftAnchor, bottom: self.informView.bottomAnchor, right: self.informView.rightAnchor, size: .init(width: 0, height: self.heigh))
        
        //Components
        
        self.btnClose.anchor(top: self.scrollView.topAnchor, left: nil, bottom: nil, right: self.scrollView.rightAnchor, padding: .init(top: 45, left: 0, bottom: 0, right: 20), size: .init(width: 20, height: 20))
         
        self.labelTitle.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 100).isActive = true
        self.labelTitle.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 10).isActive = true
        self.labelTitle.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: 10).isActive = true
        self.labelTitle.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        
        self.imageCar.anchor(top: self.labelTitle.bottomAnchor, left: self.scrollView.leftAnchor, bottom: nil, right: self.scrollView.rightAnchor, padding: .init(top: 20, left: 150, bottom: 0, right: 150), size: .init(width: 75, height: 30))
        self.imageCar.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
         
        self.lblTypeCar.anchor(top: self.imageCar.bottomAnchor, left: self.scrollView.leftAnchor, bottom: self.lblValue.topAnchor, right: self.scrollView.rightAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 50, height: 20))
        self.lblTypeCar.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true

        self.lblValue.anchor(top: self.lblTypeCar.bottomAnchor, left: self.scrollView.leftAnchor, bottom: nil, right: self.scrollView.rightAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 60, height: 20))
        self.lblValue.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
         
        self.stackView.topAnchor.constraint(equalTo: self.lblValue.bottomAnchor, constant: 20).isActive = true
        self.stackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 10).isActive = true
        self.stackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: 10).isActive = true
         
         
        let constraintsCancel = NSLayoutConstraint(item: self.btnCancel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: -15 - 5)
         
        let constraintsConfirm = NSLayoutConstraint(item: self.btnConfirm, attribute: .width, relatedBy: .equal, toItem: self.btnCancel, attribute: .width, multiplier: 1, constant: 0)
         
        self.addConstraints([constraintsCancel,constraintsConfirm])
        
        self.btnCancel.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 30).isActive = true
        self.btnCancel.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 10).isActive = true
        self.btnCancel.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -20).isActive = true
        self.btnCancel.heightAnchor.constraint(equalToConstant: 55).isActive = true
         
        self.btnConfirm.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 30).isActive = true
        self.btnConfirm.leftAnchor.constraint(equalTo: self.btnConfirm.rightAnchor, constant: 10).isActive = true
        self.btnConfirm.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: 10).isActive = true
        self.btnConfirm.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -20).isActive = true
        self.btnConfirm.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        
    }
    
    func setup(){
        for i in 0..<self.newPoints.count{
        let view = StopView()
            
        if let _stop = self.newPoints[i] as? Points{
            view.type = _stop.type ?? ""
            view.numberStop = _stop.type == "points" ? i : 0
            view.address = _stop.address
            view.setup()
        }
            
        view.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(view)
      }
       
      self.stackView.axis = .vertical
      self.stackView.distribution = .fillEqually
    }
    
    func preparePresent(){
            self.hideComponents(isHide: true)
        }
        
    func present() {

        UIView.animate(withDuration: 0.5) {
            self.hideComponents(isHide: false)
            self.informView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: -10, right: 0), size: .init(width: 0, height: self.heigh))
            self.layoutIfNeeded()
        }
    }
    
    func hideComponents(isHide: Bool){
        self.labelTitle.isHidden = isHide
        self.btnClose.isHidden = isHide
        self.imageCar.isHidden = isHide
        self.lblTypeCar.isHidden = isHide
        self.lblValue.isHidden = isHide
    }
    
    func setupCategoryDriver(){
        switch self.categoryDriver.lowercased() {
        case OptionTypesCar.truck.rawValue.lowercased():
            self.lblTypeCar.text = "Caminhão"
        case OptionTypesCar.moto.rawValue.lowercased():
            self.lblTypeCar.text = "Moto"
        case OptionTypesCar.vip.rawValue.lowercased():
            self.lblTypeCar.text = "VIP"
        case OptionTypesCar.taxi.rawValue.lowercased():
            self.lblTypeCar.text = "Taxi"
        case OptionTypesCar.women.rawValue.lowercased():
            self.lblTypeCar.text = "Mulher"
        case OptionTypesCar.plus.rawValue.lowercased():
            self.lblTypeCar.text = "Plus"
        default:
            self.lblTypeCar.text = "Comum"
        }
    }
    
    @objc
    func btnClosePressed(){
        self.removeFromSuperview()
    }
    
    @objc
    func btnCancelPressed(){
        self.removeFromSuperview()
    }
    
    @objc
    func btnConfirmPressed(){
        self.delegate?.confirmTravel(self.newPoints)
        self.removeFromSuperview()
    }

}
