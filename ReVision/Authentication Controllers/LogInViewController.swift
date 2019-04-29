//
//  LogInViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statement
import UIKit
import FirebaseAuth

class LogInViewController: UIViewController, UITextFieldDelegate {

    // outlets
    @IBAction func logInButton(_ sender: UIButton) {
        // storing email and password
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        // signing in the user and dismissing unless an error occurs
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil && user != nil{
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print(error!.localizedDescription)
            }
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    // dismissing view after user logs in
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
