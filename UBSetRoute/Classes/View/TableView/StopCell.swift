//
//  StopCell.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 05/12/19.
//

import UIKit

protocol StopCellDelegate: class {
    func stopCell(didTapAddStop cell: StopCell, index: Int)
    func stopCell(didTapRemoveStop cell: StopCell, index: Int)
    func stopCell(didTapSwapStop cell: StopCell)
    func stopCell(editText cell: StopCell, address: String, index: Int)
    func stopCell(insertText cell: StopCell, index: Int, title: String)
}

class StopCell: UITableViewCell {
    
    // MARK: UI Components
    
    private lazy var btnDrag: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "drag"), for: .normal)
        self.addSubview(button)
       return button
    }()
    
    private lazy var btnSwapStops: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "swap"), for: .normal)
        self.addSubview(button)
        button.isHidden = true
        button.addTarget(self, action: #selector(self.btnSwapStopsPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var btnRemoveStops: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "delete"), for: .normal)
            self.addSubview(button)
            button.addTarget(self, action: #selector(self.btnRemoveStopsPressed), for: .touchUpInside)
            return button
    }()
    
    private lazy var btnAddStops: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "add"), for: .normal)
        button.addTarget(self, action: #selector(self.btnAddPressed), for: .touchUpInside)
        self.addSubview(button)
        return button
    }()
    
    lazy var btnAddress: UIButton = {
       let label = UIButton()
        label.contentHorizontalAlignment = .left
        label.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 45)
        label.setTitleColor(.black, for: .normal)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textTap))
        label.addGestureRecognizer(tapGesture)
//        label.setImage(UIImage.getFrom(customClass: StopCell.self, nameResource: "drag"), for: .normal)
        return label
    }()
    
    
    private lazy var imvOriginMark: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 29, bottom: 0, right: 0), size: .init(width: 8, height: 8))
        imageView.centerYAnchor.constraint(equalTo: self.btnAddress.centerYAnchor).isActive = true
        imageView.image = (SetRouteViewSettings.shared.images.routeOrigin ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "circle"))?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = SetRouteViewSettings.shared.colors.mainColor
        return imageView
    }()
    
    private lazy var imvOriginVisitedMark: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        imageView.anchor(top: nil, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 0, left: 29, bottom: 0, right: 0), size: .init(width: 8, height: 8))
        imageView.centerYAnchor.constraint(equalTo: self.btnAddress.centerYAnchor).isActive = true
        imageView.image = (SetRouteViewSettings.shared.images.routeOriginVisited ?? UIImage.getFrom(customClass: RouteView.self, nameResource: "circle-visited"))?.withRenderingMode(.alwaysTemplate)
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
        imageView.centerYAnchor.constraint(equalTo: self.btnAddress.centerYAnchor).isActive = true
        imageView.image = SetRouteViewSettings.shared.images.routeDestiny ?? UIImage.getFrom(customClass: StopCell.self, nameResource: "pin")
        return imageView
    }()
    
    private lazy var imvRouteMarkBottom: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.backgroundColor = .clear
           imageView.translatesAutoresizingMaskIntoConstraints = false
           self.addSubview(imageView)
        imageView.anchor(top: self.imvOriginMark.bottomAnchor, left: nil, bottom: self.bottomAnchor, right: nil, padding: .init(top: 3, left: 0, bottom: 0, right: 0), size: .init(width: 8, height: 0))
           imageView.centerXAnchor.constraint(equalTo: self.imvOriginMark.centerXAnchor).isActive = true
           imageView.image = SetRouteViewSettings.shared.images.routeDots ?? UIImage.getFrom(customClass: StopCell.self, nameResource: "dots")
           return imageView
    }()
    
    private lazy var imvRouteMarkTop: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.backgroundColor = .clear
           imageView.translatesAutoresizingMaskIntoConstraints = false
           self.addSubview(imageView)
        imageView.anchor(top: self.topAnchor, left: nil, bottom: self.imvOriginMark.topAnchor, right: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 8, height: 0))
           imageView.centerXAnchor.constraint(equalTo: self.imvOriginMark.centerXAnchor).isActive = true
           imageView.image = SetRouteViewSettings.shared.images.routeDots ?? UIImage.getFrom(customClass: StopCell.self, nameResource: "dots")
           return imageView
    }()
    
    //MARK: Vars
    var isOrigin = false
    var isDestiny = false
    var isStop = false
    var removeAtIndex = 1
    var isLast = false
    var hasSwap = false
    
    var newLocal = ""
    
    var delegate: StopCellDelegate?
    
    var textDidChange: ((String)-> Void)?
    
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
    
    func setup(){
        self.textLabel?.isHidden = true
        self.backgroundColor = .white
        self.addSubview(self.btnAddress)
        self.setupConstraint()
        self.setupMarks()
        
        DispatchQueue.main.async {
            self.imvOriginMark.setCorner(3)
            self.imvOriginVisitedMark.setCorner(3)
            self.imvDestinyMark.setCorner(0)
            self.imvRouteMarkTop.setCorner(0)
            self.imvRouteMarkBottom.setCorner(0)
        }
    }
    
    func setupConstraint(){

        self.btnAddress.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 60, bottom: 8, right: 54), size: .init(width: 0, height: 38))
        self.btnAddStops.anchor(top: self.btnAddress.topAnchor, left: self.btnAddress.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 8, left: 16, bottom: 0, right: 15), size: .init(width:22, height: 22))
        self.btnRemoveStops.anchor(top: self.btnAddress.topAnchor, left: self.btnAddress.rightAnchor, bottom: nil, right: self.rightAnchor, padding: .init(top: 8, left: 16, bottom: 0, right: 15), size: .init(width:22, height: 22))
        self.btnSwapStops.anchor(top: self.topAnchor, left: self.btnAddress.rightAnchor, bottom: self.btnAddress.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 16, bottom: 8, right: 15), size: .init(width: 22, height: 22))
        
        self.btnDrag.anchor(top: self.btnAddress.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.btnAddress.rightAnchor, padding: .init(top: 10, left: 0, bottom: 15, right: 10), size: .init(width: 22, height: 22))
        
    }

    
    func setupMarks(){
        if self.isDestiny{
            self.setupDestiny()
        }
        
        if self.isStop{
            self.setupStop()
        }
        
        if self.isOrigin{
            self.setupOrigin()
        }
    }
    
    func setupStop(){
        self.btnAddress.setTitle("Adicionar parada", for: .normal)
        self.btnAddress.setTitleColor(.black, for: .normal)
        self.imvRouteMarkBottom.isHidden = false
        self.imvRouteMarkTop.isHidden = false
        self.imvDestinyMark.isHidden = true
        self.imvOriginMark.isHidden = false
        self.imvOriginVisitedMark.isHidden = true
        self.btnRemoveStops.isHidden = false
        self.btnAddStops.isHidden = true
        self.btnAddress.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.7254901961, blue: 0.7254901961, alpha: 0.3)
        self.btnSwapStops.isHidden = true
        
        if newLocal != ""{
            self.btnAddress.setTitle(newLocal, for: .normal)
        }
        
    }
    
    func setupDestiny(){
        self.btnAddress.setTitle("Adicionar destino", for: .normal)
        self.imvRouteMarkBottom.isHidden = true
        self.imvDestinyMark.isHidden = false
        self.imvOriginMark.isHidden = true
        self.imvOriginVisitedMark.isHidden = true
        self.btnSwapStops.isHidden = true
        
        if isLast{
            self.btnAddStops.isHidden = true
            self.btnRemoveStops.isHidden = false
        }else{
            self.btnAddStops.isHidden = false
            self.btnRemoveStops.isHidden = true
        }
        
        self.btnAddress.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.7254901961, blue: 0.7254901961, alpha: 0.3)
        
        if newLocal != ""{
            self.btnAddress.setTitle(newLocal, for: .normal)
        }
    }
    
    func setupOrigin(){
        self.btnAddress.setTitle("Adicionar origem", for: .normal)
        self.imvRouteMarkTop.isHidden = true
        self.imvOriginMark.isHidden = false
        self.imvOriginVisitedMark.isHidden = true
        self.imvDestinyMark.isHidden = true
        self.btnAddStops.isHidden = true
        self.btnRemoveStops.isHidden = true
        self.btnSwapStops.isHidden = self.hasSwap ? false : true
        self.btnAddress.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        
        if newLocal != ""{
            self.btnAddress.setTitle(newLocal, for: .normal)
        }
    }
    
    func blockCell(){
        self.imvOriginVisitedMark.isHidden = false
        self.imvOriginMark.isHidden = true
        self.btnDrag.isHidden = true
        self.btnRemoveStops.isHidden = true
        self.btnAddress.isUserInteractionEnabled = false
        self.btnAddress.setTitleColor(#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1), for: .normal)
    }
    
    @objc
    private func btnAddPressed(_ sender: UIButton){
        self.delegate?.stopCell(didTapAddStop: self, index: removeAtIndex+1)
    }
    
    @objc
    private func btnRemoveStopsPressed(_ sender: UIButton){
        self.delegate?.stopCell(didTapRemoveStop: self, index: removeAtIndex)
    }
    
    @objc
    private func btnSwapStopsPressed(_ sender: UIButton){
        self.delegate?.stopCell(didTapSwapStop: self)
    }
    
    @objc
    private func textTap(_ sender: UITapGestureRecognizer){
        let _add = "Adicionar"
        let _edit = "Editar"
        let _origin = " Origem"
        let _destiny = " Destino"
        let _stop = " Parada"
        var _title = ""
        
        _title = self.newLocal != "" ? (isOrigin ? _edit + _origin : isStop ? _edit + _stop : _edit + _destiny) : (isOrigin ? _add + _origin : isStop ? _add + _stop : _add + _destiny)
        self.delegate?.stopCell(insertText: self, index: self.removeAtIndex,title: _title)
    }
    
}
