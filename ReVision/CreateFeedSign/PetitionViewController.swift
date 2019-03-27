//
//  PetitionViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 1/28/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MessageUI

class PetitionViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var userId: String?
    var ref : DatabaseReference?
    var currentSignatures : [String]?
    
    //Outlets
    @IBOutlet weak var petitionTitle: UILabel!
    @IBOutlet weak var petitionAuthor: UILabel!
    @IBOutlet weak var petitionImage: UIImageView!
    @IBOutlet weak var petitonProgress: UIProgressView!
    @IBOutlet weak var petitionDescription: UILabel!
    @IBOutlet weak var signButton: UIButton!
    
    //Action that Signs the petition or Sends the Petitoin if the proper requirements have been met
    @IBAction func sign(_ sender: Any) {
        if self.signButton.currentTitle == "SIGN" {
            
            //Chooses the proper node of this petition
            guard let uid = userId else {return}
            ref = Database.database().reference().child("Active Petitions/\(uid)/Signatures/\(currentSignatures?.count ?? -1)")
            //Will replace with users name later
            guard let userid = Auth.auth().currentUser?.uid else {return}
            print(userid)
            
            Database.database().reference().child("Users/\(userid)/Name").observeSingleEvent(of: .value) { (snapshot) in
                let val = snapshot.value as! NSString
                self.ref?.setValue(val as String)
                
            }
           // print(userName)
            
            
        }
        else if self.signButton.currentTitle == "SEND" {
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

        //If the node is properly chosen
        if let uid = userId{
            
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
                self.petitonProgress.setProgress( percentDone, animated: true)
                // replace SIGN with SEND if it is the user's petition and it has reached the goal signatures
                if uid == Auth.auth().currentUser?.uid && self.currentSignatures?.count ?? 0 >= goalSignatures {
                    self.signButton.setTitle("SEND", for: .normal)

                }
                
                if let petitionImageUrl = petition?.value(forKey: "Media File URL") as? String{
                    let url = NSURL(string: petitionImageUrl as! String)
                    URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                        if (error != nil){
                            print(error)
                            return
                        }
                        self.petitionImage?.image = UIImage(data:data!)
                    }).resume()
                }
                
            })
            
            
        }else{
            print("user id is nil!!")
        
        }
        // Do any additional setup after loading the view.
        
    }

    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //mailComposerVC.setToRecipients(["revision429@gmail.com"])
        mailComposerVC.setSubject(self.petitionTitle.text ?? "Title")
        mailComposerVC.setMessageBody(self.petitionDescription.text ?? "Description", isHTML: false)
        
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
