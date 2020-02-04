//
//  MultiplesStopsViewController.swift
//  UBSetRoute
//
//  Created by Gustavo Rocha on 05/12/19.
//

import UIKit

protocol MultiplesStopsViewControllerDelegate: class {
    func editStopViewController(_ viewController: EditStopViewController, didChange text: String)
    func editStopViewController(didLoad viewController: EditStopViewController)
    func editStopViewController(callDriver countStops: Int, places: [Points])
    func editStopViewController(editStops countStops: Int, places: [Points])
    func editStopViewController(dismiss viewController: MultiplesStopsViewController )
    func editStopViewControllerDidCancel(_ viewController: MultiplesStopsViewController)
}

class MultiplesStopsViewController: UIViewController {
    
    weak var auxView: MapView?
    var auxViewIsHide: Bool = false
    
    var editPoints: [Points] = []
    var isEditingStops: Bool = false
    var chooseStops: Bool = false
    var editStopBeforeTravelBegin: Bool = false
    
    var myController: UIViewController = UIViewController()
    
    weak var delegate: MultiplesStopsViewControllerDelegate?
    lazy var mainView = NewView(controller: self)

    var routeView: RouteView? {
        return self.auxView?.routeView
    }
    var points: [Points] = []
    
    init(superView: MapView) {
        self.auxView = superView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        self.mainView.delegate = self
        self.view = self.mainView
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            if self.editStopBeforeTravelBegin {
                self.auxView?.backButton?.isHidden = false
            }
            if self.points.isEmpty {
                self.delegate?.editStopViewControllerDidCancel(self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if editStopBeforeTravelBegin {
            self.auxView?.backButton?.isHidden = true
        }
            self.routeView?.isHidden = true
            
            self.mainView.isEditingStops = self.isEditingStops
            if self.isEditingStops || self.chooseStops {
                self.setupNavigationBar()
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if !editStopBeforeTravelBegin {
            self.routeView?.isHidden = self.auxViewIsHide
            if self.auxViewIsHide{  self.routeView?.clear() }
            

            if isEditingStops{
                self.mainView.isEditingStops = false
                self.auxView?.isHidden = true
            }
            
            if chooseStops || isEditingStops {
                self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
                self.navigationController?.navigationBar.barTintColor = SetRouteViewSettings.shared.colors.mainColor
            }
            
        }
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    
    func setupLocalStop(index: Int, text: String, point: Points){
        self.mainView.tableView.myStops[index] = text
        self.mainView.tableView.myPoints[index] = point
        self.mainView.tableView.updateRows()
    }
    
    func setEditPoints(_ points: [Points]){
        self.editPoints = points
        self.mainView.setEditPoints(self.editPoints)
    }

    @objc
    func btnBackPressed(){
        self.routeView?.closedPressed = {
//            self.auxView.backButton?.isHidden = false
            self.routeView?.btnBack.isHidden = false
//            self.delegate?.cancelRouteEdit(self)
//            if let route = self.currentRoute {
        }
        self.navigationController?.popViewController(animated: true)
        self.delegate?.editStopViewController(dismiss: self)
    }
    
}

extension MultiplesStopsViewController: NewViewDelegate{
    func back() {
        //Do nothing
    }
    
    func editPoins(countStops: Int, places: [Points]) {
        self.auxViewIsHide = true
        self.delegate?.editStopViewController(editStops: countStops, places: places)
//        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func callDriver(countStops: Int, places: [Points]) {
        self.points = places
        self.auxViewIsHide = true
        self.delegate?.editStopViewController(callDriver: countStops, places: places)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didTapTxf(index: Int, title: String) {
        guard let routeView = self.routeView else { return }
        let nextVC = EditStopViewController(superView: routeView)
        nextVC.title = title
        nextVC.editAtIndex = index
        nextVC.delegate = self
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension MultiplesStopsViewController: EditStopViewControllerDelegate{
    func editStopViewController(_ viewController: EditStopViewController, didSelect text: String, atIndex: Int, point: Points) {
        self.setupLocalStop(index: atIndex, text: text, point: point)
        self.mainView.verifyStops()
    }
    
    func editStopViewController(_ viewController: EditStopViewController, didChange text: String) {
        self.delegate?.editStopViewController(viewController, didChange: text)
    }
    
    func editStopViewController(didLoad viewController: EditStopViewController){
        self.delegate?.editStopViewController(didLoad: viewController)
    }
}
