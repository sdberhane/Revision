//
//  SearchViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 2/26/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var activePetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ref = Database.database().reference().child("Active Petitions")
        
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Creating a dictionary of the Petitions
            let dicts = snapshot.value as? [String : AnyObject] ?? [:]
            for i in dicts.keys{
                let petit = dicts[i] as? [String : AnyObject] ?? [:]
               // print(petit)
                //Getting the data
                let petition = Petition()
                
                
                petition.title = petit["Title"] as? String
                petition.subtitle = petit["Subtitle"] as? String
                petition.creator = petit["Author"] as? String
                petition.description = petit["Description"] as? String
                self.activePetitions.append(petition)
                
                }
            print("    HERE                 ")
            print(self.activePetitions[0].creator)
            self.tableView.reloadData()
        })

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activePetitions.count > 0{
            return activePetitions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        let row = indexPath.row
        if activePetitions.count > 0{
            cell.textLabel?.text = activePetitions[row].title
        }
        return cell
    }

}
