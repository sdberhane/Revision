//
//  SignUpViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import GoogleSignIn

class SignUpViewController: UIViewController, GIDSignInUIDelegate {

    @IBAction func signUpButton(_ sender: UIButton) {
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func nextButton(_ sender: UIButton) {
    }
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Google Signing In
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
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
