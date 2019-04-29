//
//  HomescreenViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statements
import UIKit
import FirebaseAuth
 
class HomescreenViewController: UIViewController {

    // outlets
    @IBAction func logInButton(_ sender: UIButton) {
    }
    @IBAction func signUpButton(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // seguing to container view controller if the user is already logged in
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toContainerViewController", sender: nil)
        }
    }
    
}
