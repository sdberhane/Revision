//
//  SearchViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 2/26/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController {
    
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var activePetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillArrays()
        print("OKKKKKKKKKKKKKAYYYYYYYYY")
        print(activePetitions.description)
        // Do any additional setup after loading the view.
    }
    
    func fillArrays(){
        ref = Database.database().reference().child("Active Petitions")
        
        repeat {
            ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Creating a dictionary of the Petitions
            let dicts = snapshot.value as? [String : AnyObject] ?? [:]
            for i in dicts.keys{
                let petit = dicts[i] as? [String : AnyObject] ?? [:]
               // print(petit)
                //Getting the data
                let petition = Petition()
                petition.creator = petit["Title"] as? String
                petition.subtitle = petit["Subtitle"] as? String
                petition.creator = petit["Author"] as? String
                petition.description = petit["Description"] as? String
                self.activePetitions.append(petition)
                print("OH YEAH")
            }
            })
        } while activePetitions.count != 0
    print(activePetitions.description)
    print(activePetitions.count)
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
