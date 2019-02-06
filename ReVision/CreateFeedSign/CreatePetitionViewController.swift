//
//  CreatePetitionViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 2/1/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CreatePetitionViewController: UIViewController {
    var ref = Database.database().reference()
    var petition:Petition?
    let userID = Auth.auth().currentUser?.uid
    var petitionDict: [String:Any]?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBAction func createPetitionButton(_ sender: UIButton) {
        
       
        petitionDict = [
            "Title" : titleTextField?.text ?? " ",
            "Subtitle" : subtitleTextView.text ?? " ",
            "Signatures" : [userID," "],
            "Goal": Int(goalTextField.text ?? "0"),
            "Description": descriptionTextView?.text
        ]
        
        ref.child("Active Petitions").child(userID ?? " ").setValue(petitionDict)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
