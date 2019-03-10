//
//  ContainerViewController.swift
//  ReVision
//
//  Created by Selassie Berhane (student LM) on 3/6/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var sideMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSideMenu),
                                               name: NSNotification.Name("showSideMenu"),
                                               object: nil)
        
    }
    
    
    @objc func showSideMenu(){
        
        if sideMenuOpen{
            sideMenuOpen = false
            sideMenuConstraint.constant = -250
        }
        else{
            sideMenuOpen = true
            sideMenuConstraint.constant = 0
            
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
   


}
