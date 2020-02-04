//
//  EditStopViewController.swift
//  Pods-UBSetRoute_Example
//
//  Created by Gustavo Rocha on 16/12/19.
//

import UIKit

protocol EditStopViewControllerDelegate: class {
    func editStopViewController(_ viewController: EditStopViewController, didChange text: String)
    func editStopViewController(_ viewController: EditStopViewController, didSelect text: String, atIndex: Int, point: Points)
    func editStopViewController(didLoad viewController: EditStopViewController)
}

class EditStopViewController: UIViewController {
    
    lazy var newView = EditStopView()
    weak var delegate: EditStopViewControllerDelegate?
    weak var superviewAux: RouteView?
    var editStopBeforeTravelBegin: Bool = false
    
    var editAtIndex = 0
    
    init(superView: RouteView) {
        self.superviewAux = superView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !self.editStopBeforeTravelBegin {
            self.superviewAux?.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if !self.editStopBeforeTravelBegin {
            self.superviewAux?.isHidden = false
            self.superviewAux?.clear()
        }
    }
    
    public override func loadView() {
        self.view = self.newView
        self.newView.delegate = self
        self.delegate?.editStopViewController(didLoad: self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
}

extension EditStopViewController: EditStopDelegate{
    func editstopview(view: EditStopView, didSelect text: String, point: Points) {
        self.delegate?.editStopViewController(self, didSelect: text, atIndex: self.editAtIndex, point: point)
        self.navigationController?.popViewController(animated: true)
        self.newView.stopProgress()
    }
    
    func editstopview(view: EditStopView, didChange text: String) {
        self.delegate?.editStopViewController(self, didChange: text)
        self.newView.isProgressAnimating = true
        self.newView.startProgress()
    }
}
