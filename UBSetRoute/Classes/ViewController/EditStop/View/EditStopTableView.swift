//
//  EditStopTableView.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 18/12/19.
//

import UIKit

protocol EditStopTableViewDelegate: class {
    func editStopTable(view: EditStopTableView, didSelect text: String, point: Points)
}

class EditStopTableView: UITableView {
    
    
    private lazy var viewProgress: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        self.isHidden = false
        self.addSubview(view)
//        self.superView.addSubview(view)
        self.addConstraints([
            view.leftAnchor.constraint(equalTo: self.leftAnchor),
            view.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            view.rightAnchor.constraint(equalTo: self.rightAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.5)
            ])
        return view
    }()
  
    // MARK: Properties

    
    private var placeList: [PlaceViewModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    public var lastPlaces: [PlaceViewModel] = [] {
        didSet {
            if self.hasLastPlaces {
                self.reloadData()
            }
        }
    }
    
    private var superView: EditStopView!
    private var cnstTableTop = NSLayoutConstraint()
    
    lazy var allowUpdateTableInsets: Bool = {
        return true
    }()
    
    private var allowVelocityHide = true
    private var updateConstraintsByScroll = true
    
    var isProgressAnimating = false
    
    var didSelectPlace: ((PlaceViewModel) -> Void)?
    
    var myDelegate: EditStopTableViewDelegate?
    
    private var hasLastPlaces: Bool = true
    
//    var isProgressAnimating = false
    
    // MARK: Init
    
    required init(superView: EditStopView) {
        super.init(frame: .zero, style: .plain)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superView = superView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    public func setup() {
        #warning("Evitar ao máximo esse tipo de código, da view ter acesso a superview e ela mesmo se atribuir como subview da superview")
        self.superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupTableConstraints()
        self.backgroundColor = .white
        self.separatorStyle = .none
        self.estimatedRowHeight = 70
        self.rowHeight = UITableView.automaticDimension
        #warning("Hard code aqui, o identifier 'PlacesCell' está sendo repetido várias vezes ao longo do projeto, centralizar em uma única variável")
        self.register(PlacesCell.self, forCellReuseIdentifier: "PlacesCell")
        self.delegate = self
        self.dataSource = self
        self.keyboardDismissMode = .interactive
//        self.placeList = self.defaultOptions
    }
    
    fileprivate func setupTableConstraints() {
        #warning("Evitar ao máximo esse tipo de código, da subview adicionar as constraints")
        let topPadding: CGFloat = SetRouteViewSettings.shared.routeViewHeight + navBarSize - SetRouteViewSettings.shared.statusBarSizeAdjust
        self.cnstTableTop = self.topAnchor.constraint(equalTo: self.superView.topAnchor, constant: topPadding)
        
//        let height = UIScreen.main.bounds.height - SetRouteViewSettings.shared.routeViewHeight - navBarSize
        
        let topConstant = navBarSize + 100  - SetRouteViewSettings.shared.statusBarSizeAdjust
        
        let height  = UIScreen.main.bounds.height - topConstant
        
        self.anchor(top: self.superView.topAnchor, left: self.superView.leftAnchor, bottom: nil, right: self.superView.rightAnchor, padding: .init(top: topConstant, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: height))
        
        self.cnstTableTop.isActive = true
        self.cnstTableTop.constant = UIScreen.main.bounds.height
    }
    
    public func setPlaces(_ placeList: [PlaceViewModel]) {
        self.hasLastPlaces = placeList.isEmpty
        if placeList.isEmpty {
//            self.placeList = self.defaultOptions
        } else {
            self.placeList = placeList
        }
        layoutIfNeeded()
    }
    
    public func setLastPlaces(_ placeList: [PlaceViewModel]) {
        self.hasLastPlaces = true
        self.lastPlaces = placeList
        layoutIfNeeded()
    }
    
    public func clearPlaces() {
        self.setPlaces([])
        layoutIfNeeded()
    }
    
    func startProgress() {
        guard !self.isProgressAnimating else { return }
        self.isProgressAnimating = true
        self.viewProgress.isHidden = false
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
    }

    func stopProgress() {
        guard self.isProgressAnimating else { return }
        DispatchQueue.main.async {
            let animatingLayer = self.viewProgress.layer.sublayers?.first
            animatingLayer?.removeAllAnimations()
            animatingLayer?.removeFromSuperlayer()
        }
        self.viewProgress.isHidden = true
    }

}


extension EditStopTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        var selectedPlace: PlaceViewModel
        
        #warning("Substituir por operador ternário")
        if self.hasLastPlaces {
            selectedPlace = self.lastPlaces[row]
        }else{
            selectedPlace = self.placeList[row]
        }
        
        #warning("Instância 'stop' deveria estar dentro do if, pois se o if não for satisfeito, estará sendo instanciado sem propósito")
        let stop = Points(visited: false, address: Address(placeId: selectedPlace.objectId, text: selectedPlace.mainText, location: Location(latitude: selectedPlace.coordinates?.latitude ?? 0.0, longitude: selectedPlace.coordinates?.longitude ?? 0.0)), type: "")
        
//        let selectedPlace = self.placeList[row]
        if let cell = tableView.cellForRow(at: indexPath) as? PlacesCell {
            cell.select()
            self.startProgress()
            self.myDelegate?.editStopTable(view: self, didSelect: selectedPlace.mainText, point: stop)
            self.didSelectPlace?(selectedPlace)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                cell.isSelected = false
                cell.deselect()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PlacesCell {
            cell.deselect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension EditStopTableView: UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        switch section {
//        case 0:
//            return nil
//        default:
//            if self.hasLastPlaces && !self.lastPlaces.isEmpty {
//                let view = HeaderView()
//                return view
//            } else {
//                return nil
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        //        return CGFloat(section * 40)
//        return section != 0 && self.hasLastPlaces && !self.lastPlaces.isEmpty ? 40 : 0
//    }
    
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.hasLastPlaces && !self.lastPlaces.isEmpty ? 2 : 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.hasLastPlaces ? self.lastPlaces.count : self.placeList.count
//        return self.placeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let section = indexPath.section
        let row = indexPath.row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCell", for: indexPath) as! PlacesCell
//        switch section {
//        case 0:
//            cell.placeModel = self.placeList[row]
//        default:
//            cell.placeModel = self.lastPlaces[row]
//        }
        
        
        if self.hasLastPlaces {
            if self.lastPlaces.count > 0{
                cell.placeModel = self.lastPlaces[row]
            }
        }else{
            if self.placeList.count > 0{
                cell.placeModel = self.placeList[row]
            }
        }
        return cell
    }
    
}
