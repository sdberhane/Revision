//
//  SecondFeedViewController.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 3/11/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class SecondFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var activePetitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "secondFeedCell", for: indexPath) as! PetitionTableViewCell
//        let row = indexPath.row
//        cell.petitionTitle.font = Fonts().titleFont
//        if filteredPetitions.count > 0{
//            cell.petitionTitle.text = filteredPetitions[row].title
//            cell.petitionSubtitle.text = filteredPetitions[row].subtitle
//            //cell.author.text = "By: \(filteredPetitions[row].author ?? "ERROR")"
//            cell.creator = filteredPetitions[row].creator
//
//        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ref = Database.database().reference().child("Active Petitions")

        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            for d in dict.keys {
                let petitionKey = dict[d] as? [String : AnyObject] ?? [:]
                let petition = Petition()

                petition.title = petitionKey["Title"] as? String
                petition.subtitle = petitionKey["Subtitle"] as? String
                petition.author = petitionKey["Author"] as? String
                petition.description = petitionKey["Description"] as? String
                petition.creator = d
                self.activePetitions.append(petition)

            }

            self.tableView.reloadData()
        })
        //need to figure out how to pass what type of feed they want
//        filteredPetitions = activePetitions.filter({ (petition) -> Bool in
//            if  {
//                return true
//            }
//            return false
//        })

        self.tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? PetitionTableViewCell {
            if let vc = segue.destination as? PetitionViewController {
                vc.userId = cell.creator
            }
        }
    }


}
