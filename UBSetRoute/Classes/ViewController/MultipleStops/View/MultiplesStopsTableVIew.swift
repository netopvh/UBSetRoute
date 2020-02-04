//
//  MultiplesStopsTableVIew.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 05/12/19.
//

import UIKit
import MobileCoreServices

protocol MultiplesStopsTableVIewDelegate: class {
    func didTapTxf(index: Int, title: String)
    func verifyStops(view: MultiplesStopsTableVIew)
}

class MultiplesStopsTableVIew: UITableView {
    
    //MARK: Vars
    var myStops: [String] = ["","",""]
    var myPoints: [Points] = [Points(visited: false, address: Address(placeId: "", text: "", location: Location(latitude: 0.0, longitude: 0.0), number: ""), type: ""),
                              Points(visited: false, address: Address(placeId: "", text: "", location: Location(latitude: 0.0, longitude: 0.0), number: ""), type: ""),
                              Points(visited: false, address: Address(placeId: "", text: "", location: Location(latitude: 0.0, longitude: 0.0), number: ""), type: "")]
    let stopTexts = ["Adicionar origem", "Adicionar parada", "Adicionar destino"]
    var limitStops = 5
    var minimumStops = 2
    
    weak var myDelegate: MultiplesStopsTableVIewDelegate?
    
    var stopsComplete = 0
    
    //MARK: Init
    
    required init() {
        super.init(frame: .zero, style: .plain)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.rowHeight = UITableView.automaticDimension
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Local functions
    
    func setup(){
        self.delegate = self
        self.dataSource = self
        if #available(iOS 11.0, *) {
            self.dragInteractionEnabled = true
            self.dropDelegate = self
            self.dragDelegate = self
        } else {
            // Fallback on earlier versions
        }
        self.register(StopCell.self, forCellReuseIdentifier: "StopCell")
        self.separatorStyle = .none
        self.isScrollEnabled = false
    }
    
    @available(iOS 11.0, *)
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        
        let placeName = self.myStops[indexPath.row]

        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        return [
            
            UIDragItem(itemProvider: itemProvider)
        ]
        
    }
    
    @available(iOS 11.0, *)
    func canHandle(_ session: UIDropSession) -> Bool {
           return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func addItem(_ place: String, at index: Int) {
        self.myStops.insert(place, at: index)
        self.myPoints.insert(Points(visited: false,
                                    address: Address(placeId: "",
                                                     text: "",
                                                     location: Location(latitude: 0.0, longitude: 0.0),
                                                     number: ""),
                                    type: ""),
                             at: index)
    }
    
    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let place = self.myStops[sourceIndex]
        let _point = self.myPoints[sourceIndex]
        self.myStops.remove(at: sourceIndex)
        self.myStops.insert(place, at: destinationIndex)
        self.myPoints.remove(at: sourceIndex)
        self.myPoints.insert(_point, at: destinationIndex)
        self.updateRows()
    }
    
    func updateRows(){
        self.reloadData()
        self.myDelegate?.verifyStops(view: self)
        layoutIfNeeded()
    }
    
    func checkCells() -> Bool {
        let numberOfStops = self.numberOfRows(inSection: 0)
        var count = 0
        for i in 0..<self.myStops.count{
            if self.myStops[i] != ""{
                count = count + 1
            }
        }
        return numberOfStops == count ? true : false
    }
    
    func countCells()-> Int{
        return self.numberOfRows(inSection: 0)
    }
    
    func getPlaces() -> [Points]{
        var stopsArray: [Points] = []
        
        for i in 0..<self.myPoints.count{
            
            if i == 0{
                self.myPoints[i].type = "origin"
            }else if i == self.myPoints.count-1{
                self.myPoints[i].type = "destiny"
            }else {
                self.myPoints[i].type = "points"
            }
            stopsArray.append(self.myPoints[i])
        }
        
        return stopsArray
    }
    
    func setEditPoints(_ points: [Points]){
        self.myPoints.removeAll()
        self.myStops.removeAll()
        
        for i in 0..<points.count{
            self.myStops.append(points[i].address?.text ?? "")
            self.myPoints.append(points[i])
        }
        
        self.reloadData()
    }
    
}


extension MultiplesStopsTableVIew: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.myPoints[indexPath.row].visited == false ? true : false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.myStops.count == self.minimumStops ? false : true
    }
 
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let _sourceVisited = self.myPoints[sourceIndexPath.row].visited else {return}
        guard let _destinationVisited = self.myPoints[destinationIndexPath.row].visited else {return}
        if !_sourceVisited && !_destinationVisited{
            self.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        }
        self.updateRows()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {

        if (editingStyle ==  .delete) {
            if self.myPoints[indexPath.row].visited == false{
                if !(self.myStops.count == self.minimumStops){
                    self.myStops[indexPath.row] = ""
                    self.myStops.remove(at: indexPath.row)
                    self.myPoints.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    self.updateRows()
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        if self.myPoints[indexPath.row].visited == false {
            let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, handler) in
                
                if !(self.myStops.count == self.minimumStops){
                    self.myStops[indexPath.row] = ""
                    self.myStops.remove(at: indexPath.row)
                    self.myPoints.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    self.updateRows()
                }
            }
            deleteAction.backgroundColor = .white
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
        let configuration = UISwipeActionsConfiguration()
        return configuration
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        if self.myPoints[indexPath.row].visited == false {
            let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, handler) in
                
                if !(self.myStops.count == self.minimumStops){
                    self.myStops[indexPath.row] = ""
                    self.myStops.remove(at: indexPath.row)
                    self.myPoints.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    self.updateRows()
                }
            }
            deleteAction.backgroundColor = .white
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }
        let configuration = UISwipeActionsConfiguration()
        return configuration
    }
    
}

extension MultiplesStopsTableVIew: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  section == 0 ? self.myStops.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as! StopCell
        cell.setup()
        
        cell.newLocal = self.myStops[indexPath.row] != "" ? self.myStops[indexPath.row] : ""
        
        if indexPath.row == 0{
            cell.isOrigin = true
            cell.hasSwap = self.myStops.count == self.minimumStops ? true : false
            cell.setupOrigin()
            
        }else if indexPath.row == numberOfRows(inSection: 0) - 1{
            
            cell.isLast = indexPath.row == (self.limitStops - 1) ? true : false
            cell.isDestiny = true
            cell.setupDestiny()
            
        }else{
            cell.isStop = true
            cell.setupStop()
        }
        
        if self.myPoints[indexPath.row].visited ?? false{
            cell.blockCell()
        }
        
        cell.removeAtIndex = indexPath.row
        cell.delegate = self
        
        return cell
    }
}

extension MultiplesStopsTableVIew: UITableViewDragDelegate{
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if self.myPoints[indexPath.row].visited == false {
            return self.dragItems(for: indexPath)
        }
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let _visited = self.myPoints[indexPath.row].visited else {return [UIDragItem(itemProvider: NSItemProvider())]}
        if _visited{
            return self.dragItems(for: indexPath)
        }
        
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension MultiplesStopsTableVIew: UITableViewDropDelegate{
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return self.canHandle(session)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            guard let stringItems = items as? [String] else {return}
            
            var indexPaths = [IndexPath]()
            
            for (index, item) in stringItems.enumerated() {
                
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                self.addItem(item, at: indexPath.row)
                
                indexPaths.append(indexPath)
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
}

extension MultiplesStopsTableVIew: StopCellDelegate{
    
    func stopCell(insertText cell: StopCell, index: Int, title: String) {
        self.myDelegate?.didTapTxf(index: index, title: title)
    }
    
    func stopCell(editText cell: StopCell, address: String, index: Int) {
        self.myStops[index] = address
    }
    
    func stopCell(didTapAddStop cell: StopCell, index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if !(self.myStops.count == self.limitStops){
            self.myStops.append("")
            self.myPoints.append(Points(visited: false, address: Address(placeId: "", text: "", location: Location(latitude: 0.0, longitude: 0.0), number: ""), type: ""))
            self.beginUpdates()
            self.insertRows(at: [indexPath], with: .automatic)
            self.endUpdates()
            self.updateRows()
        }
        self.myDelegate?.verifyStops(view: self)
    }
    
    func stopCell(didTapRemoveStop cell: StopCell, index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if !(self.myStops.count == self.minimumStops){
            self.myStops[indexPath.row] = ""
            self.myStops.remove(at: index)
            self.myPoints.remove(at: index)
            self.beginUpdates()
            self.deleteRows(at: [indexPath], with: .automatic)
            self.endUpdates()
            self.updateRows()
        }
        self.myDelegate?.verifyStops(view: self)
    }
    
    func stopCell(didTapSwapStop cell: StopCell) {
        let origin = self.myStops[0]
        let _point = self.myPoints[0]
        self.myStops[0] = self.myStops[1]
        self.myPoints[0] = self.myPoints[1]
        self.myStops[1] = origin
        self.myPoints[1] = _point
        self.updateRows()
        self.myDelegate?.verifyStops(view: self)
    }
}
