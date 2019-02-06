//
//  Petition.swift
//  ReVision
//
//  Created by Eugenia Feng (student LM) on 1/3/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class Petition {
    var title: String?
    var description: String?
    var creator: String?
    var goalSignatures: Int = 0
    var signatures: [String]
    let image = UIImageView()
//    let anonymous: Bool?
//    let dateCreated: Date?
//    let dateFinished: Date?
//    var subtitle: String?
    
    //
    init() {
        title = ""
        description = ""
        creator = ""
        //creator = Auth.auth().currentUser.uid
        goalSignatures = 0
        signatures = []
//        anonymous = false
//        dateCreated = Date()
//        dateFinished = nil
//        subtitle=" "
    }
    
    init(title titleOfPetition: String, description descriptionOfPetition: String, creator creatorOfPetition: String, goalSignatures goalSignaturesOfPetition: Int, signatures currentSignaturesOnPetition: [String]) {
        title = titleOfPetition
//        subtitle = subtitleOfPetition
        description = descriptionOfPetition
        creator = creatorOfPetition
        //creator = Auth.auth().currentUser.uid
        goalSignatures = goalSignaturesOfPetition
        signatures = currentSignaturesOnPetition
//        anonymous = anon
//        dateCreated = Date()
//        dateFinished = nil
        
    }
    
    func sign (userSigningPetition user: String){
        signatures.append(user)
    }
    
    func send (){
        
    }
    //func update
    //func sign
    //func send
    
}
