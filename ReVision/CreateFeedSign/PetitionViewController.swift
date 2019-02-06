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

    var uid: String?
    var ref : DatabaseReference?
    
    var userID
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionAuthor: UILabel!
    @IBOutlet weak var petitionButton: UIButton!
    @IBOutlet weak var petitionImage: UIImageView!
    @IBOutlet weak var petitonProgress: UIProgressView!
    @IBOutlet weak var petitionDescription: UILabel!
    @IBAction func sign(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = uid else {return}
        ref = Database.database().reference().child("Active Petitions/\(uid)")
        ref?.observe(.value, with: { (snapshot) in
            let petition = snapshot.value as? NSDictionary
            self.petitionTitle.text = "\(petition?.value(forKey: "Title"))"
            self.petitionAuthor.text = "\(petition?.value(forKey: "Title"))"
            self.petitionDescription.text = "\(petition?.value(forKey: "Title"))"
        })
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
