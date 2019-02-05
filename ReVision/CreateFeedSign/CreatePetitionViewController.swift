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
    var ref = Database.database().reference().child("Active Petitions").child("uid")
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBAction func createPetitionButton(_ sender: UIButton) {
        Petition(title: titleTextField.text ?? " ", description: descriptionTextView.text, creator: userID ?? " ", goalSignatures: Int(goalTextField.text ?? "0") ?? 0, signatures: [String](), anonymous: false)
    }
    let userID = Auth.auth().currentUser?.uid
    
    
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
