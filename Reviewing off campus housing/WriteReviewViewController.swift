//
//  WriteReviewViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/4/19.
//  Copyright © 2019 housing. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import Cosmos


public class storeBool {
    public var anonymousBool = false
    // button thingy needs to default to No on the storyboard.
    public var edited = false
    public var liveagain = true
    public static let shared = storeBool()
}

class WriteReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var address: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        address.text = info + "!"
        comment.delegate = self
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        comment.layer.borderColor = borderColor.cgColor
        comment.layer.borderWidth = 0.5
        comment.layer.cornerRadius = 5.0
        
        view.addSubview(cosmosView)
        
        self.hideKeyboardWhenTap()
        
        comment.text = "Living here has been.."
        comment.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
        checkReview()
    }
    
    func checkReview(){
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            
            let email = user.email
            Em = email!
            
        } // end if
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
                        
                        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: {(action) in
                            //write some code here
                            let reviewMap = reviewMap as! NSDictionary
                            let getComment = reviewMap.value(forKey: "comments") as! String
                            self.comment.text = getComment
                            let rating = reviewMap.value(forKey: "rating") as! Float
                        }))
                        self.present(alert, animated: true)
                    }
                } // end for lop
                
                if (emailExists) {
                    let alert = UIAlertController(title: "Warning", message: "You have already rated this property before. If you post another review, your previous review will be overwritten.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: {(action) in
                        //write some code here
                        //let reviewMap = reviewMap as! NSDictionary
                    }))
                    self.present(alert, animated: true)
                    
                } // end if
            } // end if let
        } // end getDocument
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
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
    
    
    @IBOutlet weak var liveAgain: UISwitch!
    @IBOutlet weak var rating: UISlider!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var ratingValue: UILabel!
    @IBOutlet weak var locationTitle: UIImageView!
    @IBOutlet weak var managementTitle: UIImageView!
    @IBOutlet weak var amenitiesTitle: UIImageView!
    @IBOutlet weak var locationCosmos: CosmosView!
    @IBOutlet weak var managementCosmos: CosmosView!
    @IBOutlet weak var amenitiesCosmos: CosmosView!
    
    var locationRating = 5.0
    var managementRating = 5.0
    var amenitiesRating = 5.0

    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        
        locationCosmos.didFinishTouchingCosmos = {rating in self.locationRating = rating}
        managementCosmos.didFinishTouchingCosmos = {rating in self.managementRating = rating}
        amenitiesCosmos.didFinishTouchingCosmos = {rating in self.amenitiesRating = rating }
        return view
    }()
    
    
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
    
    func textViewDidBeginEditing(_ comment: UITextView) {
        if comment.textColor == UIColor.lightGray {
            comment.text = nil
            comment.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ comment: UITextView) {
        if comment.text.isEmpty {
            comment.text = "Living here has been..."
            comment.textColor = UIColor.lightGray
        }
    }


    @IBAction func submit(_ sender: UIButton) {
        //performSegue(withIdentifier: "writeToHome", sender: self)
        let time = Timestamp(date: Date())
        //let time = Date()
        print(time)
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let email = user.email
            Em = email!
            // ...
            
        }
        
        let docRef = db.collection("listings").document(info)
        let docUserRef = db.collection("Users").document(Em)

            docRef.getDocument{ (document, error) in
                if let document = document, document.exists {
                    
                    var emailExist:Bool = false
                    let review = document.get("reviews") as! NSDictionary
                    for (reviewer, _) in review {
                        let reviewer = reviewer as! String
                        //print(reviewer)
                        //print(self.Em + "---")

                        if (reviewer == self.Em){
                            emailExist = true
                            break
                        }
                    }
                    
                    print (emailExist)
                    
                    if(emailExist == false){
                        
                        let alert = UIAlertController(title: "Success", message: "Your review has successfully been posted!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok!", style: .default, handler: { action -> Void in
                            self.performSegue(withIdentifier: "unwindToDisplay", sender: self)
                        }))
                        
                        self.present(alert, animated: true)
                        //let lR = Int(storeBool.shared.locationRating)
                        print(".....")
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
                    }
                        
                    else if (emailExist == true){
                        let alert = UIAlertController(title: "Success", message: "", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok!", style: .default, handler: { action -> Void in
                            self.performSegue(withIdentifier: "unwindToDisplay", sender: self)
                        }))
                        
                        self.present(alert, animated: true)
                        
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
                                storeBool.shared.edited = true
                            }
                        }
                    }
                    
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
        
        
    }
    
    var info:String = ""
    var Em:String = ""
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


