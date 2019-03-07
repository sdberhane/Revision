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
import AVFoundation
import MobileCoreServices

class CreatePetitionViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var ref = Database.database().reference()
    var petition:Petition?
    let fileID = Database.database().reference().child("Active Petitions").childByAutoId()
    let userID = Auth.auth().currentUser?.uid
    var petitionDict: [String:Any]?
    var imagePicker: UIImagePickerController?
    var fileUrl = String()
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
            "Media File URL" : fileUrl,
            "Author" : userID
            //ref.child("Users").child(userID!).value(forKey:"Name" ?? " ")
        ]
        fileID.setValue(petitionDict)
        
        self.dismiss(animated: true, completion: nil)

    }
  
    @IBAction func imageTapped(_ sender: Any) {
        self.present(imagePicker!,animated:true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       petitionImageView.isUserInteractionEnabled = true
        petitionImageView.layer.borderWidth = 1
        petitionImageView.layer.masksToBounds = false
        petitionImageView.layer.borderColor = UIColor.blue.cgColor
        petitionImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker?.allowsEditing = true
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.delegate = self
        imagePicker?.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        getfileUrl(){url in
            let storage = Storage.storage()
            guard let fileUrl = url else {return}
            let ref = storage.reference(forURL: fileUrl)
            
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
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
           //selected a video
            let storage = Storage.storage().reference().child("petition media files").child(fileID.key ?? " ")
            
            storage.putFile(from: videoUrl as! URL, metadata: StorageMetadata(), completion: {(metadata,error) in
                if error == nil && metadata != nil{
                    
//                    storage.downloadURL{ url, error in guard let downloadURL = url else {return}completion(downloadURL)
//                    }
                }
                
                storage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Failed to download url:", error!)
                        return
                    } else {
                        guard let i = url else {return}
                        self.fileUrl = i.absoluteString
                        print("this is the url",i)
                        self.petitionImageView.image = self.videoPreview(videoUrl: url!)
                        self.reloadInputViews()
                    }
                })
            })
            
        } else {
            var selectedImageFromPicker:UIImage?
            
            print("uploaded image")
            
            if let originalImage = info[.originalImage] as? UIImage{
                selectedImageFromPicker = originalImage
                
                    uploadPetitionImage(originalImage){ url in
                        guard let i = url else {return}
                        self.fileUrl = i.absoluteString

                }
            }
            petitionImageView.image = selectedImageFromPicker
        }
        
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func uploadPetitionImage(_ image: UIImage, _ completion: @escaping((_ url:URL?)->())){
        //reference to storage object
        let storage = Storage.storage().reference().child("petition media files").child(fileID.key ?? " ")
        
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
    
    func videoPreview(videoUrl:URL) -> UIImage? {
        
        let asset = AVURLAsset(url: videoUrl as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func getfileUrl(_ completion: @escaping((_ url:String?)->())){
        let databaseRef = self.ref.child("Active Petitions").child(fileID.key ?? " ")
        
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
