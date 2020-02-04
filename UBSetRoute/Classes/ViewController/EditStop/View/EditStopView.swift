//
//  EditStopView.swift
//  Pods-UBSetRoute_Example
//
//  Created by Gustavo Rocha on 16/12/19.
//

import UIKit

protocol EditStopDelegate: class {
    func editstopview(view: EditStopView, didChange text: String)
    func editstopview(view: EditStopView, didSelect text: String, point: Points)
}

class EditStopView: UIView {
    
    #warning("Evitar cast forçado de opcionais, preferir sempre ?")
    //    var tableView: EditStopTableView!
    //    var choosePlace: PlaceViewModel!
    var tableView: EditStopTableView?
    var choosePlace: PlaceViewModel?
    
    weak var delegate: EditStopDelegate?
    
    var textDidChange: ((String) -> Void)?
    
    var callAnimation: Bool = false
    
    var isProgressAnimating = false
    
    lazy var texfField: textFieldCustom = {
        let txf = textFieldCustom()
        txf.translatesAutoresizingMaskIntoConstraints = false
        txf.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.7254901961, blue: 0.7254901961, alpha: 0.3)
        txf.placeholder = .whereTo
        txf.clearButtonMode = .whileEditing
        txf.addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
        self.mainView.addSubview(txf)
        return txf
    }()
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        return view
    }()
    
    private lazy var viewProgress: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.addSubview(view)
        self.addConstraints([
            view.leftAnchor.constraint(equalTo: self.mainView.leftAnchor, constant: 20),
            view.topAnchor.constraint(equalTo: self.mainView.bottomAnchor),
            view.rightAnchor.constraint(equalTo: self.mainView.rightAnchor, constant: 20),
            view.heightAnchor.constraint(equalToConstant: 1.5)
        ])
        return view
    }()
    
    //MARK: Init
    
    required init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Local functions
    
    func setup(){
        self.setupTable()
        self.setupConstraints()
        self.applyShadow()
        let _ = self.texfField.becomeFirstResponder()
    }
    
    func applyShadow() {
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOffset = CGSize.zero
        self.mainView.layer.shadowOpacity = 0.5
        self.mainView.layer.shadowRadius = 5
    }
    
    func setupConstraints(){
        
        let topConstant = navBarSize
        
        self.mainView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: topConstant , left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 80))
        
        self.texfField.anchor(top: self.mainView.topAnchor, left: self.mainView.leftAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 20, left: 40, bottom: 0, right: 20), size: .init(width: 0, height: 38))
    }
    
    fileprivate func setupTable() {
        self.tableView = EditStopTableView(superView: self)
        self.tableView?.myDelegate = self
        self.tableView?.setup()
        
        #warning("Adicionar weak self para closures")
        //        self.tableView?.didSelectPlace = { (placeModel) in
        //            self.choosePlace = placeModel
        //            self.tableView?.clearPlaces()
        //        }
        self.tableView?.didSelectPlace = { [weak self] (placeModel) in
            guard let self = self else { return }
            self.choosePlace = placeModel
            self.tableView?.clearPlaces()
        }
    }
    
    func startProgress() {
        if !callAnimation {
            if self.isProgressAnimating {
                let layer = CAShapeLayer()
                let size = CGSize(width: self.viewProgress.frame.width/4, height: self.viewProgress.frame.height)
                let rect = CGRect(origin: .zero, size: size)
                layer.path = UIBezierPath(roundedRect: rect, cornerRadius: 0).cgPath
                layer.fillColor = UIColor.black.cgColor
                self.viewProgress.layer.addSublayer(layer)
                
                let duration: TimeInterval = 1.2
                
                let positionAnimation = CAKeyframeAnimation(keyPath: "position.x")
                positionAnimation.values = [0, self.viewProgress.frame.width, 0]
                positionAnimation.keyTimes = [0, 0.5, 1]
                positionAnimation.duration = duration
                positionAnimation.repeatCount = .greatestFiniteMagnitude
                positionAnimation.isAdditive = true
                
                let widthAnimation = CAKeyframeAnimation(keyPath: "transform.scale.x")
                widthAnimation.values = [0, 1, 0, 1, 0]
                widthAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
                widthAnimation.duration = duration
                widthAnimation.repeatCount = .greatestFiniteMagnitude
                
                layer.add(positionAnimation, forKey: "position")
                layer.add(widthAnimation, forKey: "width")
                self.callAnimation = true
            }
        }
        
    }
    
    func stopProgress() {
        self.callAnimation = false
        DispatchQueue.main.async {
            self.isProgressAnimating = false
            let animatingLayer = self.viewProgress.layer.sublayers?.first
            animatingLayer?.removeAllAnimations()
            animatingLayer?.removeFromSuperlayer()
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        guard let currentText = textField.text else { return }
        self.textDidChange?(currentText)
        self.delegate?.editstopview(view: self, didChange: currentText)
    }
    
}

extension EditStopView: EditStopTableViewDelegate{
    func editStopTable(view: EditStopTableView, didSelect text: String, point: Points) {
        self.delegate?.editstopview(view: self, didSelect: text, point: point)
    }
}


#warning("Classe começando com letra minúscula e dentro do arquivo de outra classe")
class textFieldCustom: UITextField {
    
    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 45)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
