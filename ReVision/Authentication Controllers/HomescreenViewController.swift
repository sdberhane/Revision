//
//  HomescreenViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseAuth

class HomescreenViewController: UIViewController {

    @IBAction func logInButton(_ sender: UIButton) {
        //performSegue(withIdentifier: "toContainerViewController", sender: nil)
    }
    @IBAction func signUpButton(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil{
            performSegue(withIdentifier: "toContainerViewController", sender: nil)
        }
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
