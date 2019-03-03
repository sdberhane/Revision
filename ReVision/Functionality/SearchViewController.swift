//
//  SearchViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 2/26/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var activePetitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.returnKeyType = UIReturnKeyType.done
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
        if filteredPetitions.count > 0{
            return filteredPetitions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        let row = indexPath.row
        if filteredPetitions.count > 0{
            cell.textLabel?.text = filteredPetitions[row].title
        }
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPetitions = activePetitions.filter({ (petition) -> Bool in
            guard let text = searchBar.text else {return false}
            return petition.title?.contains(text) ?? false
        })
        tableView.reloadData()
        //searchBar.text
    }
}
