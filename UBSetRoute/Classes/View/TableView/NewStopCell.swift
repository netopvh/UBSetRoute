//
//  NewStopCell.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 20/01/20.
//

import UIKit

class NewStopCell: UITableViewCell {
    
    lazy var lblStop: UILabel = {
        let label = UILabel()
        label.text = "PARADA"
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    lazy var lblFirstAddress: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    lazy var lblSecondAddress: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(label)
        return label
    }()
    var numberStop: Int = 1
    var type: String = ""
    
    var address: Address?
    
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
        self.setStyle()
        self.setModel()
    }
    
    func setupConstraints(){
            self.lblStop.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, padding: .init(top: 20, left: 45, bottom: 0, right: 0), size: .init(width: 100, height: 20))
            
            self.lblFirstAddress.anchor(top: self.lblStop.bottomAnchor, left: self.lblStop.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, padding: .init(top: 0, left: 0, bottom: 15, right: 45), size: .init(width: 280, height: 40))
    }
    
    func setStyle(){
        if self.type == "points"{
            self.lblStop.text = "\(numberStop)ª Parada"
        }else{
            if self.type == "origin"{
                self.lblStop.text = "Origem"
            }else{
                self.lblStop.text = "Destino"
            }
        }
    }
    
    func setModel(){
        guard let _street = self.address?.text else {return}
        guard let _neighborhood = self.address?.neighborhood else {return}
        guard let _city = self.address?.city else {return}
        guard let _state = self.address?.state else {return}
        self.lblFirstAddress.text = "\(_street), \n \(_neighborhood)-\(_city)/\(_state)"
    }

}
