//
//  StopView.swift
//  UBSetRoute
//
//  Created by Usemobile on 27/01/20.
//

import UIKit

class StopView: UIView {

     lazy var lblStop: UILabel = {
            let label = UILabel()
            label.text = "PARADA"
            label.font = SetRouteViewSettings.shared.fonts.stopTitle
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            return label
        }()
        
        lazy var lblFirstAddress: UILabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.font = SetRouteViewSettings.shared.fonts.stopText
            label.lineBreakMode = .byTruncatingTail
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            return label
        }()
        
        var numberStop: Int = 1
        var type: String = ""
        
        var address: Address?

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            self.setupConstraints()
            self.setStyle()
            self.setModel()
        }
        
        func setupConstraints(){
            self.lblStop.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 20, left: 45, bottom: 0, right: 0), size: .init(width: 100, height: 20))
            
            self.lblFirstAddress.anchor(top: self.lblStop.bottomAnchor, left: self.lblStop.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 10), size: .init(width: 280, height: 0))
        }
        
        func setStyle(){
            if self.type == "points"{
                self.lblStop.text = "\(numberStop)ª Parada:"
            }else{
                if self.type == "origin"{
                    self.lblStop.text = "Origem:"
                }else{
                    self.lblStop.text = "Destino:"
                }
            }
        }
        
        func setModel(){
            var _completeAddres = ""
            if let _street = self.address?.text{
                _completeAddres = _street
            }
            
            if let _number = self.address?.number {
                _completeAddres = _number != "" ? _completeAddres + " , " + _number : _completeAddres
            }
            
            if let _neighborhood = self.address?.neighborhood {
                 _completeAddres = _neighborhood != "" ? _completeAddres + "\n" + _neighborhood : _completeAddres
            }
            
            if let _city = self.address?.city {
                _completeAddres = _city != "" ? _completeAddres + " - " + _city : _completeAddres
            }
            
            if let _state = self.address?.state {
                _completeAddres = _state != "" ? _completeAddres + "/" + _state : _completeAddres
            }
            
            self.lblFirstAddress.text = _completeAddres
            
        }

}
