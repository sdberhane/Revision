//
//  SideMenuViewController.swift
//  ReVision
//
//  Created by Selassie Berhane (student LM) on 3/6/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
        
        switch indexPath.row {
        case 0: NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
        case 1: NotificationCenter.default.post(name: NSNotification.Name("ShowSearch"), object: nil)
        //case 2: NotificationCenter.default.post(name: NSNotification.Name("ShowHomescreen"), object: nil)
        default: break
        }
        
        
    }

}
