//
//  WriteReviewViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/4/19.
//  Copyright © 2019 housing. All rights reserved.
//

//Imports
import UIKit
import Firebase
import FirebaseAuth
//for star rating i/o functionality, as taken from https://github.com/evgenyneu/Cosmos
import Cosmos

//Global variables
public class storeBool {
    public var anonymousBool = false
    public var edited = false
    public var liveagain = true
    public static let shared = storeBool()
}

class WriteReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //Instatiate varaibles
    @IBOutlet weak var liveAgain: UISwitch!
    @IBOutlet weak var rating: UISlider!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var ratingValue: UILabel!
    @IBOutlet weak var locationTitle: UIImageView!
    @IBOutlet weak var managementTitle: UIImageView!
    @IBOutlet weak var amenitiesTitle: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var locationCosmos: CosmosView!
    @IBOutlet weak var managementCosmos: CosmosView!
    @IBOutlet weak var amenitiesCosmos: CosmosView!
    var info:String = ""
    var Em:String = ""
    
    //Set default ratings for stars
    var locationRating = 5.0
    var managementRating = 5.0
    var amenitiesRating = 5.0
    
    //Changes rating when touched
    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        
        locationCosmos.didFinishTouchingCosmos = {rating in self.locationRating = rating}
        managementCosmos.didFinishTouchingCosmos = {rating in self.managementRating = rating}
        amenitiesCosmos.didFinishTouchingCosmos = {rating in self.amenitiesRating = rating }
        return view
    }()

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeBool.shared.edited = false
        address.text = info + "!"
        //Comment box settings
        comment.delegate = self
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        comment.layer.borderColor = borderColor.cgColor
        comment.layer.borderWidth = 0.5
        comment.layer.cornerRadius = 5.0
        
        view.addSubview(cosmosView)
        
        self.hideKeyboardWhenTap()
        
        //Calls fucntion to see if review has already been written or not
        checkReview()
        
        //Sets placeholder in textbox. Starts as grey if no previous review has been written
        if comment.text == "Living here has been..." as String {
            comment.textColor = UIColor.lightGray
        }
        else {
            comment.textColor = UIColor.black
        }
        
        //Creates short address for display
        var count = 0
        var shortAddress:String = ""
        for str in info.split(separator: " "){
            if (str.last == ",") { break }
            shortAddress.append(contentsOf: " ")
            shortAddress.append(contentsOf: str)
            count += 1 }
        address.text = shortAddress + "!" // label for address
    } //end of viewDidLoad()
    
    //checks to see if a user has already written a review, if yes, will autofill information on the form
    func checkReview(){
        //gets user's email through authentications
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            Em = email!
        } // end if
        //Database reference
        let docRef = db.collection("listings").document(info)
        docRef.getDocument { (document,error) in
            if let document = document, document.exists {
                var emailExists:Bool = false
                let review = document.get("reviews") as! NSDictionary
                
                for (reviewer, reviewMap) in review {
                    let reviewer = reviewer as! String
                    if (reviewer == self.Em) {
                        emailExists = true
                        let alert = UIAlertController(title: "Warning", message: "You have already rated this property before. If you post another review, your previous review will be overwritten.", preferredStyle: .alert)
                        //Loads previous review
                        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: {(action) in
                            let reviewMap = reviewMap as! NSDictionary
                            let getComment = reviewMap.value(forKey: "comments") as? String
                            self.comment.text = getComment ?? "No review in database"
                            let getRating = reviewMap.value(forKey: "rating") as? Float
                            self.rating.value = getRating ?? 5
                            self.ratingValue.text = (String(format: "%.1f", getRating ?? 5))
                            let getLiveagain = reviewMap.value(forKey: "willLiveAgain") as? Bool ?? false
                            self.liveagainOutlet.selectedSegmentIndex = getLiveagain ? 0 : 1
                            let getisAnonymous = reviewMap.value(forKey: "isAnonymous") as? Bool ?? false
                            self.anonymousOutlet.selectedSegmentIndex = getisAnonymous ? 0 : 1
                            let getAmenities = reviewMap.value(forKey: "amenitiesRating") as? Double
                            self.amenitiesCosmos.rating = getAmenities ?? 0
                            self.amenitiesRating = getAmenities ?? 0
                            let getManage = reviewMap.value(forKey: "managementRating") as? Double
                            self.managementCosmos.rating = getManage ?? 0
                            self.managementRating = getManage ?? 0
                            let getLocationrating = reviewMap.value(forKey: "locationRating") as? Double
                            self.locationCosmos.rating = getLocationrating ?? 0
                            self.locationRating = getLocationrating ?? 0
                        }))
                        self.present(alert, animated: true)
                    }
                } // end for loop
            } // end if let
        } // end getDocument
    } //end of checkReview
    
    
    //if rating goes below 2.5, it is assumed that the rater doesn't want to live here anymore 
    //and switches off the will live here again slider
    @IBAction func slideRate(_ sender: UISlider) {
        ratingValue.text = String(format: "%.1f", sender.value)
        //ratingValue.setValue(Float(), forKey: String(format: "%.1f", sender.value))
        if sender.value < 2.5 {
            liveagainOutlet.selectedSegmentIndex = 1
            storeBool.shared.liveagain = false
        }
       else{
            liveagainOutlet.selectedSegmentIndex = 0
            storeBool.shared.liveagain = true
        }
    }
    
    //Allows user to post review anonymously with toggle
    @IBOutlet weak var anonymousOutlet: UISegmentedControl!
    @IBAction func anonymousAction(_ sender: Any) {
        switch anonymousOutlet.selectedSegmentIndex {
        case 0:
            storeBool.shared.anonymousBool = true
        case 1:
            storeBool.shared.anonymousBool = false
        default:
            break
        }
    }
    
    //Allows user to say if that would live there again or not with toggle
    @IBOutlet weak var liveagainOutlet: UISegmentedControl!
    @IBAction func liveagainAction(_ sender: Any) {
        switch liveagainOutlet.selectedSegmentIndex {
        case 0:
            storeBool.shared.liveagain = true
        case 1:
            storeBool.shared.liveagain = false
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Function that clears default text and turns text color black for user to write review
    func textViewDidBeginEditing(_ comment: UITextView) {
        if comment.textColor == UIColor.lightGray {
            comment.text = nil
            comment.textColor = UIColor.black
        }
    }
    
    //Function that fills in default text and changes color if text field is empty
    func textViewDidEndEditing(_ comment: UITextView) {
        if comment.text.isEmpty {
            comment.text = "Living here has been..."
            comment.textColor = UIColor.lightGray
        }
    }


    //when submit is tapped, database will be overwritten in listings collection and Users collections
    @IBAction func submit(_ sender: UIButton) {
        let time = Timestamp(date: Date())
        print(time)
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            Em = email!
        }
     
        let docRef = db.collection("listings").document(info)
        let docUserRef = db.collection("Users").document(Em)

            docRef.getDocument{ (document, error) in
                if let document = document, document.exists {
                    
                    var emailExist:Bool = false
                    let review = document.get("reviews") as! NSDictionary
                    for (reviewer, _) in review {
                        let reviewer = reviewer as! String

                        if (reviewer == self.Em){
                            emailExist = true
                            break //break when reviewer is found
                        }//end if
                    } //end for loop
                    
                    //If comment is empty or the default text, it posts default comment that user didn't want to write review
                    if self.comment.text == "Living here has been..." as String || self.comment.text == "" as String  {
                        self.comment.text = "This user has decided not to write a review"
                    }
                    
                    //Checks if email already existed for that particular listing and sets Bool "isEdited" to false
                    // and writes review to the database
                    if(emailExist == false){
                        let alert = UIAlertController(title: "Success", message: "Your review has successfully been posted!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action -> Void in
                            self.performSegue(withIdentifier: "unwindToDisplay", sender: self)
                        }))
                        
                        self.present(alert, animated: true)              
                        
                        docRef.setData([
                            "reviews" : [
                                "\(self.Em)" : [
                                    "comments" : self.comment.text!,
                                    "isAnonymous" : storeBool.shared.anonymousBool,
                                    "isEdited" : false,
                                    "rating" : self.rating.value,
                                    "willLiveAgain" : storeBool.shared.liveagain,
                                    "timeStamp" : time,
                                    "locationRating" : self.locationRating,
                                    "managementRating" : self.managementRating,
                                    "amenitiesRating" : self.amenitiesRating
                                ]
                            ]
                            ], merge: true)
                        { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                storeBool.shared.edited = false
                            }
                        }
                    }//end if
                    
                    //Checks if email already exists for that particular listing and sets Bool "isEdited" to true
                    // and writes review to the database
                    else if (emailExist == true){
                        storeBool.shared.edited = true
                        let alert = UIAlertController(title: "Success", message: "Your review has successfully been posted!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action -> Void in
                            self.performSegue(withIdentifier: "unwindToDisplay", sender: self)
                        }))
                        
                        self.present(alert, animated: true)
                        

                        //set to a review of a users in the listings collection database
                        docRef.setData([
                            "reviews" : [
                                "\(self.Em)" : [
                                    "comments" : self.comment.text!,
                                    "isAnonymous" : storeBool.shared.anonymousBool,
                                    "isEdited" : true,
                                    "rating" : self.rating.value,
                                    "willLiveAgain" : storeBool.shared.liveagain,
                                    "timeStamp" : time,
                                    "locationRating" : self.locationRating,
                                    "managementRating" : self.managementRating,
                                    "amenitiesRating" : self.amenitiesRating
                                ]
                            ]
                            ], merge: true)
                        { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                                
                            }
                        }
                    } //end elseIf
                    
                    //set values to be sent to Users collection in database for reviewHistory
                    docUserRef.setData([
                        "Review History" : [
                            "\(self.info)" : [
                                "comments" : self.comment.text!,
                                "isAnonymous" : storeBool.shared.anonymousBool,
                                "rating" : self.rating.value,
                                "isEdited" : storeBool.shared.edited,
                                "willLiveAgain" : storeBool.shared.liveagain,
                                "timeStamp" : time,
                                "locationRating" : self.locationRating,
                                "managementRating" : self.managementRating,
                                "amenitiesRating" : self.amenitiesRating
                                
                            ]
                        ]
                        ], merge: true)
                    { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        
        
    } //end of submit()
} //end of class


