//
//  SearchTableViewCell.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 3/3/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var author: UILabel!
    var creator: String? = ""
    var active: Bool = false
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
