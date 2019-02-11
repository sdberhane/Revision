//
//  PetitionViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 1/28/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class PetitionViewController: UIViewController {

    var userId: String?
    var ref : DatabaseReference?
    var currentSignatures : [String]?
    
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionAuthor: UILabel!
    @IBOutlet weak var petitionButton: UIButton!
    @IBOutlet weak var petitionImage: UIImageView!
    @IBOutlet weak var petitonProgress: UIProgressView!
    @IBOutlet weak var petitionDescription: UILabel!
    @IBAction func sign(_ sender: Any) {
        guard let uid = userId else {return}
        print(currentSignatures?.count)
        ref = Database.database().reference().child("Active Petitions/\(uid)/Signatures/\(currentSignatures?.count ?? -1)")
        //Will replace with users name later
        ref?.setValue("HELLO")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //guard let uid = uid else {return}
        if let uid = userId{
            print("IT IS WORKKING \n \n YEAH")
            ref = Database.database().reference().child("Active Petitions/\(uid)")
            ref?.observe(.value, with: { (snapshot) in
                let petition = snapshot.value as? NSDictionary
                self.petitionTitle.text = petition?.value(forKey: "Title") as? String
                self.petitionAuthor.text = "Written By: " + (petition?.value(forKey: "Author") as? String ?? "ERROR")
                self.petitionDescription.text = petition?.value(forKey: "Description") as? String
                self.currentSignatures = petition?.value(forKey: "Signatures") as? [String]
                let goalSignatures = petition?.value(forKey: "Goal") as? Double
                self.petitonProgress.progress = Float(Double(self.currentSignatures?.count ?? 0) / (goalSignatures ?? 100))
                
            })
        }else{
            print("user id is nil!!")
        
        }
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
