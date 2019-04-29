//
//  CreatePetitionViewController.swift
//  ReVision
//
//  Created by Sihan Wu (student LM) on 2/1/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

// import statements
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import AVFoundation

class CreatePetitionViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // declaring variables
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
    
    // outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var petitionImageView: UIImageView!
    @IBOutlet weak var tagPicker: UIPickerView!
    @IBOutlet var scrollView: UIScrollView!
    @IBAction func createPetitionButton(_ sender: UIButton) {
        // checking if the title is too long or not
        if titleTextField?.text?.count ?? 10 > 50{
            let alreadySignedAlert = UIAlertController(title: "Too Many Characters", message: "Please Make Title Shorter", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alreadySignedAlert.addAction(dismiss)
            self.present(alreadySignedAlert, animated: true, completion: nil)
            titleTextField.text = ""
        }
        // storing the values from the create into an array
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
        // setting the petition into firebase
        guard let uid = Auth.auth().currentUser?.uid else {return}
        fileID.setValue(petitionDict)
        
        // returning to the feed view after the user creates a petition
        self.navigationController?.popViewController(animated: true)

    }

    // opening the image picker when the user taps the image
    @IBAction func petitionImageViewTapped(_ sender: UITapGestureRecognizer) {
        self.present(imagePicker!, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // petition image view display settings
        petitionImageView.layer.cornerRadius = 10
        petitionImageView.layer.borderWidth = 10
        petitionImageView.layer.borderColor = UIColor.gray.cgColor
        
        // title text field display settings
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.borderWidth = 1.5
        titleTextField.layer.borderColor = UIColor.gray.cgColor
        
        // goal text field display settings
        goalTextField.layer.cornerRadius = 6
        goalTextField.layer.borderWidth = 1.5
        goalTextField.layer.borderColor = UIColor.gray.cgColor
        
        // constraining the view and implementing scroll view
        view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
     
        // description text view display settings
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 1.5
        
        // subtitle text view display settings
        subtitleTextView.layer.cornerRadius = 10
        subtitleTextView.layer.borderColor = UIColor.gray.cgColor
        subtitleTextView.layer.borderWidth = 1.5
        
        // getting the author's name
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let refere = Database.database().reference().child("Users/\(uid)/Name")
        refere.observeSingleEvent(of: .value) { (snapshot) in
            self.author = snapshot.value as? String
        }
        
        // implementing tag picker
        tagPicker.delegate = self
        tagPicker.dataSource = self
        
        // petition image view display settings
        petitionImageView.isUserInteractionEnabled = true
        petitionImageView.layer.borderWidth = 1
        petitionImageView.layer.masksToBounds = false
        petitionImageView.layer.borderColor = UIColor.blue.cgColor
        petitionImageView.clipsToBounds = true
        
        // checking if the photo library is accessible
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker?.allowsEditing = true
            imagePicker?.delegate = self
            imagePicker?.sourceType = .photoLibrary
        }
        
        // storing the image file and loading it
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
        // setting the title on the navigation bar
        self.navigationItem.title = "Create A Petition"
    }
    
    // dismissing the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var selectedImageFromPicker:UIImage?
        
            // uploading the image and dismissing the picker
            if let originalImage = info[.originalImage] as? UIImage{
                selectedImageFromPicker = originalImage
           
                petitionImageView.image = selectedImageFromPicker
                
                uploadPetitionImage(originalImage){ url in
                    guard let i = url else {return}
                    self.fileUrl = i.absoluteString
               //     self.imagePicker?.dismiss(animated: true, completion: nil)
                }
            }
        
        
        // dismissing image picker
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func uploadPetitionImage(_ image: UIImage, _ completion: @escaping((_ url:URL?)->())){
        //reference to storage object
        imageName = randomString(20) as String
        let storage = Storage.storage().reference().child("petition media files").child(imageName ?? " ")

        //images must be saved as data objects to convert and compress the image
        guard let image = petitionImageView?.image, let imageData = image.jpegData(compressionQuality: 0.75) else {return}
    
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
    
    // producing a random string
    func randomString(_ length: Int)-> String{
        let letters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    // retrieving the photoURL
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

    // returning number of components in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of rows in pickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 14
    }
    
  
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // adding all the pickerView options
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
    
    // storing the tag from the one that was selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tag = tagOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        // turning all the tags white in the pickerView
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
