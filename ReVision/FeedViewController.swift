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
        let cell = tableView.dequeueReusableCell(withIdentifier: "petitionCell", for: indexPath) as! PokemonTableViewCell
        let row = indexPath.row
        let sample: [String: AnyObject] = [:]
        let componentArray = Array(dict?.keys ?? sample.keys)
        if componentArray != []{
            let ref2 = Database.database().reference().child("Pokemon").child(componentArray[row])
            var postDict: [String: AnyObject] = [:]
            ref2.observe(.value) { (snapshot) in
                postDict = snapshot.value as? [String : AnyObject] ?? [:]
                //self.tableView.reloadData()
                let error = "error"
                cell.nameLabel.text = postDict["Name"] as? String
                cell.typeLabel.text = "Type: \(postDict["Type"] as? String ?? error)"
                cell.hpLabel.text = "HP: \(postDict["HP"] as? String ?? error)"
                cell.levelLabel.text = "Level: \(postDict["Level"] as? String ?? error)"
                cell.abilityLabel.text = "Ability: \(postDict["Ability"] as? String ?? error)"
                
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
