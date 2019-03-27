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
                petition.author = petit["Author"] as? String
                petition.description = petit["Description"] as? String
                petition.creator = i
                self.activePetitions.append(petition)
                
                }
            print("    HERE                 ")
            print(self.activePetitions[0].creator)
            self.tableView.reloadData()
        })
        
        self.navigationItem.title = "Search"

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPetitions.count > 0{
            return filteredPetitions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedPetition", for: indexPath) as! SearchTableViewCell
        let row = indexPath.row
        cell.title.font = Fonts().titleFont
        if filteredPetitions.count > 0{
            //cell.textLabel?.text = filteredPetitions[row].title
            cell.title.text = filteredPetitions[row].title
            cell.subtitle.text = filteredPetitions[row].subtitle
            cell.author.text = "By: \(filteredPetitions[row].author ?? "ERROR")"
            cell.creator = filteredPetitions[row].creator
    
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? SearchTableViewCell {
            if let vc = segue.destination as? PetitionViewController {
                vc.userId = cell.creator
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPetitions = activePetitions.filter({ (petition) -> Bool in
            guard let text = searchBar.text else {return false}
//            return petition.title?.contains(text) ?? false
            if petition.title?.lowercased().contains(text.lowercased()) ?? false || petition.creator?.lowercased().contains(text.lowercased()) ?? false || petition.subtitle?.lowercased().contains(text.lowercased()) ?? false || petition.description?.lowercased().contains(text.lowercased()) ?? false {
                print(petition.description)
                return true
            }
            return false
        })
        tableView.reloadData()
        //searchBar.text
    }
}
