//
//  PetitionTableViewCell.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/8/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit 
import FirebaseAuth
import FirebaseDatabase

class PetitionTableViewCell: UITableViewCell {
    @IBOutlet weak var petitionDescription: UILabel!
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionImage: UIImageView!
    var creator: String?
    var id: String?
    
    @IBOutlet weak var saveForLater: UIBarButtonItem!
    
    @IBAction func save(_ sender: Any) {
        let userid = Auth.auth().currentUser?.uid
        guard let uid = userid else {return}
        let ref = Database.database().reference().child("Users/\(uid)/Saved Petitions")
        guard let id = id else {return}
        ref.setValue(id)
        saveForLater.image = #imageLiteral(resourceName: "saved4later.png")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
