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

class CreatePetitionViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    var ref = Database.database().reference()
    var petition:Petition?
    let userID = Auth.auth().currentUser?.uid ?? ""
    let fileID = Database.database().reference().child("Active Petitions/\(Auth.auth().currentUser?.uid ?? "")")
    var petitionDict: [String:Any]?
    var imagePicker: UIImagePickerController?
    var fileUrl = String()
    var tagOptions = [String?]()
    var tag : String?
    var author : String?
    var grade : String?
    var imageName: String?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var petitionImageView: UIImageView!
    @IBOutlet weak var tagPicker: UIPickerView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBAction func createPetitionButton(_ sender: UIButton) {
        
        if titleTextField?.text?.count ?? 10 > 50{
            let alreadySignedAlert = UIAlertController(title: "Too Many Characters", message: "Please Make Title Shorter", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alreadySignedAlert.addAction(dismiss)
            self.present(alreadySignedAlert, animated: true, completion: nil)
            titleTextField.text = ""
        }
        petitionDict = [
            "Title" : titleTextField?.text ?? " ",
            "Subtitle" : subtitleTextView.text ?? " ",
            "Tag" : tag ?? " ",
            "Signatures" : [],
            "Goal": Int(goalTextField.text ?? "0"),
            "Description": descriptionTextView?.text,
            "Media File URL" : fileUrl,
            "Author" : author ?? " "
        ]
        guard let uid = Auth.auth().currentUser?.uid else {return}
        fileID.setValue(petitionDict)
        
        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func petitionImageViewTapped(_ sender: UITapGestureRecognizer) {
        self.present(imagePicker!, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.safeAreaLayoutGuide
        //view.addConstraint(view.sa) view.safeAreaLayoutGuide.widthAnchor
    
        petitionImageView.layer.cornerRadius = 10
        petitionImageView.layer.borderWidth = 10
        petitionImageView.layer.borderColor = UIColor.gray.cgColor
        
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.borderWidth = 1.5
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        
        goalTextField.layer.cornerRadius = 6
        goalTextField.layer.borderWidth = 1.5
        goalTextField.layer.borderColor = UIColor.gray.cgColor
        
        
        view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        //view.widthAnchor.constraint(equalToConstant: width).isActive = true
      //  scrollView.widthAnchor.constraint(equalToConstant: width).isActive = true
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 1.5
        
        
        subtitleTextView.layer.cornerRadius = 10
        subtitleTextView.layer.borderColor = UIColor.gray.cgColor
        subtitleTextView.layer.borderWidth = 1.5
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let refere = Database.database().reference().child("Users/\(uid)/Name")
        refere.observeSingleEvent(of: .value) { (snapshot) in
            self.author = snapshot.value as? String
        }
        
        tagPicker.delegate = self
        tagPicker.dataSource = self
        
        petitionImageView.isUserInteractionEnabled = true
        
        petitionImageView.layer.borderWidth = 1
        petitionImageView.layer.masksToBounds = false
        petitionImageView.layer.borderColor = UIColor.blue.cgColor
        petitionImageView.clipsToBounds = true
        
//        imagePicker?.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker?.allowsEditing = true
            imagePicker?.delegate = self
            imagePicker?.sourceType = .photoLibrary
            print("another one")
        }
        
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
        
        self.navigationItem.title = "Create A Petition"
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            var selectedImageFromPicker:UIImage?
  
            if let originalImage = info[.originalImage] as? UIImage{
                selectedImageFromPicker = originalImage
                print("inside if")
                uploadPetitionImage(originalImage){ url in
                    print("inside the method")
                    guard let i = url else {return}
                    self.fileUrl = i.absoluteString
                    print("this is the url",i.absoluteString)
                    print("uploaded image")
                    self.imagePicker?.dismiss(animated: true, completion: nil)
                }
            }
            
            petitionImageView.image = selectedImageFromPicker
        
      //  imagePicker?.dismiss(animated: true, completion: nil)
        print("dimissed please")
    }
    
    func uploadPetitionImage(_ image: UIImage, _ completion: @escaping((_ url:URL?)->())){
        //reference to storage object
        print("hello this is me")
        imageName = randomString(20) as String
        let storage = Storage.storage().reference().child("petition media files").child(imageName ?? " ")
        print("media files")
        
        //images must be saved as data objects to convert and compress the image
        guard let image = petitionImageView?.image, let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        
        print("this is me again")
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
        print("hows it going")
    }
    
    
    func randomString(_ length: Int)-> String{
        let letters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getfileUrl(_ completion: @escaping((_ url:String?)->())){
        let databaseRef = self.ref.child("Active Petitions").child(userID)
        
        databaseRef.observeSingleEvent(of: .value, with: {snapshot in
            let postDict = snapshot.value as? [String:AnyObject] ?? [:]
            if let photoURL = postDict["photoURL"]{
                completion(photoURL as? String)
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 14
    }
    
  
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        guard let uid = Auth.auth().currentUser?.uid else {return "ERROR"}
//        var handler = Database.database().reference().child("Users/\(uid)/Grade").observe(.value) { (snapshot) in
//            self.grade = snapshot.value as? String
//        }
//        if let grd = grade {
//            tagOptions.append(grd)
//        }else{
//            tagOptions.append("Freshmen")
//        }
        tagOptions.append("Freshmen")
        tagOptions.append("Sophomore")
        tagOptions.append("Juniors")
        tagOptions.append("Seniors")
        tagOptions.append("Sports")
        tagOptions.append("Parents")
        tagOptions.append("Teachers")
        tagOptions.append("Sports")
        tagOptions.append("Clubs")
        tagOptions.append("Academics")
        tagOptions.append("Graduation")
        tagOptions.append("Facilities")
        tagOptions.append("Schedule")
        tagOptions.append("Other")
        return tagOptions[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tag = tagOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        tagOptions.append("Freshmen")
        tagOptions.append("Sophomore")
        tagOptions.append("Juniors")
        tagOptions.append("Seniors")
        tagOptions.append("Sports")
        tagOptions.append("Parents")
        tagOptions.append("Teachers")
        tagOptions.append("Sports")
        tagOptions.append("Clubs")
        tagOptions.append("Academics")
        tagOptions.append("Graduation")
        tagOptions.append("Facilities")
        tagOptions.append("Schedule")
        tagOptions.append("Other")
        return NSAttributedString(string: tagOptions[row] ?? "Freshmen", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
