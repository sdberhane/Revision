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

    @IBOutlet weak var tableView: UITableView!
    var dict: [String: AnyObject]?
    var ref: DatabaseReference?
    //create an array of Petition objects
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
