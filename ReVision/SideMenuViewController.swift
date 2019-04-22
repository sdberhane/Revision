//
//  SideMenuViewController.swift
//  ReVision
//
//  Created by Selassie Berhane (student LM) on 3/6/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {

    
    @IBOutlet var sideMenuView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuView.layer.shadowOpacity = 1
        sideMenuView.layer.shadowRadius = 6
        sideMenuView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        sideMenuView.layer.cornerRadius = 3
        sideMenuView.layer.shadowOffset = CGSize(width: 1.75, height: 1.75)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
                
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
        switch indexPath.section{
        case 0:
            switch indexPath.row {
            case 0: NotificationCenter.default.post(name: NSNotification.Name("ShowSignedPetitions"), object: nil)
            case 1: NotificationCenter.default.post(name: NSNotification.Name("ShowSavedForLater"), object: nil)
            case 2: NotificationCenter.default.post(name: NSNotification.Name("ShowCreatedPetitions"), object: nil)
            case 3: NotificationCenter.default.post(name: NSNotification.Name("ShowSearch"), object: nil)
            case 4: NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
            default: break
        }
        case 1:
            switch indexPath.row {
            case 0: NotificationCenter.default.post(name: NSNotification.Name("ShowFreshmen"), object: nil)
            case 1: NotificationCenter.default.post(name: NSNotification.Name("ShowSophomore"), object: nil)
            case 2: NotificationCenter.default.post(name: NSNotification.Name("ShowJunior"), object: nil)
            case 3: NotificationCenter.default.post(name: NSNotification.Name("ShowSenior"), object: nil)
            case 4: NotificationCenter.default.post(name: NSNotification.Name("ShowParents"), object: nil)
            case 5: NotificationCenter.default.post(name: NSNotification.Name("ShowTeachers"), object: nil)
            case 6: NotificationCenter.default.post(name: NSNotification.Name("ShowAcademics"), object: nil)
            case 7: NotificationCenter.default.post(name: NSNotification.Name("ShowClubs"), object: nil)
            case 8: NotificationCenter.default.post(name: NSNotification.Name("ShowFacilities"), object: nil)
            case 9: NotificationCenter.default.post(name: NSNotification.Name("ShowGraduation"), object: nil)
            case 10: NotificationCenter.default.post(name: NSNotification.Name("ShowSchedule"), object: nil)
            case 11: NotificationCenter.default.post(name: NSNotification.Name("ShowSports"), object: nil)
            case 12: NotificationCenter.default.post(name: NSNotification.Name("ShowOther"), object: nil)
            default: break
        }
        default:
            break
        }
        
        if let index = self.sideMenuView.indexPathForSelectedRow{
            self.sideMenuView.deselectRow(at: index, animated: true)
        }

        
    }

}
