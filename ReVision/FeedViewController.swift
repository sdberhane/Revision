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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func createPetition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCreateController", sender: nil)
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
            let ref2 = Database.database().reference().child("Active Petitions").child(componentArray[row])
            ref2.observe(.value) { (snapshot) in
                var postDict = snapshot.value as? [String : AnyObject] ?? [:]
                // setting the petition titles and description to whatever is in the database
                cell.petitionTitle.text = postDict["Title"] as? String
                cell.petitionDescription.text = postDict["Description"] as? String
                //cell.petitionImage = ????
                //petitions.append(Petition(title: postDict["Title"] as? String, description: postDict["Description"] as? String, creator: componentArray[row], goalSignatures: postDict["Goal"] as? String, signatures: postDict["Signatures"] as? Array))
                
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creates a dictionary of each petition under "Active Petitions"
        // key is user ID, value is everything about the petition
        ref = Database.database().reference().child("Active Petitions")
        self.ref!.observe(.value) { (snapshot) in
            self.dict = snapshot.value as? [String : AnyObject] ?? [:]
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        // sample is an empty placeholder dictionary
        let sample: [String: AnyObject] = [:]
        self.ref!.observe(.value) { (snapshot) in
            self.dict = snapshot.value as? [String : AnyObject] ?? [:]
        }
        // componentArray is an array of the keys in the dictionary
        let componentArray = Array(dict?.keys ?? sample.keys)
        // if there are keys and elements in the dictionary, this will run
        if componentArray != []{
            userid = componentArray[row]
            performSegue(withIdentifier: "toPetitionViewController", sender: nil)
            print(userid)
        }
       // performSegue(withIdentifier: "tableToPetitionSegue", sender: nil)
        
    }
    
//    override func performSegue(withIdentifier identifier: String, sender: Any?) {
//        if let vc = segue.destination as? PetitionViewController {
//            vc.uid = userid
//            print(userid)
//        }
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PetitionViewController {
            vc.userId = userid
            print(userid)
            print("Prepare")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
