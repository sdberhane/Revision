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
   
    @IBAction func createPetition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCreateController", sender: nil)
    }
    
    let blackview = UIView()
    
    @IBAction func sideMenuButtonTouchedUp(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
       
        if let window = UIApplication.shared.keyWindow{
            blackview.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            window.addSubview(blackview)
            blackview.frame = CGRect(x: 240, y: 0, width: Int(window.frame.width) - 240, height: Int(window.frame.height))
            blackview.alpha = 0
            
            blackview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBlackview)))
            
            UIView.animate(withDuration: 0.3) {
                self.blackview.alpha = 1
            }
        }
        
        
    }
    
    @objc func dismissBlackview(){
        UIView.animate(withDuration: 0.3) {
            self.blackview.alpha = 0
        }
        UIView.setAnimationDelay(0.3)
        
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
    }
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    var dict: [String: AnyObject]?
    var ref: DatabaseReference?
    //create an array of Petition objects
    var petitions = [Petition]()
    var userid: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dict?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // creating a table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "petitionCell", for: indexPath) as! PetitionTableViewCell 
        let section = indexPath.section
        // sample is an empty placeholder dictionary
        let sample: [String: AnyObject] = [:]
        // componentArray is an array of the keys in the dictionary
        let componentArray = Array(dict?.keys ?? sample.keys)
        // if there are keys and elements in the dictionary, this will run
        if componentArray != []{
            // creating another dictionary based on the user ID
            // key is the title/description/whatever
            // value is whatever the value it is
            guard Auth.auth().currentUser != nil else {return UITableViewCell()}
            let ref2 = Database.database().reference().child("Active Petitions").child(componentArray[section])
            ref2.observe(.value) { (snapshot) in
                let petition = snapshot.value as? NSDictionary
                // setting the petition titles and description to whatever is in the database
                cell.id = snapshot.key
                cell.petitionTitle.text = petition?.value(forKey: "Title") as? String
                cell.petitionSubtitle.text = petition?.value(forKey: "Subtitle") as? String
                cell.petitionTag.text = petition?.value(forKey: "Tag") as? String
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
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 8
                cell.clipsToBounds = true
                cell.creator = componentArray[section]
                
                cell.petitionProgressView.transform = cell.petitionProgressView.transform.scaledBy(x: 1, y: 30)
                let goalSignatures = petition?.value(forKey: "Goal") as? Int ?? 0
                let currentSignatures = petition?.value(forKey: "Signatures") as? [String]
                let percentDone = Float(Double(currentSignatures?.count ?? 0) / Double(goalSignatures))
                cell.petitionProgressView.setProgress(percentDone, animated: true)
                
                cell.petitionUserName.text = (petition?.value(forKey: "Author") as? String ?? "ERROR")
                
            }
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Feed"

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

         NotificationCenter.default.addObserver(self, selector: #selector(showFreshmenTag), name: NSNotification.Name("ShowFreshmen"), object: nil)

         NotificationCenter.default.addObserver(self, selector: #selector(showSophomoreTag), name: NSNotification.Name("ShowSophomore"), object: nil)

         NotificationCenter.default.addObserver(self, selector: #selector(showJuniorTag), name: NSNotification.Name("ShowJunior"), object: nil)

         NotificationCenter.default.addObserver(self, selector: #selector(showSeniorTag), name: NSNotification.Name("ShowSenior"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showParentsTag), name: NSNotification.Name("ShowParents"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showTeachersTag), name: NSNotification.Name("ShowTeachers"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showSportsTag), name: NSNotification.Name("ShowSports"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showClubsTag), name: NSNotification.Name("ShowClubs"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(showAcademicsTag), name: NSNotification.Name("ShowAcademics"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showGraduationTag), name: NSNotification.Name("ShowGraduation"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showFacilitiesTag), name: NSNotification.Name("ShowFacilities"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showScheduleTag), name: NSNotification.Name("ShowSchedule"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showOtherTag), name: NSNotification.Name("ShowOther"), object: nil)

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
        
        // idk someone change the colors here later
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.blackTranslucent
        nav?.tintColor = UIColor.cyan
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "petitionView", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "petitionView" {
            if let cell = sender as? PetitionTableViewCell {
                if let vc = segue.destination as? PetitionViewController {
                    vc.userId = cell.creator
                    self.navigationItem.title = ""
                }
            }
        }
        else if segue.identifier == "showSelectedPetitions" {
            
            if let vc = segue.destination as? SecondFeedViewController {
                vc.navigationItem.title = "Second Feed"
                vc.petitionCategory = sender as? Int
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
        performSegue(withIdentifier: "showSelectedPetitions", sender: 0)
    }
    
    @objc func showSavedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 1)
    }
    
    @objc func showCreatedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 2)
    }
    
    @objc func showFreshmenTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 3)
    }

    @objc func showSophomoreTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 4)
    }

    @objc func showJuniorTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 5)
    }

    @objc func showSeniorTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 6)
    }

    @objc func showParentsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 7)
    }
    
    @objc func showTeachersTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 8)
    }
    
    @objc func showAcademicsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 9)
    }
    
    @objc func showClubsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 10)
    }

    @objc func showFacilitiesTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 11)
    }
    
    @objc func showGraduationTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 12)
    }
    
    @objc func showScheduleTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 13)
    }
    
    @objc func showSportsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 14)
    }
    
    @objc func showOtherTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 15)
    }
    
//    @objc func showHomescreen() {
//        performSegue(withIdentifier: "ShowSignIn", sender: nil)
//    }

  
}
