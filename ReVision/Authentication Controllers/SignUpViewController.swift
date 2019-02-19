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
                
                //Checks to see if they are not a freshmen, if they aren't it adds an s so that
                //it will be Sophmores and not Sophmore in the database
                guard var role = self.role else {return}
                
                //Creates the user
                let ref = Database.database().reference().child("Users/\(uid)")
                
                //Sets particular values
                ref.child("Name").setValue(name)
                ref.child("School").setValue(school)
                ref.child("Grade").setValue(role)
                ref.child("Signed Petitions").setValue(nil)
                ref.child("Created Petitions").setValue(nil)
                
                //Dismisses to Home Screen View Controller
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print(error.debugDescription)
            }
        }
        
 
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Sets delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        schoolNameTextField.delegate = self
        gradeRoleChooser.delegate = self
        

        // Do any additional setup after loading the view.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Text field protocol
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
 
    //Picker View Protocol
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
        //So they won't have a blank role
        if choices[row] != ""{
            role = choices[row]
            emailTextField.becomeFirstResponder()
        }else{
            emailTextField.resignFirstResponder()
        }
    }
}
