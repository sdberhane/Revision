//
//  PetitionTableViewCell.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/8/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statements
import UIKit 
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PetitionTableViewCell: UITableViewCell {
    // outlets and variables
    @IBOutlet weak var petitionSubtitle: UILabel!
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionImage: UIImageView!
    @IBOutlet weak var petitionTag: UILabel!
    @IBOutlet weak var saveForLater: UIBarButtonItem!
    @IBOutlet weak var petitionProgressView: UIProgressView!
    @IBOutlet weak var petitionUserName: UILabel!
    var creator: String?
    var id: String?
    var active: Bool = false

    // saving petitiosn when users click the bookmarks
    @IBAction func save(_ sender: Any) {
        // saving the petition under the user's branch in Firebase
        let userid = Auth.auth().currentUser?.uid
        guard let uid = userid else {return}
        let time = Date().description
        let ref = Database.database().reference().child("Users/\(uid)/Saved Petitions/\(time)")
        guard let id = id else {return}
        ref.setValue(id)
        saveForLater.image = #imageLiteral(resourceName: "saved4later.png")
    }

    // default methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
