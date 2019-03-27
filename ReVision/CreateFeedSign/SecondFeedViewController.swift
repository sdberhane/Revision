//
//  SecondFeedViewController.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 3/11/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SecondFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var activePetitions: [Petition]?
    var filteredPetitions: [Petition]?
    var savedPetitions = [String]()
    var petitionCategory: Int?
    var name: String? 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredPetitions?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "secondFeedCell", for: indexPath) as! PetitionTableViewCell
        let section = indexPath.section
        cell.petitionTitle.font = Fonts().titleFont
        if filteredPetitions?.count ?? 0 > 0 {
            cell.petitionTitle.text = filteredPetitions?[section].title
            cell.petitionSubtitle.text = filteredPetitions?[section].subtitle
            cell.petitionTag.text = filteredPetitions?[section].tag
            //cell.author.text = "By: \(filteredPetitions[section].author ?? "ERROR")"
            cell.creator = filteredPetitions?[section].creator
            if let petitionImageUrl = filteredPetitions?[section].imageURL{
                let url = NSURL(string: petitionImageUrl as! String)
                URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                    if (error != nil){
                        print(error)
                        return
                    }
                    cell.petitionImage.image = UIImage(data:data!)
                }).resume()
            }
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true

        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activePetitions = [Petition]()
        filteredPetitions = [Petition]()
        
        ref = Database.database().reference().child("Active Petitions")

        ref?.observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            for d in dict.keys {
                let petitionKey = dict[d] as? [String : AnyObject] ?? [:]
                let petition = Petition()
                
                petition.title = petitionKey["Title"] as? String
                petition.subtitle = petitionKey["Subtitle"] as? String
                petition.author = petitionKey["Author"] as? String
                petition.description = petitionKey["Description"] as? String
                petition.creator = d
                petition.tag = petitionKey["Tag"] as? String
                petition.signatures = petitionKey["Signatures"] as? Array ?? []
                petition.imageURL = petitionKey["Media File URL"] as? String
                
                self.activePetitions?.append(petition)
                
            }
            
            self.tableView.reloadData()
        })
        
        ref = Database.database().reference().child("Completed Petitions")
        
        ref?.observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            for d in dict.keys {
                let petitionKey = dict[d] as? [String : AnyObject] ?? [:]
                let petition = Petition()
                
                petition.title = petitionKey["Title"] as? String
                petition.subtitle = petitionKey["Subtitle"] as? String
                petition.author = petitionKey["Author"] as? String
                petition.description = petitionKey["Description"] as? String
                petition.creator = petitionKey["Creator"] as? String
                petition.tag = petitionKey["Tag"] as? String
                petition.signatures = petitionKey["Signatures"] as? Array ?? []
                petition.imageURL = petitionKey["Media File URL"] as? String

                self.activePetitions?.append(petition)
                
                
            }
            
            self.tableView.reloadData()
            
        })
    Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Name").observeSingleEvent(of: .value) { (snapshot) in
            self.name = snapshot.value as? String
        }
        
        if petitionCategory == 1 {
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Saved Petitions").observeSingleEvent(of: .value) { (snapshot) in
                let dict = snapshot.value as? [String : String] ?? [:]
                for d in dict.values {
                    self.savedPetitions.append(d)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //need to figure out how to pass what type of feed they want
        filteredPetitions = activePetitions?.filter({ (petition) -> Bool in
            switch petitionCategory {
            case 0: // show signed petitions
                titleLabel.text = "Signed Petitions"
                if petition.signatures.contains(name ?? ""){
                    return true
                }
                return false
            case 1: // show saved petitions
                titleLabel.text = "Saved Petitions"
                if savedPetitions.contains(petition.creator ?? "") {
                    return true
                }
                return false
            case 2: // show created petitions
                titleLabel.text = "My Created Petitions"
                if petition.creator == Auth.auth().currentUser?.uid {
                    return true
                }
                return false
            case 3: // show petitions with freshmen tag
                titleLabel.text = "Freshmen Petitions"
                if petition.tag == "Freshmen"{
                    return true
                }
                return false
            case 4: // show petitions with sophomore tag
                titleLabel.text = "Sophomore Petitions"
                if petition.tag == "Sophomore"{
                    return true
                }
                return false
            case 5: // show petitions with junior tag
                titleLabel.text = "Junior Petitions"
                if petition.tag == "Junior"{
                    return true
                }
                return false
            case 6: // show petitions with senior tag
                titleLabel.text = "Senior Petitions"
                if petition.tag == "Senior"{
                    return true
                }
                return false
            case 7: // show petitions with parents tag
                titleLabel.text = "Parent Petitions"
                if petition.tag == "Parents"{
                    return true
                }
                return false
            case 8: // show petitions with teachers tag
                titleLabel.text = "Teacher Petitions"
                if petition.tag == "Teachers"{
                    return true
                }
                return false
            case 9: // show petitions with academics tag
                self.navigationItem.title = "Academics Petitions"
                titleLabel.text = "Academics Petitions"
                if petition.tag == "Academics"{
                    return true
                }
                return false
            case 10: // show petitions with clubs tag
                titleLabel.text = "Clubs Petitions"
                if petition.tag == "Clubs"{
                    return true
                }
                return false
            case 11: // show petitions with facilities tag
                titleLabel.text = "Facilities Petitions"
                if petition.tag == "Facilities"{
                    return true
                }
                return false
            case 12: // show petitions with graduation tag
                titleLabel.text = "Graduation Petitions"
                if petition.tag == "Graduation"{
                    return true
                }
                return false
            case 13: // show petitions with schedule tag
                titleLabel.text = "Schedule Petitions"
                if petition.tag == "Schedule"{
                    return true
                }
                return false
            case 14: // show petitions with sports tag
                titleLabel.text = "Sports Petitions"
                if petition.tag == "Sports"{
                    return true
                }
                return false
            case 15: // show petitions with other tag
                titleLabel.text = "Other Petitions"
                if petition.tag == "Other"{
                    return true
                }
                return false
            default:
                return false
            }
        })
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "petitionView2", sender: tableView.cellForRow(at: indexPath))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? PetitionTableViewCell {
            if let vc = segue.destination as? PetitionViewController {
                vc.userId = cell.creator
            }
        }
    }


}
