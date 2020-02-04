//
//  RouteView.swift
//  UBSetRoute
//
//  Created by Usemobile on 21/01/19.
//  Copyright © 2019 Usemobile. All rights reserved.
//

import UIKit

enum State {
    case closed
    case open
    case finished
    
    var opposite: State {
        return self == .open ? .closed : .open
    }
}

var statusBarHeight: CGFloat = {
    return UIApplication.shared.statusBarFrame.size.height
}()

var navBarSize: CGFloat = {
    return statusBarHeight + 44
}()

protocol RouteViewDelegate: class {
    func finishEdit(editPoints countStops: Int, places: [Points], view: RouteView)
    func removedTravelOptions()
}

class RouteView: UIView {
    
    // MARK: UI Components
    
    lazy var btnSwap: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "swap"), for: .normal)
        button.addTarget(self, action: #selector(self.btnSwapPressed), for: .touchUpInside)
       return button
    }()
    
    lazy var btnAddStops: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "add"), for: .normal)
        button.addTarget(self, action: #selector(self.btnAddPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var txfOrigin: RouteTextField = {
        let textField = RouteTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.hasStop = self.hasMultiples
        textField.font = SetRouteViewSettings.shared.fonts.originTxfText
        textField.placeHolderFont = SetRouteViewSettings.shared.fonts.originTxfPlaceholder
        textField.placeHolder = .loading
        textField.textColor = SetRouteViewSettings.shared.colors.mainColor
        textField.placeHolderColor = SetRouteViewSettings.shared.colors.mainColor
        textField.returnPressed = { (text) in
            let _ = self.txfDestiny.becomeFirstResponder()
        }
        textField.shouldBeginEdit = { _ in
            self.lastFirstResponder = self.txfOrigin
            self.hasBecomeFirstResponder?()
        }
        textField.editingChanged = { (text) in
            self.textDidChange?(text)
        }
        return textField
    }()
    
    lazy var txfDestiny: RouteTextField = {
        let textField = RouteTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.hasStop = self.hasMultiples
        textField.font = SetRouteViewSettings.shared.fonts.destinyTxfText
        textField.placeHolderFont = SetRouteViewSettings.shared.fonts.destinyTxfPlaceholder
        textField.placeHolder = .whereTo
        textField.textColor = SetRouteViewSettings.shared.colors.destinyTxfTextColor
        textField.placeHolderColor = SetRouteViewSettings.shared.colors.destinyTxfPlaceHolderColor
        textField.returnPressed = { (text) in
            let _ = self.txfDestiny.resignFirstResponder()
            self.textDidChange?(text)
        }
        textField.shouldBeginEdit = { _ in
            self.lastFirstResponder = self.txfDestiny
            self.hasBecomeFirstResponder?()
        }
        textField.editingChanged = { (text) in
            self.textDidChange?(text)
        }
        return textField
    }()
    
    lazy var btnBack: UIButton = {
        let button = UIButton()
        let image = SetRouteViewSettings.shared.images.backBtnIcon ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "arrow-left")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(self.btnBackPressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imvOriginMark: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 29, bottom: 0, right: 0), size: .init(width: 8, height: 8))
        imageView.centerYAnchor.constraint(equalTo: self.txfOrigin.centerYAnchor).isActive = true
        imageView.image = (SetRouteViewSettings.shared.images.routeOrigin ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "circle"))?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = SetRouteViewSettings.shared.colors.mainColor
        return imageView
    }()
    
    private lazy var imvDestinyMark: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 29, bottom: 0, right: 0), size: .init(width: 8, height: 10))
        imageView.centerYAnchor.constraint(equalTo: self.txfDestiny.centerYAnchor).isActive = true
        imageView.image = SetRouteViewSettings.shared.images.routeDestiny ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "pin")
        return imageView
    }()
    
    private lazy var imvRouteMark: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: self.imvOriginMark.bottomAnchor, left: nil, bottom: self.imvDestinyMark.topAnchor, right: nil, padding: .init(top: 3, left: 0, bottom: 3, right: 0), size: .init(width: 8, height: 0))
        imageView.centerXAnchor.constraint(equalTo: self.imvOriginMark.centerXAnchor).isActive = true
        imageView.image = SetRouteViewSettings.shared.images.routeDots ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "dots")
        return imageView
    }()
    
    private lazy var viewProgress: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.addConstraints([
            view.leftAnchor.constraint(equalTo: self.leftAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.rightAnchor.constraint(equalTo: self.rightAnchor),
            view.heightAnchor.constraint(equalToConstant: 1.5)
            ])
        return view
    }()
    
    // MARK: Properties
    
    weak var delegate: RouteViewDelegate?
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            self.btnBack.tintColor = self.isUserInteractionEnabled ? .black : UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    var categoryForEdit = "Comum"
    var hasMultiples = false
    var multiplesStopsViewController: MultiplesStopsViewController?
    
    var origin: String {
        get {
            return self.txfOrigin.text
        } set {
            self.txfOrigin.text = newValue
        }
    }
    
    var destiny: String {
        get {
            return self.txfDestiny.text
        } set {
            self.txfDestiny.text = newValue
        }
    }
    
    var closedPressed: (() -> Void)?
    var hasBecomeFirstResponder: (() -> Void)?
    var textDidChange: ((String) -> Void)?
    var didConfirmTap: (() -> Void)?
    
    private var superView: UIView!
    var controller: UIViewController!
    
    public var isPresented: Bool = false
    //    private lazy var hasNavigation: Bool = {
    //        return self.controller.navigationController != nil
    //    }()
    
    public private(set) var lastFirstResponder: RouteTextField? {
        didSet {
            if let _oldValue = oldValue {
                _oldValue.backgroundColor = .textFieldBackground
            }
            if let _textField = self.lastFirstResponder {
                _textField.backgroundColor = .textFieldSelected
            }
        }
    }
    
    // MARK: Init
    
    required init(superView: UIView, controller: UIViewController, hasStops: Bool) {
        super.init(frame: .zero)
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.hasMultiples = hasStops
        self.superView = superView
        self.controller = controller
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        self.setupConstraints()
        self.setupOrigin()
        self.setupDestiny()
        self.setupBtnBack()
        if self.hasMultiples{
            self.setupMultiplesStops()
        }
        self.viewProgress.isHidden = false
        DispatchQueue.main.async {
            self.setBottomShadow()
            self.imvOriginMark.setCorner(3)
            self.imvDestinyMark.setCorner(0)
            self.imvRouteMark.setCorner(0)
        }
    }
    
    fileprivate func setupConstraints() {
        if let nav = self.controller.navigationController {
            self.superView = nav.view
        }
        let topPadding: CGFloat = -SetRouteViewSettings.shared.statusBarSizeAdjust
        self.superView.addSubview(self)
        self.anchor(top: self.superView.topAnchor, left: self.superView.leftAnchor, bottom: nil, right: self.superView.rightAnchor, padding: .init(top: topPadding, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: SetRouteViewSettings.shared.routeViewHeight + navBarSize))
    }
    
    fileprivate func setupOrigin() {
        self.addSubview(self.txfOrigin)
        
        if self.hasMultiples{
            self.txfOrigin.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: statusBarHeight+35, left: 56, bottom: 0, right: 54), size: .init(width: 0, height: 32))
        }else{
            self.txfOrigin.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: statusBarHeight+35, left: 56, bottom: 0, right: 24), size: .init(width: 0, height: 32))
        }
    }
    
    fileprivate func setupDestiny() {
        self.addSubview(self.txfDestiny)
        self.txfDestiny.anchor(top: self.txfOrigin.bottomAnchor, left: self.txfOrigin.leftAnchor, bottom: nil, right: self.txfOrigin.rightAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 32))
    }
    
    fileprivate func setupBtnBack() {
        self.addSubview(self.btnBack)
        self.btnBack.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: statusBarHeight, left: 0, bottom: 0, right: 0), size: .init(width: 44, height: 44))
    }
    
    fileprivate func setupMultiplesStops(){
        self.addSubview(self.btnSwap)
        self.addSubview(self.btnAddStops)
        self.btnSwap.anchor(top: self.topAnchor, left: self.txfOrigin.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: statusBarHeight+40, left: 16, bottom: 0, right: 15), size: .init(width: 22, height: 22))
        self.btnAddStops.anchor(top: self.btnSwap.bottomAnchor, left: self.txfDestiny.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 20, left: 16, bottom: 0, right: 15), size: .init(width:22, height: 22))
    }
    
    // MARK: Selectors
    
    @objc private func btnBackPressed(_ sender: UIButton) {
        sender.isEnabled = false
        self.closedPressed?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isEnabled = true
        }
    }
    
    @objc private func btnSwapPressed(_ sender: UIButton){
        let originAddress = self.txfOrigin.text
        self.txfOrigin.text = self.txfDestiny.text
        self.txfDestiny.text = originAddress
    }
    
    @objc private func btnAddPressed(_ sender: UIButton){
        self.showViewInformation()
    }
    
    // MARK: Presenter
    
    func present(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.isHidden = false
            let _ = self.txfDestiny.becomeFirstResponder()
        }) { _ in
            self.isPresented = true
            completion?()
        }
    }
    
    func hide(duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        self.hideKeyboard()
        UIView.animate(withDuration: duration, animations: {
            self.isHidden = true
        }) { _ in
            self.isPresented = false
            completion?()
        }
    }
    
    func hideKeyboard() {
        let _ = self.txfDestiny.resignFirstResponder()
        let _ = self.txfOrigin.resignFirstResponder()
    }
    
    func setFirstResponder() {
        if let textField = self.lastFirstResponder {
            let _ = textField.becomeFirstResponder()
        }
    }
    
    func isOrigin(_ textField: RouteTextField? = nil ) -> Bool {
        if textField == nil {
            return self.lastFirstResponder == self.txfOrigin
        } else {
            return textField == self.txfOrigin
        }
    }
    
    func clear() {
        self.txfOrigin.text = ""
        self.txfDestiny.text = ""
        self.lastFirstResponder = self.txfOrigin
    }
    
    func showViewInformation(){
        self.endEditing(true)
        let view = StopsInformationView(superView: self.superView, controller: self.controller)
        view.delegate = self
        view.fillSuperview()
        view.preparePresent()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            view.present()
        }
        
    }
    
    // MARK: Progress
    
    var isProgressAnimating = false
    
    func startProgress() {
        guard !self.isProgressAnimating else { return }
        self.isProgressAnimating = true
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
            self.isProgressAnimating = false
            let animatingLayer = self.viewProgress.layer.sublayers?.first
            animatingLayer?.removeAllAnimations()
            animatingLayer?.removeFromSuperlayer()
        }
    }
    
    public func setCurrentLocation(viewModel: PlaceViewModel, for textField: RouteTextField? = nil) {
        let _textField = textField ?? self.txfOrigin
        if _textField == self.txfOrigin {
            self.origin = viewModel.mainText
            _textField.placeHolder = .origin
        } else if _textField == self.txfDestiny {
            self.destiny = viewModel.mainText
            _textField.placeHolder = .whereTo
        }
    }
    
    public func setLoading() {
        self.lastFirstResponder?.placeHolder = .loading
        if self.lastFirstResponder == self.txfOrigin {
            self.origin = ""
        } else if self.lastFirstResponder == self.txfDestiny {
            self.destiny = ""
        }
    }
    
    func confirmEditPoins(places: [Points], imageCar: UIImageView?, value :Double = 0.0, categoryCar: String = ""){
        let view = EditingRouteView(places: places)
        self.addSubview(view)
        view.delegate = self
        view.lblValue.text = "R$ " + String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
        view.categoryDriver = self.categoryForEdit
        view.imageCar.image = imageCar?.image
        view.lblTypeCar.text = categoryCar.uppercased()
        view.fillSuperview()
        view.preparePresent()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            view.present()
        }
    }
    
}

extension RouteView : EditingRouteViewDelegate{
    func confirmTravel(_ places: [Points]){
        self.delegate?.finishEdit(editPoints: places.count, places: places, view: self)
    }
}

extension RouteView: StopsInformationViewDelegate{
    func didConfirmTap(view: StopsInformationView) {
        self.didConfirmTap?()
    }
}
