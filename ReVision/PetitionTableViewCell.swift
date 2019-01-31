//
//  PetitionTableViewCell.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 1/8/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class PetitionTableViewCell: UITableViewCell {
    @IBOutlet weak var petitionDescription: UILabel!
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
