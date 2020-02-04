//
//  NewView.swift
//  Pods-UBSetRoute_Example
//
//  Created by Gustavo Rocha on 19/12/19.
//

import UIKit

protocol NewViewDelegate: class {
    func didTapTxf(index: Int, title: String)
    func callDriver(countStops: Int, places: [Points])
    func editPoins(countStops: Int, places: [Points])
    func back()
}

class NewView: UIView {
   
    let controller: UIViewController
    var delegate: NewViewDelegate?
    
    var isEditingStops = false
    var editPoints: [Points] = []

    lazy var tableView = MultiplesStopsTableVIew()
        
    lazy var btnDone: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pronto", for: .normal)
        button.addTarget(self, action: #selector(self.callTravel), for: .touchUpInside)
        button.layer.cornerRadius = 27
        button.isUserInteractionEnabled = false
        button.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        return button
    }()
    
    lazy var viewBackgroundButton: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init(controller: UIViewController) {
        self.controller = controller
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.tableView.myDelegate = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tableView)
        self.addSubview(self.viewBackgroundButton)
        self.addSubview(self.btnDone)
        self.addConstraints([
            self.tableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.btnDone.topAnchor),
            self.viewBackgroundButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.viewBackgroundButton.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.viewBackgroundButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.viewBackgroundButton.topAnchor.constraint(equalTo: self.tableView.bottomAnchor),
            self.btnDone.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 25),
            self.btnDone.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -25),
            self.btnDone.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            self.btnDone.heightAnchor.constraint(equalToConstant: 55),
        ])
    }
    
    @objc
    func callTravel(){
        
        if isEditingStops{
//            self.delegate?.editPoins(countStops: , places: )
            self.delegate?.editPoins(countStops: self.tableView.countCells(), places: self.tableView.getPlaces())
        }else{
            self.delegate?.callDriver(countStops: self.tableView.countCells(), places: self.tableView.getPlaces())
            self.removeFromSuperview()
        }
    
    }
    
    @objc
    func btnBackPressed(){
        self.delegate?.back()
    }
    
    func enableButton(){
        self.btnDone.backgroundColor = SetRouteViewSettings.shared.colors.mainColor
        self.btnDone.isUserInteractionEnabled = true
    }
    
    func desableButton(){
        self.btnDone.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.btnDone.isUserInteractionEnabled = false
    }
    
    func verifyStops(){
        let isComplete = self.tableView.checkCells()
        if isComplete{
            self.enableButton()
        }else{
            self.desableButton()
        }
        layoutIfNeeded()
    }
    
    func setEditPoints(_ points: [Points]){
        self.editPoints = points
        self.tableView.setEditPoints(self.editPoints)
        self.verifyStops()
    }
    
}

extension NewView: MultiplesStopsTableVIewDelegate{
    func verifyStops(view: MultiplesStopsTableVIew) {
        self.verifyStops()
    }
    
    func didTapTxf(index: Int, title: String) {
        self.delegate?.didTapTxf(index: index, title: title)
    }
}
