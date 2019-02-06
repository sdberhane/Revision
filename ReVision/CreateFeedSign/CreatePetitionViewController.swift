//
//  CreatePetitionViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 2/1/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class CreatePetitionViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var ref = Database.database().reference()
    var petition:Petition?
    let userID = Auth.auth().currentUser?.uid
    var petitionDict: [String:Any]?
    var imagePicker: UIImagePickerController?
    var imageURL = String()
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var petitionImageView: UIImageView!
    @IBAction func createPetitionButton(_ sender: UIButton) {
        petitionDict = [
            "Title" : titleTextField?.text ?? " ",
            "Subtitle" : subtitleTextView.text ?? " ",
            "Signatures" : [" "],
            "Goal": Int(goalTextField.text ?? "0"),
            "Description": descriptionTextView?.text,
            "ImageURL" : imageURL
        ]
        ref.child("Active Petitions").child(userID ?? " ").setValue(petitionDict)

    }
  
    @IBAction func imageTapped(_ sender: Any) {
        self.present(imagePicker!,animated:true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        petitionImageView.layer.borderWidth = 1
        petitionImageView.layer.masksToBounds = false
        petitionImageView.layer.borderColor = UIColor.blue.cgColor
        petitionImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker?.allowsEditing = true
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.delegate = self
        
        getImageURL(){url in
            let storage = Storage.storage()
            guard let imageURL = url else {return}
            let ref = storage.reference(forURL: imageURL)
            
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error == nil && data != nil{
                    self.petitionImageView.image=UIImage(data:data!)
                    self.reloadInputViews()
                }
                else{
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Set photoImageView to display the selected image.
        petitionImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        uploadPetitionImage(selectedImage){ url in
            guard let i = url else {return}
            //let database = self.ref.child("Active Petitions").child(self.userID!)
            self.imageURL = i.absoluteString
            //database.child("imageURL").setValue(userObject)
        }
    }
    
    func uploadPetitionImage(_ image: UIImage, _ completion: @escaping((_ url:URL?)->())){
        //reference to storage object
        let storage = Storage.storage().reference().child("petition images").child((self.titleTextField.text ?? " ")+".jpg")
        
        //images must be saved as data objects so convert and compress the image
        guard let image = petitionImageView?.image,let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        //store image
        storage.putData(imageData,metadata: StorageMetadata()){
            (metaData, error) in
            if error == nil && metaData != nil{
                storage.downloadURL{ url, error in guard let downloadURL = url else {return}
                    completion(downloadURL)
                }
            }else{
                completion(nil)
            }
        }
    }
    
    func getImageURL(_ completion: @escaping((_ url:String?)->())){
        let databaseRef = self.ref.child("Active Petitions").child(userID ?? " ")
        
        databaseRef.observeSingleEvent(of: .value, with: {snapshot in
            let postDict = snapshot.value as? [String:AnyObject] ?? [:]
            if let photoURL = postDict["photoURL"]{
                completion(photoURL as? String)
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }


}
