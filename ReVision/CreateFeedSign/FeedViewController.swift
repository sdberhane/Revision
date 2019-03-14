//
//  FeedViewController.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 1/31/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func signOut(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func createPetition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCreateController", sender: nil)
    }
    

    
    
    @IBAction func sideMenuButtonTouchedUp(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
    }
    
    
    

   
    
    
    @IBOutlet weak var tableView: UITableView!
    var dict: [String: AnyObject]?
    var ref: DatabaseReference?
    //create an array of Petition objects
    var petitions = [Petition]()
    var userid: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // creating a table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "petitionCell", for: indexPath) as! PetitionTableViewCell
        let row = indexPath.row
        // sample is an empty placeholder dictionary
        let sample: [String: AnyObject] = [:]
        // componentArray is an array of the keys in the dictionary
        let componentArray = Array(dict?.keys ?? sample.keys)
        // if there are keys and elements in the dictionary, this will run
        if componentArray != []{
            // creating another dictionary based on the user ID
            // key is the title/description/whatever
            // value is whatever the value it is
            guard let user = Auth.auth().currentUser else {return UITableViewCell()}
            let ref2 = Database.database().reference().child("Active Petitions").child(componentArray[row])
            ref2.observe(.value) { (snapshot) in
                let petition = snapshot.value as? NSDictionary
                // setting the petition titles and description to whatever is in the database
                cell.id = snapshot.key
                cell.petitionTitle.text = petition?.value(forKey: "Title") as? String
                cell.petitionSubtitle.text = petition?.value(forKey: "Subtitle") as? String
                if let petitionImageUrl = petition?.value(forKey: "Media File URL") as? String{
                    let url = NSURL(string: petitionImageUrl as! String)
                    URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                        if (error != nil){
                            print(error)
                            return
                        }
                        cell.petitionImage?.image = UIImage(data:data!)
                    }).resume()
                }
              
                cell.creator = componentArray[row]
                
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // creates a dictionary of each petition under "Active Petitions"
        // key is user ID, value is everything about the petition
      //  guard let user = Auth.auth().currentUser else {return}
        ref = Database.database().reference().child("Active Petitions")
        self.ref!.observe(.value) { (snapshot) in
            self.dict = snapshot.value as? [String : AnyObject] ?? [:]
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSettings), name: NSNotification.Name("ShowSettings"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSearch), name: NSNotification.Name("ShowSearch"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(showProfile), name: NSNotification.Name("ShowHomescreen"), object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(showSignedPetitions), name: NSNotification.Name("ShowSignedPetitions"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedPetitions), name: NSNotification.Name("ShowSavedForLater"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCreatedPetitions), name: NSNotification.Name("ShowCreatedPetitions"), object: nil)

        
    }

        
    
    override func viewDidAppear(_ animated: Bool) {
        let sample: [String: AnyObject] = [:]
        // componentArray is an array of the keys in the dictionary
        let componentArray = Array(self.dict?.keys ?? sample.keys)
        // if there are keys and elements in the dictionary, this will run
        if componentArray != []{
            for row in componentArray{
                let activeRef = Database.database().reference().child("Active Petitions").child(row)
                let completedRef = Database.database().reference().child("Completed Petitions")
                activeRef.observeSingleEvent(of: .value) { (snapshot) in
                    var petition = snapshot.value as? [String: AnyObject] ?? [:]
                    let currentSignatures = petition["Signatures"] as? [String]
                    let numSignatures = currentSignatures?.count ?? 0
                    let goal = petition["Goal"] as? Int ?? 0
                    if numSignatures >= goal {
                        petition["Creator"] = row as AnyObject
                        completedRef.childByAutoId().updateChildValues(petition)
                        activeRef.removeValue()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "petitionView", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? PetitionTableViewCell {
            if let vc = segue.destination as? PetitionViewController {
                vc.userId = cell.creator
            }
        }
        
    }
    
    
    @objc func showSettings() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
    }
    
    @objc func showSearch() {
        performSegue(withIdentifier: "ShowSearch", sender: nil)
    }
    
    @objc func showSignedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: nil)
    }
    
    @objc func showSavedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: nil)
    }
    
    @objc func showCreatedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: nil)
    }
    
//    @objc func showHomescreen() {
//        performSegue(withIdentifier: "ShowSignIn", sender: nil)
//    }

  
}
