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
        if filteredPetitions?.count ?? 0 > 0 {
            cell.petitionTitle.text = filteredPetitions?[section].title
            cell.petitionSubtitle.text = filteredPetitions?[section].subtitle
            cell.petitionTag.text = filteredPetitions?[section].tag
            //cell.author.text = "By: \(filteredPetitions[section].author ?? "ERROR")"
            cell.creator = filteredPetitions?[section].creator
            cell.active = filteredPetitions?[section].active ?? false
            cell.id = filteredPetitions?[section].ID
            if let petitionImageUrl = filteredPetitions?[section].imageURL{
                let url = NSURL(string: petitionImageUrl as! String)
                URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                    if (error != nil){
                        return
                    }
                    cell.petitionImage.image = UIImage(data:data!)
                }).resume()
            }
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
            
            let percentDone = Float(Double(filteredPetitions?[section].signatures.count ?? 0) / Double(filteredPetitions?[section].goalSignatures ?? 100))
            cell.petitionProgressView.setProgress(percentDone, animated: true)

            cell.petitionUserName.text = filteredPetitions?[section].author ?? "ERROR"

        }
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activePetitions = [Petition]()
        savedPetitions = [String]()
        activePetitions?.removeAll()
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
                petition.ID = d
                petition.goalSignatures = petitionKey["Goal"] as? Int ?? 0
                petition.tag = petitionKey["Tag"] as? String
                petition.signatures = petitionKey["Signatures"] as? Array ?? []
                petition.imageURL = petitionKey["Media File URL"] as? String
                petition.active = true
                
                self.activePetitions?.append(petition)
                
            }
            
            self.tableView.reloadData()
        })
        
        ref = Database.database().reference().child("Completed Petitions")
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
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
                petition.goalSignatures = petitionKey["Goal"] as? Int ?? 0
                petition.signatures = petitionKey["Signatures"] as? Array ?? []
                petition.imageURL = petitionKey["Media File URL"] as? String
                petition.active = false
                petition.ID = d

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
        filteredPetitions = [Petition]()
        
        //need to figure out how to pass what type of feed they want
        filteredPetitions = activePetitions?.filter({ (petition) -> Bool in
            switch petitionCategory {
            case 0: // show signed petitions
                self.navigationItem.title = "Signed Petitions"
                if petition.signatures.contains(name ?? ""){
                    return true
                }
                return false
            case 1: // show saved petitions
                self.navigationItem.title = "Saved Petitions"
                if savedPetitions.contains(petition.creator ?? "") {
                    return true
                }
                return false
            case 2: // show created petitions
                self.navigationItem.title = "My Created Petitions"
                if petition.creator == Auth.auth().currentUser?.uid {
                    return true
                }
                return false
            case 3: // show petitions with freshmen tag
                self.navigationItem.title = "Freshmen Petitions"
                if petition.tag == "Freshmen"{
                    return true
                }
                return false
            case 4: // show petitions with sophomore tag
                self.navigationItem.title = "Sophomore Petitions"
                if petition.tag == "Sophomore"{
                    return true
                }
                return false
            case 5: // show petitions with junior tag
                self.navigationItem.title = "Junior Petitions"
                if petition.tag == "Junior"{
                    return true
                }
                return false
            case 6: // show petitions with senior tag
                self.navigationItem.title = "Senior Petitions"
                if petition.tag == "Senior"{
                    return true
                }
                return false
            case 7: // show petitions with parents tag
                self.navigationItem.title = "Parent Petitions"
                if petition.tag == "Parents"{
                    return true
                }
                return false
            case 8: // show petitions with teachers tag
                self.navigationItem.title = "Teacher Petitions"
                if petition.tag == "Teachers"{
                    return true
                }
                return false
            case 9: // show petitions with academics tag
                self.navigationItem.title = "Academics Petitions"
                if petition.tag == "Academics"{
                    return true
                }
                return false
            case 10: // show petitions with clubs tag
               self.navigationItem.title = "Clubs Petitions"
                if petition.tag == "Clubs"{
                    return true
                }
                return false
            case 11: // show petitions with facilities tag
                self.navigationItem.title = "Facilities Petitions"
                if petition.tag == "Facilities"{
                    return true
                }
                return false
            case 12: // show petitions with graduation tag
                self.navigationItem.title = "Graduation Petitions"
                if petition.tag == "Graduation"{
                    return true
                }
                return false
            case 13: // show petitions with schedule tag
                self.navigationItem.title = "Schedule Petitions"
                if petition.tag == "Schedule"{
                    return true
                }
                return false
            case 14: // show petitions with sports tag
                self.navigationItem.title = "Sports Petitions"
                if petition.tag == "Sports"{
                    return true
                }
                return false
            case 15: // show petitions with other tag
                self.navigationItem.title = "Other Petitions"
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
                vc.active = cell.active
                vc.petitionID = cell.id
                self.navigationItem.title = ""

            }
        }
    }


}
