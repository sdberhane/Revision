//
//  SignUpViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func nextButton(_ sender: UIButton) {
    }
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpButtonTouchedUp(_ sender: UIButton) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        guard let school = schoolNameTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if user != nil, error == nil{
                print("user created")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print(error.debugDescription)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
//usernameTextField.delegate = self
        schoolNameTextField.delegate = self
        
        emailTextField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        }
        else if passwordTextField.isFirstResponder {
            usernameTextField.becomeFirstResponder()
        }
        else if usernameTextField.isFirstResponder {
            schoolNameTextField.becomeFirstResponder()
        }
        else if schoolNameTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        }
        else {
            passwordTextField.resignFirstResponder()
            signUpButton.isEnabled = true
        }
        return true
    }
 

}
