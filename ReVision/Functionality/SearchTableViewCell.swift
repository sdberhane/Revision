//
//  SearchTableViewCell.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 3/3/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var author: UILabel!
    
    //Instance Fields
    var creator: String? = ""
    var active: Bool = false
    var id: String?
    
    //Depreceated
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //Depreceated
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
