//
//  FeedViewController.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 1/31/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statements
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    // outlets and variables
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var dict: [String: AnyObject]?
    var ref: DatabaseReference?
    //create an array of Petition objects
    var petitions = [Petition]()
    var userid: String?
    
    // segue to create view
    @IBAction func createPetition(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toCreateController", sender: nil)
    }
     
    let blackview = UIView()
    
    // opening the side menu
    @IBAction func sideMenuButtonTouchedUp(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
       
        if let window = UIApplication.shared.keyWindow{
            blackview.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            window.addSubview(blackview)
            blackview.frame = CGRect(x: 240, y: 0, width: Int(window.frame.width) - 240, height: Int(window.frame.height))
            blackview.alpha = 0
            
            blackview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBlackviewBack)))
            
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {self.blackview.alpha = 1}, completion: nil)
            
        }
    }
    
    // dismissing blackview
    @objc func dismissBlackviewBack(){
        UIView.animate(withDuration: 0.3) {
            self.blackview.alpha = 0
        }
        UIView.setAnimationDelay(0.3)
        
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
    }
    
    // animating dismiss
    @objc func dismissBlackview(){
        UIView.animate(withDuration: 0.3) {
            self.blackview.alpha = 0}
    }
    // returning the number of rows in the tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // returning the sections in the table view, one per petition
    func numberOfSections(in tableView: UITableView) -> Int {
        return dict?.count ?? 1
    }
    
    // returning height for header
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
                // setting the image to what was in the database
                if let petitionImageUrl = petition?.value(forKey: "Media File URL") as? String{
                    let url = NSURL(string: petitionImageUrl as! String)
                    URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                        if (error != nil){
                            print(error)
                            return
                        }
                        DispatchQueue.main.async {
                            cell.petitionImage?.image = UIImage(data:data!)
                        }
                        
                        
                    }).resume()
                }
                
                // cell display
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 2
                cell.layer.cornerRadius = 8
                cell.clipsToBounds = true
                
                // storing other values from database
                cell.creator = componentArray[section]
                let goalSignatures = petition?.value(forKey: "Goal") as? Int ?? 0
                let currentSignatures = petition?.value(forKey: "Signatures") as? [String]
                let percentDone = Float(Double(currentSignatures?.count ?? 0) / Double(goalSignatures))
                // setting petition progress and the author
                cell.petitionProgressView.setProgress(percentDone, animated: true)
                cell.petitionUserName.text = (petition?.value(forKey: "Author") as? String ?? "ERROR")
                
            }
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setting the navigation title to Feed and deselecting the cell after it is clicked
        self.navigationItem.title = "Feed"
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
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
        
        // observing the notifications so they run the selectors
        NotificationCenter.default.addObserver(self, selector: #selector(showSettings), name: NSNotification.Name("ShowSettings"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSearch), name: NSNotification.Name("ShowSearch"), object: nil)
        
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
        // moving completed petitions to the new branch
        let sample: [String: AnyObject] = [:]
        // componentArray is an array of the keys in the dictionary
        let componentArray = Array(self.dict?.keys ?? sample.keys)
        // if there are keys and elements in the dictionary, this will run
        if componentArray != []{
            for row in componentArray{
                let activeRef = Database.database().reference().child("Active Petitions").child(row)
                let completedRef = Database.database().reference().child("Completed Petitions")
                // moving completed petitions from the active branch to the completed branch
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
    
    // segueing to petition view based on which petition was selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "petitionView", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // preparing to segue to petition view by storing the userID, state, and petition ID in the petition view controller, removing navigation name to allow for a blue back button only
        if segue.identifier == "petitionView" {
            if let cell = sender as? PetitionTableViewCell {
                if let vc = segue.destination as? PetitionViewController {
                    vc.userId = cell.creator
                    vc.active = true
                    vc.petitionID = cell.creator
                    self.navigationItem.title = ""
                }
            }
        }
        // preparing to segue to second feed and storing petition category
        else if segue.identifier == "showSelectedPetitions" {
            
            if let vc = segue.destination as? SecondFeedViewController {
                vc.navigationItem.title = "Second Feed"
                vc.petitionCategory = sender as? Int
            }
        }
        
    }
    
    // all the fuunctions to allow for senders to identify which category of petition is selected
    @objc func showSettings() {
        performSegue(withIdentifier: "ShowSettings", sender: nil)
        dismissBlackview()
    }
    
    @objc func showSearch() {
        performSegue(withIdentifier: "ShowSearch", sender: nil)
        dismissBlackview()
    }
    
    @objc func showSignedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 0)
        dismissBlackview()
    }
    
    @objc func showSavedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 1)
        dismissBlackview()
    }
    
    @objc func showCreatedPetitions() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 2)
        dismissBlackview()
    }
    
    @objc func showFreshmenTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 3)
        dismissBlackview()
    }

    @objc func showSophomoreTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 4)
        dismissBlackview()
    }

    @objc func showJuniorTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 5)
        dismissBlackview()
    }

    @objc func showSeniorTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 6)
        dismissBlackview()
    }

    @objc func showParentsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 7)
        dismissBlackview()
    }
    
    @objc func showTeachersTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 8)
        dismissBlackview()
    }
    
    @objc func showAcademicsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 9)
        dismissBlackview()
    }
    
    @objc func showClubsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 10)
        dismissBlackview()
    }

    @objc func showFacilitiesTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 11)
        dismissBlackview()
    }
    
    @objc func showGraduationTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 12)
        dismissBlackview()
    }
    
    @objc func showScheduleTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 13)
        dismissBlackview()
    }
    
    @objc func showSportsTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 14)
        dismissBlackview()
    }
    
    @objc func showOtherTag() {
        performSegue(withIdentifier: "showSelectedPetitions", sender: 15)
        dismissBlackview()
    }
  
}
