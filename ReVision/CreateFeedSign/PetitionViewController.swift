//
//  PetitionViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 1/28/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statements
import UIKit
import FirebaseDatabase
import FirebaseAuth
import MessageUI

class PetitionViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // Declaring Variables
    var userId: String?
    var petitionID: String?
    var ref : DatabaseReference?
    var currentSignatures : [String]?
    var active: Bool?
    var name: String?
    
    // Outlets
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionAuthor: UILabel!
    @IBOutlet weak var petitionImage: UIImageView!
    @IBOutlet weak var petitionProgress: UIProgressView!
    @IBOutlet weak var petitionDescription: UITextView!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var signaturesLabel: UILabel!
    
    //Action that Signs the petition or Sends the Petition if the proper requirements have been met
    @IBAction func sign(_ sender: Any) {
        if signButton.titleLabel?.text == "SIGN" {
            
            //Chooses the proper node of this petition
            guard let uid = userId else {return}
            
            guard (Auth.auth().currentUser?.uid) != nil else {return}

             if !(currentSignatures?.contains(name ?? "") ?? false) {
                ref = Database.database().reference().child("Active Petitions/\(uid)/Signatures/\(currentSignatures?.count ?? 0)")
                self.ref?.setValue(name)
            }
            else {
                let alreadySignedAlert = UIAlertController(title: "Already Signed", message: "You have already signed this petition.", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alreadySignedAlert.addAction(dismiss)
                self.present(alreadySignedAlert, animated: true, completion: nil)
            }
            //Will replace with users name later
            
        }
        else {
            let mailComposeViewController = configureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
                
            } else {
                showMailError()
            }
            
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sign Petition"
        
        petitionDescription.layer.borderColor = UIColor.darkGray.cgColor
        petitionDescription.layer.borderWidth = 1
        petitionDescription.layer.cornerRadius = 5
        petitionProgress.layer.cornerRadius = 100
        //If the node is properly chosen
        if let uid = userId{
            if active ?? false {
                //Proper reference and then listening to that reference
                ref = Database.database().reference().child("Active Petitions/\(uid)")
                ref?.observe(.value, with: { (snapshot) in
                    //Dictionary from the petition
                    let petition = snapshot.value as? NSDictionary
                    
                    //Displays all the values of the petitions
                    self.petitionTitle.text = petition?.value(forKey: "Title") as? String
                    self.petitionAuthor.text = "By: " + (petition?.value(forKey: "Author") as? String ?? "ERROR")
                    self.petitionDescription.text = petition?.value(forKey: "Description") as? String
                    self.currentSignatures = petition?.value(forKey: "Signatures") as? [String]
                    let goalSignatures = petition?.value(forKey: "Goal") as? Int ?? 0
                    let percentDone = Float(Double(self.currentSignatures?.count ?? 0) / Double(goalSignatures))
                    self.petitionProgress.setProgress( percentDone, animated: true)
                    // replace SIGN with SEND if it is the user's petition and it has reached the goal signatures
                    self.signaturesLabel.text = "\(self.currentSignatures?.count ?? 0)/\(goalSignatures) Signatures"

                    if uid == Auth.auth().currentUser?.uid && self.currentSignatures?.count ?? 0 >= goalSignatures {
                        self.signButton.setTitle("SEND", for: .normal)
                    }
                    else{
                        self.signButton.setTitle("SIGN", for: .normal)
                    }
                    
                    if let petitionImageUrl = petition?.value(forKey: "Media File URL") as? String{
                        let url = NSURL(string: petitionImageUrl)
                        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                            if (error != nil){
                                print(error)
                                return
                            }
                            self.petitionImage?.image = UIImage(data:data!)
                        }).resume()
                    }
                    
                })
            }
            
            else {
                ref = Database.database().reference().child("Completed Petitions/\(petitionID ?? "")")
                ref?.observe(.value, with: { (snapshot) in
                    //Dictionary from the petition
                    let petition = snapshot.value as? NSDictionary
                    
                    //Displays all the values of the petitions
                    self.petitionTitle.text = petition?.value(forKey: "Title") as? String
                    self.petitionAuthor.text = "By: " + (petition?.value(forKey: "Author") as? String ?? "ERROR")
                    self.petitionDescription.text = petition?.value(forKey: "Description") as? String
                    self.currentSignatures = petition?.value(forKey: "Signatures") as? [String]
                    let goalSignatures = petition?.value(forKey: "Goal") as? Int ?? 0
                    let percentDone = Float(Double(self.currentSignatures?.count ?? 0) / Double(goalSignatures))
                    self.petitionProgress.setProgress( percentDone, animated: true)
                    self.signaturesLabel.text = "\(self.currentSignatures?.count ?? 0)/\(goalSignatures) Signatures"
                    // replace SIGN with SEND if it is the user's petition and it has reached the goal signatures
                    if uid == Auth.auth().currentUser?.uid && self.currentSignatures?.count ?? 0 >= goalSignatures {
                        self.signButton.setTitle("SEND", for: .normal)
                    }
                    else{
                        self.signButton.setTitle("SIGN", for: .normal)
                    }
                    
                    if let petitionImageUrl = petition?.value(forKey: "Media File URL") as? String{
                        let url = NSURL(string: petitionImageUrl)
                        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                            if (error != nil){
                                print(error)
                                return
                            }
                            self.petitionImage?.image = UIImage(data:data!)
                        }).resume()
                    }
                    
                })
            }
            
            guard (Auth.auth().currentUser?.uid) != nil else {return}
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Name").observeSingleEvent(of: .value) { (snapshot) in
                self.name = snapshot.value as? String
            }
            
        }else{
            print("user id is nil!!")
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        petitionTitle.adjustsFontSizeToFitWidth = true
    }

    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //mailComposerVC.setToRecipients(["revision429@gmail.com"])
        mailComposerVC.setSubject(self.petitionTitle.text ?? "Title")
        
        var message = self.petitionDescription.text + "\n\n Signatures: \n"
        for c in currentSignatures ?? [] {
            message += c+"\n"
        }
        print(message)
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

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
