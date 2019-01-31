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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dict?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "petitionCell", for: indexPath) as! PetitionTableViewCell
        let row = indexPath.row
        let sample: [String: AnyObject] = [:]
        let componentArray = Array(dict?.keys ?? sample.keys)
        if componentArray != []{
            let ref2 = Database.database().reference().child("Active Petitions").child(componentArray[row])
            var postDict: [String: AnyObject] = [:]
            ref2.observe(.value) { (snapshot) in
                postDict = snapshot.value as? [String : AnyObject] ?? [:]
                let error = "error"
                cell.petitionTitle.text = postDict["Title"] as? String
                cell.petitionDescription.text = postDict["Description"] as? String
                //cell.petitionImage = ????
                
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
