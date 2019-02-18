//
//  SignUpViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/9/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
//import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    //Outlets
    @IBOutlet weak var gradeRoleChooser: UIPickerView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var schoolNameTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    //Instances that will need to be used multiple times throughout signing up
    var role : String?          //Grade, Teacher, or Parent chosen
    var choices = [String]()    //Array that contains all the choices for role
    
    //When the user is ready to sign up, the button must be turned on first by completing all the other functions
    @IBAction func signUpButtonTouchedUp(_ sender: UIButton) {
        
        //Creates strings for most of the values
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let name = usernameTextField.text else {return}
        guard let school = schoolNameTextField.text else {return}
        

        //Creates the user and then adds information about them into the database
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if user != nil, error == nil{
                print("user created")
                
                guard let uid = Auth.auth().currentUser?.uid else {return}
                guard var role = self.role else {return}
                if role != "Freshmen"{
                    role = role + "s"
                }
                let ref = Database.database().reference().child("Users/\(role)/\(uid)")

                ref.child("Name").setValue(name)
                ref.child("School").setValue(school)
                
                
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
        usernameTextField.delegate = self
        schoolNameTextField.delegate = self
        gradeRoleChooser.delegate = self
        

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
            signupButton.isEnabled = true
        }
        return true
    }
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        choices.append("")
        choices.append("Freshmen")
        choices.append("Sophmore")
        choices.append("Junior")
        choices.append("Senior")
        choices.append("Teacher")
        choices.append("Parent")
        return choices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if choices[row] != ""{
            role = choices[row]
            emailTextField.becomeFirstResponder()
        }else{
            emailTextField.resignFirstResponder()
        }
    }
}
