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

//Creates a set of values that constitues a petition that can be used throughout the app
class Petition {
    
    var title: String?  //The petition's title 
    var description: String?    //the actual petition
    var subtitle: String?   //the subtitle for the petition
    var creator: String?    //the uid of the user who creates the petition
    var author: String?     //the name of the user who creates the petion
    var goalSignatures: Int = 0     //the number of signatures required to send petition
    var signatures: [String]    //everyone who signed the petition (their names not their uid)
    var tag: String?        //petition's grouping
    let image = UIImageView()   //petition's image
    var imageURL: String?       //url for the image
    var ID: String?             //uid
    var active: Bool = false    //if the petition is active or not

    //default
    init() {
        title = ""
        description = ""
        creator = ""
        goalSignatures = 0
        signatures = []

    }
    
    //nondefault
    init(title titleOfPetition: String, description descriptionOfPetition: String, creator creatorOfPetition: String, goalSignatures goalSignaturesOfPetition: Int, signatures currentSignaturesOnPetition: [String]) {
        title = titleOfPetition
        description = descriptionOfPetition
        creator = creatorOfPetition
        goalSignatures = goalSignaturesOfPetition
        signatures = currentSignaturesOnPetition

    }
    //depreceated
    func sign (userSigningPetition user: String){
        signatures.append(user)
    }
    

    
}
