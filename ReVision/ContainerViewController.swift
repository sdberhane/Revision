//
//  ContainerViewController.swift
//  ReVision
//
//  Created by Selassie Berhane (student LM) on 3/6/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    // outlets and variables
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var sideMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // observing for the side menu notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSideMenu),
                                               name: NSNotification.Name("showSideMenu"),
                                               object: nil)
        
    }
    
    // opening and closing the side menu with animation
    @objc func showSideMenu(){
        if sideMenuOpen{
            sideMenuOpen = false
            sideMenuConstraint.constant = -240
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
