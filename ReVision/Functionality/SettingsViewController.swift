//
//  SettingsViewController.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 3/5/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    //Logs the user out and sents them to the homescreen
    @IBAction func logOutButton(_ sender: UIButton) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    //Sets the nav title to settings
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
